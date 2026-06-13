/**
 * recordsContent — 📏 „Rekordai ir keistenybės" temos klausimų INDEKSAS.
 *
 * MAŽI FAILAI: kiekviena potemė savo faile (recordsHuman.ts ir t. t.), čia tik
 * sujungiam į vieną masyvą. Gyvūnų rekordai — GAMTOS temoje (čia nekartojama).
 *
 * Potemės (subThemeConfig.ts „records"):
 *   🏆 human   — Žmonių rekordai (ĮGYVENDINTA, 40 kl.);
 *   🌍 world   — Pasaulio rekordai (ĮGYVENDINTA, 40 kl.);
 *   🤪 laws    — Keisti įstatymai ir tradicijos (ĮGYVENDINTA, 40 kl.);
 *   💎 objects — Daiktų ir maisto rekordai (ĮGYVENDINTA, 40 kl.).
 */

import { TriviaQuestion } from "./triviaTypes";
import { RECORDS_HUMAN } from "./recordsHuman";
import { RECORDS_WORLD } from "./recordsWorld";
import { RECORDS_LAWS } from "./recordsLaws";
import { RECORDS_OBJECTS } from "./recordsObjects";

export const RECORDS_QUESTIONS: TriviaQuestion[] = [
  ...RECORDS_HUMAN,
  ...RECORDS_WORLD,
  ...RECORDS_LAWS,
  ...RECORDS_OBJECTS,
];
