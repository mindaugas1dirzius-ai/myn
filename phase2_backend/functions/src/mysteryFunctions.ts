/**
 * mysteryFunctions — „Atspėk paslaptį / Cyber-Ratelis" SERVERIO smegenys.
 *
 * SAUGUMAS (taisyklė #1): pilnas tekstas, atvertų raidžių indeksai, panaudota
 * pagalba (`spent`) ir banko skaičiavimas gyvena TIK serveryje
 * (users/{uid}.mystery). Klientui siunčiama tik kaukė + pool + skaitliukai.
 * Pilnas atsakymas grąžinamas TIK kai paslaptis išspręsta arba pralaimėta.
 *
 * EKONOMIKA (B būdas / banko modelis):
 *  - kiekviena partija turi banką = bankoMax(level) − spent (≥ GRINDŲ 50);
 *  - MOKAMA pagalba (užuomina #1/#2, pirkta raidė, +spėjimas) didina `spent`,
 *    t.y. tirpdo banką — bet TIK jei bankas nenukristų žemiau grindų;
 *  - atspėjus į žaidėjo RAKTŲ balansą (mysteryKeys) įrašomas dabartinis bankas;
 *  - suklydus raktai/bankas NEmažinami, tik dingsta spėjimas (širdelė);
 *  - NEMOKAMOS raidės iš kitų žaidimų (pendingMysteryLetters) banko NEmažina.
 *
 * Anti-cheat: visos kainos/efektai skaičiuojami serveryje; spėjimui — pauzė;
 * visos funkcijos enforceAppCheck: true (kaip visur).
 */

import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

import { Lang } from "./triviaTypes";
import { TESTING_UNLOCK_ALL } from "./gameConfig";
import {
  MysteryItem,
  MysteryText,
  GUESS_COOLDOWN_MS,
  SOLVED_CAP,
  POWERUP_HINT_COST,
  POWERUP_REVEAL_COST,
  POWERUP_GUESS_COST,
  attemptsLeftFor,
  bankMaxFor,
  bankFor,
  canAfford,
  MYSTERY_FLOOR,
  buildMask,
  buildPool,
  letterIndices,
  normalizeGuess,
  shuffle,
} from "./mysteryTypes";
import { pickMystery, findMystery } from "./mysteryContent";

const REGION = "europe-west1";

const SUPPORTED_LANGS: Lang[] = [
  "en", "lt", "es", "it", "pl", "de", "fr", "uk", "pt", "ar",
];
function parseLang(x: unknown): Lang {
  return typeof x === "string" && (SUPPORTED_LANGS as string[]).includes(x)
    ? (x as Lang)
    : "en";
}

/** Serveryje saugoma vienos žaidėjo paslapties būsena. */
interface MysteryState {
  id: string;
  lang: Lang;
  level: number; // lygis (banko dydžiui)
  revealed: number[]; // atvertų raidžių simbolių indeksai
  spent: number; // RAKTAI, išleisti pagalbai ŠIAI partijai (banko tirpimas)
  hint1?: boolean; // ar nupirkta papildoma užuomina #1
  hint2?: boolean; // ar nupirkta papildoma užuomina #2
  lastGuessTs?: number;
  wrong?: number; // kiek kartų suklysta (limitas MAX_GUESSES + bonusGuesses)
  bonusGuesses?: number; // papildomi spėjimai, nupirkti „+1 spėjimas"
}

/** Šviežia būsena naujai paslapčiai (visi skaitliukai nuliniai). */
function freshState(id: string, lang: Lang, level: number): MysteryState {
  return {
    id,
    lang,
    level,
    revealed: [],
    spent: 0,
    hint1: false,
    hint2: false,
    lastGuessTs: 0,
    wrong: 0,
    bonusGuesses: 0,
  };
}

/**
 * Suderina IŠSAUGOTOS paslapties kalbą su žaidėjo PASIRINKTA kalba (tas pats
 * vienetas, kita kalba), IŠLAIKYDAMA tiek pat atvertų raidžių ir VISĄ partijos
 * būseną (spent, užuominos, spėjimai). Jei dar neišversta — paliekam kaip yra.
 */
