/**
 * gameConfig — visų 16 režimų nustatymai vienoje vietoje.
 * 4 veiksmai (+ − × ÷) × 4 lygiai (lengvas..ekstremalus).
 * Žr. DIZAINAS.md sprendimai 2 ir 5.
 */

export type Op = "+" | "-" | "*" | "/";
export type Level = "lengvas" | "vidutinis" | "sunkus" | "ekstremalus";

export interface LevelScoring {
  maxPoints: number; // maksimalūs taškai už greitą teisingą atsakymą
}

/** Taškų nustatymai (V2: VIENODA visiems lygiams — max 100).
 *  Leaderboard atskiras kiekvienam režimui, tad lygiai skiriasi klausimų
 *  sunkumu, ne taškų skale. */
export const SCORING: Record<Level, LevelScoring> = {
  lengvas: { maxPoints: 100 },
  vidutinis: { maxPoints: 100 },
  sunkus: { maxPoints: 100 },
  ekstremalus: { maxPoints: 100 },
};

/** Taškų formulė vienam teisingam atsakymui (V2):
 *  score = max(10, 100 − sekundės × 3). Greitas → ~100; 30s → 10; klaida → 0. */
export const MAX_TIME_PER_Q_MS = 30000; // 30s viršutinė riba
export const MIN_POINTS_PER_Q = 10; // minimumas už teisingą, bet lėtą
export const PENALTY_PER_SECOND = 3; // kiek taškų krenta per sekundę

export function pointsForAnswer(maxPoints: number, elapsedMs: number): number {
  const cappedMs = Math.min(Math.max(elapsedMs, 0), MAX_TIME_PER_Q_MS);
  const seconds = cappedMs / 1000;
  const score = maxPoints - seconds * PENALTY_PER_SECOND;
  return Math.max(MIN_POINTS_PER_Q, Math.floor(score));
}

export const QUESTIONS_PER_GAME = 10;
export const OPTIONS_PER_QUESTION = 6;

/** Kiek paskutinių klausimų ID atsimename PER REŽIMĄ (recentByMode[mode]).
 *  Tai VIRŠUTINĖ riba; faktinį „vengimo" langą lanksčiai mažina pickQuestions
 *  pagal realų klausimų kiekį (kad mažam pool'ui visada liktų šviežių). */
export const ROTATION_KEEP = 150;

/** TEMOS atmintis (2026-06-12, savininko taisyklė „be pasikartojimų"):
 *  trivijos/gamtos klausimų istorija laikoma PER TEMĄ (recentByMode["cat_sport"]),
 *  o ne per režimą — žaidžiant potemę ir „Mix" tas pats klausimas nebepasirodys
 *  abiejuose. Langas dengia net didžiausią temą (gamta ~720). */
export const ROTATION_KEEP_CAT = 800;

/**
 * 🧪 TESTAVIMO JUNGIKLIS (savininkas 2026-06-13: „testavime noriu žaisti VISKĄ, visur").
 * true = nuima VISUS žaidimo blokus, kad savininkas galėtų žaisti be ribų:
 *   • matematikos užrakintus lygius (mix/brackets/algebra — be paketų/premium);
 *   • „Atspėk paslaptį" — leidžia kartoti jau išspręstas paslaptis (jokio „Paslapčių dar nėra");
 *   • Detektyvą — ignoruoja išspręstas bylas IR dienos nemokamų bylų limitą.
 * ⚠️ PRIEŠ GOOGLE PLAY BŪTINA GRĄŽINTI Į false (kitaip viskas nemokama/be ribų).
 * (Trivija/Blitz/Mitai blokų neturi — jie patys recikliuoja klausimus.)
 */
export const TESTING_UNLOCK_ALL = true;

/** Matematikos šeimos (jų rotacija lieka per režimą — klausimai generuojami). */
export const MATH_FAMILIES = new Set([
  "add", "sub", "mul", "div", "mix", "brackets", "algebra",
]);
export const MIN_TIME_PER_Q_MS = 200; // greičiau = botas
export const TIME_TOLERANCE_MS = 3000; // tinklo/latency paklaida lyginant laikus

