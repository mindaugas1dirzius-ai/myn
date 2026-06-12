/**
 * meltTypes — „Raidžių tirpimas" režimo TIPAI, KONSTANTOS ir GRYNOS formulės.
 *
 * IDĖJA: žaidėjas PATS pasirenka laiko limitą ir raidžių atsivėrimo intervalą.
 * Raidės atsiveria savaime kas intervalą; taškai tirpsta kartu su laiku ir
 * atsivėrusiomis raidėmis. Jokio banko, jokių mokamų pagalbų, jokių gyvybių —
 * vienintelis priešas yra laikas. Procentinė formulė lėto žaidėjo nebaudžia.
 *
 * SAUGUMAS (taisyklė #1): visa būsena gyvena users/{uid}.mysteryMelt; laikas
 * matuojamas TIK serveryje (startedAt įrašomas serverio laiku). Šis failas —
 * tik tipai ir grynos funkcijos (be Firestore), kad logika būtų testuojama.
 *
 * DETERMINIZMAS: starte išsaugoma sumaišyta raidžių tvarka `revealOrder`.
 * Automatiškai atsivėrusios = pirmos k pozicijų (k išvedamas iš praėjusio
 * laiko), NEMOKAMOS raidės (iš viktorinų) — iš sąrašo GALO (`freeCount`).
 * Todėl bet kuri užklausa bet kuriuo momentu atkuria identišką lentą be jokių
 * laikmačių ar papildomų įrašų.
 */

import { Lang } from "./triviaTypes";

// ---------------------------------------------------------------------------
// KONFIGŪRACIJA (whitelist — serveris niekada nepasitiki kliento skaičiais).
// ---------------------------------------------------------------------------

/** Leidžiami bendro laiko limitai (sekundėmis). */
export const MELT_LIMITS_SEC = [60, 120, 300] as const;

/** Leidžiami raidžių atsivėrimo intervalai (sekundėmis). */
export const MELT_INTERVALS_SEC = [5, 10, 20] as const;

/** Mažiausias raidžių kiekis frazei — trumpos frazės tirpsta per žiauriai. */
export const MELT_MIN_LETTERS = 12;

/** Didžiausias raidžių kiekis — ilgos citatos (60+) beveik neįmenamos. */
export const MELT_MAX_LETTERS = 40;

/** Leidžiami sunkumo lygiai (1 lengvas … 4 ekstremalus) — lemia bazę 200–500. */
export const MELT_LEVELS = [1, 2, 3, 4] as const;

/** Bazinė anti-spam pauzė tarp spėjimų (ms); auga su klaidomis (žr. žemiau). */
export const MELT_GUESS_COOLDOWN_MS = 2500;

/** Nemokamų raidžių lubos: frazė niekada ne „pre-solved" (liks bent tiek paslėptų). */
export const MELT_FREE_KEEP_HIDDEN = 3;

/** SPĖJIMO LANGAS: paspaudus SPĖTI laikas sustoja, kad žaidėjas ramiai
 *  suvestų atsakymą — taškai ir raidės tuo metu netirpsta. Langą „suvartoja"
 *  spėjimas (teisingas ar ne) arba jis baigiasi pats.
 *  Numatytoji trukmė (1 žodis / senos partijos be freezeMs lauko). */
export const MELT_FREEZE_MS = 30000;

/** Lango trukmė pagal ATSAKYMO ŽODŽIŲ kiekį (savininko taisyklė 2026-06-12):
 *  1 žodis → 30 s; 2–3 žodžiai → 1 min; 4+ žodžiai → 1 min 30 s —
 *  kad ilgesnį atsakymą žmogus spėtų surinkti. */
export function meltFreezeMsFor(wordCount: number): number {
  if (wordCount <= 1) return 30000;
  if (wordCount <= 3) return 60000;
  return 90000;
}

/** Kiek kartų per partiją SPĖTI gali stabdyti laiką — saugiklis, kad nebūtų
 *  galima „pauzuoti amžinai" be spėjimo (5 langai = 150 s ramybės, sąžiningam
 *  žaidėjui daugiau nei reikia). Išnaudojus — SPĖTI veikia, bet laikas tiksi. */
