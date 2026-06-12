/**
 * detectiveTypes — 🕵️ DETEKTYVO v2 tipai, konstantos ir grynos formulės.
 *
 * SAVININKO SPECIFIKACIJA (2026-06-13, docs/planai/DETEKTYVAS_PLANAS.md):
 *  - slaptas ŽODIS + perkamų klausimų „turgus" (3 kainų lygiai);
 *  - atsakymai TAIP / NE / „TAIP, BET…" su paaiškinimu (a: "both" + note);
 *  - LAIKAS TIKSI NUOLAT: laimėjus award = bankas − pirkimai − laikas×koef,
 *    bet NIEKADA mažiau MIN_AWARD (spėti apsimoka visada);
 *  - nupirkus VISUS klausimus banke lieka ~20 🔑 (kainos sustyguotos);
 *  - 3 gyvybės; likus 1 — atrakinama SOS mįslė (brangi, bet PROTINGA);
 *  - 2 spėjimo variantai: ✍️ rašyk pats (premija ×1,25) / 🎯 įtariamųjų
 *    lenta su ~30 kortelių (kai byla turi board) — be rašymo, visoms kalboms.
 *
 * SAUGUMAS (taisyklė #1): žodis, atsakymai, bankas, gyvybės, laikas — TIK
 * serveryje (users/{uid}.detective). Atsakymas grąžinamas TIK nupirkus.
 */

import { Lang } from "./triviaTypes";

/** Klausimo kainos lygis: 1 pigus (platus) · 2 vidutinis · 3 brangus (protinga užuomina). */
export type ClueTier = 1 | 2 | 3;

/** Atsakymas: true = TAIP · false = NE · "both" = TAIP/NE su paaiškinimu. */
export type ClueAnswer = boolean | "both";

/** Vienas perkamas klausimas apie slaptą žodį. */
export interface ClueQuestion {
  t: ClueTier;   // kainos lygis
  q: string;     // klausimo tekstas (matomas NEMOKAMAI)
  a: ClueAnswer; // siunčiama klientui TIK nupirkus!
  note?: string; // paaiškinimas; PRIVALOMAS kai a === "both"
}

/** Bylos turinys viena kalba. */
export interface DetectiveText {
  word: string;            // slaptas žodis (V1 spėjimui — normalizeGuess)
  categoryLabel: string;   // kategorijos kortelė („Maistas") — nemokama
  questions: ClueQuestion[]; // v2 bylos: 30 (po 10 lygio); senos: 12 (po 4)
  intro?: string;          // 1 sakinio intriga bylos pradžiai
  board?: string[];        // ~30 variantų „įtariamųjų lentai" (su žodžiu!)
  boardEmoji?: string[];   // po emoji kiekvienam variantui (ta pačia tvarka)
  sos?: string;            // SOS mįslė — stipriausia, bet PROTINGA užuomina
}

/** Viena detektyvo byla (visomis turimomis kalbomis). */
export interface DetectiveCase {
  id: string;            // pvz. "det_001" — NEKEISTI (solved sąrašai!)
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
  startedAt: number; // serverio ms — LAIKRODŽIUI (bauda už laiką)
  variant?: 1 | 2;        // 1 ✍️ rašyk pats · 2 🎯 lenta (tik kai board yra)
  boardOrder?: number[];  // sumaišyti lentos indeksai (fiksuoti starte)
  sosBought?: boolean;    // SOS mįslė nupirkta
  wrongGuesses?: number;  // klaidingų spėjimų kiekis (rangui)
}

// ---------------------------------------------------------------------------
// EKONOMIKA (SAVININKO taisyklės; konstantos derinamos testuojant).
// ---------------------------------------------------------------------------

/** Bylos bankas — visiems lygiams vienodas (lygis keičia žodžių sunkumą
 *  ir laiko tempą, ne pradinę sumą). */
export const DETECTIVE_BANK = 1000;