function reconcileLang(
  state: MysteryState,
  item: MysteryItem,
  lang: Lang
): { state: MysteryState; content: MysteryText; changed: boolean } {
  const current = item.texts[state.lang]!; // else-šakoje garantuotai egzistuoja
  if (state.lang === lang) return { state, content: current, changed: false };

  const target = item.texts[lang];
  if (!target) return { state, content: current, changed: false };

  // Persijungiam: išlaikom atvertų raidžių SKAIČIŲ, bet naujose pozicijose.
  const revealCount = state.revealed.length;
  const newLetters = letterIndices(target.text);
  const newRevealed = shuffle(newLetters)
    .slice(0, Math.min(revealCount, newLetters.length))
    .sort((a, b) => a - b);
  const newState: MysteryState = {
    ...state,
    lang,
    revealed: newRevealed,
  };
  return { state: newState, content: target, changed: true };
}

/** Kliento payload'as: kaukė + pool + bankas + užuominos + skaitliukai. */
function statePayload(
  content: MysteryText,
  category: string,
  level: number,
  revealed: Set<number>,
  spent: number,
  hint1Unlocked: boolean,
  hint2Unlocked: boolean,
  wrong = 0,
  bonusGuesses = 0,
  keys = 0
) {
  const total = letterIndices(content.text).length;
  return {
    hint: content.hint, // nemokama, visada matoma (klausimas/užuomina)
    category,
    level,
    mask: buildMask(content.text, revealed),
    pool: buildPool(content.text, revealed),
    totalLetters: total,
    revealedLetters: revealed.size,
    bankMax: bankMaxFor(level),
    potentialWin: bankFor(level, spent), // dabartinis bankas = laimėjimas DABAR
    spent,
    floor: MYSTERY_FLOOR,
    // Papildomos užuominos: ar egzistuoja turinys + ar atrakinta + tekstas
    // (tekstą siunčiam TIK kai atrakinta — kitaip neatskleistume veltui).
    hasHint1: !!content.hint1,
    hasHint2: !!content.hint2,
    hint1Unlocked,
    hint2Unlocked,
    hint1Text: hint1Unlocked ? content.hint1 ?? "" : null,
    hint2Text: hint2Unlocked ? content.hint2 ?? "" : null,
    // Kainos (klientui rodyti ir blokuoti; serveris vis tiek tikrina).
    costHint: POWERUP_HINT_COST,
    costReveal: POWERUP_REVEAL_COST,
    costGuess: POWERUP_GUESS_COST,
    attemptsLeft: attemptsLeftFor(wrong, bonusGuesses),
    keys, // bendras raktų (🔑) balansas — rodom viršuje
  };
}

// =================================================================
// 1) startMystery — užkrauna (ar sukuria) žaidėjo aktyvią paslaptį
// =================================================================
export const startMystery = onCall(
  { enforceAppCheck: true, minInstances: 0, region: REGION },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Prisijungimas privalomas.");
    }
    const uid = request.auth.uid;
    const lang = parseLang(request.data?.lang);

    const db = admin.firestore();
    const userRef = db.collection("users").doc(uid);

    return await db.runTransaction(async (tx) => {
      const snap = await tx.get(userRef);
      const data = snap.data() ?? {};
      const solvedIds: string[] = TESTING_UNLOCK_ALL
        ? []
        : ((data.mysterySolved as string[]) ?? []);
      let state = data.mystery as MysteryState | undefined;

      let item = state ? findMystery(state.id) : undefined;
      let content = item && state ? item.texts[state.lang] : undefined;

      if (!state || !item || !content) {
        const picked = pickMystery(lang, solvedIds);
        if (!picked) {
          throw new HttpsError("failed-precondition", "Paslapčių dar nėra.");
        }
        state = freshState(picked.item.id, picked.lang, picked.item.level);
        item = picked.item;
        content = picked.content;
        tx.set(userRef, { mystery: state }, { merge: true });
      } else {
        const rec = reconcileLang(state, item, lang);
        if (rec.changed) {
          state = rec.state;
          content = rec.content;
          tx.set(userRef, { mystery: state }, { merge: true });
        }
      }

      const level = state.level ?? item.level ?? 1;
      const revealed = new Set<number>(state.revealed);
      return {
        mysteryId: state.id,
        pendingLetters: (data.pendingMysteryLetters as number) ?? 0,
        ...statePayload(
          content,
          item.category,
          level,
          revealed,
          state.spent ?? 0,
          state.hint1 ?? false,
          state.hint2 ?? false,
          state.wrong ?? 0,
          state.bonusGuesses ?? 0,
          (data.mysteryKeys as number) ?? 0
        ),
      };
    });
  }
);

