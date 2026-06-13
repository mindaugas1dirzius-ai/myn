/**
 * subThemeConfig — bendrų trivijos TEMŲ potemės (subthemes).
 *
 * KODĖL: Gamta turi savo potemes per startNatureGame. Visos kitos temos
 * (pop/geo/history/tech/food/sport/body) eina per BENDRĄ startTriviaGame.
 * Kad ir jos galėtų turėti potemes (pvz. Žmogaus kūnas → Smegenys, Kaulai...),
 * čia laikom žemėlapį „tema → potemė → tos potemės klausimų žymų (subTheme) sąrašas".
 *
 * STRUKTŪRA (2026-06-11 atnaujinimas): viena POTEMĖ (žaidėjo pasirinkimas, pvz.
 * „Sostinės ir šalys") gali apjungti KELIAS smulkias `subTheme` žymas (capitals,
 * countries, continents). Taip iš jau turimų ~120 klausimų temoje sudėliojam 2–3
 * sodrias potemes BE naujo turinio rašymo — tik sugrupuojam esamas žymas.
 *
 * MODELIS (suderinamumas, nulis regresijos):
 *   - „facts" (NUMATYTOJI potemė) = klausimai, kurių `subTheme` NĖRA NĖ VIENAME
 *     šios temos potemės žymų sąraše. Mode: `<tema>_<lygis>` (2 dalys).
 *   - Įvardyta potemė = klausimai, kurių `subTheme` yra tos potemės žymų sąraše.
 *     Mode: `<tema>_<potemė>_<lygis>` (3 dalys). Atskira Top 10 lentelė.
 *   - „mix" = traukia iš VISŲ tos temos klausimų (ne klausimo žyma, o režimas).
 *   - Tuščias žemėlapis = tema dar be potemių (veikia kaip seniau: viena „facts").
 *
 * NIEKADA nekeičiam jau PASKELBTŲ potemių KODŲ (sugadintų Top 10 lenteles):
 * games / world / science / exotic / brain / bones lieka kaip buvę.
 */

import { GenericTriviaCategory } from "./triviaRegistry";

/**
 * Tema → { potemės KODAS → tos potemės klausimų `subTheme` žymos }.
 * Kodas naudojamas `mode` eilutėj ir Top 10 raktuose (stabilus!); žymų sąrašas —
 * vidinis sugrupavimas, kurį galima koreguoti nekeičiant Top 10.
 */
export const TRIVIA_SUBTHEMES: Record<
  GenericTriviaCategory,
  Record<string, string[]>
