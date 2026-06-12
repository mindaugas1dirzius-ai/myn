/**
 * meltFunctions — „Raidžių tirpimas" SERVERIO funkcijos (IZOLIUOTAS modulis).
 *
 * Režimas: žaidėjas pasirenka laiko limitą ir raidžių tirpimo intervalą;
 * raidės atsiveria savaime, taškai tirpsta su laiku ir atvertomis raidėmis.
 * Jokio banko ir mokamų pagalbų — formulė žr. meltTypes.ts.
 *
 * SAUGUMAS (taisyklė #1):
 *  - būsena users/{uid}.mysteryMelt — rašo TIK serveris (rules jau draudžia klientui);
 *  - startedAt imamas SERVERIO laiku; kliento laikrodis tik kosmetikai;
 *  - pilnas tekstas siunčiamas TIK laimėjus/pralaimėjus;
 *  - nustatymai tikrinami pagal whitelist (isValidMeltConfig);
 *  - atsiskaitymas vienoje transakcijoje (no replay);
 *  - eskaluojantis spėjimų cooldown (meltCooldownMs).
 *
 * Klasikinis režimas (mysteryFunctions) NEPALIESTAS — abu veikia greta.
 */

import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

import { Lang } from "./triviaTypes";
import {
  MysteryText,
  SOLVED_CAP,
  buildMask,
  buildPool,
  letterIndices,
  normalizeGuess,
  shuffle,
} from "./mysteryTypes";
import { findMystery, pickMeltMystery } from "./mysteryContent";
import {
  MeltState,
  MELT_FREE_KEEP_HIDDEN,
  MELT_FREEZE_MS,
  MELT_FREEZE_GRACE_MS,
  MELT_MAX_FREEZES,
  deriveMelt,
  isValidMeltConfig,
  meltCooldownMs,
  meltFreezeMsFor,
  meltLenBoundsFor,
  meltPMax,
  meltPoints,
  meltWrongPenalty,
} from "./meltTypes";

const REGION = "europe-west1";

const SUPPORTED_LANGS: Lang[] = [
  "en", "lt", "es", "it", "pl", "de", "fr", "uk", "pt", "ar",
];
function parseLang(x: unknown): Lang {
  return typeof x === "string" && (SUPPORTED_LANGS as string[]).includes(x)
    ? (x as Lang)
    : "en";
}

/** Kliento payload'as: kaukė + skaitliukai (be pilno teksto!). */
function meltPayload(
  state: MeltState,
  content: MysteryText,
  category: string,
  nowMs: number,
  keys: number
) {
  const total = letterIndices(content.text).length;
  const d = deriveMelt(state, total, nowMs);
  // Spėjimo lango būsena klientui: kiek ms dar užšaldyta ir kiek langų liko.
  const windowMs = state.freezeMs ?? MELT_FREEZE_MS;
  const frozenLeftMs =
    state.lockedAt != null
      ? Math.max(0, windowMs - (nowMs - state.lockedAt))
      : 0;
  return {
    mysteryId: state.id,
    hint: content.hint,
    category,
    level: state.level,
    mask: buildMask(content.text, d.revealedSet),
    pool: buildPool(content.text, d.revealedSet),
    totalLetters: total,
    autoRevealed: d.autoPenaltyCount,
    freeRevealed: Math.min(state.freeCount, total),
    limitSec: state.limitSec,
    intervalSec: state.intervalSec,
    startedAt: state.startedAt,
    serverNow: nowMs,
    remainingMs: d.remainingMs,
    nextRevealInMs: d.nextRevealInMs,
    pMax: meltPMax(state.level, state.intervalSec),
    potentialPointsNow: d.potentialPointsNow,
    keys,
    freezeUsed: state.lockedAt != null,
    frozenLeftMs,
    lockedAt: state.lockedAt ?? null,
    lockMsUsed: state.lockMsUsed ?? 0,
    freezesLeft: Math.max(0, MELT_MAX_FREEZES - (state.freezeCount ?? 0)),
    wrongPenalty: meltWrongPenalty(meltPMax(state.level, state.intervalSec)),
    freezeMs: windowMs,
    // LAIPSNIŠKOS UŽUOMINOS (savininko prašymu — „užuominos aiškesnės"):
    // įpusėjus laikui (40 %) atsiveria hint1, link pabaigos (70 %) — hint2.
    // Nemokama ir deterministiška (iš elapsed) — kuo ilgiau lauki, tuo
    // aiškiau, bet taškai jau aptirpę. Jokios naujos būsenos.
    hint1: progressFrac(state, d.remainingMs) >= 0.4
      ? content.hint1 ?? null
      : null,
    hint2: progressFrac(state, d.remainingMs) >= 0.7
      ? content.hint2 ?? null
      : null,
  };
}

