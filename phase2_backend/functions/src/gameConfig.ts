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

/** Taškų nustatymai pagal lygį (V2: laikas tiksi aukštyn, 30s riba).
 *  Sunkesnis lygis = daugiau maksimalių taškų. */
export const SCORING: Record<Level, LevelScoring> = {
  lengvas: { maxPoints: 100 },
  vidutinis: { maxPoints: 150 },
  sunkus: { maxPoints: 200 },
  ekstremalus: { maxPoints: 300 },
};

/** Taškų formulė vienam teisingam atsakymui (V2).
 *  Greitas → ~maxPoints; lėtas (iki 30s) → minimumas; klaida → 0.
 *  score = max(MIN, maxPoints − sekundės × PENALTY). */
export const MAX_TIME_PER_Q_MS = 30000; // 30s viršutinė riba
export const MIN_POINTS_PER_Q = 10; // minimumas už teisingą, bet lėtą
export const PENALTY_PER_SECOND = 4; // kiek taškų krenta per sekundę

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
