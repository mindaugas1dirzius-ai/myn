/**
 * triviaTypes — žinių (trivijos) klausimų modelis (Gamta, Geografija ...).
 *
 * SKIRTUMAS nuo matematikos: matematika GENERUOJAMA kode (7+3),
 * o trivija — TIKRI FAKTAI, kuriuos saugome. Kiekvienas klausimas:
 *   - daugiakalbis (translations: en, lt, ...) — žmogus mato savo kalba;
 *   - turi 1 teisingą + ≥5 „distractors" (klaidingus), iš kurių serveris
 *     parenka 5 → 6 variantai (kaip matematikoj, OPTIONS_PER_QUESTION);
 *   - sourceVerified — iš kur faktas (drausmina mus, taisyklė #2: 100% teisinga);
 *   - isTrap — „False Friend" mitas (atrodo logiška, bet populiarus klaidingas
 *     įsitikinimas) — stipri retencijos priemonė.
 *
 * Modelis SUDERINTAS su būsima Firestore kolekcija (`questions_nature`),
 * tad vėliau turinį galima perkelti į DB be perrašymo.
 */

import { Level } from "./gameConfig";

/** Palaikomos kalbos (plėsim palaipsniui; AR — paskutinė dėl RTL). */
export type Lang =
  | "en" | "lt" | "es" | "it" | "pl" | "de" | "fr" | "uk" | "pt" | "ar";

/** Numatytoji kalba, jei vartotojo kalbos klausimas dar neišverstas. */
export const DEFAULT_LANG: Lang = "en";

/**
 * Stambi gamtos POTEMĖ (tema „Gamta ir gyvūnai"), kurią renkasi žaidėjas.
 * SKIRIASI nuo `subTheme` (smulkus: animals, plants, records...) — `topic`
 * yra didelis pasirinkimo blokas:
 *   - "facts"   — Įdomūs faktai apie gamtą ir gyvūnus (esami klausimai);
 *   - "extinct" — Išnykę gyvūnai ir gamta;
 *   - "plants"  — Augalai (ir kt.).
 * "facts" yra NUMATYTASIS: klausimas be `topic` lauko laikomas "facts", tad
 * esamų 211 klausimų KEISTI NEREIKIA. ("mix" nėra klausimo žyma — tai
 * pasirinkimo režimas, traukiantis iš visų potemių; žr. triviaFunctions.)
 */
export type NatureTopic = "facts" | "extinct" | "plants";

/** Numatytoji potemė, jei klausimas neturi `topic` lauko. */
export const DEFAULT_TOPIC: NatureTopic = "facts";

/** Vienos kalbos turinys: klausimas, teisingas, klaidingi variantai. */
export interface LocalizedContent {
  question: string;
  correct: string;
  /** ≥5 klaidingi variantai (serveris parinks 5 į 6 langelių sąrašą). */
  distractors: string[];
  /**
   * Paaiškinimas, rodomas žaidimo pabaigoje: kodėl teisingas atsakymas yra
   * teisingas (mokomoji vertė + retencija). Neprivalomas (senesni klausimai
   * gali neturėti) — tada peržiūroje paprasčiausiai nerodom paaiškinimo.
   */
  explanation?: string;
}

/** Vienas trivijos klausimas (visomis turimomis kalbomis). */
export interface TriviaQuestion {
  id: string;             // unikalus, pvz. "nat_animals_001"
  category: "nature" | "geography";
  subTheme: string;       // pvz. "animals", "plants", "records", "myths"
  /**
   * Stambi potemė pasirinkimui (žr. NatureTopic). NEPRIVALOMA — jei nenurodyta,
   * klausimas laikomas DEFAULT_TOPIC ("facts"). Todėl esamų klausimų, kurie
   * šio lauko neturi, KEISTI NEREIKIA — jie automatiškai patenka į „faktus".
   */
  topic?: NatureTopic;
  level: Level;           // lengvas | vidutinis | sunkus | ekstremalus
  isTrap: boolean;        // True = mitų spąstas ("False Friend")
  sourceVerified: string; // faktų šaltinis (taisyklė #2)
  /** Iliustracinis emoji (vietoj nuotraukos — momentinis, neutralus kalbai). */
  emoji?: string;
  /** Vertimai. Partial — pradžioje turim ne visas kalbas (yra EN atsarga). */
  translations: Partial<Record<Lang, LocalizedContent>>;
}