export const MELT_MAX_FREEZES = 5;

/** Bauda už KLAIDINGĄ spėjimą — dalis nuo pMax (lygis 1 ≈ 20–30 🔑,
 *  lygis 4 ≈ 50–75 🔑). Balansas niekada nekrenta žemiau 0. */
export const MELT_WRONG_PENALTY_FRAC = 0.10;

/** Baudos dydis raktais už klaidingą spėjimą. */
export function meltWrongPenalty(pMax: number): number {
  return Math.round(pMax * MELT_WRONG_PENALTY_FRAC);
}

/** Bazinis laimėjimas pagal lygį 1..4 — sąmoningai sutampa su klasikinio
 *  režimo banko dydžiais (200/300/400/500), kad ekonomika būtų pažįstama. */
export function meltBaseFor(level?: number): number {
  switch (level) {
    case 4: return 500;
    case 3: return 400;
    case 2: return 300;
    default: return 200;
  }
}

/** Greičio koeficientas: greitesnis tirpimas = didesnis maksimumas (rizika=atlygis). */
export function speedCoefFor(intervalSec: number): number {
  if (intervalSec <= 5) return 1.5;
  if (intervalSec <= 10) return 1.25;
  return 1.0;
}

/** Maksimalūs taškai partijos pradžioje. */
export function meltPMax(level: number | undefined, intervalSec: number): number {
  return Math.round(meltBaseFor(level) * speedCoefFor(intervalSec));
}

/** Eskaluojantis spėjimų cooldown: 2.5s, 5s, 10s, 15s (lubos). */
export function meltCooldownMs(wrongGuesses: number): number {
  return Math.min(MELT_GUESS_COOLDOWN_MS * Math.pow(2, Math.max(0, wrongGuesses)), 15000);
}

// ---------------------------------------------------------------------------
// BŪSENA (saugoma users/{uid}.mysteryMelt — rašo TIK serveris).
// ---------------------------------------------------------------------------

export interface MeltState {
  id: string; // paslapties id iš MYSTERIES
  lang: Lang;
  level: number;
  /** Sumaišyta VISŲ raidžių pozicijų tvarka (fiksuota starte). */
  revealOrder: number[];
  /** Kiek NEMOKAMŲ raidžių pritaikyta (imamos iš revealOrder galo). */
  freeCount: number;
  /** Serverio laikas (ms) partijos starte. */
  startedAt: number;
  limitSec: number;
  intervalSec: number;
  lastGuessTs: number;
  wrongGuesses: number;
  /** AKTYVAUS spėjimo lango pradžia (null — langas neatidarytas). Derivacija
   *  atima min(now − lockedAt, MELT_FREEZE_MS) iš praėjusio laiko, todėl lango
   *  metu laikas, taškai ir raidės sustoja. Langą uždaro spėjimas (laikas
   *  perkeliamas į lockMsUsed) arba jis baigiasi pats po 30 s. */
  lockedAt?: number | null;
  /** ANKSTESNIŲ (uždarytų/pasibaigusių) langų susikaupęs užšaldytas laikas ms —
   *  visam laikui atimamas iš praėjusio laiko (deterministiška, be laikmačių). */
  lockMsUsed?: number;
  /** Kiek spėjimo langų jau atidaryta šioje partijoje (lubos MELT_MAX_FREEZES). */
  freezeCount?: number;
  /** Šios partijos spėjimo lango trukmė ms (pagal atsakymo žodžių kiekį,
   *  fiksuojama starte; nesant — MELT_FREEZE_MS). */
  freezeMs?: number;
}

// ---------------------------------------------------------------------------
// GRYNOS IŠVEDIMO FUNKCIJOS.
// ---------------------------------------------------------------------------

