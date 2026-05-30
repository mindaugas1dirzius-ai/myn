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
export const MIN_TIME_PER_Q_MS = 200; // greičiau = botas
export const TIME_TOLERANCE_MS = 3000; // tinklo/latency paklaida lyginant laikus

/** Patikrina, ar mode eilutė yra leistina (pvz. "*_sunkus"). */
export function parseMode(mode: unknown): { op: Op; level: Level } | null {
  if (typeof mode !== "string") return null;
  const [opPart, levelPart] = mode.split("_");
  const ops: Record<string, Op> = { add: "+", sub: "-", mul: "*", div: "/" };
  const levels: Level[] = ["lengvas", "vidutinis", "sunkus", "ekstremalus"];
  if (!(opPart in ops) || !levels.includes(levelPart as Level)) return null;
  return { op: ops[opPart], level: levelPart as Level };
}
