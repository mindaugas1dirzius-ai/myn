/**
 * detectiveFunctions — 🕵️ DETEKTYVO serverio funkcijos (IZOLIUOTAS modulis).
 *
 * Mechanika: slaptas žodis + perkamų TAIP/NE klausimų turgus (3 kainų lygiai)
 * + 3 gyvybės. Laiko spaudimo nėra. Žodis PERDEGA po vieno žaidimo.
 * Nemokamai — DETECTIVE_FREE_PER_DAY bylų per parą; premium — be ribos.
 *
 * SAUGUMAS (taisyklė #1):
 *  - žodis, atsakymai, bankas, gyvybės — TIK serveryje (users/{uid}.detective);
 *  - klausimo atsakymas grąžinamas TIK nupirkus (transakcija, bankas ≥ grindų);
 *  - spėjimas tikrinamas serveryje (normalizeGuess); perdegusios bylos
 *    nekartojamos (detectiveSolved) — replay neįmanomas;
 *  - enforceAppCheck: true visur. Esama ekonomika NELIESTA.
 */

import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

import { Lang } from "./triviaTypes";
import { buildMask, buildPool, letterIndices, normalizeGuess } from "./mysteryTypes";
import {
  DetectiveState,
  DetectiveText,
  DETECTIVE_FLOOR,
  DETECTIVE_FREE_PER_DAY,
  DETECTIVE_LIVES,
  DETECTIVE_SOLVED_CAP,
  canBuyClue,
  detectiveBank,
  detectivePricesFor,
} from "./detectiveTypes";
import { findDetectiveCase, pickDetectiveCase } from "./detectiveContent";

const REGION = "europe-west1";

const SUPPORTED_LANGS: Lang[] = [
  "en", "lt", "es", "it", "pl", "de", "fr", "uk", "pt", "ar",
];
function parseLang(x: unknown): Lang {
  return typeof x === "string" && (SUPPORTED_LANGS as string[]).includes(x)
    ? (x as Lang)
    : "en";
}

/** UTC data YYYY-MM-DD (dienos limitui — nepriklauso nuo laiko juostos). */
function todayUtc(): string {
  return new Date().toISOString().slice(0, 10);
}

/** Ar premium galioja (premiumUntil ms > dabar). */
function isPremium(data: FirebaseFirestore.DocumentData): boolean {
  const until = data.premiumUntil as number | undefined;
  return typeof until === "number" && until > Date.now();
}

/** Kiek nemokamų bylų liko šiandien (-1 = be ribos, premium). */
function freeLeftFor(data: FirebaseFirestore.DocumentData): number {
  if (isPremium(data)) return -1;
  const date = (data.detectiveDate as string) ?? "";
  const count = (data.detectiveCount as number) ?? 0;
  return date === todayUtc()
    ? Math.max(0, DETECTIVE_FREE_PER_DAY - count)
    : DETECTIVE_FREE_PER_DAY;
}

/** Kliento payload'as: turgus BE neapmokėtų atsakymų, žodžio — tik kaukė. */
function detectivePayload(
  state: DetectiveState,
  text: DetectiveText,
  keys: number,
  freeLeft: number,
  resumed: boolean
) {
  const empty = new Set<number>();
  const boughtSet = new Set(state.bought);
  return {
    caseId: state.caseId,
    level: state.level,
    categoryLabel: text.categoryLabel,
    mask: buildMask(text.word, empty),
    pool: buildPool(text.word, empty),
    totalLetters: letterIndices(text.word).length,
    bank: detectiveBank(state.level, state.spent),
    floor: DETECTIVE_FLOOR,
    lives: state.lives,
    maxLives: DETECTIVE_LIVES,
    prices: detectivePricesFor(state.level),
    // Klausimų TEKSTAI matomi visi (turgaus esmė) — atsakymas tik nupirktų.
    questions: text.questions.map((q, i) => ({
      i,
      t: q.t,
      q: q.q,
      ...(boughtSet.has(i) ? { a: q.a } : {}),
    })),
    keys,
    freeLeft,
    resumed,
  };
}

