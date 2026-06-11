/**
 * triviaFunctions — IZOLIUOTAS gamtos/žinių žaidimo startas.
 *
 * KODĖL atskirai: matematika generuojama (skaičiai), trivija — faktai.
 * BET įrašas į `active_games` daromas TUO PAČIU formatu kaip matematika,
 * todėl taškus/monetas/Top 10/rotaciją skaičiuoja TAS PATS, jau veikiantis
 * ir App Check apsaugotas `submitScore` — be jokio pakeitimo. Nulis regresijos.
 *
 * Saugumas: enforceAppCheck: true (kaip visur). Atsakymas grąžinamas klientui
 * (variantas C — kaip matematikoj): taškus serveris skaičiuoja pagal LAIKĄ,
 * tad atsakymo žinojimas sukčiui nieko neduoda.
 *
 * mode formatas: "nature_<lygis>" (pvz. "nature_lengvas", "nature_vidutinis").
 * Atskira mode eilutė = atskira Top 10 lentelė kiekvienam lygiui.
 */

import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

import {
  QUESTIONS_PER_GAME,
  MAX_TIME_PER_Q_MS,
  ROTATION_KEEP,
  Level,
} from "./gameConfig";
import { NATURE_QUESTIONS } from "./natureContent";
import { pickQuestions, assembleOptions, mergeRecent } from "./triviaEngine";
import { Lang, NatureTopic } from "./triviaTypes";
import { TRIVIA_REGISTRY, isGenericTriviaCategory } from "./triviaRegistry";
import { isSubThemeOf, poolForSubTheme } from "./subThemeConfig";

const REGION = "europe-west1";

/** Palaikomos kalbos (plėsim palaipsniui). Nežinoma → EN. */
const SUPPORTED_LANGS: Lang[] = [
  "en", "lt", "es", "it", "pl", "de", "fr", "uk", "pt", "ar",
];
function parseLang(x: unknown): Lang {
  return typeof x === "string" && (SUPPORTED_LANGS as string[]).includes(x)
    ? (x as Lang)
    : "en";
}

/** Atviri visi keturi lygiai: Easy, Medium, Hard, Extreme. */
const NATURE_LEVELS: Level[] = ["lengvas", "vidutinis", "sunkus", "ekstremalus"];

/**
 * Galimos potemės pasirinkimui. "mix" — ne klausimo žyma, o režimas, traukiantis
 * iš VISŲ potemių (pickQuestions tai supranta). Jei potemė tuščia šiam lygiui,
 * žemiau įvyks „Per mažai klausimų" — todėl klientas tokias užrakina („Greitai").
 */
const NATURE_TOPICS: (NatureTopic | "mix")[] = [
  "facts", "extinct", "plants", "mix",
];

