/**
 * detectiveTypes — 🕵️ DETEKTYVO tipai, konstantos ir grynos formulės.
 *
 * IDĖJA (savininko sprendimas 2026-06-12): slaptas ŽODIS + perkamų TAIP/NE
 * klausimų „turgus" (3 kainų lygiai) + 3 gyvybės. Laiko spaudimo NĖRA — tai
 * MĄSTYMO žaidimas (kontrastas blitz/tirpimui). Žodis PERDEGA po vieno
 * žaidimo → nemokamai ribotas dienos srautas, premium — be ribos.
 *
 * SAUGUMAS (taisyklė #1): žodis, atsakymai, bankas, gyvybės — TIK serveryje
 * (users/{uid}.detective). Atsakymas grąžinamas TIK nupirkus (transakcija).
 */

import { Lang } from "./triviaTypes";

/** Klausimo kainos lygis: 1 pigus (platus) · 2 vidutinis · 3 brangus (beveik pasako). */
export type ClueTier = 1 | 2 | 3;

/** Kainos pagal lygį 🔑 (perkama iš BYLOS banko, ne iš balanso). */
export const DETECTIVE_PRICES: Record<ClueTier, number> = {
  1: 15,
  2: 30,
  3: 60,
};

/** Bylos bankas pagal sunkumo lygį 1..4 — kaip paslapčių (pažįstama ekonomika). */
export function detectiveBankFor(level?: number): number {
  switch (level) {
    case 4: return 500;
    case 3: return 400;
    case 2: return 300;
    default: return 200;
  }
}

/** Žemiausia banko riba — pirkti galima tik jei liks bent tiek. */
export const DETECTIVE_FLOOR = 50;

/** Nemokamų bylų limitas per parą (UTC). Premium (premiumUntil) — be ribos. */
export const DETECTIVE_FREE_PER_DAY = 3;

/** Gyvybės: klaidingas spėjimas −1; 0 → byla žlugo (žodis vis tiek perdega). */
export const DETECTIVE_LIVES = 3;

/** Kiek perdegusių bylų ID saugome (seniausi išstumiami). */
export const DETECTIVE_SOLVED_CAP = 300;

/** Vienas perkamas TAIP/NE klausimas apie slaptą žodį. */
export interface ClueQuestion {
  t: ClueTier; // kainos lygis
  q: string;   // klausimo tekstas
  a: boolean;  // TAIP/NE (siunčiama klientui TIK nupirkus!)
}

/** Bylos turinys viena kalba. */
export interface DetectiveText {
  word: string;          // slaptas žodis (spėjimui — normalizeGuess)
  categoryLabel: string; // kategorijos kortelė („Gyvūnas") — nemokama užuomina
  questions: ClueQuestion[]; // ~9 (po 3 kiekvieno lygio)
}

/** Viena detektyvo byla (visomis turimomis kalbomis). */
export interface DetectiveCase {
  id: string;            // pvz. "det_001"
  level: 1 | 2 | 3 | 4;  // amžiaus skalė: 1 vaikai … 4 žinovai
  texts: Partial<Record<Lang, DetectiveText>>;
}

/** Aktyvios bylos būsena (users/{uid}.detective — rašo TIK serveris). */
export interface DetectiveState {
  caseId: string;
  lang: Lang;
  level: number;
  spent: number;     // kiek banko ištirpdyta pirkimais
  lives: number;
  bought: number[];  // nupirktų klausimų indeksai
  startedAt: number; // serverio ms (statistikai)
}

/** Likęs bankas (niekada žemiau 0). */
export function detectiveBank(level: number, spent: number): number {
  return Math.max(0, detectiveBankFor(level) - spent);
}

/** Ar galima pirkti: po pirkimo bankas liktų ≥ grindų. */
export function canBuyClue(level: number, spent: number, price: number): boolean {
  return detectiveBank(level, spent) - price >= DETECTIVE_FLOOR;
}