/** Bylos perdegimas: įrašoma į detectiveSolved (cap), būsena trinama. */
function burnWrites(
  tx: FirebaseFirestore.Transaction,
  userRef: FirebaseFirestore.DocumentReference,
  data: FirebaseFirestore.DocumentData,
  caseId: string,
  extra: Record<string, unknown> = {}
) {
  const solved: string[] = (data.detectiveSolved as string[]) ?? [];
  const set = new Set(solved);
  set.add(caseId);
  let newSolved = [...set];
  if (newSolved.length > DETECTIVE_SOLVED_CAP) {
    newSolved = newSolved.slice(newSolved.length - DETECTIVE_SOLVED_CAP);
  }
  tx.set(
    userRef,
    {
      detectiveSolved: newSolved,
      detective: admin.firestore.FieldValue.delete(),
      ...extra,
    },
    { merge: true }
  );
}

// =================================================================
// 1) startDetective — pradeda (arba grąžina aktyvią) bylą
// =================================================================
export const startDetective = onCall(
  { enforceAppCheck: true, minInstances: 0, region: REGION },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Prisijungimas privalomas.");
    }
    const uid = request.auth.uid;
    const lang = parseLang(request.data?.lang);
    const levelRaw = request.data?.level;
    const level =
      typeof levelRaw === "number" && [1, 2, 3, 4].includes(levelRaw)
        ? levelRaw
        : 1;

    const db = admin.firestore();
    const userRef = db.collection("users").doc(uid);

    return await db.runTransaction(async (tx) => {
      const snap = await tx.get(userRef);
      const data = snap.data() ?? {};
      const keys = (data.mysteryKeys as number) ?? 0;

      // Aktyvi byla — grąžinam ją (resume; naujo limito NEnaudoja).
      const existing = data.detective as DetectiveState | undefined;
      if (existing) {
        const item = findDetectiveCase(existing.caseId);
        const text = item?.texts[existing.lang];
        if (item && text) {
          return {
            ...detectivePayload(existing, text, keys, freeLeftFor(data), true),
          };
        }
        // Byla nebegalioja (turinys pasikeitė) — išvalom ir startuojam naują.
        tx.set(
          userRef,
          { detective: admin.firestore.FieldValue.delete() },
          { merge: true }
        );
      }

      // Dienos limitas (premium — be ribos). Skaitliukas naudojamas TIK
      // pradedant NAUJĄ bylą.
      const today = todayUtc();
      const premium = isPremium(data);
      const sameDay = (data.detectiveDate as string) === today;
      const count = sameDay ? ((data.detectiveCount as number) ?? 0) : 0;
      if (!premium && count >= DETECTIVE_FREE_PER_DAY) {
        throw new HttpsError(
          "resource-exhausted",
          "Šiandienos nemokamos bylos baigtos — grįžk rytoj!"
        );
      }

      const solvedIds: string[] = (data.detectiveSolved as string[]) ?? [];
      const picked = pickDetectiveCase(lang, level, solvedIds);
      if (!picked) {
        throw new HttpsError(
          "failed-precondition",
          "Šio lygio bylos kol kas išspręstos — netrukus bus naujų!"
        );
      }
      const text = picked.item.texts[picked.lang]!;

      const state: DetectiveState = {
        caseId: picked.item.id,
        lang: picked.lang,
        level,
        spent: 0,
        lives: DETECTIVE_LIVES,
        bought: [],
        startedAt: Date.now(),
      };

      tx.set(
        userRef,
        {
          detective: state,
          detectiveDate: today,
          detectiveCount: count + 1,
        },
        { merge: true }
      );

      const freeLeft = premium
        ? -1
        : Math.max(0, DETECTIVE_FREE_PER_DAY - (count + 1));
      return { ...detectivePayload(state, text, keys, freeLeft, false) };
    });
  }
);

