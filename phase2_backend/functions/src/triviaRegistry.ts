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

/**
 * Temos, kurias aptarnauja BENDRAS startTriviaGame (be „nature" — ji atskira).
 * Tai TriviaCategory poaibis: visa, IŠSKYRUS „nature".
 */
export type GenericTriviaCategory = Exclude<TriviaCategory, "nature">;

/** Kodas → tos temos klausimų masyvas. */
export const TRIVIA_REGISTRY: Record<GenericTriviaCategory, TriviaQuestion[]> = {
  pop: POP_QUESTIONS,
  geo: GEO_QUESTIONS,
  history: HISTORY_QUESTIONS,
  tech: TECH_QUESTIONS,
  food: FOOD_QUESTIONS,
  sport: SPORT_QUESTIONS,
  body: BODY_QUESTIONS,
};

/** Ar duotas tekstas yra žinoma bendro variklio tema? (type guard) */
export function isGenericTriviaCategory(x: string): x is GenericTriviaCategory {
  return Object.prototype.hasOwnProperty.call(TRIVIA_REGISTRY, x);
}
