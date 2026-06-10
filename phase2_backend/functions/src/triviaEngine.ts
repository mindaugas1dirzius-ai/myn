/**
 * triviaEngine — gryna trivijos logika (jokio Firestore, jokios būsenos).
 *
 * Du darbai:
 *  1) pickQuestions — parenka N klausimų pagal lygį, vengdamas neseniai matytų
 *     (recentIds), kad neatsibostų. Jei rinkinys mažas — leidžia kartotis.
 *  2) assembleOptions — iš klausimo padaro 6 variantus (1 teisingas + 5
 *     atsitiktiniai distractors), sumaišytus (Fisher-Yates). Parenka kalbą,
 *     su EN atsarga, jei vertimo dar nėra.
 *
 * Saugumas: ČIA atsakymas dar matomas (tai serverio pusė). Klientui jis
 * keliaus taip pat kaip matematikoj (variantas C), o taškus skaičiuoja
 * submitScore pagal LAIKĄ — tad atsakymo žinojimas sukčiui nieko neduoda.
 */

import { Level, OPTIONS_PER_QUESTION } from "./gameConfig";
import {
  TriviaQuestion,
  LocalizedContent,
  Lang,
  DEFAULT_LANG,
  NatureTopic,
  DEFAULT_TOPIC,
} from "./triviaTypes";
import { emojiForOption } from "./natureEmoji";

