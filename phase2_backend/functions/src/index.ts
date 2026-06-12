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
  ROTATION_KEEP,
  ROTATION_KEEP_CAT,
  MATH_FAMILIES,
} from "./gameConfig";
import { mergeRecent } from "./triviaEngine";
import {
  QUESTION_GENERATORS,
  GenQuestion,
  isFamily,
  pickGenerated,
} from "./questionRegistry";
import { generateOptions } from "./generateOptions";
import {
  UNLOCK_COST_COINS,
  PLAYS_PER_PACK,
  DAILY_AD_PACK_LIMIT,
  isLockedByDefault,
} from "./unlockConfig";
import { lettersFor } from "./mysteryTypes";

admin.initializeApp();
const db = admin.firestore();

const REGION = "europe-west1";
// ROTATION_KEEP — bendra konstanta gameConfig.ts (naudoja ir startNatureGame).

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
    if (!parsed || !isFamily(parsed.family)) {
      throw new HttpsError("invalid-argument", "Nežinomas režimas.");
    }
    const { family, level } = parsed;
    const generator = QUESTION_GENERATORS[family];
    const mode = request.data.mode as string;

    // Profilis: rotacija + UŽRAKTO patikra (sukčius negali žaisti užrakinto).
    const userRef = db.collection("users").doc(uid);
    const userSnap = await userRef.get();
    const userData = userSnap.data() ?? {};

    // Užrakintas lygis žaidžiamas TIK jei turi paketą (playPacks[mode] > 0)
    // arba aktyvią premium prenumeratą (Etapas B). Greita patikra prieš
    // generuojant klausimus — kad serveris nedirbtų be reikalo.
    const locked = isLockedByDefault(family, level);
    const isPremium = ((userData.premiumUntil as number) ?? 0) > Date.now();
    if (locked && !isPremium) {
      const packs = (userData.playPacks as Record<string, number>) ?? {};
      if ((packs[mode] ?? 0) <= 0) {
        throw new HttpsError("permission-denied", "Lygis užrakintas.");
      }
    }

    // Atmintis PER REŽIMĄ: šio mode istorija neliečia kitų lygių/temų.
    const recentByMode = (userData.recentByMode as Record<string, string[]>) ?? {};
    const recent: string[] = recentByMode[mode] ?? [];

    // Parenkam 10 klausimų su LANKSTAU atminties langu (kaip Gamtoj): surenkam
    // fondą, vengiam tik tiek neseniai matytų, kad visada liktų šviežių, ir
    // dalinam SUMAIŠYTUS. Viename žaidime — niekada nesikartoja; mažam fondui
    // (pvz. lengva ×/÷ = 64) žaidėjas pamato VISUS prieš bet kuriam pasikartojant.
    const questions: GenQuestion[] = pickGenerated(
      generator,
      level,
      recent,
      QUESTIONS_PER_GAME
    );

    // Kiekvienam klausimui — 6 variantai (su trap ir neighbors, jei yra).
    const options = questions.map((q) =>
      generateOptions(q.answer, { trap: q.trap, neighbors: q.neighbors })
    );

    const gameRef = db.collection("active_games").doc();
    // Atominis paketo nuskaičiavimas (-1) + žaidimo įrašas vienoje transakcijoje.
    // Skaičiuojama PRADŽIOJE (kai žaidimas startuoja), kad greitas start'ų
    // spamas neišsunktų paketo daugiau nei priklauso.
    await db.runTransaction(async (transaction) => {
      if (locked) {
        const fresh = await transaction.get(userRef);
        const fd = fresh.data() ?? {};
        const freshPremium = ((fd.premiumUntil as number) ?? 0) > Date.now();
        if (!freshPremium) {
          const packs = (fd.playPacks as Record<string, number>) ?? {};
          const left = packs[mode] ?? 0;
          if (left <= 0) {
            throw new HttpsError("permission-denied", "Lygis užrakintas.");
          }
          transaction.update(userRef, { [`playPacks.${mode}`]: left - 1 });
        }
      }
      transaction.set(gameRef, {
        uid,
        mode: request.data.mode,
        level,
        answers: questions.map((q) => q.answer), // slapta
        actions: questions.map((q) => q.display),
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    // Klientui grąžinam ir `answer` (variantas C, DIZAINAS.md):
    // saugu, nes taškus serveris skaičiuoja iš BENDRO LAIKO — atsakymo
    // žinojimas sukčiui nieko neduoda, o UX gauna momentinį žalia/raudona.
    return {
      gameId: gameRef.id,
      level,
      maxTimeMs: MAX_TIME_PER_Q_MS, // V2: 30s riba (žiedo pilnėjimui)
      questions: questions.map((q, i) => ({
        action: q.display,
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
      const prevData = userDoc.data() ?? {};
      const prevCoins = (prevData.coins as number) ?? 0;
      const newCoins = prevCoins + coinsEarned;

      // „Atspėk paslaptį" meta-žaidimas: pagal SERVERIO patikrintą teisingų
      // skaičių sukaupiam „pažadėtas" atveriamas raides. Vėliau revealLetters
      // jas suvartoja. ADITYVU — ekonomikos/taškų logika NEPALIESTA.
      const prevPendingLetters = (prevData.pendingMysteryLetters as number) ?? 0;
      const newPendingLetters = prevPendingLetters + lettersFor(correct);

      // ===== ETAPAS C: kaupiama profilio statistika (viskas SERVERYJE) =====
      // Kategorija pagal mode: "nature_*" → žinios, kita → matematika.
      const category = (game.mode as string).startsWith("nature")
        ? "nature"
        : "math";

      // Bendri (viso gyvenimo) taškai — avatarų progresui.
      const prevTotal = (prevData.totalPoints as number) ?? 0;
      const newTotal = prevTotal + score;

      // Taškai pagal temą (merge išsaugo kitos temos reikšmę).
      const prevCats = (prevData.pointsByCategory as Record<string, number>) ?? {};
      const newCatPoints = (prevCats[category] ?? 0) + score;

      // Išmokti faktai: tik UNIKALŪS (kartojant tą patį klausimą — NEDIDĖJA).
      // Saugome teisingai atsakytų klausimų ID rinkinį (game.actions[i] = klausimo
      // ID gamtai / išraiška matui). learnedFacts = to rinkinio dydis.
      // Skaičiuojam Gamtos teisingus (žinios) arba sunkų/ekstremalų matą.
      const isHardMath =
        category === "math" && (level === "sunkus" || level === "ekstremalus");
      const countsAsFact = category === "nature" || isHardMath;
      const factIds = (game.actions as unknown[]) ?? [];
      const prevFactIds: string[] = (prevData.learnedFactIds as string[]) ?? [];
      const factSet = new Set<string>(prevFactIds);
      if (countsAsFact) {
        for (let i = 0; i < serverAnswers.length; i++) {
          const id = factIds[i];
          if (clientAnswers[i] === serverAnswers[i] && id != null) {
            factSet.add(String(id));
          }
        }
      }
      // Saugiklis: ribojam dokumento dydį (laikom naujausius). Gamtos pūlas
      // mažas (~150), tad praktiškai niekada nepasieks; tai tik apsauga matui.
      const LEARNED_CAP = 2000;
      let newFactIds = Array.from(factSet);
      if (newFactIds.length > LEARNED_CAP) {
        newFactIds = newFactIds.slice(newFactIds.length - LEARNED_CAP);
      }
      const newLearned = newFactIds.length;

      // Serija (streak): dienos iš eilės (UTC data, nepriklauso nuo TZ).
      const today = new Date().toISOString().slice(0, 10);
      const yesterday = new Date(Date.now() - 86400000).toISOString().slice(0, 10);
      const lastPlay = (prevData.lastPlayDate as string) ?? "";
      const prevStreak = (prevData.streakDays as number) ?? 0;
      let newStreak: number;
      if (lastPlay === today) {
        newStreak = prevStreak > 0 ? prevStreak : 1; // jau žaista šiandien
      } else if (lastPlay === yesterday) {
        newStreak = prevStreak + 1; // tęsiasi serija
      } else {
        newStreak = 1; // nutrūko (arba pirmas kartas)
      }

      // Rotacijos raktas (2026-06-12): matematikai — per režimą (klausimai
      // generuojami), trivijai/gamtai — PER TEMĄ ("cat_sport"), kad potemės ir
      // „Mix" dalintųsi viena istorija ir klausimai nesikartotų tarp srautų.
      const gameMode = game.mode as string;
      const fam = gameMode.split("_")[0];
      const isMathMode = MATH_FAMILIES.has(fam);
      const rotKey = isMathMode ? gameMode : `cat_${fam}`;
      const rotKeep = isMathMode ? ROTATION_KEEP : ROTATION_KEEP_CAT;
      const prevByMode = (prevData.recentByMode as Record<string, string[]>) ?? {};
      const prevRecent: string[] = prevByMode[rotKey] ?? [];
      // mergeRecent: naujausi pirma, BE dublikatų. Trivijoj žaidimo ID jau įrašyti
      // PRADŽIOJE (start funkcijose) — dedup užtikrina, kad jie neužims dviejų
      // vietų lange. Matematikai elgesys nepakitęs (tiesiog be atsitiktinių dublių).
      const newRecent = mergeRecent(game.actions as string[], prevRecent, rotKeep);
      transaction.set(
        userRef,
        {
          recentByMode: { [rotKey]: newRecent },
          username,
          coins: newCoins,
          pendingMysteryLetters: newPendingLetters,
          totalPoints: newTotal,
          pointsByCategory: { [category]: newCatPoints },
          learnedFacts: newLearned,
          learnedFactIds: newFactIds,
          streakDays: newStreak,
          lastPlayDate: today,
        },
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
        // „Atspėk paslaptį" kabliukas: kiek raidžių uždirbta ŠIAME žaidime ir
        // kiek iš viso laukia neatvertų — rezultatų ekranas tai parodo iškart.
        earnedLetters: lettersFor(correct),
        pendingMysteryLetters: newPendingLetters,
        // Etapas C: nauja kaupiama statistika (klientas gali parodyti progresą).
        totalPoints: newTotal,
        learnedFacts: newLearned,
        streakDays: newStreak,
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

// =================================================================
// 4) unlockMode — nuperka žaidimų PAKETĄ lygiui už COINS (Etapas 3)
//    Paketas NĖRA amžinas: playPacks[mode] += PLAYS_PER_PACK; startGame nuskaičiuoja po 1.
// =================================================================
export const unlockMode = onCall(
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
    const mode = request.data.mode as string;

    // Negalima pirkti nemokamo lygio.
    if (!isLockedByDefault(parsed.family, parsed.level)) {
      throw new HttpsError("failed-precondition", "Šis lygis nemokamas.");
    }

    const userRef = db.collection("users").doc(uid);
    return await db.runTransaction(async (transaction) => {
      const userDoc = await transaction.get(userRef);
      const data = userDoc.data() ?? {};
      const coins = (data.coins as number) ?? 0;
      if (coins < UNLOCK_COST_COINS) {
        throw new HttpsError("failed-precondition", "Per mažai monetų.");
      }
      const packs = (data.playPacks as Record<string, number>) ?? {};
      const newLeft = (packs[mode] ?? 0) + PLAYS_PER_PACK;
      // Atominė transakcija: nurašom coins + pridedam paketą (merge išsaugo kitų lygių paketus).
      transaction.set(
        userRef,
        {
          coins: coins - UNLOCK_COST_COINS,
          playPacks: { [mode]: newLeft },
        },
        { merge: true }
      );
      return {
        success: true,
        coins: coins - UNLOCK_COST_COINS,
        playsLeft: newLeft,
      };
    });
  }
);

// =================================================================
// 5) unlockByAd — duoda žaidimų PAKETĄ lygiui už PAŽIŪRĖTĄ reklamą
//    Saugiklis: DAILY_AD_PACK_LIMIT paketų per parą vienam uid (anti-farm).
//    Pilnas AdMob SSV (server-side verification) — vėliau.
// =================================================================
export const unlockByAd = onCall(
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
    const mode = request.data.mode as string;
    if (!isLockedByDefault(parsed.family, parsed.level)) {
      throw new HttpsError("failed-precondition", "Šis lygis nemokamas.");
    }

    // Dabartinė UTC diena „YYYY-MM-DD" — stabili, nepriklauso nuo serverio TZ.
    const today = new Date().toISOString().slice(0, 10);

    const userRef = db.collection("users").doc(uid);
    return await db.runTransaction(async (transaction) => {
      const userDoc = await transaction.get(userRef);
      const data = userDoc.data() ?? {};

      const savedDate = (data.adPacksDate as string) ?? "";
      // Nauja diena (arba laukų dar nėra) — nulinam dienos skaitiklį.
      const usedToday =
        savedDate === today ? ((data.adPacksToday as number) ?? 0) : 0;
      if (usedToday >= DAILY_AD_PACK_LIMIT) {
        throw new HttpsError(
          "resource-exhausted",
          "Šiandien pasiekei reklamų limitą. Bandyk rytoj arba pirk prenumeratą."
        );
      }

      const packs = (data.playPacks as Record<string, number>) ?? {};
      const newLeft = (packs[mode] ?? 0) + PLAYS_PER_PACK;
      const newUsedToday = usedToday + 1;

      // Atominė transakcija: paketas + dienos skaitiklis/data.
      transaction.set(
        userRef,
        {
          playPacks: { [mode]: newLeft },
          adPacksToday: newUsedToday,
          adPacksDate: today,
        },
        { merge: true }
      );

      return {
        success: true,
        unlockedNow: true,
        playsLeft: newLeft,
        adsLeftToday: DAILY_AD_PACK_LIMIT - newUsedToday,
      };
    });
  }
);

// =================================================================
// 6) startNatureGame — Gamtos/žinių trivijos startas (IZOLIUOTAS modulis).
//    Įrašo į active_games tuo pačiu formatu → submitScore veikia be pakeitimų.
//    Ekonomika (1–5) nepaliesta; tai TIK nauja eilutė.
// =================================================================
export { startNatureGame, startTriviaGame } from "./triviaFunctions";

// =================================================================
// 7) „Atspėk paslaptį" meta-žaidimas (IZOLIUOTAS modulis).
//    Raides atveria pagal submitScore užrašytą pendingMysteryLetters;
//    spėjimą tikrina serveris, monetos keičiamos saugiai (≥0).
// =================================================================
export {
  startMystery,
  revealLetters,
  guessMystery,
  resetMystery,
  getMysteryStatus,
  mysteryPowerup,
} from "./mysteryFunctions";

// =================================================================
// 8) „Raidžių tirpimas" — naujas paslapties režimas (IZOLIUOTAS modulis).
//    Žaidėjas pats renkasi laiką ir tirpimo tempą; taškai pagal procentinę
//    formulę; raidės atsiveria deterministiškai iš serverio laiko.
// =================================================================
export {
  startMelt,
  syncMelt,
  guessMelt,
  abandonMelt,
} from "./meltFunctions";