export interface MeltDerived {
  /** Ar laikas baigėsi (partija pralaimėta). */
  expired: boolean;
  /** Kiek raidžių atsivėrė automatiškai (galvos dalis). */
  autoCount: number;
  /** Kiek automatinių BAUDŽIA formulę (nemokamos nebaudžia). */
  autoPenaltyCount: number;
  /** Visos šiuo metu atvertos pozicijos (automatinės + nemokamos). */
  revealedSet: Set<number>;
  remainingMs: number;
  /** Po kiek ms atsivers kita raidė (0 — nebėra ko verti / pasibaigė). */
  nextRevealInMs: number;
  /** Kiek taškų laimėtų atspėjęs DABAR. */
  potentialPointsNow: number;
}

/** Laimėjimo taškai: P_max × (likęs laikas %) × (neatvertų raidžių %); min. 1. */
export function meltPoints(
  pMax: number,
  elapsedMs: number,
  limitMs: number,
  autoPenaltyCount: number,
  totalLetters: number
): number {
  const timeFrac = Math.max(0, Math.min(1, 1 - elapsedMs / limitMs));
  const letterFrac = totalLetters > 0
    ? Math.max(0, Math.min(1, 1 - autoPenaltyCount / totalLetters))
    : 0;
  return Math.max(1, Math.round(pMax * timeFrac * letterFrac));
}

/** Atkuria visą lentos būseną iš laiko — determinizmo šerdis. */
export function deriveMelt(
  state: MeltState,
  totalLetters: number,
  nowMs: number
): MeltDerived {
  const limitMs = state.limitSec * 1000;
  const intervalMs = state.intervalSec * 1000;
  // Laiko stabdymas: susikaupęs ankstesnių langų laikas + aktyvus langas
  // (iki šios partijos lango trukmės).
  const freezeMs = state.freezeMs ?? MELT_FREEZE_MS;
  const activeLockMs =
    state.lockedAt != null
      ? Math.min(Math.max(0, nowMs - state.lockedAt), freezeMs)
      : 0;
  const lockExtra = (state.lockMsUsed ?? 0) + activeLockMs;
  const elapsedMs = Math.max(0, nowMs - state.startedAt - lockExtra);
  const expired = elapsedMs >= limitMs;

  // Automatinės: pirmos k revealOrder pozicijų.
  const rawK = Math.floor(elapsedMs / intervalMs);
  const autoCount = Math.min(rawK, totalLetters);

  // Nemokamos: paskutinės freeCount pozicijų. Automatinės bauda tik tiek,
  // kiek NEpersikloja su nemokamomis (galva niekada nelipa ant uodegos,
  // kol frazė beveik pilnai atvira — tada perteklius nebaudžia).
  const freeCount = Math.max(0, Math.min(state.freeCount, totalLetters));
  const autoPenaltyCount = Math.min(autoCount, Math.max(0, totalLetters - freeCount));

  const revealedSet = new Set<number>();
  for (let i = 0; i < autoPenaltyCount; i++) revealedSet.add(state.revealOrder[i]);
  for (let i = 0; i < freeCount; i++) {
    revealedSet.add(state.revealOrder[state.revealOrder.length - 1 - i]);
  }

  const remainingMs = Math.max(0, limitMs - elapsedMs);
  const hiddenLeft = totalLetters - revealedSet.size;
  const nextRevealInMs = expired || hiddenLeft <= 0
    ? 0
    : Math.max(0, (autoCount + 1) * intervalMs - elapsedMs);

  const pMax = meltPMax(state.level, state.intervalSec);
  const potentialPointsNow = expired
    ? 0
    : meltPoints(pMax, elapsedMs, limitMs, autoPenaltyCount, totalLetters);

  return {
    expired,
    autoCount,
    autoPenaltyCount,
    revealedSet,
    remainingMs,
    nextRevealInMs,
    potentialPointsNow,
  };
}

/** Ar nustatymai leidžiami (whitelist). */
export function isValidMeltConfig(
  limitSec: unknown,
  intervalSec: unknown,
  level: unknown
): boolean {
  return (
    typeof limitSec === "number" &&
    typeof intervalSec === "number" &&
    typeof level === "number" &&
    (MELT_LIMITS_SEC as readonly number[]).includes(limitSec) &&
    (MELT_INTERVALS_SEC as readonly number[]).includes(intervalSec) &&
    (MELT_LEVELS as readonly number[]).includes(level)
  );
}