/** Fisher-Yates — teisingas, nešališkas masyvo maišymas (kaip generateOptions). */
function shuffle<T>(arr: T[]): T[] {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

/**
 * Sulieja naujus ID su ankstesne atmintimi: NAUJAUSI pirma, BE dublikatų,
 * apkarpyta iki `keep`. Naudojama ir žaidimo PRADŽIOJE (kad išėjus/grįžus
 * gautum kitus klausimus), ir submitScore pabaigoje (dedup → tas pats ID
 * neužima dviejų vietų lange, net jei įrašoma du kartus).
 */
export function mergeRecent(
  newIds: string[],
  prevRecent: string[],
  keep: number
): string[] {
  const seen = new Set<string>();
  const out: string[] = [];
  for (const id of [...newIds, ...prevRecent]) {
    if (!seen.has(id)) {
      seen.add(id);
      out.push(id);
    }
  }
  return out.slice(0, keep);
}

/** Parenka kalbos turinį; jei tos kalbos nėra — krenta į EN. */
export function pickContent(q: TriviaQuestion, lang: Lang): LocalizedContent {
  return q.translations[lang] ?? q.translations[DEFAULT_LANG]!;
}

/** Klausimo potemė su atsarga: jei `topic` nenurodytas → DEFAULT_TOPIC. */
export function topicOf(q: TriviaQuestion): NatureTopic {
  return q.topic ?? DEFAULT_TOPIC;
}

/**
 * Parenka `count` klausimų duotam lygiui (ir potemei).
 *  - pirmiausia bando NEMATYTUS (id ne recentIds) ir nesikartojančius;
 *  - jei tokių nepakanka (mažas rinkinys) — papildo likusiais (be dublio žaidime,
 *    o jei vis tiek maža — leidžia kartotis, kad žaidimas visada turėtų N klausimų).
 *
 * `topic` filtras: jei nenurodytas arba "mix" — imama iš VISŲ potemių; kitaip
 * tik tos potemės klausimai (DEFAULT_TOPIC, jei klausimas neturi `topic`).
 */
/**
 * Papildoma „švieži" atsarga virš `count`: kiek klausimų DAR turi likti
 * neištrintų iš atminties, kad fresh rinkinys turėtų iš ko maišytis (kitaip
 * fresh būtų lygiai `count` ir kiekviena partija būtų ta pati). ~5 → įvairovė.
 */
const FRESH_MARGIN = 5;

export function pickQuestions(
  all: TriviaQuestion[],
  level: Level,
  recentIds: string[],
  count: number,
  topic?: NatureTopic | "mix"
): TriviaQuestion[] {
  const pool = all.filter(
    (q) =>
      q.level === level &&
      (topic === undefined || topic === "mix" || topicOf(q) === topic)
  );
  if (pool.length === 0) return [];

  // LANKSTUS ATMINTIES LANGAS: niekada nevengiam tiek klausimų, kad neliktų
  // bent `count` + atsarga ŠVIEŽIŲ. Mažam pool'ui (pvz. 51) langas automatiškai
  // susitraukia (51 − 10 − 5 = vengiam max 36 naujausių → ≥15 šviežių visada).
  // `recentIds` ateina naujausi-pirma, tad imam tik naujausią dalį.
  const maxAvoid = Math.max(0, pool.length - count - FRESH_MARGIN);
  const recent = new Set(recentIds.slice(0, maxAvoid));

  const fresh = shuffle(pool.filter((q) => !recent.has(q.id)));
  const seen = shuffle(pool.filter((q) => recent.has(q.id)));
  // Eilė: pirma nematyti, paskui neseniai matyti.
  const ordered = [...fresh, ...seen];

  const result: TriviaQuestion[] = [];
  // 1-as ratas: be pasikartojimo.
  for (const q of ordered) {
    if (result.length >= count) break;
    result.push(q);
  }
  // Jei rinkinys per mažas N langelių — leidžiam kartotis (geriau nei <N klausimų).
  while (result.length < count) {
    result.push(ordered[result.length % ordered.length]);
  }
  return result;
}

/** Vieno klausimo paruošimas žaidimui (kalba + 6 sumaišyti variantai). */
export interface AssembledQuestion {
  display: string;       // klausimo tekstas (pasirinkta kalba)
  options: string[];     // 6 variantai, sumaišyti
  answer: string;        // teisingas (sutaps su vienu iš options)
  explanation?: string;  // kodėl teisingas (rodoma pabaigoje)
  emoji?: string;        // iliustracinis emoji (vietoj nuotraukos)
  /**
   * Po vieną emoji KIEKVIENAM variantui (ta pati tvarka kaip `options`).
   * „Viskas arba nieko": užpildoma TIK jei VISI variantai turi emoji — kitaip
   * tuščias masyvas (klientas rodo tik tekstą). Taip vienas variantas niekada
   * neišsiskiria ikonėle ir neišduoda atsakymo.
   */
  optionEmojis: string[];
}

export function assembleOptions(
  q: TriviaQuestion,
  lang: Lang
): AssembledQuestion {
  const content = pickContent(q, lang);
  const needDistractors = OPTIONS_PER_QUESTION - 1; // 6 → 5
  const chosen = shuffle(content.distractors).slice(0, needDistractors);
  const options = shuffle([content.correct, ...chosen]);

  // Per-variantą emoji. DVI sąlygos (kitaip rodom tik tekstą):
  //  1) VISKAS-ARBA-NIEKO: jei bent vienas variantas neturi emoji — nerodom nė
  //     vieno (kad vienas neišsiskirtų ir neišduotų atsakymo).
  //  2) VISI SKIRTINGI: jei keli variantai gautų TĄ PATĮ emoji (pvz. 6 paukščiai
  //     visi → 🐦), tai atrodo kaip nesąmonė ir nieko nepasako — tada irgi
  //     rodom tik tekstą. Emoji rodom TIK kai kiekvienas variantas turi savo,
  //     unikalų, prasmingą paveikslėlį (pvz. 🦁 🦅 🐸 🦈 🐍 🐝).
  const looked = options.map((o) => emojiForOption(o));
  const allHaveEmoji = looked.every((e) => !!e);
  const allDistinct = new Set(looked).size === looked.length;
  const optionEmojis =
    allHaveEmoji && allDistinct ? (looked as string[]) : [];

  return {
    display: content.question,
    options,
    answer: content.correct,
    explanation: content.explanation,
    emoji: q.emoji,
    optionEmojis,
  };
}
