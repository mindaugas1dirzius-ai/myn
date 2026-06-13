/**
 * recordsContent — 📏 „Rekordai ir keistenybės" temos klausimų INDEKSAS.
 *
 * MAŽI FAILAI: kiekviena potemė savo faile (recordsHuman.ts ir t. t.), čia tik
 * sujungiam į vieną masyvą. Gyvūnų rekordai — GAMTOS temoje (čia nekartojama).
 *
 * Potemės (subThemeConfig.ts „records"):
 *   🏆 human   — Žmonių rekordai (ĮGYVENDINTA, 40 kl.);
 *   🌍 world   — Pasaulio rekordai (ĮGYVENDINTA, 40 kl.);
 *   🤪 laws    — Keisti įstatymai ir tradicijos (Greitai);
 *   💎 objects — Daiktų ir maisto rekordai (Greitai).
 */

import { TriviaQuestion } from "./triviaTypes";
import { RECORDS_HUMAN } from "./recordsHuman";
import { RECORDS_WORLD } from "./recordsWorld";

export const RECORDS_QUESTIONS: TriviaQuestion[] = [
  ...RECORDS_HUMAN,
  ...RECORDS_WORLD,
  // ...RECORDS_LAWS, ...RECORDS_OBJECTS — pildoma partijomis.
];