// ── ⚡ TAIP/NE BLITZ (planas docs/planai/TAIP_NE_BLITZ_PLANAS.md) ──────────────
/** Numatytoji raundo trukmė (senas klientas be pasirinkimo). */
export const BLITZ_DURATION_MS = 30000;
/** Leidžiamos raundo trukmės (savininkas 2026-06-12: „30 sek labai greitai
 *  praeina" → pridėtas 1 min pasirinkimas). */
export const BLITZ_DURATIONS_SEC = [30, 60] as const;
/** Kiek teiginių paruošiama 30 s raundui (60 s gauna dvigubai). */
export const BLITZ_BATCH = 40;
/** Greičiau nei tiek vienam atsakymui = botas (žmogus skaito ~0,5–2 s). */
export const BLITZ_MIN_ANSWER_MS = 250;
/** Kiek vėliausiai po raundo pabaigos priimam submit (lėtas tinklas). */
export const BLITZ_SUBMIT_GRACE_MS = 10000;
/** Bazė už teisingą atsakymą (kombo daugina, žr. submitBlitzScore). */
export const BLITZ_BASE_POINTS = 100;
/** Kiek paskutinių ms taškai dvigubinami („paskutinės 5 s ×2"). */
export const BLITZ_FINAL_X2_LAST_MS = 5000;
/** Kandidato (atsakymo varianto) ilgio lubos — turi būti perskaitomas žaibiškai. */
export const BLITZ_CAND_MAX_CHARS = 30;
/** Klausimo ilgio lubos blitz'ui. */
export const BLITZ_Q_MAX_CHARS = 100;
/** BAUDA už klaidingą blitz atsakymą — SAVININKO LOGIKA (2026-06-13):
 *  klaida kainuoja DVIGUBĄ teisingo atsakymo vertę (2 × bazė 100).
 *  Atsitiktinio spaudymo vidurkis neigiamas; 9/1 lieka aukštai.
 *  Galutinis rezultatas niekada nekrenta žemiau 0. */
export const BLITZ_WRONG_PENALTY = 200;

/** Mažiausias tarpas tarp blitz atsakymų, kad atsakymas DUOTŲ taškų:
 *  per <0,6 s žmogus klausimo neperskaito — tai spaudinėjimas. Tokie
 *  atsakymai taškų neduoda (bet klaidos bauda vis tiek galioja). */
export const BLITZ_MIN_GAP_MS = 600;

/** „Tiesa ar mitas?" bauda — SAVININKO FORMULĖ (2026-06-13, žr. submitScore):
 *  klaida nubraukia DVIGUBĄ teisingo vertę proporcingai:
 *  taškai = uždirbta × max(0, teisingi − 2×klaidos) / teisingi.
 *  (Fiksuotos konstantos nebėra — formulė dinaminė.) */

/** BAUDA už ATSAKYTĄ klaidingai 6 variantų žaidimuose (matematika/gamta/
 *  trivijos; savininkas 2026-06-13: „už neatspėtus niekas nenuraso — tada
 *  spaudinėji bele ką"). Atsitiktinis spaudymas pataiko ~1/6, tad su šia
 *  bauda jo vidurkis ≤ 0. PRALEISTI dėl laiko (tuščias atsakymas) —
 *  NEbaudžiami. Galutinis rezultatas niekada nekrenta žemiau 0. */
export const QUIZ_WRONG_PENALTY = 25;

/** Monetos/raidės 6 variantų žaidimuose duodamos tik surinkus bent tiek
 *  teisingų (atsitiktinai ~1,7/10 — atlygių nefarmina; sąžiningam nieko
 *  nekeičia). */
export const QUIZ_REWARD_MIN_CORRECT = 4;

/** Patikrina mode eilutę (pvz. "mul_sunkus", "mix_lengvas").
 *  Grąžina šeimą (add/sub/mul/div/mix) ir lygį. Validuoja prieš registrą. */
export function parseMode(
  mode: unknown
): { family: string; level: Level } | null {
  if (typeof mode !== "string") return null;
  const [family, levelPart] = mode.split("_");
  const families = ["add", "sub", "mul", "div", "mix", "brackets", "algebra"];
  const levels: Level[] = ["lengvas", "vidutinis", "sunkus", "ekstremalus"];
  if (!families.includes(family) || !levels.includes(levelPart as Level)) {
    return null;
  }
  return { family, level: levelPart as Level };
}