/** Kokia laiko dalis jau praėjo (0..1) — laipsniškoms užuominoms. */
function progressFrac(state: MeltState, remainingMs: number): number {
  const limitMs = state.limitSec * 1000;
  return limitMs > 0 ? (limitMs - remainingMs) / limitMs : 0;
}

/** Uždaro aktyvų spėjimo langą: jo laikas perkeliamas į lockMsUsed. */
function foldLock(state: MeltState, nowMs: number): MeltState {
  if (state.lockedAt == null) return state;
  const windowMs = state.freezeMs ?? MELT_FREEZE_MS;
  const used = Math.min(Math.max(0, nowMs - state.lockedAt), windowMs);
  return {
    ...state,
    lockMsUsed: (state.lockMsUsed ?? 0) + used,
    lockedAt: null,
  };
}

/** Pralaimėjimo užskaita: ištrina būseną; grąžina atsakymą parodymui. */
function settleLossWrites(
  tx: FirebaseFirestore.Transaction,
  userRef: FirebaseFirestore.DocumentReference
) {
  tx.set(
    userRef,
    { mysteryMelt: admin.firestore.FieldValue.delete() },
    { merge: true }
  );
}

// =================================================================
// 1) startMelt — pradeda (arba grąžina aktyvią) tirpimo partiją
// =================================================================
export const startMelt = onCall(
  { enforceAppCheck: true, minInstances: 0, region: REGION },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Prisijungimas privalomas.");
    }
    const uid = request.auth.uid;
    const lang = parseLang(request.data?.lang);
    const limitSec = request.data?.limitSec;
    const intervalSec = request.data?.intervalSec;
    const level = request.data?.level;

    const db = admin.firestore();
    const userRef = db.collection("users").doc(uid);

    return await db.runTransaction(async (tx) => {
      const snap = await tx.get(userRef);
      const data = snap.data() ?? {};
      const now = Date.now();
      const solvedIds: string[] = (data.mysterySolved as string[]) ?? [];
      const existing = data.mysteryMelt as MeltState | undefined;

      // Aktyvi nepasibaigusi partija — grąžinam ją (resume; nustatymai ignoruojami).
      if (existing) {
        const item = findMystery(existing.id);
        const content = item?.texts[existing.lang];
        if (item && content) {
          const total = letterIndices(content.text).length;
          const d = deriveMelt(existing, total, now);
          if (!d.expired) {
            return {
              resumed: true,
              expiredLoss: null,
              ...meltPayload(existing, content, item.category, now,
                (data.mysteryKeys as number) ?? 0),
            };
          }
          // Pasibaigusi — užskaitom pralaimėjimą ir startuojam naują žemiau.
          settleLossWrites(tx, userRef);
        }
      }

      // Naujos partijos nustatymai privalomi ir tikrinami pagal whitelist.
      if (!isValidMeltConfig(limitSec, intervalSec, level)) {
        throw new HttpsError("invalid-argument", "Netinkami režimo nustatymai.");
      }

      // Ilgio/žodžių ribos pagal lygį: lengvame tik trumpi, atspėjami atsakymai.
      const bounds = meltLenBoundsFor(level as number);
      const picked = pickMeltMystery(
        lang,
        solvedIds,
        bounds.min,
        bounds.max,
        level as number,
        bounds.maxWords
      );
      if (!picked) {
        throw new HttpsError("failed-precondition", "Paslapčių dar nėra.");
      }
      const totalLetters = letterIndices(picked.content.text).length;

      // Nemokamos raidės pritaikomos iškart (lieka bent MELT_FREE_KEEP_HIDDEN paslėptų).
      const pending = (data.pendingMysteryLetters as number) ?? 0;
      const maxFree = Math.max(0, totalLetters - MELT_FREE_KEEP_HIDDEN);
      const freeCount = Math.min(pending, maxFree);
      const leftoverPending = pending - freeCount;

      const state: MeltState = {
        id: picked.item.id,
        lang: picked.lang,
        level: picked.item.level ?? 1,
        revealOrder: shuffle(letterIndices(picked.content.text)),
        freeCount,
        startedAt: now,
        limitSec: limitSec as number,
        intervalSec: intervalSec as number,
        lastGuessTs: 0,
        wrongGuesses: 0,
        lockMsUsed: 0,
        freezeCount: 0,
        // Lango trukmė pagal atsakymo žodžių kiekį (30 s / 1 min / 1,5 min).
        freezeMs: meltFreezeMsFor(
          picked.content.text.trim().split(/\s+/).length
        ),
      };

      tx.set(
        userRef,
        { mysteryMelt: state, pendingMysteryLetters: leftoverPending },
        { merge: true }
      );

      const expiredLoss = existing ? { answer: null } : null; // atsakymo senai partijai nerodome čia
      return {
        resumed: false,
        expiredLoss,
        pendingApplied: freeCount,
        pendingLeft: leftoverPending,
        ...meltPayload(state, picked.content, picked.item.category, now,
          (data.mysteryKeys as number) ?? 0),
      };
    });
  }
);

