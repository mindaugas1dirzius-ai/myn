/**
 * mythologyContent — 🏺 „Mitologija ir legendos" temos klausimų INDEKSAS.
 *
 * MAŽI FAILAI: kiekviena potemė savo faile (mythologyGreek.ts ir t. t.), čia tik
 * sujungiam į vieną masyvą, kurį naudoja triviaRegistry. SAUGA: tik SENOVĖS mitai
 * ir legendos — gyvų religijų neliečiam.
 *
 * Potemės (subThemeConfig.ts „mythology"):
 *   ⚡ greek     — Graikų ir romėnų mitai (ĮGYVENDINTA, 40 kl.);
 *   🔨 norse     — Šiaurės mitai (Greitai);
 *   🐫 egypt     — Egiptas ir Rytai (Greitai);
 *   🐉 creatures — Būtybės ir legendos (Greitai).
 */

import { TriviaQuestion } from "./triviaTypes";
import { MYTHOLOGY_GREEK } from "./mythologyGreek";
import { MYTHOLOGY_NORSE } from "./mythologyNorse";

export const MYTHOLOGY_QUESTIONS: TriviaQuestion[] = [
  ...MYTHOLOGY_GREEK,
  ...MYTHOLOGY_NORSE,
  // ...MYTHOLOGY_EGYPT, ...MYTHOLOGY_CREATURES — pildoma partijomis.
];
