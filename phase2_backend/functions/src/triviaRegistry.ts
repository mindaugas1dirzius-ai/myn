/**
 * triviaRegistry — vieta, kur TEMOS kodas susiejamas su jos klausimų masyvu.
 *
 * KODĖL: vienas variklis (startTriviaGame) aptarnauja VISAS žinių temas. Kad
 * pridėti naują temą būtų 1 eilutė (be naujo Cloud Function), čia laikome
 * žemėlapį „kodas → klausimai". Nauja tema = naujas content failas + 1 įrašas.
 *
 * SVARBU:
 *   - „nature" ČIA NĖRA: gamta turi atskirą, jau veikiantį startNatureGame su
 *     potemėmis (facts/extinct/plants/mix). Nelietam, kad nesugadintume Top 10.
 *   - Tuščias masyvas = tema dar be turinio. Serveris ją SAUGIAI atmeta
 *     („Per mažai klausimų"), o klientas rodo užrakintą „Greitai".
 */

import { TriviaQuestion, TriviaCategory } from "./triviaTypes";
import { POP_QUESTIONS } from "./popContent";
import { GEO_QUESTIONS } from "./geoContent";
import { HISTORY_QUESTIONS } from "./historyContent";
import { TECH_QUESTIONS } from "./techContent";
import { FOOD_QUESTIONS } from "./foodContent";
import { SPORT_QUESTIONS } from "./sportContent";
import { BODY_QUESTIONS } from "./bodyContent";
import { COSMOS_QUESTIONS } from "./cosmosContent";
import { MYTHOLOGY_QUESTIONS } from "./mythologyContent";
import { RECORDS_QUESTIONS } from "./recordsContent";

/**
 * Temos, kurias aptarnauja BENDRAS startTriviaGame (be „nature" — ji atskira).
 * Tai TriviaCategory poaibis: visa, IŠSKYRUS „nature".
 */
export type GenericTriviaCategory = Exclude<TriviaCategory, "nature">;

// 🌌 „Kosmoso lenktynės" (savininko valia 2026-06-13): tech „space" klausimai
// PERKELTI į Kosmoso temą kaip potemė „spacerace" — kad kosmosas nebūtų dviejose
// temose (painu). IDŲ NEKEIČIAM (rotacija saugi); tik category→cosmos,
// subTheme→spacerace. Fiziškai jie lieka techContent.ts (saugu — be 5000 eil. failo
// chirurgijos), o čia perskirstomi registre. (Vėliau galima fiziškai iškelti į
// atskirą cosmosSpacerace.ts — tik tvarkos sumetimais.)
const TECH_SPACE_AS_COSMOS: TriviaQuestion[] = TECH_QUESTIONS.filter(
  (q) => q.subTheme === "space"
).map((q) => ({ ...q, category: "cosmos" as const, subTheme: "spacerace" }));
const TECH_CORE: TriviaQuestion[] = TECH_QUESTIONS.filter(
  (q) => q.subTheme !== "space"
);

/** Kodas → tos temos klausimų masyvas. */
export const TRIVIA_REGISTRY: Record<GenericTriviaCategory, TriviaQuestion[]> = {
  pop: POP_QUESTIONS,
  geo: GEO_QUESTIONS,
  history: HISTORY_QUESTIONS,
  tech: TECH_CORE,
  food: FOOD_QUESTIONS,
  sport: SPORT_QUESTIONS,
  body: BODY_QUESTIONS,
  cosmos: [...COSMOS_QUESTIONS, ...TECH_SPACE_AS_COSMOS],
  mythology: MYTHOLOGY_QUESTIONS,
  records: RECORDS_QUESTIONS,
};

/** Ar duotas tekstas yra žinoma bendro variklio tema? (type guard) */
export function isGenericTriviaCategory(x: string): x is GenericTriviaCategory {
  return Object.prototype.hasOwnProperty.call(TRIVIA_REGISTRY, x);
}
