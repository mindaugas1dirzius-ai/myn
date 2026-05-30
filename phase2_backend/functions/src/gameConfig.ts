/**
 * gameConfig — visų 16 režimų nustatymai vienoje vietoje.
 * 4 veiksmai (+ − × ÷) × 4 lygiai (lengvas..ekstremalus).
 * Žr. DIZAINAS.md sprendimai 2 ir 5.
 */

export type Op = "+" | "-" | "*" | "/";
export type Level = "lengvas" | "vidutinis" | "sunkus" | "ekstremalus";

export interface LevelScoring {
  maxTimeMs: number; // langelio laikas (ir taškų bonuso riba)
  basePoints: number; // bazė už teisingą
}

/** Taškų nustatymai pagal lygį (5 sprendimas). */
export const SCORING: Record<Level, LevelScoring> = {
  lengvas: { maxTimeMs: 3000, basePoints: 50 },
  vidutinis: { maxTimeMs: 4000, basePoints: 100 },
  sunkus: { maxTimeMs: 5000, basePoints: 150 },
  ekstremalus: { maxTimeMs: 6000, basePoints: 200 },
};

export const QUESTIONS_PER_GAME = 10;
export const OPTIONS_PER_QUESTION = 6;
export const MIN_TIME_PER_Q_MS = 250; // greičiau = botas
export const TIME_TOLERANCE_MS = 1500;

/** Patikrina, ar mode eilutė yra leistina (pvz. "*_sunkus"). */
export function parseMode(mode: unknown): { op: Op; level: Level } | null {
  if (typeof mode !== "string") return null;
  const [opPart, levelPart] = mode.split("_");
  const ops: Record<string, Op> = { add: "+", sub: "-", mul: "*", div: "/" };
  const levels: Level[] = ["lengvas", "vidutinis", "sunkus", "ekstremalus"];
  if (!(opPart in ops) || !levels.includes(levelPart as Level)) return null;
  return { op: ops[opPart], level: levelPart as Level };
}