// =================================================================
// 2) revealLetters — atveria raides iš pendingMysteryLetters (po žaidimo).
//    SVARBU: šios NEMOKAMOS raidės banko NEMAŽINA (`spent` nekeičiamas).
// =================================================================
export const revealLetters = onCall(
  { enforceAppCheck: true, minInstances: 0, region: REGION },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Prisijungimas privalomas.");
    }
    const uid = request.auth.uid;
    const lang = parseLang(request.data?.lang);

    const db = admin.firestore();
    const userRef = db.collection("users").doc(uid);

    return await db.runTransaction(async (tx) => {
      const snap = await tx.get(userRef);
      const data = snap.data() ?? {};
      const pending = (data.pendingMysteryLetters as number) ?? 0;
      const solvedIds: string[] = TESTING_UNLOCK_ALL
        ? []
        : ((data.mysterySolved as string[]) ?? []);
      let state = data.mystery as MysteryState | undefined;
      let item = state ? findMystery(state.id) : undefined;
      let content = item && state ? item.texts[state.lang] : undefined;

      if (!state || !item || !content) {
        const picked = pickMystery(lang, solvedIds);
        if (!picked) {
          throw new HttpsError("failed-precondition", "Paslapčių dar nėra.");
        }
        state = freshState(picked.item.id, picked.lang, picked.item.level);
        item = picked.item;
        content = picked.content;
      } else {
        const rec = reconcileLang(state, item, lang);
        state = rec.state;
        content = rec.content;
      }

      const allLetters = letterIndices(content.text);
      const revealed = new Set<number>(state.revealed);
      const hidden = allLetters.filter((i) => !revealed.has(i));

      const toReveal = Math.min(pending, hidden.length);
      const chosen = shuffle(hidden).slice(0, toReveal);
      for (const i of chosen) revealed.add(i);

      const leftover = pending - toReveal;
      const newState: MysteryState = {
        ...state,
        level: state.level ?? item.level ?? 1,
        revealed: [...revealed].sort((a, b) => a - b),
      };
      tx.set(
        userRef,
        { mystery: newState, pendingMysteryLetters: leftover },
        { merge: true }
      );

      return {
        mysteryId: state.id,
        revealedNow: chosen.sort((a, b) => a - b),
        pendingLetters: leftover,
        ...statePayload(
          content,
          item.category,
          newState.level,
          revealed,
          newState.spent ?? 0,
          newState.hint1 ?? false,
          newState.hint2 ?? false,
          newState.wrong ?? 0,
          newState.bonusGuesses ?? 0,
          (data.mysteryKeys as number) ?? 0
        ),
      };
    });
  }
);