export const startNatureGame = onCall(
  { enforceAppCheck: true, minInstances: 0, region: REGION },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Prisijungimas privalomas.");
    }
    const uid = request.auth.uid;

    // mode: DU palaikomi formatai:
    //   "nature_<lygis>"            — senas (suderinamumas; potemė = "facts");
    //   "nature_<potemė>_<lygis>"   — naujas (su potemių struktūra).
    const modeRaw = typeof request.data?.mode === "string" ? request.data.mode : "";
    const parts = modeRaw.split("_");
    if (parts[0] !== "nature" || (parts.length !== 2 && parts.length !== 3)) {
      throw new HttpsError("invalid-argument", "Nežinomas režimas.");
    }
    let topic: NatureTopic | "mix";
    let level: Level;
    if (parts.length === 2) {
      topic = "facts";               // senas formatas → faktai
      level = parts[1] as Level;
    } else {
      topic = parts[1] as NatureTopic | "mix";
      level = parts[2] as Level;
    }
    if (!NATURE_TOPICS.includes(topic)) {
      throw new HttpsError("invalid-argument", "Nežinoma potemė.");
    }
    if (!NATURE_LEVELS.includes(level)) {
      throw new HttpsError("failed-precondition", "Šis lygis dar neparuoštas.");
    }

    const lang = parseLang(request.data?.lang);

    // admin.firestore() — TIK funkcijos viduje (initializeApp jau įvykęs).
    const db = admin.firestore();
    const userRef = db.collection("users").doc(uid);
    const userSnap = await userRef.get();
    // Atmintis PER REŽIMĄ (recentByMode[modeRaw]): kiekviena gamtos potemė×lygis
    // turi SAVO nepriklausomą istoriją — žaidžiant vieną neištrinsi kitos.
    const recentByMode =
      (userSnap.data()?.recentByMode as Record<string, string[]>) ?? {};
    const recent: string[] = recentByMode[modeRaw] ?? [];

    // Parenkam 10 klausimų (vengiant neseniai matytų) + sudėliojam variantus.
    // topic filtras: "mix" → iš visų potemių; kitaip tik tos potemės klausimai.
    const picked = pickQuestions(
      NATURE_QUESTIONS,
      level,
      recent,
      QUESTIONS_PER_GAME,
      topic
    );
    if (picked.length < QUESTIONS_PER_GAME) {
      throw new HttpsError("failed-precondition", "Per mažai klausimų šiam lygiui.");
    }
    const assembled = picked.map((q) => assembleOptions(q, lang, "nature"));

    const pickedIds = picked.map((q) => q.id);

    // Įrašas į active_games — TAS PATS formatas kaip matematika
    // (answers=teisingi, actions=klausimų ID rotacijai). submitScore tai supras.
    const gameRef = db.collection("active_games").doc();
    await gameRef.set({
      uid,
      mode: modeRaw,
      level,
      answers: assembled.map((a) => a.answer), // slapta (string)
      actions: pickedIds,                        // rotacijai (ne display!)
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // SVARBU (pasikartojimų taisymas): atmintį atnaujinam JAU DABAR, žaidimo
    // PRADŽIOJE — ne tik submitScore pabaigoje. Taip net jei žaidėjas iškart
    // išeina ir vėl įeina į tą patį langą, gauna KITUS klausimus (nebe tuos
    // pačius). mergeRecent: naujausi pirma, be dublikatų, apkarpyta. submitScore
    // vėliau dar kartą įrašys tuos pačius ID — dedup neleidžia dvigubinti.
    await userRef.set(
      { recentByMode: { [modeRaw]: mergeRecent(pickedIds, recent, ROTATION_KEEP) } },
      { merge: true }
    );

    return {
      gameId: gameRef.id,
      level,
      maxTimeMs: MAX_TIME_PER_Q_MS,
      questions: assembled.map((a) => ({
        action: a.display,
        options: a.options,
        answer: a.answer,
        explanation: a.explanation ?? "",
        emoji: a.emoji ?? "",
        cardEmoji: a.cardEmoji ?? "",     // kortelės subjektas (arba "" → scena)
        optionEmojis: a.optionEmojis, // [] arba 6 emoji (viskas-arba-nieko)
      })),
    };
  }
);

/**
 * startTriviaGame — BENDRAS žinių trivijos startas VISOMS temoms, IŠSKYRUS
 * gamtą (ji turi savo startNatureGame su potemėmis). Viena funkcija aptarnauja
 * pop / geo / history / tech / food / sport / body — temą parenka registras.
 *
 * mode formatas: "<tema>_<lygis>" (pvz. "tech_lengvas"). PAPRASTAS — be potemių
 * segmento, kad Top 10 raktai būtų švarūs (po vieną lentelę temai×lygiui).
 *
 * Saugiklis: jei temos masyvas tuščias arba per mažas tam lygiui — grąžinam
 * „failed-precondition" (klientas tokias temas šiaip jau rodo užrakintas).
 *
 * Įrašas į active_games ir atminties (recentByMode) logika — TA PATI kaip
 * startNatureGame ir matematikoj, todėl submitScore veikia be jokio pakeitimo.
 */