// =================================================================
// 2) buyDetectiveClue — perka klausimo atsakymą iš bylos banko
// =================================================================
export const buyDetectiveClue = onCall(
  { enforceAppCheck: true, minInstances: 0, region: REGION },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Prisijungimas privalomas.");
    }
    const uid = request.auth.uid;
    const iRaw = request.data?.i;
    if (typeof iRaw !== "number" || !Number.isInteger(iRaw) || iRaw < 0) {
      throw new HttpsError("invalid-argument", "Netinkamas klausimas.");
    }

    const db = admin.firestore();
    const userRef = db.collection("users").doc(uid);

    return await db.runTransaction(async (tx) => {
      const snap = await tx.get(userRef);
      const data = snap.data() ?? {};
      const state = data.detective as DetectiveState | undefined;
      if (!state) {
        throw new HttpsError("failed-precondition", "Nėra aktyvios bylos.");
      }
      const item = findDetectiveCase(state.caseId);
      const text = item?.texts[state.lang];
      if (!item || !text || iRaw >= text.questions.length) {
        throw new HttpsError("invalid-argument", "Netinkamas klausimas.");
      }
      if (state.bought.includes(iRaw)) {
        // Jau nupirktas — grąžinam atsakymą be mokesčio (idempotentiška).
        return {
          i: iRaw,
          a: text.questions[iRaw].a,
          bank: detectiveBank(state.level, state.spent),
          lives: state.lives,
        };
      }
      const price = detectivePricesFor(state.level)[text.questions[iRaw].t];
      if (!canBuyClue(state.level, state.spent, price)) {
        throw new HttpsError(
          "failed-precondition",
          "Banke per mažai — spėk iš to, ką žinai!"
        );
      }
      const newState: DetectiveState = {
        ...state,
        spent: state.spent + price,
        bought: [...state.bought, iRaw],
      };
      tx.set(userRef, { detective: newState }, { merge: true });
      return {
        i: iRaw,
        a: text.questions[iRaw].a,
        bank: detectiveBank(newState.level, newState.spent),
        lives: newState.lives,
      };
    });
  }
);

// =================================================================
// 3) guessDetective — spėjimas; atspėjus bankas → mysteryKeys
// =================================================================
export const guessDetective = onCall(
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
      const state = data.detective as DetectiveState | undefined;
      if (!state) {
        throw new HttpsError("failed-precondition", "Nėra aktyvios bylos.");
      }
      const item = findDetectiveCase(state.caseId);
      const text = item?.texts[state.lang];
      if (!item || !text) {
        burnWrites(tx, userRef, data, state.caseId);
        throw new HttpsError("failed-precondition", "Byla nebegalioja.");
      }

      const correct =
        normalizeGuess(guessRaw) === normalizeGuess(text.word);
      if (correct) {
        const awarded = detectiveBank(state.level, state.spent);
        const totalKeys = ((data.mysteryKeys as number) ?? 0) + awarded;
        burnWrites(tx, userRef, data, state.caseId, {
          mysteryKeys: totalKeys,
        });
        return {
          correct: true,
          dead: false,
          word: text.word,
          awarded,
          totalKeys,
        };
      }

      const newLives = state.lives - 1;
      if (newLives <= 0) {
        // Gyvybės baigėsi: byla žlugo, žodis parodomas ir VIS TIEK perdega.
        burnWrites(tx, userRef, data, state.caseId);
        return { correct: false, dead: true, word: text.word, lives: 0 };
      }
      tx.set(
        userRef,
        { detective: { ...state, lives: newLives } },
        { merge: true }
      );
      return { correct: false, dead: false, lives: newLives };
    });
  }
);

// =================================================================
// 4) abandonDetective — pasiduoti (žodis parodomas, byla perdega)
// =================================================================
export const abandonDetective = onCall(
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
      const state = data.detective as DetectiveState | undefined;
      if (!state) {
        return { abandoned: false };
      }
      const item = findDetectiveCase(state.caseId);
      const text = item?.texts[state.lang];
      burnWrites(tx, userRef, data, state.caseId);
      return { abandoned: true, word: text?.word ?? null };
    });
  }
);
