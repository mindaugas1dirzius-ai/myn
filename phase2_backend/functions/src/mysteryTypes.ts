/**
 * mysteryTypes — „Atspėk paslaptį" meta-žaidimo TIPAI ir GRYNI helperiai.
 *
 * Idėja (skėtinis režimas): žaisdamas BET KURIĄ temą (Matematika/Gamta),
 * žaidėjas pagal rezultatą „atveria" raides paslėptame tekste (patarlė,
 * citata, istorinė frazė). Kai jaučiasi galįs — bando atspėti visą tekstą.
 * Kuo MAŽIAU raidžių atversta spėjimo metu, tuo DIDESNIS taškų daugiklis
 * (rizika = atlygis). Klaida atima taškų proporcingai atvertoms raidėms.
 *
 * SAUGUMAS (taisyklė #1): visa „tiesa" (tekstas, atvertų raidžių indeksai,
 * taškai) gyvena TIK serveryje. Klientui niekada nesiunčiamas pilnas tekstas,
 * kol paslaptis neišspręsta. Šis failas — TIK tipai + grynos funkcijos
 * (be Firestore), kad logiką būtų lengva testuoti ir nesulaužyti.
 */

import { Lang } from "./triviaTypes";

/**
 * Paslapties kategorija. „klausimas" = „Laimės rato" stilius: virš langelių
 * rodomas ĮDOMUS KLAUSIMAS, o paslėptas tekstas — atsakymas į jį.
 */
export type MysteryCategory =
  | "patarle"
  | "citata"
  | "istorija"
  | "klausimas"
  | "faktas";

/** Vienos kalbos paslapties turinys. */
export interface MysteryText {
  /** Pats paslėptas tekstas (atsakymas). */
  text: string;
  /**
   * NEMOKAMA, visada matoma užuomina/klausimas virš langelių
   * (pvz. „Lietuvių liaudies patarlė" arba „Kuri planeta vadinama Raudonąja?").
   */
  hint: string;
  /** Papildoma užuomina #1 (perkama už raktus) — pasako šiek tiek daugiau. */
  hint1?: string;
  /** Papildoma užuomina #2 (perkama) — pasako dar aiškiau. */
  hint2?: string;
}

/** Viena paslaptis (visomis turimomis kalbomis). */
export interface MysteryItem {
  id: string; // unikalus, pvz. "mys_pat_001"
  category: MysteryCategory;
  /**
   * Sudėtingumo lygis 1..4 — lemia banko (galimo laimėjimo) dydį:
   *   1 Lengva 200 · 2 Vidutinė 300 · 3 Sunki 400 · 4 Ekstremali 500 🔑.
   */
  level: number;
  sourceVerified: string; // šaltinis (taisyklė #2: faktai 100% patikrinti)
  /** Vertimai. Partial — ne visos paslaptys turi visas kalbas. */
  texts: Partial<Record<Lang, MysteryText>>;
}

// ---------------------------------------------------------------------------
// KONFIGŪRACIJA (vienoje vietoje — lengva derinti balansą).
// ---------------------------------------------------------------------------

/** Kiek raidžių atveriama pagal teisingų atsakymų skaičių viename žaidime. */
export function lettersFor(correct: number): number {
  if (correct >= 10) return 3;
  if (correct >= 8) return 2;
  if (correct >= 6) return 1;
  return 0;
}

/** Minimali pauzė tarp dviejų spėjimų (anti-spam, ms). */
export const GUESS_COOLDOWN_MS = 2000;

/**
 * Kiek SPĖJIMŲ leidžiama vienai paslapčiai. Suklydus tiek kartų — paslaptis
 * „pralaimėta": atskleidžiamas atsakymas ir parenkama NAUJA paslaptis. Tai daro
 * žaidimą įtemptesnį (negali spėlioti be galo) ir saugo ekonomiką.
 * Galios priemone „+1 spėjimas" žaidėjas gali laikinai pridėti papildomų.
 */
export const MAX_GUESSES = 5;

/**
 * Galios priemonių kainos. SVARBU (B būdas / „Cyber-Ratelis"): kaina nuimama
 * NE iš bendro raktų balanso, o iš ŠIOS partijos BANKO (galimo laimėjimo). Kuo
 * daugiau pagalbos panaudoji — tuo mažiau laimi atspėjęs. Žaidžiama savarankiškai,
 * be jokio sukaupto balanso. Į bendrą piniginę raktai įrašomi TIK atspėjus.
 */
