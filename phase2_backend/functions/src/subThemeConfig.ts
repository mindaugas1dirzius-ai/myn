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
  // Pop kultūra: 2 sodrios potemės iš esamų žymų.
  //   • "cinema"  → 🎬 Kinas ir muzika (filmai, daina, animacija);
  //   • "stories" → 📚 Herojai ir istorijos (knygos, menas, personažai, mitai, žaidimai).
  pop: {
    cinema: ["movies", "music", "cartoons"],
    stories: ["books", "art", "characters", "superheroes", "heroes", "myth", "games"],
  },
  // Geografija: 2 potemės.
  //   • "cities"  → 🏙️ Sostinės ir šalys;
  //   • "nature"  → 🏔️ Gamta ir orientyrai (kalnai, upės, ežerai, jūros, dykumos…).
  geo: {
    cities: ["capitals", "countries", "continents"],
    nature: [
      "mountains", "rivers", "lakes", "seas", "oceans",
      "deserts", "islands", "earth", "landforms", "landmarks", "records",
    ],
  },
  // Istorija: 2 potemės.
  //   • "ancient" → 🏛️ Senovės pasaulis (priešistorė, antika, viduramžiai, renesansas);
  //   • "modern"  → 🚀 Naujieji laikai ir mokslas (atradimai, išradimai, įvykiai…).
  history: {
    ancient: ["ancient", "prehistory", "medieval", "renaissance", "art"],
    modern: [
      "modern", "events", "science", "inventions",
      "people", "explorers", "exploration", "space", "landmarks",
    ],
  },
  // Technologijos: 1 potemė (NEKEISTI kodo „games").
  tech: {
    games: ["games"],
  },
  // Maistas: 3 žymėtos potemės (NEKEISTI kodų).
  food: {
    world: ["world"],
    science: ["science"],
    exotic: ["exotic"],
  },
  // Sportas: 2 potemės.
  //   • "rules"       → 🏆 Taisyklės ir technika;
  //   • "disciplines" → ⚽ Šakos ir varžybos (olimpinės, futbolas, istorija…).
  sport: {
    rules: ["rules", "equipment"],
    disciplines: [
      "sports", "identify", "olympics", "football", "history", "tennis", "basketball",
    ],
  },
  // Žmogaus kūnas: 2 žymėtos potemės + „facts" (NEKEISTI kodų).
  body: {
    brain: ["brain"],
    bones: ["bones"],
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
