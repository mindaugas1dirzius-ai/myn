/**
 * FAZĖ 2 — Server-Authoritative Anti-Cheat backend.
 *
 * Dvi Cloud Functions (2nd Gen, onCall, App Check enforced):
 *   - startGame:   serveris sugeneruoja klausimus, slepia atsakymus.
 *   - submitScore: serveris viską patikrina, skaičiuoja taškus, rašo į leaderboard.
 *
 * Diegimas:
 *   cd functions && npm install
 *   firebase deploy --only functions,firestore:rules
 */

import { onCall, HttpsError } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

// --------- Konfigūracija ----------
const QUESTIONS_PER_GAME = 10;
const MAX_TIME_PER_Q_MS = 5000;   // virš šito už atsakymą taškų nebeduodam
const MIN_TIME_PER_Q_MS = 250;    // greičiau žmogui fiziškai neįmanoma -> botas
const BASE_POINTS = 50;           // bazė už teisingą atsakymą
const TIME_TOLERANCE_MS = 1500;   // tinklo/latency paklaida lyginant laikus

// Leistini režimai ir jų generavimo parametrai
type Mode = "sudetis_lengvas" | "sudetis_sunkus" | "daugyba_lengvas" | "daugyba_sunkus";
const MODES: Record<Mode, { op: "+" | "*"; max: number }> = {
  sudetis_lengvas: { op: "+", max: 10 },
  sudetis_sunkus: { op: "+", max: 50 },
  daugyba_lengvas: { op: "*", max: 9 },
  daugyba_sunkus: { op: "*", max: 12 },
};

interface Question {
  action: string; // pvz. "3+5"
  answer: number; // 8  (NIEKADA nesiunčiama klientui)
}

function randInt(max: number): number {
  return Math.floor(Math.random() * max) + 1;
}

/** Sugeneruoja klausimų rinkinį pagal režimą (su teisingais atsakymais). */
function generateQuestions(mode: Mode): Question[] {
  const { op, max } = MODES[mode];
  const questions: Question[] = [];
  for (let i = 0; i < QUESTIONS_PER_GAME; i++) {
    const a = randInt(max);
    const b = randInt(max);
    const answer = op === "+" ? a + b : a * b;
    questions.push({ action: `${a}${op}${b}`, answer });
  }
  return questions;
}

/** Vartotojo vardo sanitizacija prieš rašant į VIEŠĄ leaderboard. */
function sanitizeUsername(raw: unknown): string {
  if (typeof raw !== "string") return "Žaidėjas";
  // tik raidės/skaičiai/tarpas, maks. 16 simbolių
  const cleaned = raw.replace(/[^\p{L}\p{N} ]/gu, "").trim().slice(0, 16);
  return cleaned.length >= 2 ? cleaned : "Žaidėjas";
}

// =================================================================
// 1) startGame — pradeda žaidimą, generuoja klausimus serveryje
// =================================================================
export const startGame = onCall(
  // minInstances: 0 = nemokama, bet "cold start" (3-5s) pirmą kartą.
  // Jei žaidimo pradžia stringa esant srautui -> perjunk į 1.
  { enforceAppCheck: true, minInstances: 0, region: "europe-west1" },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Prisijungimas privalomas.");
    }
    const uid = request.auth.uid;

    const mode = request.data?.mode as Mode;
    if (!mode || !(mode in MODES)) {
      throw new HttpsError("invalid-argument", "Nežinomas režimas.");
    }

    const questions = generateQuestions(mode);

    const gameRef = db.collection("active_games").doc();
    await gameRef.set({
      uid,
      mode,
      questions, // su atsakymais — bet ši kolekcija klientui UŽDARA
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      used: false,
    });

    // Klientui grąžinam TIK tekstus, BE atsakymų:
    return {
      gameId: gameRef.id,
      questions: questions.map((q) => q.action),
    };
  }
);