// =================================================================
// 2) syncMelt — lentos atnaujinimas (rašo tik pasibaigus laikui)
// =================================================================
export const syncMelt = onCall(
  { enforceAppCheck: true, minInstances: 0, region: REGION },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Prisijungimas privalomas.");
    }
    const uid = request.auth.uid;
    const db = admin.firestore();
    const userRef = db.collection("users").doc(uid);

    return await db.runTransaction(async (tx) => {
      const snap = await tx.get(userRef);
      const data = snap.data() ?? {};
      const state = data.mysteryMelt as MeltState | undefined;
      if (!state) {
        throw new HttpsError("failed-precondition", "Nėra aktyvios partijos.");
      }
      const item = findMystery(state.id);
      const content = item?.texts[state.lang];
      if (!item || !content) {
        settleLossWrites(tx, userRef);
        throw new HttpsError("failed-precondition", "Partija nebegalioja.");
      }

      const now = Date.now();
      const total = letterIndices(content.text).length;
      const d = deriveMelt(state, total, now);

      if (d.expired) {
        settleLossWrites(tx, userRef);
        return { expired: true, answer: content.text };
      }
      return {
        expired: false,
        ...meltPayload(state, content, item.category, now,
          (data.mysteryKeys as number) ?? 0),
      };
    });
  }
);

