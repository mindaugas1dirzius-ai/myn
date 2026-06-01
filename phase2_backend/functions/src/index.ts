/**
 * FAZĖ 2 — Server-Authoritative Anti-Cheat backend (16 režimų).
 *
 * startGame:   serveris generuoja 10 klausimų + 6 variantus kiekvienam,
 *              slepia atsakymus, taiko rotaciją (kad neatsibostų).
 * submitScore: serveris tikrina, matuoja laiką, skaičiuoja taškus pagal lygį,
 *              trina žaidimą (replay apsauga), rašo rekordą.
 *
 * Moduliai (mūsų 2 taisyklė):
 *   gameConfig.ts       — 16 režimų nustatymai, taškų lentelė
 *   generateQuestion.ts — klausimų variklis
 *   generateOptions.ts  — 6 atsakymų generatorius (Fisher-Yates)
 */

import { onCall, HttpsError } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";
import * as admin from "firebase-admin";

import {
  parseMode,
  SCORING,
  pointsForAnswer,
  QUESTIONS_PER_GAME,
  MIN_TIME_PER_Q_MS,
  MAX_TIME_PER_Q_MS,
  TIME_TOLERANCE_MS,
} from "./gameConfig";
import { generateQuestion, Question } from "./generateQuestion";
import { generateOptions } from "./generateOptions";

admin.initializeApp();
const db = admin.firestore();

const REGION = "europe-west1";
const ROTATION_KEEP = 30; // kiek paskutinių klausimų atsimename (žr. rotacijos saugiklį)

/** Vartotojo vardo sanitizacija prieš rašant į VIEŠĄ leaderboard. */
function sanitizeUsername(raw: unknown): string {
  if (typeof raw !== "string") return "Žaidėjas";
  const cleaned = raw.replace(/[^\p{L}\p{N} ]/gu, "").trim().slice(0, 16);
  return cleaned.length >= 2 ? cleaned : "Žaidėjas";
}

/** Auto-vardas pirmam kartui: "Player_XXXX" (4 atsitiktiniai skaičiai).
 *  Variantas C: jokios trinties starte, žaidėjas vėliau pats pasikeičia. */
function generateAutoUsername(): string {
  const n = Math.floor(1000 + Math.random() * 9000); // 1000–9999
  return `Player_${n}`;
}

// =================================================================
// 1) startGame — generuoja 10 klausimų + variantus, taiko rotaciją
// =================================================================
export const startGame = onCall(
  { enforceAppCheck: true, minInstances: 0, region: REGION },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Prisijungimas privalomas.");
    }
    const uid = request.auth.uid;

    const parsed = parseMode(request.data?.mode);
    if (!parsed) {
      throw new HttpsError("invalid-argument", "Nežinomas režimas.");
    }
    const { op, level } = parsed;

    // Rotacija: paimam paskutinių klausimų sąrašą iš profilio
    const userSnap = await db.collection("users").doc(uid).get();
    const recent: string[] = userSnap.exists
      ? (userSnap.data()?.recentQuestions ?? [])
      : [];
    const seen = new Set<string>(recent);

    // Generuojam 10 UNIKALIŲ klausimų (vengiam pasikartojimo šioje sesijoje
    // ir paskutinių parodytų). Saugiklis nuo begalinio ciklo: maks. bandymų.
    const questions: Question[] = [];
    const usedThisGame = new Set<string>();
    let guard = 0;
    while (questions.length < QUESTIONS_PER_GAME && guard < 500) {
      guard++;
      const q = generateQuestion(op, level);
      if (usedThisGame.has(q.action)) continue;
      if (seen.has(q.action) && guard < 200) continue; // po 200 bandymų atsileidžiam
      usedThisGame.add(q.action);
      questions.push(q);
    }

    // Kiekvienam klausimui — 6 variantai (1 teisingas + 5 panašūs klaidingi)
    const options = questions.map((q) =>
      generateOptions(q.a, q.b, q.answer, q.op)
    );

    const gameRef = db.collection("active_games").doc();
    await gameRef.set({
      uid,
      mode: request.data.mode,
      level,
      answers: questions.map((q) => q.answer), // slapta
      actions: questions.map((q) => q.action),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Klientui grąžinam ir `answer` (variantas C, DIZAINAS.md):
    // saugu, nes taškus serveris skaičiuoja iš BENDRO LAIKO — atsakymo
    // žinojimas sukčiui nieko neduoda, o UX gauna momentinį žalia/raudona.
    return {
      gameId: gameRef.id,
      level,
      maxTimeMs: MAX_TIME_PER_Q_MS, // V2: 30s riba (žiedo pilnėjimui)
      questions: questions.map((q, i) => ({
        action: q.action,
        options: options[i],
        answer: q.answer,
      })),
    };
  }
);

