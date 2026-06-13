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

/** Vieno PAKETO atrakinimo kaina coinais (paketas = PLAYS_PER_PACK žaidimų). */
export const UNLOCK_COST_COINS = 150;

/** Kiek žaidimų duoda vienas atrakintas paketas (coins arba reklama).
 *  Po kiekvieno žaidimo skaitliukas mažėja; pasiekus 0 — lygis vėl užrakinamas. */
export const PLAYS_PER_PACK = 2;

/** Saugiklis (anti-farm): daugiausia reklamų-paketų per parą vienam žaidėjui.
 *  25 paketai × 2 = max 50 nemokami žaidimai/parą. Kas nori daugiau —
 *  perka mėnesinę prenumeratą (Etapas B) arba renka monetas žaisdamas. */
export const DAILY_AD_PACK_LIMIT = 25;

/** Prenumeratos trukmė (ms) — Etapas B (2.99 €/mėn). */
export const PREMIUM_DURATION_MS = 30 * 24 * 60 * 60 * 1000;

/** Ar šis režimas (family_level) yra užrakintas pagal nutylėjimą?
 *  (Nepriklauso nuo to, ar žaidėjas jį jau atrakino.) */
export function isLockedByDefault(family: string, level: Level): boolean {
  if (!LOCKED_FAMILIES.has(family)) return false; // baziniai — nemokami
  return level !== DEMO_LEVEL; // demo lygis nemokamas, kiti užrakinti
}

// =====================================================================
// NAUJŲ ŽINIŲ TEMŲ UŽRAKTAS (griaučiai — vieta paruošta, įjungsim su turiniu)
// =====================================================================

/**
 * Visos žinių temos kaina coinais (kai jas atrakinsim parduotuvėje).
 * Manifestas: temos 4–10 — 150–200 coinų. Tikslias kainas suderinsim vėliau.
 */
export const TRIVIA_THEME_UNLOCK_COST = 150;

/**
 * Temos, kurios jau ATRAKINTOS visiems (turi turinio). Kol tuščia — VISOS
 * naujos temos užrakintos. Kai pripildysim, pvz., „tech" klausimų, pridėsim
 * "tech" čia (1 eilutė) — ir serveris ją laikys atrakinta.
 *
 * SVARBU: gamta (nature) NĖRA šitame sąraše, nes turi savo seną nemokamą
 * srautą (startNatureGame) — jos čia liesti nereikia.
 */
export const OPEN_TRIVIA_CATEGORIES = new Set<string>([
  "cosmos", // 🌌 Kosmosas — atrakinta 2026-06-13 (planets potemė turi turinio)
  "mythology", // 🏺 Mitologija — atrakinta 2026-06-13 (greek potemė turi turinio)
  "records", // 📏 Rekordai — atrakinta 2026-06-13 (human potemė turi turinio)
  "brands", // 🏷️ Prekių ženklai — atrakinta 2026-06-13 (visos 4 potemės pilnos)
]);

/** Ar žinių tema užrakinta pagal nutylėjimą? (kol nėra turinio → taip). */
export function isTriviaCategoryLocked(category: string): boolean {
  return !OPEN_TRIVIA_CATEGORIES.has(category);
}
