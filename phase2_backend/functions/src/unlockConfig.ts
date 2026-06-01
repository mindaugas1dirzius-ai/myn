/**
 * unlockConfig — kas užrakinta, kainos, demo lygiai (Etapas 3).
 *
 * Modelis:
 *  - Baziniai veiksmai (add/sub/mul/div) — VISIŠKAI nemokami.
 *  - Kiber-lygos (mix/brackets/algebra): Vidutinis = nemokamas DEMO,
 *    kiti 3 lygiai (lengvas/sunkus/ekstremalus) = užrakinti.
 *  - Naujos temos (vėliau) — irgi per šitą konfigą.
 */

import { Level } from "./gameConfig";

/** Šeimos, kurių dalis lygių užrakinta. */
const LOCKED_FAMILIES = new Set(["mix", "brackets", "algebra"]);

/** Nemokamas demo lygis užrakintose šeimose. */
const DEMO_LEVEL: Level = "vidutinis";

/** Vieno lygio atrakinimo kaina coinais. */
export const UNLOCK_COST_COINS = 150;

/** Kiek reklamų reikia atrakinti vieną lygį (kiekviena +75 coins ekvivalentas). */
export const ADS_TO_UNLOCK = 2;

/** Prenumeratos trukmė (ms). */
export const PREMIUM_DURATION_MS = 30 * 24 * 60 * 60 * 1000;

/** Ar šis režimas (family_level) yra užrakintas pagal nutylėjimą?
 *  (Nepriklauso nuo to, ar žaidėjas jį jau atrakino.) */
export function isLockedByDefault(family: string, level: Level): boolean {
  if (!LOCKED_FAMILIES.has(family)) return false; // baziniai — nemokami
  return level !== DEMO_LEVEL; // demo lygis nemokamas, kiti užrakinti
}