// =================================================================
// 2) submitScore — tikrina, skaičiuoja taškus, rašo rekordą
// =================================================================
export const submitScore = onCall(
  { enforceAppCheck: true, minInstances: 0, region: REGION },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Prisijungimas privalomas.");
    }
    const uid = request.auth.uid;

    const { gameId, clientAnswers, clientTimesMs } = request.data ?? {};
    // Švelnus modelis: žaidėjas visada atsako į 10 (klaida = 0 už langelį).
    // clientTimesMs — per-langelį laikai (V2 taškų formulei).
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
    const userRef = db.collection("users").doc(uid);

    return await db.runTransaction(async (transaction) => {
      // ---- VISI SKAITYMAI PIRMA (read-before-write) ----
      const gameDoc = await transaction.get(gameRef);
      if (!gameDoc.exists) {
        throw new HttpsError("not-found", "Žaidimas nerastas.");
      }
      const game = gameDoc.data()!;
      if (game.uid !== uid) {
        throw new HttpsError("permission-denied", "Neleistinas veiksmas.");
      }

      const userDoc = await transaction.get(userRef);

      const leaderboardRef = db
        .collection("leaderboard")
        .doc(`${uid}_${game.mode}`);
      const leaderboardDoc = await transaction.get(leaderboardRef);
      // ---- skaitymai baigti ----

      // Serveris PATS matuoja bendrą laiką (null-safe).
      const ts = game.createdAt as admin.firestore.Timestamp | null;
      const createdAtMs = ts ? ts.toDate().getTime() : Date.now();
      const totalDurationMs = Date.now() - createdAtMs;

      // Botų filtras: viso žaidimo laikas negali būti neįmanomai trumpas.
      const minPossible = QUESTIONS_PER_GAME * MIN_TIME_PER_Q_MS;
      if (totalDurationMs < minPossible) {
        logger.warn("Anti-cheat: per greitas žaidimas", { uid, totalDurationMs });
        throw new HttpsError("invalid-argument", "Neteisingi rezultatai.");
      }

      // ANTI-CHEAT (V2): per-langelį laikai naudojami taškams, BET jų SUMA
      // negali viršyti serverio matuoto bendro laiko (+ paklaida). Kitaip
      // sukčius galėtų atsiųsti melagingai mažus laikus dideliems taškams.
      const times = (clientTimesMs as unknown[]).map((t) =>
        typeof t === "number" && t >= 0 ? t : MAX_TIME_PER_Q_MS
      );
      const sumClientTimes = times.reduce((s, t) => s + t, 0);
      if (sumClientTimes > totalDurationMs + TIME_TOLERANCE_MS) {
        logger.warn("Anti-cheat: laikų neatitikimas", {
          uid, sumClientTimes, totalDurationMs,
        });
        throw new HttpsError("invalid-argument", "Neteisingi rezultatai.");
      }

      // Taškai (V2): kiekvienam teisingam — pagal to langelio laiką
      // (greitas → ~maxPoints, lėtas iki 30s → minimumas). Klaida → 0.
      const serverAnswers = game.answers as number[];
      const level = game.level as keyof typeof SCORING;
      const { maxPoints } = SCORING[level];
      let correct = 0;
      // Coins (DIZAINAS.md): 1 už teisingą + 1 bonusas jei atsakyta < 3s.
      // Skaičiuojama SERVERYJE (sauga). Kaupiama users/{uid}.coins.
      let score = 0;
      let coinsEarned = 0;
      for (let i = 0; i < serverAnswers.length; i++) {
        if (clientAnswers[i] === serverAnswers[i]) {
          correct++;
          score += pointsForAnswer(maxPoints, times[i]);
          coinsEarned += 1;
          if (times[i] < 3000) coinsEarned += 1; // greičio bonusas
        }
      }

      // ---- RAŠYMAI ----
      transaction.delete(gameRef); // replay apsauga + švari DB

      // Auto-vardas pirmam kartui (variantas C): jei dar nėra — sukuriam Player_XXXX.
      const existingName = userDoc.data()?.username as string | undefined;
      const username = existingName
        ? sanitizeUsername(existingName)
        : generateAutoUsername();
      const hasCustomName = existingName !== undefined;

      // Coins balansas (kaupiamas serveryje).
      const prevCoins = (userDoc.data()?.coins as number) ?? 0;
      const newCoins = prevCoins + coinsEarned;

      // Rotacijos atnaujinimas + username + coins (vienas rašymas).
      const prevRecent: string[] = userDoc.data()?.recentQuestions ?? [];
      const newRecent = [...(game.actions as string[]), ...prevRecent].slice(0, ROTATION_KEEP);
      transaction.set(
        userRef,
        { recentQuestions: newRecent, username, coins: newCoins },
        { merge: true }
      );

      // Rekordas tik jei naujas geriausias.
      const prevBest = leaderboardDoc.exists
        ? (leaderboardDoc.data()!.score as number)
        : -1;
      const isNewRecord = score > prevBest;
      if (isNewRecord) {
        transaction.set(leaderboardRef, {
          uid,
          username,
          mode: game.mode,
          score,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      return {
        success: true,
        finalScore: score,
        correct,
        isNewRecord,
        coinsEarned,
        totalCoins: newCoins,
        // Raginimas įvesti vardą (variantas C): rekordas + dar auto-vardas.
        promptName: isNewRecord && !hasCustomName,
      };
    });
  }
);

// =================================================================
// 3) getMyRank — žaidėjo pozicija konkrečiame režime (Etapas 1)
// =================================================================
export const getMyRank = onCall(
  { enforceAppCheck: true, minInstances: 0, region: REGION },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Prisijungimas privalomas.");
    }
    const uid = request.auth.uid;
    const mode = request.data?.mode;
    if (typeof mode !== "string") {
      throw new HttpsError("invalid-argument", "Nežinomas režimas.");
    }

    const col = db.collection("leaderboard");

    // Mano geriausias šiame režime.
    const myDoc = await col.doc(`${uid}_${mode}`).get();
    if (!myDoc.exists) {
      return { hasScore: false };
    }
    const myScore = myDoc.data()!.score as number;

    // Pozicija = kiek žaidėjų turi DAUGIAU taškų + 1 (count query — pigu).
    const higher = await col
      .where("mode", "==", mode)
      .where("score", ">", myScore)
      .count()
      .get();
    const total = await col.where("mode", "==", mode).count().get();

    return {
      hasScore: true,
      score: myScore,
      rank: higher.data().count + 1,
      total: total.data().count,
    };
  }
);
