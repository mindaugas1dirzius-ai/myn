/**
 * subThemeConfig — bendrų trivijos TEMŲ potemės (subthemes).
 *
 * KODĖL: Gamta turi savo potemes per startNatureGame. Visos kitos temos
 * (pop/geo/history/tech/food/sport/body) eina per BENDRĄ startTriviaGame.
 * Kad ir jos galėtų turėti potemes (pvz. Žmogaus kūnas → Smegenys, Kaulai...),
 * čia laikom žemėlapį „tema → potemių kodų sąrašas".
 *
 * MODELIS (suderinamumas, nulis regresijos):
 *   - „facts" (NUMATYTOJI potemė) = klausimai, kurių `subTheme` NĖRA šiame
 *     sąraše. T.y. esami klausimai (organs/skeleton/blood...) automatiškai
 *     lieka „faktuose" — jų KEISTI NEREIKIA. Mode: `<tema>_<lygis>` (2 dalys).
 *   - Nauja potemė = klausimai su `subTheme === <kodas>`. Mode:
 *     `<tema>_<potemė>_<lygis>` (3 dalys). Atskira Top 10 lentelė.
 *   - „mix" = traukia iš VISŲ tos temos klausimų (ne klausimo žyma, o režimas).
 *   - Tuščias sąrašas = tema dar be potemių (veikia kaip seniau: viena „facts").
 *
 * NIEKADA nekeičiam jau paskelbtų kodų (sugadintų Top 10 lenteles).
 */

import { GenericTriviaCategory } from "./triviaRegistry";

/** Tema → jos NAUJŲ potemių kodų sąrašas (be „facts" ir „mix" — jie numanomi). */
export const TRIVIA_SUBTHEMES: Record<GenericTriviaCategory, string[]> = {
  pop: [],
  geo: [],
  history: [],
  // Technologijos: 1 potemė. „games" = kompiuteriniai žaidimai (istorija/faktai).
  // „facts" = bendri tech/mokslo klausimai. „mix" = visi.
  tech: ["games"],
  // Maistas: 3 žymėtos potemės (be „facts" — visi klausimai pažymėti).
  //   • "world"   → 🍕 Pasaulio virtuvės (kilmė + virtuvės);
  //   • "science" → 🧪 Maisto mokslas (chemija + ingredientai);
  //   • "exotic"  → 🌶️ Egzotiškas maistas (neįprasti patiekalai, gėrimai).
  food: ["world", "science", "exotic"],
  sport: [],
  // Žmogaus kūnas: 2 žymėtos potemės + „facts" katch-all.
  //   • "brain"  → 🧠 Smegenų paslaptys (iliuzijos, sapnai, atmintis);
  //   • "bones"  → 💪 Raumenys ir fitnesas (kaulai, ištvermė);
  //   • "facts"  → 🧬 Biologiniai kuriozai = VISI kiti (širdis, organai, juslės,
  //     fiziologija, anatomija) — todėl „heart"/„weird" ČIA nebėra (kad širdies
  //     klausimai patektų į „facts" biologijos rinkinį, o ne į tuščią potemę).
  body: ["brain", "bones"],
};

/** Ar tema turi bent vieną potemę (klientui — rodyti potemių parinkiklį)? */
export function hasSubThemes(category: GenericTriviaCategory): boolean {
  return (TRIVIA_SUBTHEMES[category]?.length ?? 0) > 0;
}

/** Ar duotas potemės kodas priklauso tai temai? */
export function isSubThemeOf(
  category: GenericTriviaCategory,
  sub: string
): boolean {
  return (TRIVIA_SUBTHEMES[category] ?? []).includes(sub);
}

/**
 * Parenka tos temos+potemės klausimų baseiną iš viso temos masyvo.
 *   - sub === "facts" → klausimai, kurių subTheme NĖRA potemių sąraše;
 *   - sub === "mix"   → visi temos klausimai;
 *   - kitaip          → tik tos potemės klausimai (subTheme === sub).
 */
import { TriviaQuestion } from "./triviaTypes";
export function poolForSubTheme(
  category: GenericTriviaCategory,
  all: TriviaQuestion[],
  sub: string
): TriviaQuestion[] {
  if (sub === "mix") return all;
  const subs = TRIVIA_SUBTHEMES[category] ?? [];
  if (sub === "facts") return all.filter((q) => !subs.includes(q.subTheme));
  return all.filter((q) => q.subTheme === sub);
}
