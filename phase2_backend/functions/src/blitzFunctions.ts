/**
 * blitzFunctions — ⚡ TAIP/NE BLITZ (IZOLIUOTAS modulis).
 *
 * MECHANIKA: 30 s raundas, teiginiai krenta vienas po kito, žaidėjas spaudžia
 * TAIP arba NE. Teiginys = „patikrinimo šablonas" (be linksniavimo rizikos):
 * rodom klausimą PAŽODŽIUI + kandidatą — TAIP, jei kandidatas yra teisingas
 * atsakymas, NE — jei distraktorius. Veikia 100 % fondo visomis kalbomis.
 *
 * SAUGUMAS (taisyklė #1):
 *  - enforceAppCheck: true (kaip visur);
 *  - vertinimas TIK iš serverio isTrue[] (active_games doc), klientu nepasitikim;
 *  - laiko vartai: serverio matuota trukmė ≥ atsakymų × 250 ms (botai) ir
 *    ≤ 30 s + malonė (pavėluoti submit'ai atmetami);
 *  - isTrue klientui siunčiamas SĄMONINGAI (variantas C, kaip 6 variantų
 *    trivijoje siunčiamas answer): bazinė tikimybė 50 %, tad žinojimas duoda
 *    tik 2× pranašumą — mažiau nei esamas modelis; UX gauna momentinę reakciją;
 *  - doc trinamas po submit (no replay).
 *
 * Esama ekonomika/funkcijos NELIESTOS — tai tik naujos eilutės.
 */

import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";

import {
  BLITZ_BATCH,
  BLITZ_BASE_POINTS,
  BLITZ_CAND_MAX_CHARS,
  BLITZ_DURATION_MS,
  BLITZ_DURATIONS_SEC,
  BLITZ_FINAL_X2_LAST_MS,
  BLITZ_MIN_ANSWER_MS,
  BLITZ_MIN_GAP_MS,
  BLITZ_Q_MAX_CHARS,
  BLITZ_SUBMIT_GRACE_MS,
  BLITZ_WRONG_PENALTY,
  ROTATION_KEEP_CAT,
  TIME_TOLERANCE_MS,
} from "./gameConfig";
import { NATURE_QUESTIONS } from "./natureContent";
import { TRIVIA_REGISTRY } from "./triviaRegistry";
import { pickContent, mergeRecent } from "./triviaEngine";
import { shuffle } from "./generateOptions";
import { Lang, TriviaQuestion } from "./triviaTypes";
import { lettersFor } from "./mysteryTypes";

const REGION = "europe-west1";

const SUPPORTED_LANGS: Lang[] = [
  "en", "lt", "es", "it", "pl", "de", "fr", "uk", "pt", "ar",
];
function parseLang(x: unknown): Lang {
  return typeof x === "string" && (SUPPORTED_LANGS as string[]).includes(x)
    ? (x as Lang)
    : "en";
}

/** Rotacijos raktas — blitz turi SAVO istoriją (visų temų mišinys). */
const BLITZ_ROT_KEY = "cat_blitz";

/**
 * Ar klausimas tinka blitz'ui ŠIA kalba: lengvas/vidutinis (skubantis skaitymas),
 * trumpas klausimas, trumpas teisingas atsakymas IR bent vienas trumpas
 * distraktorius (kad klausimas galėtų būti ir TAIP, ir NE teiginiu).
 */
function fitsBlitz(q: TriviaQuestion, lang: Lang): boolean {
  if (q.level !== "lengvas" && q.level !== "vidutinis") return false;
  const c = pickContent(q, lang);
  return (
    c.question.length <= BLITZ_Q_MAX_CHARS &&
    c.correct.length <= BLITZ_CAND_MAX_CHARS &&
    c.distractors.some(
      (d) => d.length <= BLITZ_CAND_MAX_CHARS && d !== c.correct
    )
  );
}

/** Paima iki `need` klausimų: pirma nematyti (sumaišyti), tada seniausiai matyti. */
function takeSome(
  pool: TriviaQuestion[],
  recentIds: string[],
  need: number
): TriviaQuestion[] {
  const recencyRank = new Map<string, number>();
  recentIds.forEach((id, i) => recencyRank.set(id, i));
  const fresh = shuffle(pool.filter((q) => !recencyRank.has(q.id)));
  const seen = pool
    .filter((q) => recencyRank.has(q.id))
    .sort(
      (a, b) => (recencyRank.get(b.id) ?? 0) - (recencyRank.get(a.id) ?? 0)
    );
  return [...fresh, ...seen].slice(0, need);
}

