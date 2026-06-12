/**
 * mythFunctions — 🧐 „TIESA AR MITAS?" startas (IZOLIUOTAS modulis).
 *
 * Žaidėjas mato MŪSŲ PARUOŠTĄ teiginį ir sprendžia: ✅ TIESA ar ❌ MITAS.
 * Po atsakymo klientas parodo paaiškinimą (mokomasis efektas).
 *
 * KODĖL pigus saugumui: įrašas į `active_games` daromas TUO PAČIU formatu
 * kaip matematika/trivija (answers = teisingi atsakymai, čia bool[]), todėl
 * taškus/monetas/Top 10/rotaciją skaičiuoja TAS PATS, jau veikiantis ir
 * App Check apsaugotas `submitScore` — be jokio pakeitimo. Nulis regresijos.
 *
 * mode formatas: "myth_<lygis>" → atskira Top 10 lentelė kiekvienam lygiui;
 * rotacija per temą (cat_myth) — teiginiai nesikartoja tarp partijų.
 */

import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

import {
  QUESTIONS_PER_GAME,
  MAX_TIME_PER_Q_MS,
  ROTATION_KEEP_CAT,
  Level,
} from "./gameConfig";
import { mergeRecent } from "./triviaEngine";
import { shuffle } from "./generateOptions";
import { Lang } from "./triviaTypes";
import { MYTH_STATEMENTS, MythStatement } from "./mythContent";

const REGION = "europe-west1";

const SUPPORTED_LANGS: Lang[] = [
  "en", "lt", "es", "it", "pl", "de", "fr", "uk", "pt", "ar",
];
function parseLang(x: unknown): Lang {
  return typeof x === "string" && (SUPPORTED_LANGS as string[]).includes(x)
    ? (x as Lang)
    : "en";
}

const MYTH_LEVELS: Level[] = ["lengvas", "vidutinis", "sunkus", "ekstremalus"];
const MYTH_ROT_KEY = "cat_myth";

/** Paima iki `need`: pirma nematyti (sumaišyti), tada seniausiai matyti (LRU). */
function takeMyth(
  pool: MythStatement[],
  recentIds: string[],
  need: number
): MythStatement[] {
  const rank = new Map<string, number>();
  recentIds.forEach((id, i) => rank.set(id, i));
  const fresh = shuffle(pool.filter((m) => !rank.has(m.id)));
  const seen = pool
    .filter((m) => rank.has(m.id))
    .sort((a, b) => (rank.get(b.id) ?? 0) - (rank.get(a.id) ?? 0));
  return [...fresh, ...seen].slice(0, need);
}

export const startMythGame = onCall(
  { enforceAppCheck: true, minInstances: 0, region: REGION },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Prisijungimas privalomas.");
    }
    const uid = request.auth.uid;

    // mode: "myth_<lygis>".
    const modeRaw =
      typeof request.data?.mode === "string" ? request.data.mode : "";
    const parts = modeRaw.split("_");
    if (parts[0] !== "myth" || parts.length !== 2) {
      throw new HttpsError("invalid-argument", "Nežinomas režimas.");
    }
    const level = parts[1] as Level;
    if (!MYTH_LEVELS.includes(level)) {
      throw new HttpsError("failed-precondition", "Šis lygis dar neparuoštas.");
    }
    const lang = parseLang(request.data?.lang);

    const pool = MYTH_STATEMENTS.filter(
      (m) => m.level === level && (m.texts[lang] || m.texts.en)
    );
    if (pool.length < QUESTIONS_PER_GAME) {
      throw new HttpsError(
        "failed-precondition",
        "Per mažai teiginių šiam lygiui."
      );
    }

    const db = admin.firestore();
    const userRef = db.collection("users").doc(uid);
    const userSnap = await userRef.get();
    const recentByMode =
      (userSnap.data()?.recentByMode as Record<string, string[]>) ?? {};
    const recent: string[] = recentByMode[MYTH_ROT_KEY] ?? [];

    const picked = takeMyth(pool, recent, QUESTIONS_PER_GAME);
    const pickedIds = picked.map((m) => m.id);

    // Įrašas TUO PAČIU formatu kaip trivija → submitScore veikia be pakeitimų
    // (bool[] palyginimas clientAnswers[i] === serverAnswers[i] saugus).
    const gameRef = db.collection("active_games").doc();
    await gameRef.set({
      uid,
      mode: modeRaw,
      level,
      answers: picked.map((m) => m.isTrue),
      actions: pickedIds,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Atmintis rašoma JAU PRADŽIOJE (išėjus/grįžus — kiti teiginiai).
    await userRef.set(
      {
        recentByMode: {
          [MYTH_ROT_KEY]: mergeRecent(pickedIds, recent, ROTATION_KEEP_CAT),
        },
      },
      { merge: true }
    );

    return {
      gameId: gameRef.id,
      level,
      maxTimeMs: MAX_TIME_PER_Q_MS,
      statements: picked.map((m) => {
        const t = m.texts[lang] ?? m.texts.en!;
        // isTrue/ex siunčiami klientui (variantas C, kaip trivijos answer):
        // momentinei reakcijai + paaiškinimui; taškus skaičiuoja serveris
        // pagal LAIKĄ, tad žinojimas sukčiui nieko neduoda.
        return { st: t.st, ex: t.ex, isTrue: m.isTrue };
      }),
    };
  }
);
