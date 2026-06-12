/**
 * cosmosContent — 🌌 „Kosmosas" temos klausimų INDEKSAS.
 *
 * MAŽI FAILAI: kiekviena potemė gyvena savo faile (cosmosPlanets.ts ir t. t.),
 * o čia tik sujungiam į vieną masyvą, kurį naudoja triviaRegistry. Pridedant naują
 * potemę — 1 importas + 1 narys masyve (failas lieka mažas ir lengvai taisomas).
 *
 * Potemės (subThemeConfig.ts „cosmos"):
 *   🪐 planets   — Planetos ir Saulės sistema (ĮGYVENDINTA, 40 kl.);
 *   🚀 spacerace — Kosmoso lenktynės (40 kl., PERKELTA iš tech „space" —
 *                  sujungiama triviaRegistry.ts, NE čia, kad nekeistume techContent);
 *   🧑‍🚀 astronauts — Astronautai ir misijos (Greitai);
 *   🔭 universe  — Visata ir žvaigždės (Greitai);
 *   🛰️ rockets   — Raketos ir tyrimai (Greitai).
 */

import { TriviaQuestion } from "./triviaTypes";
import { COSMOS_PLANETS } from "./cosmosPlanets";
import { COSMOS_ASTRONAUTS } from "./cosmosAstronauts";

export const COSMOS_QUESTIONS: TriviaQuestion[] = [
  ...COSMOS_PLANETS,
  ...COSMOS_ASTRONAUTS,
  // ...COSMOS_UNIVERSE, ...COSMOS_ROCKETS — pildoma partijomis.
];