export const POWERUP_HINT_COST = 50; // papildoma užuomina (#1 arba #2)
export const POWERUP_REVEAL_COST = 50; // atskleisti vieną paslėptą raidę
export const POWERUP_GUESS_COST = 30; // +1 spėjimas šiai paslapčiai

/**
 * Kiek spėjimų liko: bazinis limitas + nupirkti papildomi (bonus) − jau suklysta.
 * Viena vieta skaičiavimui, kad serveris ir klientas rodytų vienodai.
 */
export function attemptsLeftFor(wrong: number, bonus = 0): number {
  return Math.max(0, MAX_GUESSES + bonus - wrong);
}

/** Kiek „šiukšlių" raidžių pridėti į pool'ą (kad būtų sunkiau). */
export const POOL_JUNK_LETTERS = 4;

/** Maksimalus įsimenamų išspręstų paslapčių ID kiekis (dokumento dydžio sauga). */
export const SOLVED_CAP = 500;

// ---------------------------------------------------------------------------
// RAKTŲ (🔑) EKONOMIKA — „Cyber-Ratelis" BANKO modelis (B būdas). Viena vieta.
// ---------------------------------------------------------------------------
//
// Raktai — ATSKIRA paslapties valiuta (NE monetos, NE bendri taškai). Jie tik
// KAUPIAMI: įrašomi į žaidėjo balansą TIK kai paslaptis atspėta.
//
// PRINCIPAS (vartotojo patvirtintas): kiekviena partija prasideda su BANKU pagal
// lygį (200/300/400/500 🔑). Kiekviena MOKAMA pagalba (užuomina / pirkta raidė /
// +spėjimas) tirpdo ŠĮ banką. Atspėjęs gauni tiek, kiek banke liko. Bankas niekada
// nenukrenta žemiau GRINDŲ (50). Pagalbą pirkti galima TIK jei bankas nenukristų
// žemiau grindų (kitaip mygtukas blokuojamas) — taip pagalba niekada netampa
// „nemokama". NEMOKAMOS raidės iš kitų žaidimų (pendingMysteryLetters) banko
// NEMAŽINA — tai atlygis už žaidimą. Suklydus — banko nemažinam, tik dingsta
// spėjimas (širdelė); jei baigiasi visi — paslaptis pralaimėta (0 🔑).
//
// VISKAS SKAIČIUOJAMA SERVERYJE (taisyklė #1): būsenoje saugom `spent` (kiek
// išleista), o banką visada perskaičiuojam = max(GRINDYS, bankoMax(level) − spent).

/** Žemiausias įmanomas laimėjimas atspėjus (saugiklis). */
export const MYSTERY_FLOOR = 50;

/** Banko (galimo laimėjimo) dydis pagal lygį 1..4. */
export function bankMaxFor(level?: number): number {
  switch (level) {
    case 4:
      return 500; // Ekstremali
    case 3:
      return 400; // Sunki
    case 2:
      return 300; // Vidutinė
    default:
      return 200; // Lengva (1 arba nenurodyta)
  }
}

/** Dabartinis bankas = laimėjimas atspėjus DABAR. Niekada < GRINDŲ. */
export function bankFor(level: number | undefined, spent: number): number {
  return Math.max(MYSTERY_FLOOR, bankMaxFor(level) - Math.max(0, spent));
}

/**
 * Ar galima pirkti pagalbą už `cost`: TIK jei po pirkimo bankas liks ≥ GRINDŲ.
 * (Kitaip pagalba nuvarytų banką žemiau saugiklio — neleidžiam.)
 */
export function canAfford(
  level: number | undefined,
  spent: number,
  cost: number
): boolean {
  return bankMaxFor(level) - (Math.max(0, spent) + cost) >= MYSTERY_FLOOR;
}

// ---------------------------------------------------------------------------
// GRYNI HELPERIAI (be Firestore).
// ---------------------------------------------------------------------------

/** Ar simbolis yra raidė (įsk. lietuviškas su diakritikais). */
export function isLetter(ch: string): boolean {
  return /\p{L}/u.test(ch);
}