// =================================================================
// 3) guessMelt — spėjimas; laimėjus taškai į mysteryKeys
// =================================================================
export const guessMelt = onCall(
  { enforceAppCheck: true, minInstances: 0, region: REGION },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Prisijungimas privalomas.");
    }
    const uid = request.auth.uid;
    const guessRaw = request.data?.guess;
    if (typeof guessRaw !== "string" || guessRaw.trim().length === 0) {
      throw new HttpsError("invalid-argument", "Tuščias spėjimas.");
    }

    const db = admin.firestore();
    const userRef = db.collection("users").doc(uid);

    return await db.runTransaction(async (tx) => {
      const snap = await tx.get(userRef);
      const data = snap.data() ?? {};
      const state = data.mysteryMelt as MeltState | undefined;
      if (!state) {
        throw new HttpsError("failed-precondition", "Nėra aktyvios partijos.");
      }
      const item = findMystery(state.id);
      const content = item?.texts[state.lang];
      if (!item || !content) {
        settleLossWrites(tx, userRef);
        throw new HttpsError("failed-precondition", "Partija nebegalioja.");
      }

      const now = Date.now();
      const total = letterIndices(content.text).length;
      const d = deriveMelt(state, total, now);

      if (d.expired) {
        settleLossWrites(tx, userRef);
        return { correct: false, expired: true, answer: content.text };
      }

      // Anti-spam: eskaluojanti pauzė tarp spėjimų.
      const cooldown = meltCooldownMs(state.wrongGuesses);
      if (now - (state.lastGuessTs ?? 0) < cooldown) {
        throw new HttpsError("resource-exhausted", "Palauk akimirką ir bandyk vėl.");
      }

      const correct = normalizeGuess(guessRaw) === normalizeGuess(content.text);
      if (correct) {
        // Praėjęs laikas BE užšaldytų tarpų (kaip deriveMelt) — spėjimo
        // langas taškų netirpdo, kitaip SPĖTI baustų pats save.
        const limitMs = state.limitSec * 1000;
        const elapsedMs = limitMs - d.remainingMs;
        const pMax = meltPMax(state.level, state.intervalSec);
        const awarded = meltPoints(pMax, elapsedMs, limitMs, d.autoPenaltyCount, total);
        const newKeys = ((data.mysteryKeys as number) ?? 0) + awarded;

        const solved: string[] = (data.mysterySolved as string[]) ?? [];
        const solvedSet = new Set(solved);
        solvedSet.add(state.id);
        let newSolved = [...solvedSet];
        if (newSolved.length > SOLVED_CAP) {
          newSolved = newSolved.slice(newSolved.length - SOLVED_CAP);
        }

        tx.set(
          userRef,
          {
            mysteryKeys: newKeys,
            mysterySolved: newSolved,
            mysteryMelt: admin.firestore.FieldValue.delete(),
          },
          { merge: true }
        );
        return {
          correct: true,
          expired: false,
          answer: content.text,
          awarded,
          totalKeys: newKeys,
          // Sąžiningas laimėjimo paaiškinimas klientui.
          breakdown: {
            pMax,
            elapsedMs,
            limitMs,
            autoPenaltyCount: d.autoPenaltyCount,
            totalLetters: total,
          },
        };
      }

      // KLAIDA: minus raktų bauda (balansas niekada nekrenta žemiau 0),
      // spėjimo langas uždaromas (laikas vėl tiksi), cooldown auga.
      const pMaxW = meltPMax(state.level, state.intervalSec);
      const penalty = meltWrongPenalty(pMaxW);
      const keysNow = (data.mysteryKeys as number) ?? 0;
      const keysAfter = Math.max(0, keysNow - penalty);
      const folded = foldLock(state, now);
      tx.set(
        userRef,
        {
          mysteryKeys: keysAfter,
          mysteryMelt: {
            ...folded,
            lastGuessTs: now,
            wrongGuesses: (state.wrongGuesses ?? 0) + 1,
          },
        },
        { merge: true }
      );
      return {
        correct: false,
        expired: false,
        nextGuessInMs: meltCooldownMs((state.wrongGuesses ?? 0) + 1),
        penalty,
        penaltyApplied: keysNow - keysAfter,
        totalKeys: keysAfter,
      };
    });
  }
);