// =================================================================
// 3) guessMystery — tikrina spėjimą; atspėjus įrašo banką į raktų balansą
// =================================================================
export const guessMystery = onCall(
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
      const state = data.mystery as MysteryState | undefined;
      if (!state) {
        throw new HttpsError("failed-precondition", "Nėra aktyvios paslapties.");
      }
      const item = findMystery(state.id);
      const content = item?.texts[state.lang];
      if (!item || !content) {
        throw new HttpsError("failed-precondition", "Paslaptis nebegalioja.");
      }

      // Anti-spam: pauzė tarp spėjimų.
      const now = Date.now();
      const last = state.lastGuessTs ?? 0;
      if (now - last < GUESS_COOLDOWN_MS) {
        throw new HttpsError("resource-exhausted", "Palauk sekundę ir bandyk vėl.");
      }

      const level = state.level ?? item.level ?? 1;
      const spent = state.spent ?? 0;
      const keys = (data.mysteryKeys as number) ?? 0;
      const bonus = state.bonusGuesses ?? 0;
      const correct =
        normalizeGuess(guessRaw) === normalizeGuess(content.text);

      if (correct) {
        const awarded = bankFor(level, spent); // dabartinis bankas (≥ GRINDŲ)
        const newKeys = keys + awarded;
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
            mystery: admin.firestore.FieldValue.delete(),
          },
          { merge: true }
        );
        return {
          correct: true,
          answer: content.text,
          awarded, // laimėti raktai = bankas
          totalKeys: newKeys,
        };
      }

      // Klaida: banko/raktų NEmažinam — tik dingsta spėjimas.
      const wrong = (state.wrong ?? 0) + 1;
      const attemptsLeft = attemptsLeftFor(wrong, bonus);

      if (attemptsLeft <= 0) {
        // Bandymai išseko — paslaptis pralaimėta: atskleidžiam atsakymą ir
        // PARENKAM NAUJĄ paslaptį. Raktų balansas nepasikeičia (laimėjimo nėra).
        const solvedIds: string[] = TESTING_UNLOCK_ALL
        ? []
        : ((data.mysterySolved as string[]) ?? []);
        const picked =
          pickMystery(state.lang, [...solvedIds, state.id]) ??
          pickMystery(state.lang, solvedIds);
        const writes: Record<string, unknown> = {};
        if (picked) {
          writes.mystery = freshState(
            picked.item.id,
            picked.lang,
            picked.item.level
          );
        } else {
          writes.mystery = admin.firestore.FieldValue.delete();
        }
        tx.set(userRef, writes, { merge: true });
        return {
          correct: false,
          totalKeys: keys, // nepasikeitė
          attemptsLeft: 0,
          exhausted: true,
          answer: content.text,
        };
      }

      // Dar yra bandymų: NEatskleidžiam, didinam suklydimų skaitiklį.
      tx.set(
        userRef,
        { mystery: { ...state, lastGuessTs: now, wrong } },
        { merge: true }
      );
      return {
        correct: false,
        totalKeys: keys, // nepasikeitė
        attemptsLeft,
        exhausted: false,
      };
    });
  }
);

// =================================================================
// 3b) mysteryPowerup — galios priemonė; kaina tirpdo PARTIJOS BANKĄ (spent)
//     action: "hint1" | "hint2" | "revealLetter" | "extraGuess"
//
// SAUGUMAS: kainos/efektai SERVERYJE; bendro raktų balanso NELIEČIAM (keičiam tik
// `spent`); pirkti leidžiam TIK jei bankas nenukristų žemiau grindų.
// =================================================================
type PowerupAction = "hint1" | "hint2" | "revealLetter" | "extraGuess";