> = {
  // Pop kultūra: 4 potemės pagal žaidėjo planą (2026-06-12).
  //   • "films"   → 🎥 Filmai (movies + cartoons);
  //   • "tv"      → 📺 TV ir serialai (nauja žyma "tv");
  //   • "music"   → 🎵 Muzika;
  //   • "stories" → 📚 Herojai ir istorijos (knygos, menas, personažai, mitai, žaidimai).
  // Pastaba: senas kodas "cinema" pakeistas testavimo fazėje (Top 10 dar tuščias).
  pop: {
    films: ["movies", "cartoons"],
    tv: ["tv"],
    music: ["music"],
    stories: ["books", "art", "characters", "superheroes", "heroes", "myth", "games"],
  },
  // Geografija: 4 potemės pagal žaidėjo planą.
  //   • "nature"    → 🏞️ Gamtos stebuklai ir anomalijos (ATVIRA — esami gamtos klausimai);
  //   • "megapolis" → 🏙️ Megapoliai ir urbanistinės paslaptys (Greitai — rašomi nauji);
  //   • "culture"   → 🗼 Pasaulio kultūra ir festivaliai (Greitai — rašomi nauji);
  //   • "paradox"   → 🗺️ Geografiniai paradoksai ir žemėlapiai (Greitai — rašomi nauji).
  // Esami capitals/countries/continents lieka „Mix" sraute (be atskiros potemės).
  geo: {
    nature: [
      "mountains", "rivers", "lakes", "seas", "oceans",
      "deserts", "islands", "earth", "landforms", "landmarks", "records",
    ],
    megapolis: ["megacity", "architecture", "urban", "lostcities"],
    culture: ["culture", "festivals", "traditions"],
    paradox: ["paradox", "borders", "maps", "timezones", "enclaves"],
  },
  // Istorija: 3 potemės (kiekviena su savo turtingu rinkiniu po 40 klausimų).
  //   • "engineering" → 🗿 Senovės civilizacijų inžinerija;
  //   • "rulers"      → 👑 Ekscentriški valdovai;
  //   • "myths"       → 🔍 Didieji istoriniai mitai.
  // Senesni žymenys (ancient/modern/...) lieka „facts" puode (bendri klausimai).
  history: {
    engineering: ["engineering"],
    rulers: ["rulers"],
    myths: ["myths"],
  },
  // Technologijos: 2 potemės (NEKEISTI kodų „games"/„myths").
  //   • "myths" → 💻 Tech mitai ir išradimai (2026-06-12).
  //   Pastaba: „space" potemė PERKELTA į Kosmoso temą („spacerace") 2026-06-13 —
  //   kad kosmosas nebūtų dviejose temose. Perskirstoma triviaRegistry.ts.
  tech: {
    games: ["games"],
    myths: ["myths"],
  },
  // Maistas: 4 žymėtos potemės (NEKEISTI kodų).
  //   • "production" → 🍳 Gamybos paslaptys (2026-06-12).
  food: {
    world: ["world"],
    science: ["science"],
    exotic: ["exotic"],
    production: ["production"],
  },
  // Sportas: 6 potemės pagal žaidėjo planą (2026-06-12).
  //   • "racing"     → 🏎️ Lenktynės;
  //   • "gymnastics" → 🤸 Gimnastika;
  //   • "olympics"   → 🏅 Olimpiada (žyma perkelta IŠ disciplines);
  //   • "martial"    → 🥋 Kovos menai;
  //   • "rules"      → 🏆 Taisyklės ir technika;
  //   • "disciplines"→ ⚽ Šakos ir varžybos.
  sport: {
    racing: ["racing"],
    gymnastics: ["gymnastics"],
    olympics: ["olympics"],
    martial: ["martial"],
    rules: ["rules", "equipment"],
    disciplines: [
      "sports", "identify", "football", "history", "tennis", "basketball",
    ],
  },
  // Žmogaus kūnas: 2 žymėtos potemės + „facts" (NEKEISTI kodų).
  body: {
    brain: ["brain"],
    bones: ["bones"],
  },
  // Kosmosas: 4 potemės (2026-06-13). Visi klausimai turi vieną šių žymų, tad
  // „facts" puodas tuščias — klientas rodo 4 potemes + „Mix" (be „facts" kortelės).
  //   🪐 planets — Planetos ir Saulės sistema (ĮGYVENDINTA);
  //   🧑‍🚀 astronauts / 🔭 universe / 🛰️ rockets — pildoma partijomis (Greitai).
  cosmos: {
    planets: ["planets"],
    spacerace: ["spacerace"], // perkelta iš tech „space" (2026-06-13)
    astronauts: ["astronauts"],
    universe: ["universe"],
    rockets: ["rockets"],
  },
  // Mitologija: 4 potemės (2026-06-13). SENOVĖS mitai/legendos.
  //   ⚡ greek (graikų+romėnų, ĮGYVENDINTA) · 🔨 norse · 🐫 egypt · 🐉 creatures (Greitai).
  mythology: {
    greek: ["greek"],
    norse: ["norse"],
    egypt: ["egypt"],
    creatures: ["creatures"],
  },
};

/** Ar tema turi bent vieną potemę (klientui — rodyti potemių parinkiklį)? */
export function hasSubThemes(category: GenericTriviaCategory): boolean {
  return Object.keys(TRIVIA_SUBTHEMES[category] ?? {}).length > 0;
}

/** Ar duotas potemės KODAS priklauso tai temai? */
export function isSubThemeOf(
  category: GenericTriviaCategory,
  sub: string
): boolean {
  return Object.prototype.hasOwnProperty.call(
    TRIVIA_SUBTHEMES[category] ?? {},
    sub
  );
}

/**
 * Parenka tos temos+potemės klausimų baseiną iš viso temos masyvo.
 *   - sub === "mix"   → visi temos klausimai;
 *   - sub === "facts" → klausimai, kurių subTheme NĖRA NĖ VIENOJE potemėje;
 *   - kitaip          → klausimai, kurių subTheme yra tos potemės žymų sąraše.
 */
import { TriviaQuestion } from "./triviaTypes";
export function poolForSubTheme(
  category: GenericTriviaCategory,
  all: TriviaQuestion[],
  sub: string
): TriviaQuestion[] {
  if (sub === "mix") return all;
  const map = TRIVIA_SUBTHEMES[category] ?? {};
  if (sub === "facts") {
    const tagged = new Set<string>(Object.values(map).flat());
    return all.filter((q) => !tagged.has(q.subTheme));
  }
  const tags = map[sub];
  if (!tags || tags.length === 0) return [];
  const tagSet = new Set(tags);
  return all.filter((q) => tagSet.has(q.subTheme));
}