export const startTriviaGame = onCall(
  { enforceAppCheck: true, minInstances: 0, region: REGION },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Prisijungimas privalomas.");
    }
    const uid = request.auth.uid;

    // mode: DU palaikomi formatai (lygiai BE pabraukimo, tad split saugus):
    //   "<tema>_<lygis>"            — be potemės (potemė = „facts");
    //   "<tema>_<potemė>_<lygis>"   — su poteme (pvz. "body_brain_lengvas").
    const modeRaw =
      typeof request.data?.mode === "string" ? request.data.mode : "";
    const parts = modeRaw.split("_");
    if (parts.length !== 2 && parts.length !== 3) {
      throw new HttpsError("invalid-argument", "Nežinomas režimas.");
    }
    const category = parts[0];
    let subTheme: string;
    let level: Level;
    if (parts.length === 2) {
      subTheme = "facts";              // be potemės → numatytoji „facts"
      level = parts[1] as Level;
    } else {
      subTheme = parts[1];             // potemė (arba „mix")
      level = parts[2] as Level;
    }
    if (!isGenericTriviaCategory(category)) {
      throw new HttpsError("invalid-argument", "Nežinoma tema.");
    }
    // Potemė turi būti žinoma: „facts"/„mix" visada leidžiama, kitos — pagal konfigą.
    if (
      subTheme !== "facts" &&
      subTheme !== "mix" &&
      !isSubThemeOf(category, subTheme)
    ) {
      throw new HttpsError("invalid-argument", "Nežinoma potemė.");
    }
    if (!NATURE_LEVELS.includes(level)) {
      throw new HttpsError("failed-precondition", "Šis lygis dar neparuoštas.");
    }

    const lang = parseLang(request.data?.lang);

    const db = admin.firestore();
    const userRef = db.collection("users").doc(uid);
    const userSnap = await userRef.get();
    const recentByMode =
      (userSnap.data()?.recentByMode as Record<string, string[]>) ?? {};
    const recent: string[] = recentByMode[modeRaw] ?? [];

    // Baseinas pagal potemę: „facts" → bendri klausimai, „mix" → visi,
    // kitaip → tik tos potemės. (Atgaliniam suderinamumui: tema be potemių
    // turi tuščią sąrašą, tad „facts" = visi klausimai, kaip ir seniau.)
    const pool = poolForSubTheme(category, TRIVIA_REGISTRY[category], subTheme);
    const picked = pickQuestions(pool, level, recent, QUESTIONS_PER_GAME);
    if (picked.length < QUESTIONS_PER_GAME) {
      throw new HttpsError(
        "failed-precondition",
        "Per mažai klausimų šiam lygiui."
      );
    }
    // category perduodam, kad atsakymų ženkliukas (kai nėra savų emoji) būtų
    // TEMOS (🗺️/⚙️/📜…), o ne bendras.
    const assembled = picked.map((q) => assembleOptions(q, lang, category));
    const pickedIds = picked.map((q) => q.id);

    const gameRef = db.collection("active_games").doc();
    await gameRef.set({
      uid,
      mode: modeRaw,
      level,
      answers: assembled.map((a) => a.answer),
      actions: pickedIds,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await userRef.set(
      { recentByMode: { [modeRaw]: mergeRecent(pickedIds, recent, ROTATION_KEEP) } },
      { merge: true }
    );

    return {
      gameId: gameRef.id,
      level,
      maxTimeMs: MAX_TIME_PER_Q_MS,
      questions: assembled.map((a) => ({
        action: a.display,
        options: a.options,
        answer: a.answer,
        explanation: a.explanation ?? "",
        emoji: a.emoji ?? "",
        cardEmoji: a.cardEmoji ?? "",     // kortelės subjektas (arba "" → scena)
        optionEmojis: a.optionEmojis,
      })),
    };
  }
);