// =================================================================
// 3b) freezeMelt — SPĖJIMO LANGAS: paspaudus SPĖTI laikas sustoja 30 s
//     atsakymui suvesti. Langą uždaro spėjimas arba jis baigiasi pats.
//     Saugiklis MELT_MAX_FREEZES — negalima „pauzuoti amžinai" be spėjimo;
//     išnaudojus langus SPĖTI veikia toliau, tik laikas tiksi (frozen:false).
// =================================================================
export const freezeMelt = onCall(
  { enforceAppCheck: true, minInstances: 0, region: REGION },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Prisijungimas privalomas.");
    }
    const uid = request.auth.uid;
    const db = admin.firestore();
    const userRef = db.collection("users").doc(uid);

    return await db.runTransaction(async (tx) => {
      const snap = await tx.get(userRef);
      const data = snap.data() ?? {};
      const state = data.mysteryMelt as MeltState | undefined;
      if (!state) {
        throw new HttpsError("failed-precondition", "Nėra aktyvios partijos.");
      }
      const item = findMystery(state.id);
      const content = item?.texts[state.lang];
      if (!item || !content) {
        settleLossWrites(tx, userRef);
        throw new HttpsError("failed-precondition", "Partija nebegalioja.");
      }
      const now = Date.now();
      const total = letterIndices(content.text).length;
      const d = deriveMelt(state, total, now);
      if (d.expired) {
        settleLossWrites(tx, userRef);
        return { expired: true, answer: content.text };
      }
      const keys = (data.mysteryKeys as number) ?? 0;

      // Langas jau aktyvus — grąžinam esamą būseną (pakartotinis paspaudimas
      // nekainuoja naujo lango ir nemeta klaidos).
      const windowMs = state.freezeMs ?? MELT_FREEZE_MS;
      const activeLeft =
        state.lockedAt != null ? windowMs - (now - state.lockedAt) : 0;
      if (activeLeft > 0) {
        return {
          expired: false,
          frozen: true,
          ...meltPayload(state, content, item.category, now, keys),
        };
      }

      // Langų limitas išnaudotas — laikas tiksi, bet žaisti galima toliau.
      const used = state.freezeCount ?? 0;
      if (used >= MELT_MAX_FREEZES) {
        const folded = foldLock(state, now);
        if (folded !== state) {
          tx.set(userRef, { mysteryMelt: folded }, { merge: true });
        }
        return {
          expired: false,
          frozen: false,
          ...meltPayload(folded, content, item.category, now, keys),
        };
      }

      // SĄŽININGAS STARTAS: raidė, iškritusi kol SPĖTI užklausa keliavo
      // (per paskutines GRACE ms), atšaukiama — langas pradedamas PRIEŠ jos
      // ribą. Klientas siunčia seenAuto (kiek raidžių JAU matė ekrane):
      // matytų neatšaukiam. Cap'ai: daugiausia 1 riba (intervalas ≥ 5 s),
      // ne anksčiau partijos starto / ankstesnio lango pabaigos / spėjimo.
      const seenAutoRaw = request.data?.seenAuto;
      const seenAuto =
        typeof seenAutoRaw === "number" && Number.isFinite(seenAutoRaw)
          ? Math.max(0, Math.floor(seenAutoRaw))
          : d.autoCount; // senas klientas nepraneša — nieko neatšaukiam
      const intervalMs = state.intervalSec * 1000;
      const elapsedNow = state.limitSec * 1000 - d.remainingMs;
      const rawK = Math.floor(elapsedNow / intervalMs);
      const sinceBoundary = elapsedNow - rawK * intervalMs;
      let lockStart = now;
      if (
        rawK > 0 &&
        rawK === d.autoCount && // lenta nepilna (skaičiai nesusikerta)
        sinceBoundary <= MELT_FREEZE_GRACE_MS &&
        seenAuto < d.autoCount
      ) {
        const floorTs = Math.max(
          state.startedAt,
          state.lastGuessTs ?? 0,
          state.lockedAt != null ? state.lockedAt + windowMs : 0
        );
        lockStart = Math.max(now - sinceBoundary - 1, floorTs);
      }

      // Atidaram naują langą: pasibaigusio lango laikas — į lockMsUsed.
      const newState: MeltState = {
        ...foldLock(state, now),
        lockedAt: lockStart,
        freezeCount: used + 1,
      };
      tx.set(userRef, { mysteryMelt: newState }, { merge: true });
      return {
        expired: false,
        frozen: true,
        ...meltPayload(newState, content, item.category, now, keys),
      };
    });
  }
);

// =================================================================
// 4) abandonMelt — pasiduoti (pralaimėjimas be taškų, nauja per startMelt)
// =================================================================
export const abandonMelt = onCall(
  { enforceAppCheck: true, minInstances: 0, region: REGION },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Prisijungimas privalomas.");
    }
    const uid = request.auth.uid;
    const db = admin.firestore();
    const userRef = db.collection("users").doc(uid);

    return await db.runTransaction(async (tx) => {
      const snap = await tx.get(userRef);
      const data = snap.data() ?? {};
      const state = data.mysteryMelt as MeltState | undefined;
      if (!state) {
        return { abandoned: false };
      }
      const item = findMystery(state.id);
      const content = item?.texts[state.lang];
      settleLossWrites(tx, userRef);
      return { abandoned: true, answer: content?.text ?? null };
    });
  }
);