// =================================================================
// 1) startBlitz — paruošia ~40 teiginių paketą iš VISŲ temų fondo
// =================================================================
export const startBlitz = onCall(
  { enforceAppCheck: true, minInstances: 0, region: REGION },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Prisijungimas privalomas.");
    }
    const uid = request.auth.uid;
    const lang = parseLang(request.data?.lang);

    // Trukmė pagal žaidėjo pasirinkimą (whitelist 30/60 s); 60 s raundas
    // gauna dvigubą teiginių paketą.
    const durRaw = request.data?.durationSec;
    const durationSec = (BLITZ_DURATIONS_SEC as readonly number[]).includes(
      durRaw as number
    )
      ? (durRaw as number)
      : 30;
    const durationMs = durationSec * 1000;
    const batch = Math.round(BLITZ_BATCH * (durationSec / 30));

    // SUJUNGTAS fondas: gamta + visos 7 trivijos temos.
    const merged: TriviaQuestion[] = [
      ...NATURE_QUESTIONS,
      ...Object.values(TRIVIA_REGISTRY).flat(),
    ].filter((q) => fitsBlitz(q, lang));
    if (merged.length < 10) {
      throw new HttpsError("failed-precondition", "Per mažai klausimų.");
    }

    const db = admin.firestore();
    const userRef = db.collection("users").doc(uid);
    const userSnap = await userRef.get();
    const recentByMode =
      (userSnap.data()?.recentByMode as Record<string, string[]>) ?? {};
    const recent: string[] = recentByMode[BLITZ_ROT_KEY] ?? [];

    // Svoris į lengvus (60/40) — skubantis skaitymas.
    const easyPool = merged.filter((q) => q.level === "lengvas");
    const medPool = merged.filter((q) => q.level === "vidutinis");
    const wantEasy = Math.round(batch * 0.6);
    let picked = [
      ...takeSome(easyPool, recent, wantEasy),
      ...takeSome(medPool, recent, batch - wantEasy),
    ];
    // Jei kurio lygio pritrūko — papildom kitu (be dublikatų).
    if (picked.length < batch) {
      const have = new Set(picked.map((q) => q.id));
      const extra = takeSome(
        merged.filter((q) => !have.has(q.id)),
        recent,
        batch - picked.length
      );
      picked = [...picked, ...extra];
    }
    picked = shuffle(picked);

    // TAIP/NE balansas ~50/50 — fiksuotas serveryje (ne monetos metimas
    // kiekvienam atskirai, kad nebūtų iškrypusių serijų).
    const flags = shuffle(picked.map((_, i) => i % 2 === 0));

    const statements = picked.map((q, i) => {
      const c = pickContent(q, lang);
      let cand = c.correct;
      if (!flags[i]) {
        const shortD = c.distractors.filter(
          (d) => d.length <= BLITZ_CAND_MAX_CHARS && d !== c.correct
        );
        cand = shuffle(shortD)[0];
      }
      // `cat` — temos kodas kortelės dizainui (emoji+spalva kliente).
      // SAUGU: tema nesusijusi su tuo, ar kandidatas teisingas.
      return { q: c.question, cand, isTrue: flags[i], cat: q.category };
    });

    // active_games įrašas — vertinimui (isTrue) ir rotacijai (actions).
    const gameRef = db.collection("active_games").doc();
    await gameRef.set({
      uid,
      mode: "blitz",
      durationMs,
      isTrue: statements.map((s) => s.isTrue),
      actions: picked.map((q) => q.id),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Atmintis rašoma JAU PRADŽIOJE (išėjus/grįžus — kiti klausimai).
    await userRef.set(
      {
        recentByMode: {
          [BLITZ_ROT_KEY]: mergeRecent(
            picked.map((q) => q.id),
            recent,
            ROTATION_KEEP_CAT
          ),
        },
      },
      { merge: true }
    );

    return {
      gameId: gameRef.id,
      durationMs,
      statements,
    };
  }
);