/**
 * Normalizacija palyginimui: mažosios, diakritikai IŠLAIKOMI (lietuvių k.),
 * skyryba/tarpai suvienodinami. „Žinau, kad nieko!" === „žinau kad nieko".
 */
export function normalizeGuess(s: string): string {
  return s
    .toLowerCase()
    .replace(/[^\p{L}\p{N}]+/gu, " ") // viskas, kas ne raidė/skaičius → tarpas
    .trim()
    .replace(/\s+/g, " ");
}

/** Paslapties raidžių pozicijų indeksai (tik raidės — tarpai/skyryba ne). */
export function letterIndices(text: string): number[] {
  const out: number[] = [];
  const chars = [...text];
  for (let i = 0; i < chars.length; i++) {
    if (isLetter(chars[i])) out.push(i);
  }
  return out;
}

/** Vienos kaukės pozicijos aprašas, siunčiamas klientui. */
export interface MaskCell {
  /** true = raidės langelis (brūkšnelis arba atverta raidė); false = skyriklis. */
  slot: boolean;
  /**
   * Skyrikliui — pats simbolis (tarpas, kablelis...).
   * Raidės langeliui — atverta raidė (didžioji) arba null (dar paslėpta).
   */
  ch: string | null;
}

/**
 * Sukuria kaukę klientui: paslėptos raidės → null (brūkšnelis), atvertos →
 * didžioji raidė, skyrikliai (tarpai/skyryba) — rodomi atvirai.
 * Pilno teksto klientas NIEKADA negauna, kol paslaptis neišspręsta.
 */
export function buildMask(text: string, revealed: Set<number>): MaskCell[] {
  const chars = [...text];
  return chars.map((ch, i) => {
    if (isLetter(ch)) {
      return { slot: true, ch: revealed.has(i) ? ch.toUpperCase() : null };
    }
    return { slot: false, ch }; // skyriklis — visada matomas
  });
}

/** Fisher-Yates maišymas (kaip variantų generatoriuje — be šališkumo). */
export function shuffle<T>(arr: T[]): T[] {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

/** Atsarginis alfabetas „šiukšlėms" (jei tekste per mažai skirtingų raidžių). */
const JUNK_ALPHABET = "AĄBCČDEĘĖFGHIĮYJKLMNOPRSŠTUŲŪVZŽ".split("");

/**
 * Atsitiktinė „šiukšlių" raidė. KALBAI NEUTRALU: pirmiausia renkamės iš paties
 * teksto raidžių (ta pati rašto sistema — lotynų, kirilica, arabų...), todėl
 * šiukšlės visada atrodo natūraliai bet kuria kalba. Atsarga — lietuviškas
 * alfabetas (jei tekstas per trumpas).
 */
export function randomJunkLetter(alphabet?: string[]): string {
  const pool = alphabet && alphabet.length > 0 ? alphabet : JUNK_ALPHABET;
  return pool[Math.floor(Math.random() * pool.length)];
}

/** Skirtingos (unikalios) teksto raidės DIDŽIOSIOMIS — „šiukšlių" šaltinis. */
function distinctLetters(text: string): string[] {
  const set = new Set<string>();
  for (const ch of [...text]) {
    if (isLetter(ch)) set.add(ch.toUpperCase());
  }
  return [...set];
}

/**
 * Raidžių „pool" (klaviatūra): visos DAR PASLĖPTOS atsakymo raidės (didžiosios)
 * + kelios šiukšlės, sumaišytos. Žaidėjas iš jų dėlioja spėjimą.
 *
 * Šiukšlės imamos iš paties teksto raidžių (kalbai neutralu) — kad bet kuria
 * kalba (taip pat būsima kirilica/arabų) klaviatūra būtų tos pačios sistemos.
 */
export function buildPool(text: string, revealed: Set<number>): string[] {
  const chars = [...text];
  const hidden: string[] = [];
  for (let i = 0; i < chars.length; i++) {
    if (isLetter(chars[i]) && !revealed.has(i)) {
      hidden.push(chars[i].toUpperCase());
    }
  }
  const alphabet = distinctLetters(text); // teksto raidės (ta pati rašto sistema)
  const junk: string[] = [];
  for (let i = 0; i < POOL_JUNK_LETTERS; i++) junk.push(randomJunkLetter(alphabet));
  return shuffle([...hidden, ...junk]);
}
