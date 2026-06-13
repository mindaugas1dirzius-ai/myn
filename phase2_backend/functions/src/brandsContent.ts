/**
 * brandsContent — 🏷️ „Prekių ženklų istorijos" temos klausimų INDEKSAS.
 *
 * MAŽI FAILAI: kiekviena potemė savo faile (brandsFood.ts ir t. t.), čia tik
 * sujungiam į vieną masyvą. Tik istoriniai/įsitvirtinę faktai — JOKIOS reklamos.
 *
 * Potemės (subThemeConfig.ts „brands"):
 *   🍟 food    — Maistas ir gėrimai (ĮGYVENDINTA, 40 kl.);
 *   👟 fashion — Mada ir daiktai (ĮGYVENDINTA, 40 kl.);
 *   🚗 cars    — Automobiliai ir technika (ĮGYVENDINTA, 40 kl.);
 *   💡 names   — Vardų paslaptys (ĮGYVENDINTA, 40 kl.).
 */

import { TriviaQuestion } from "./triviaTypes";
import { BRANDS_FOOD } from "./brandsFood";
import { BRANDS_FASHION } from "./brandsFashion";
import { BRANDS_CARS } from "./brandsCars";
import { BRANDS_NAMES } from "./brandsNames";

export const BRANDS_QUESTIONS: TriviaQuestion[] = [
  ...BRANDS_FOOD,
  ...BRANDS_FASHION,
  ...BRANDS_CARS,
  ...BRANDS_NAMES,
];