export const mysteryPowerup = onCall(
  { enforceAppCheck: true, minInstances: 0, region: REGION },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Prisijungimas privalomas.");
    }
    const uid = request.auth.uid;
    const action = request.data?.action as PowerupAction;
    const VALID: PowerupAction[] = ["hint1", "hint2", "revealLetter", "extraGuess"];
    if (!VALID.includes(action)) {
      throw new HttpsError("invalid-argument", "Nežinoma galios priemonė.");
    }

    const db = admin.firestore();
    const userRef = db.collection("users").doc(uid);

    return await db.runTransaction(async (tx) => {
      const snap = await tx.get(userRef);
      const data = snap.data() ?? {};
      const state = data.mystery as MysteryState | undefined;
      if (!state) {
        throw new HttpsError("failed-precondition", "Nėra aktyvios paslapties.");
      }
      const item = findMystery(state.id);
      const content = item?.texts[state.lang];
      if (!item || !content) {
        throw new HttpsError("failed-precondition", "Paslaptis nebegalioja.");
      }

      const level = state.level ?? item.level ?? 1;
      let spent = state.spent ?? 0;
      let bonus = state.bonusGuesses ?? 0;
      let hint1 = state.hint1 ?? false;
      let hint2 = state.hint2 ?? false;
      const revealed = new Set<number>(state.revealed);
      const revealedNow: number[] = [];

      // 1) Veiksmui specifinės sąlygos + kaina.
      let cost: number;
      let revealChoice = -1;
      if (action === "hint1") {
        if (!content.hint1) {
          throw new HttpsError("failed-precondition", "Nėra papildomos užuominos.");
        }
        if (hint1) {
          throw new HttpsError("failed-precondition", "Užuomina jau atverta.");
        }
        cost = POWERUP_HINT_COST;
      } else if (action === "hint2") {
        if (!content.hint2) {
          throw new HttpsError("failed-precondition", "Nėra papildomos užuominos.");
        }
        if (hint2) {
          throw new HttpsError("failed-precondition", "Užuomina jau atverta.");
        }
        cost = POWERUP_HINT_COST;
      } else if (action === "revealLetter") {
        const hidden = letterIndices(content.text).filter((i) => !revealed.has(i));
        if (hidden.length === 0) {
          throw new HttpsError("failed-precondition", "Visos raidės jau atvertos.");
        }
        revealChoice = shuffle(hidden)[0];
        cost = POWERUP_REVEAL_COST;
      } else {
        cost = POWERUP_GUESS_COST;
      }

      // 2) Bankas negali nukristi žemiau grindų.
      if (!canAfford(level, spent, cost)) {
        throw new HttpsError(
          "failed-precondition",
          "Per mažai banke (žemiausia riba 50 🔑)."
        );
      }

      // 3) Pritaikom efektą.
      if (action === "hint1") hint1 = true;
      else if (action === "hint2") hint2 = true;
      else if (action === "revealLetter") {
        revealed.add(revealChoice);
        revealedNow.push(revealChoice);
      } else bonus += 1;

      spent += cost;
      const newState: MysteryState = {
        ...state,
        level,
        revealed: [...revealed].sort((a, b) => a - b),
        spent,
        hint1,
        hint2,
        bonusGuesses: bonus,
      };
      // Bendro raktų balanso NEKEIČIAM — tik partijos būseną.
      tx.set(userRef, { mystery: newState }, { merge: true });

      return {
        mysteryId: state.id,
        revealedNow,
        pendingLetters: (data.pendingMysteryLetters as number) ?? 0,
        ...statePayload(
          content,
          item.category,
          level,
          revealed,
          spent,
          hint1,
          hint2,
          state.wrong ?? 0,
          bonus,
          (data.mysteryKeys as number) ?? 0
        ),
      };
    });
  }
);

// =================================================================
// 5) getMysteryStatus — LENGVAS skaitymas meniu ženkliukui + profiliui
// =================================================================
export const getMysteryStatus = onCall(
  { enforceAppCheck: true, minInstances: 0, region: REGION },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Prisijungimas privalomas.");
    }
    const uid = request.auth.uid;
    const db = admin.firestore();
    const snap = await db.collection("users").doc(uid).get();
    const data = snap.data() ?? {};
    const solved: string[] = (data.mysterySolved as string[]) ?? [];
    return {
      pendingLetters: (data.pendingMysteryLetters as number) ?? 0,
      solvedCount: solved.length,
    };
  }
);

// =================================================================
// 4) resetMystery — atsisakom dabartinės paslapties, gaunam naują (nuo nulio)
// =================================================================
export const resetMystery = onCall(
  { enforceAppCheck: true, minInstances: 0, region: REGION },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Prisijungimas privalomas.");
    }
    const uid = request.auth.uid;
    const lang = parseLang(request.data?.lang);

    const db = admin.firestore();
    const userRef = db.collection("users").doc(uid);

    return await db.runTransaction(async (tx) => {
      const snap = await tx.get(userRef);
      const data = snap.data() ?? {};
      const solvedIds: string[] = TESTING_UNLOCK_ALL
        ? []
        : ((data.mysterySolved as string[]) ?? []);
      const current = data.mystery as MysteryState | undefined;

      const exclude = current ? [...solvedIds, current.id] : solvedIds;
      const picked = pickMystery(lang, exclude) ?? pickMystery(lang, solvedIds);
      if (!picked) {
        throw new HttpsError("failed-precondition", "Paslapčių dar nėra.");
      }
      const newState = freshState(picked.item.id, picked.lang, picked.item.level);
      tx.set(userRef, { mystery: newState }, { merge: true });

      return {
        mysteryId: newState.id,
        pendingLetters: (data.pendingMysteryLetters as number) ?? 0,
        ...statePayload(
          picked.content,
          picked.item.category,
          newState.level,
          new Set<number>(),
          0,
          false,
          false,
          0,
          0,
          (data.mysteryKeys as number) ?? 0
        ),
      };
    });
  }
);
