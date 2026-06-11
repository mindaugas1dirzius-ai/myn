/**
 * historyContent — „Istorija ir civilizacijos" trivijos klausimai.
 *
 * TUŠČIA (skeletas). Klausimus pildysim VĖLIAU, kai bus patvirtintos tikslios
 * turinio taisyklės. Kol masyvas tuščias, serveris šią temą saugiai atmeta
 * („Per mažai klausimų"), o klientas ją rodo užrakintą su statusu „Greitai".
 *
 * Formatas — žr. triviaTypes.ts (TriviaQuestion): daugiakalbis, 1 teisingas +
 * ≥5 distractors, sourceVerified, isTrap, neprivalomas emoji ir explanation.
 * SVARBU (taisyklė): jokios politikos, religijos, ginčytinų teritorijų.
 */

import { TriviaQuestion } from "./triviaTypes";

export const HISTORY_QUESTIONS: TriviaQuestion[] = [];