// =================================================================
// 2) submitBlitzScore — vertina TIK iš serverio isTrue[], rašo rekordą
// =================================================================
export const submitBlitzScore = onCall(
  { enforceAppCheck: true, minInstances: 0, region: REGION },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Prisijungimas privalomas.");
    }
    const uid = request.auth.uid;

    const gameId = request.data?.gameId;
    const answersRaw = request.data?.answers;
    if (typeof gameId !== "string" || !Array.isArray(answersRaw)) {
      throw new HttpsError("invalid-argument", "Netinkami duomenys.");
    }

    const db = admin.firestore();
    const gameRef = db.collection("active_games").doc(gameId);
    const userRef = db.collection("users").doc(uid);

    return await db.runTransaction(async (tx) => {
      // ---- VISI SKAITYMAI PIRMA ----
      const gameDoc = await tx.get(gameRef);
      if (!gameDoc.exists) {
        throw new HttpsError("not-found", "Raundas nerastas.");
      }
      const game = gameDoc.data()!;
      if (game.uid !== uid || game.mode !== "blitz") {
        throw new HttpsError("permission-denied", "Neleistinas veiksmas.");
      }
      const userDoc = await tx.get(userRef);
      const leaderboardRef = db.collection("leaderboard").doc(`${uid}_blitz`);
      const leaderboardDoc = await tx.get(leaderboardRef);
      // ---- skaitymai baigti ----

      const isTrue = (game.isTrue as boolean[]) ?? [];
      // Raundo trukmė iš žaidimo įrašo (seni įrašai be lauko → 30 s).
      const durationMs = (game.durationMs as number) ?? BLITZ_DURATION_MS;
      const finalX2FromMs = durationMs - BLITZ_FINAL_X2_LAST_MS;

      // Atsakymų validacija: unikalūs indeksai ribose, val bool, tMs skaičius.
      type Ans = { i: number; val: boolean; tMs: number };
      const seenIdx = new Set<number>();
      const answers: Ans[] = [];
      for (const a of answersRaw as unknown[]) {
        const o = a as Record<string, unknown>;
        const i = o?.i;
        const val = o?.val;
        const tMs = o?.tMs;
        if (
          typeof i !== "number" ||
          !Number.isInteger(i) ||
          i < 0 ||
          i >= isTrue.length ||
          seenIdx.has(i) ||
          typeof val !== "boolean" ||
          typeof tMs !== "number" ||
          !Number.isFinite(tMs)
        ) {
          throw new HttpsError("invalid-argument", "Netinkami atsakymai.");
        }
        seenIdx.add(i);
        answers.push({
          i,
          val,
          tMs: Math.min(Math.max(tMs, 0), durationMs),
        });
      }
      answers.sort((a, b) => a.i - b.i);

      // Laiko vartai: serveris PATS matuoja raundo trukmę.
      const ts = game.createdAt as admin.firestore.Timestamp | null;
      const createdAtMs = ts ? ts.toDate().getTime() : Date.now();
      const serverDurationMs = Date.now() - createdAtMs;
      if (serverDurationMs < answers.length * BLITZ_MIN_ANSWER_MS) {
        logger.warn("Blitz anti-cheat: per greita", { uid, serverDurationMs });
        throw new HttpsError("invalid-argument", "Neteisingi rezultatai.");
      }
      if (
        serverDurationMs >
        durationMs + BLITZ_SUBMIT_GRACE_MS + TIME_TOLERANCE_MS
      ) {
        tx.delete(gameRef); // pavėluotas — raundas nebegalioja
        throw new HttpsError("failed-precondition", "Raundas nebegalioja.");
      }

      // Vertinimas + kombo (×1.0 → ×2.0 ties 10 iš eilės) + finalo ×2.
      // SPAUDINĖJIMO APSAUGA (savininkas 2026-06-13, sugriežtinta po jo
      // testo): (1) klaida = −BLITZ_WRONG_PENALTY; (2) atsakymas, atėjęs
      // greičiau nei BLITZ_MIN_GAP_MS po ankstesnio, TAŠKŲ NEDUODA ir kombo
      // nedidina (žmogus per tiek neperskaito) — bet klaidos bauda galioja.
      // Eigos suma gali būti minusinė; galutinė — clamp ≥0.
      let score = 0;
      let correct = 0;
      let streak = 0;
      let bestCombo = 0;
      let prevTMs = -BLITZ_MIN_GAP_MS; // pirmas atsakymas — be tarpo ribos
      for (const a of answers) {
        const gapOk = a.tMs - prevTMs >= BLITZ_MIN_GAP_MS;
        prevTMs = a.tMs;
        if (a.val === isTrue[a.i]) {
          correct++;
          if (gapOk) {
            streak++;
            if (streak > bestCombo) bestCombo = streak;
            let pts =
              BLITZ_BASE_POINTS * (1 + 0.1 * Math.min(streak - 1, 10));
            if (a.tMs >= finalX2FromMs) pts *= 2;
            score += Math.round(pts);
          }
          // per greitas teisingas: 0 taškų, kombo nesikeičia.
        } else {
          streak = 0; // kombo nulinasi
          score -= BLITZ_WRONG_PENALTY;
        }
      }
      score = Math.max(0, score);
      // Persvara atlygiams: spaudinėjant correct≈wrong → atlygis ≈ 0.
      const netCorrect = Math.max(0, correct - (answers.length - correct));

      // ---- RAŠYMAI ----
      tx.delete(gameRef); // no replay

      const prevData = userDoc.data() ?? {};
      const existingName = prevData.username as string | undefined;
      const username =
        existingName ??
        `Player_${Math.floor(1000 + Math.random() * 9000)}`;

      // Monetos — TIK už persvarą (teisingi − klaidos): spaudinėjimas
      // monetų nebefarmina (savininko radinys: „gavau 20 monetų be galvojimo").
      const coinsEarned = Math.floor(netCorrect / 2);
      const newCoins = ((prevData.coins as number) ?? 0) + coinsEarned;

      // Paslapčių raidės — irgi tik už persvarą, puse tempo.
      const earnedLetters = lettersFor(Math.floor(netCorrect / 2));
      const newPendingLetters =
        ((prevData.pendingMysteryLetters as number) ?? 0) + earnedLetters;

      const newTotal = ((prevData.totalPoints as number) ?? 0) + score;
      const prevCats =
        (prevData.pointsByCategory as Record<string, number>) ?? {};
      const newCatPoints = (prevCats.blitz ?? 0) + score;

      // Serija (streak) — kaip submitScore (UTC data).
      const today = new Date().toISOString().slice(0, 10);
      const yesterday = new Date(Date.now() - 86400000)
        .toISOString()
        .slice(0, 10);
      const lastPlay = (prevData.lastPlayDate as string) ?? "";
      const prevStreakDays = (prevData.streakDays as number) ?? 0;
      let newStreakDays: number;
      if (lastPlay === today) {
        newStreakDays = prevStreakDays > 0 ? prevStreakDays : 1;
      } else if (lastPlay === yesterday) {
        newStreakDays = prevStreakDays + 1;
      } else {
        newStreakDays = 1;
      }

      // Rotacija: start jau įrašė — merge dedup neleidžia dvigubinti.
      const prevByMode =
        (prevData.recentByMode as Record<string, string[]>) ?? {};
      const newRecent = mergeRecent(
        (game.actions as string[]) ?? [],
        prevByMode[BLITZ_ROT_KEY] ?? [],
        ROTATION_KEEP_CAT
      );

      tx.set(
        userRef,
        {
          recentByMode: { [BLITZ_ROT_KEY]: newRecent },
          username,
          coins: newCoins,
          pendingMysteryLetters: newPendingLetters,
          totalPoints: newTotal,
          pointsByCategory: { blitz: newCatPoints },
          streakDays: newStreakDays,
          lastPlayDate: today,
        },
        { merge: true }
      );

      const prevBest = leaderboardDoc.exists
        ? (leaderboardDoc.data()!.score as number)
        : -1;
      const isNewRecord = score > prevBest;
      if (isNewRecord) {
        tx.set(leaderboardRef, {
          uid,
          username,
          mode: "blitz",
          score,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      return {
        success: true,
        finalScore: score,
        correct,
        answered: answers.length,
        bestCombo,
        isNewRecord,
        coinsEarned,
        totalCoins: newCoins,
        earnedLetters,
        pendingMysteryLetters: newPendingLetters,
        promptName: isNewRecord && existingName === undefined,
      };
    });
  }
);