/** Mažiausias laimėjimas atspėjus — kad ir viską nusipirkus / ilgai mąsčius
 *  SPĖTI APSIMOKA VISADA (savininko taisyklė „lieka vis tiek ~20"). */
export const DETECTIVE_MIN_AWARD = 20;

/** Laiko bauda 🔑/sek. pagal lygį — sunkesnės bylos tiksi greičiau. */
export function detectiveTimeCoef(level?: number): number {
  switch (level) {
    case 4: return 4;
    case 3: return 3;
    case 2: return 2;
    default: return 1;
  }
}

/** Kainos pagal klausimų KIEKĮ byloje: visų klausimų suma = bankas − 20.
 *  30 kl. (po 10): 10×(18+30+50) = 980 → lieka 20.
 *  12 kl. (po 4):   4×(40+80+125) = 980 → lieka 20. */
export function detectivePricesFor(
  questionCount: number
): Record<ClueTier, number> {
  if (questionCount >= 30) return { 1: 18, 2: 30, 3: 50 };
  return { 1: 40, 2: 80, 3: 125 };
}

/** SOS mįslės kaina (atrakinama TIK likus 1 gyvybei, vienkartinė). */
export const DETECTIVE_SOS_PRICE = 120;

/** ✍️ „Rašyk pats" premija — be variantų sunkiau = vertingiau. Taikoma TIK
 *  kai byla turi lentą (t. y. žaidėjas turėjo lengvesnį pasirinkimą). */
export const DETECTIVE_TYPED_BONUS = 1.25;

/** Žemiausia banko riba perkant. 0 — galima nupirkti VISKĄ (laimėjimą
 *  saugo DETECTIVE_MIN_AWARD grindys). */
export const DETECTIVE_FLOOR = 0;

/** Nemokamų bylų limitas per parą (UTC). Premium (premiumUntil) — be ribos.
 *  ⚠️ TESTUI laikinai 999 — PRIEŠ PALEIDIMĄ GRĄŽINTI į 3! */
export const DETECTIVE_FREE_PER_DAY = 999;

/** Gyvybės: klaidingas spėjimas −1; 0 → byla žlugo (žodis vis tiek perdega). */
export const DETECTIVE_LIVES = 3;

/** Kiek perdegusių bylų ID saugome (seniausi išstumiami). */
export const DETECTIVE_SOLVED_CAP = 300;

/** Likęs bankas po pirkimų (niekada žemiau 0). */
export function detectiveBank(spent: number): number {
  return Math.max(0, DETECTIVE_BANK - spent);
}

/** Ar galima pirkti: po pirkimo bankas liktų ≥ grindų. */
export function canBuyClue(spent: number, price: number): boolean {
  return detectiveBank(spent) - price >= DETECTIVE_FLOOR;
}

/** Kiek laimėtų atspėjęs DABAR (savininko formulė su grindimis):
 *  max(MIN, (bankas − pirkimai − sek×koef) [× 1,25 jei rašė pats]). */
export function detectiveAward(
  level: number,
  spent: number,
  elapsedMs: number,
  typedBonus: boolean
): number {
  const timePenalty =
    Math.floor(Math.max(0, elapsedMs) / 1000) * detectiveTimeCoef(level);
  let raw = detectiveBank(spent) - timePenalty;
  if (typedBonus) raw = Math.round(raw * DETECTIVE_TYPED_BONUS);
  return Math.max(DETECTIVE_MIN_AWARD, raw);
}

/** Detektyvo rangas pagal efektyvumą (rodymui po bylos). */
export function detectiveRank(
  boughtCount: number,
  wrongGuesses: number
): 1 | 2 | 3 {
  if (boughtCount <= 6 && wrongGuesses === 0) return 1; // 🥇 Šerlokas
  if (boughtCount <= 12 && wrongGuesses <= 1) return 2; // 🥈 Inspektorius
  return 3; // 🥉 Naujokas
}