// =================================================================
// 2) submitScore — patikrina, skaičiuoja taškus, rašo rekordą
// =================================================================
export const submitScore = onCall(
  { enforceAppCheck: true, minInstances: 0, region: "europe-west1" },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Prisijungimas privalomas.");
    }
    const uid = request.auth.uid;

    const { gameId, clientAnswers, clientTimesMs } = request.data ?? {};

    // --- Įeinančių duomenų validacija ---
    if (
      typeof gameId !== "string" ||
      !Array.isArray(clientAnswers) ||
      !Array.isArray(clientTimesMs) ||
      clientAnswers.length !== QUESTIONS_PER_GAME ||
      clientTimesMs.length !== QUESTIONS_PER_GAME
    ) {
      throw new HttpsError("invalid-argument", "Netinkami duomenys.");
    }

    const gameRef = db.collection("active_games").doc(gameId);

    return await db.runTransaction(async (transaction) => {
      // ---- VISI SKAITYMAI PIRMA (Firestore reikalauja read-before-write!) ----
      const gameDoc = await transaction.get(gameRef);
      if (!gameDoc.exists) {
        throw new HttpsError("not-found", "Žaidimas nerastas.");
      }
      const game = gameDoc.data()!;
      if (game.used || game.uid !== uid) {
        throw new HttpsError("permission-denied", "Neleistinas veiksmas.");
      }

      const userRef = db.collection("users").doc(uid);
      const userDoc = await transaction.get(userRef);

      const leaderboardRef = db
        .collection("leaderboard")
        .doc(`${uid}_${game.mode}`);
      const leaderboardDoc = await transaction.get(leaderboardRef);
      // ---- skaitymai baigti, toliau galima rašyti ----

      // Serveris PATS matuoja bendrą laiką (telefonu nepasitikim).
      // Apsauga nuo null (jei serverTimestamp dar neišspręstas -> fail'ina saugiai):
      const timestamp = game.createdAt as admin.firestore.Timestamp | null;
      const createdAtMs = timestamp ? timestamp.toDate().getTime() : Date.now();
      const totalDurationMs = Date.now() - createdAtMs;

      // Botų filtras (priežastį tik į logus, klientui bendra klaida):
      const minPossible = QUESTIONS_PER_GAME * MIN_TIME_PER_Q_MS;
      if (totalDurationMs < minPossible) {
        logger.warn("Anti-cheat: per greitas žaidimas", {
          uid,
          totalDurationMs,
        });
        throw new HttpsError("invalid-argument", "Neteisingi rezultatai.");
      }

      // Kliento laikų suma negali viršyti serverio matuoto laiko:
      const sumClientTimes = (clientTimesMs as number[]).reduce(
        (s, t) => s + (typeof t === "number" && t > 0 ? t : 0),
        0
      );
      if (sumClientTimes > totalDurationMs + TIME_TOLERANCE_MS) {
        logger.warn("Anti-cheat: laikų neatitikimas", { uid });
        throw new HttpsError("invalid-argument", "Neteisingi rezultatai.");
      }

      // --- Taškų skaičiavimas SERVERYJE pagal serverio klausimus ---
      const serverQuestions = game.questions as Question[];
      let score = 0;
      for (let i = 0; i < serverQuestions.length; i++) {
        const correct = clientAnswers[i] === serverQuestions[i].answer;
        if (!correct) continue; // klaida = 0 taškų

        // greitis: per-langelį laikas apribotas leistinomis ribomis
        let t = clientTimesMs[i];
        if (typeof t !== "number" || t < MIN_TIME_PER_Q_MS) t = MIN_TIME_PER_Q_MS;
        if (t > MAX_TIME_PER_Q_MS) t = MAX_TIME_PER_Q_MS;
        const speedBonus = Math.floor((MAX_TIME_PER_Q_MS - t) / 10);
        score += BASE_POINTS + speedBonus;
      }

      // --- RAŠYMAI ---
      // 1. Ištriname žaidimą iškart: apsauga nuo Replay Attack (exists=false)
      //    + DB nesikaupia šiukšlės nuo užbaigtų žaidimų.
      transaction.delete(gameRef);

      // 2. Įrašom rekordą TIK jei naujas geriausias:
      const username = sanitizeUsername(userDoc.data()?.username);
      const prevBest = leaderboardDoc.exists
        ? (leaderboardDoc.data()!.score as number)
        : -1;

      if (score > prevBest) {
        transaction.set(leaderboardRef, {
          uid,
          username,
          mode: game.mode,
          score,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      return { success: true, finalScore: score, isNewRecord: score > prevBest };
    });
  }
);
