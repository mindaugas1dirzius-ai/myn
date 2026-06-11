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
import { emojiForOption } from "./themeEmoji";

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
   * KLAUSIMO KORTELĖS paveikslėlis: q.emoji (subjektas), kai NEIŠDUODA atsakymo,
   * kitaip "" (klientas rodo bendrą temos „sceną"). Žr. logiką assembleOptions.
   */
  cardEmoji?: string;
  /**
   * Po vieną emoji KIEKVIENAM variantui (ta pati tvarka kaip `options`).
   * „Viskas arba nieko": užpildoma TIK jei VISI variantai turi emoji — kitaip
   * tuščias masyvas (klientas rodo tik tekstą). Taip vienas variantas niekada
   * neišsiskiria ikonėle ir neišduoda atsakymo.
   */
  optionEmojis: string[];
}

/**
 * TEMOS ŽENKLIUKAS atsakymo mygtukams, kai NEGALIM duoti kiekvienam variantui
 * savo, unikalaus ir neišduodančio paveikslėlio. Vietoj TUŠČIŲ (be jokio
 * paveikslėlio — savininkas to nenori: „net to lapelio nebuvo") rodom VIENODĄ
 * temos ženkliuką ant VISŲ 6 mygtukų. Kadangi jis identiškas visiems, jis
 * NIEKADA neišduoda, kuris atsakymas teisingas — tad saugu net spalvų/vėliavų
 * klausimuose. Taip kiekvienas klausimas atrodo „gyvas", vientisas ir užbaigtas,
 * niekada nei tuščias, nei mišrus (vieni su, kiti be).
 */
const THEME_BADGE: Record<string, string> = {
  nature: "🍃",
  tech: "⚙️",
  geo: "🗺️",
  history: "📜",
  food: "🍽️",
  sport: "🏅",
  body: "🩺",
  pop: "🎵",
};
const DEFAULT_BADGE = "✨";

export function assembleOptions(
  q: TriviaQuestion,
  lang: Lang,
  category?: string
): AssembledQuestion {
  const content = pickContent(q, lang);
  const needDistractors = OPTIONS_PER_QUESTION - 1; // 6 → 5
  const chosen = shuffle(content.distractors).slice(0, needDistractors);
  const options = shuffle([content.correct, ...chosen]);

  // Emoji prie ATSAKYMŲ — „VISKAS ARBA NIEKO" (profesionalus, vienodas vaizdas).
  // Paveikslėlį rodom KIEKVIENAM variantui TIK kai VISI variantai turi savą,
  // UNIKALŲ ir neišduodantį paveikslėlį. Kitaip — JOKIO emoji (švarus tekstas),
  // NIEKADA „šakutės" filerio ar mišraus rinkinio (vieni su, kiti be). Klausimo
  // SUBJEKTAS lieka ant kortelės (cardEmoji), tad vaizdas vis tiek gyvas.
  // „Atskleidžiantys" emoji: spalvoti kvadratai = pati spalva = atsakymas.
  const REVEALING = new Set([
    "⬜", "⬛", "🟫", "🟦", "🟩", "🟥", "🟨", "🟧", "🟪", "🌫️",
  ]);
  // ORIENTYRAI — žinomi statiniai/vietos, kurie KORTELĖJE išduotų vietos atsakymą
  // (pvz. 🗼 → Paryžius, 🗽 → Niujorkas). Geografijoj nenaudojam jų kortelėje.
  const CARD_LANDMARKS = new Set([
    "🗼", "🗽", "🏛️", "🏰", "🏯", "🕌", "⛩️", "🗿", "🕋", "🛕",
    "⛲", "🌉", "🎡", "🎢", "🏟️", "🏝️",
  ]);
  const looked = options.map((o) => emojiForOption(o)); // emoji | undefined

  // ⭐ NAUJA SISTEMA (2026-06-11) — protinga, veikia VISIEMS klausimams be žodyno
  // pildymo po vieną. Rodom KIEKVIENAM variantui SAVĄ paveikslėlį (ten, kur yra),
  // o kur nėra — temos ženklą. Į temos ženklą (vienodą ant VISŲ) krentam TIK kai
  // paveikslėliai realiai IŠDUOTŲ teisingą atsakymą. Trys išdavimo atvejai:
  //   (1) spalvų kvadratai / regimos savybės klausimas (žr. žemiau);
  //   (2) teisingas — VIENINTELIS su paveikslėliu (kiti be) → 🦈 „Megalodonas",
  //       kiti lapukai → matosi, kuris teisingas;
  //   (3) teisingas — VIENINTELIS BE paveikslėlio (visi kiti turi) → irgi išskiria.
  // Visais kitais atvejais teisingas atsakymas „pasislepia" tarp kitų → saugu
  // rodyti įvairius, su tema susijusius paveikslėlius (būtent to prašė savininkas).
  const correctIdx = options.indexOf(content.correct);
  const correctHasEmoji = correctIdx >= 0 && !!looked[correctIdx];
  const numWithEmoji = looked.filter((e) => !!e).length;
  const numDistractorsWithEmoji = numWithEmoji - (correctHasEmoji ? 1 : 0);
  const distractorsCount = options.length - 1;

  // (1) Spalvų kvadratai variantuose — pati spalva = atsakymas.
  const anyRevealing = looked.some((e) => !!e && REVEALING.has(e));
  // (1b) Klausimas apie REGIMĄ savybę (spalvą), kur paveikslėlis ją parodytų
  //      (pvz. „kokios spalvos…", „kuris RAUDONAS vaisius?") → saugiau be jų.
  const visualQuestion =
    /(spalv|colou?r|raudon|žali|zali|gelton|mėlyn|melyn|oranžin|oranzin|violetin|rožin|rozin|rud[aąoų]|balt|juod|pilk)/i.test(
      content.question
    );
  // (1c) Klausimas apie VĖLIAVĄ („kuri šalis turi šią vėliavą?") — šalių vėliavos
  //      variantuose tiesiogiai išduotų atsakymą, tad saugiau be jų.
  const flagQuestion = /(vėliav|veliav|\bflag\b)/i.test(content.question);
  // (2) teisingas — vienintelis su paveikslėliu.
  const correctIsLonePicture =
    correctHasEmoji && numDistractorsWithEmoji === 0;
  // (3) teisingas — vienintelis be paveikslėlio.
  const correctIsLoneFallback =
    !correctHasEmoji && numDistractorsWithEmoji === distractorsCount;

  const reveals =
    anyRevealing ||
    visualQuestion ||
    flagQuestion ||
    correctIsLonePicture ||
    correctIsLoneFallback;

  // ── KLAUSIMO KORTELĖS paveikslėlis (cardEmoji) ─────────────────────────────
  // Rodom q.emoji — klausimo SUBJEKTĄ (pvz. 🕷️ prie „kiek kojų turi voras?",
  // kur atsakymas „8") — TIK kai jis NEIŠDUODA atsakymo. Kitaip grąžinam "" ir
  // klientas parenka bendrą temos „sceną" (kaip seniau). Į sceną krentam, kai:
  //   • q.emoji tuščias;
  //   • spalvos kvadratas (REVEALING) arba regimos savybės/spalvos klausimas;
  //   • q.emoji SUTAMPA su kurio nors varianto emoji (looked) → identifikacinis
  //     klausimas, kur subjektas = atsakymas („kuris gyvūnas…" → 🦇 = atsakymas);
  //   • vėliava (🇫🇷, 🇯🇵…) ar žinomas orientyras (🗼, 🗽…) → geografijoj išduotų
  //     vietą (sostinę/šalį).
  const qEmoji = q.emoji ?? "";
  const isFlagEmoji = /[\u{1F1E6}-\u{1F1FF}]/u.test(qEmoji);
  const cardEmoji =
    qEmoji &&
    !REVEALING.has(qEmoji) &&
    !visualQuestion &&
    !isFlagEmoji &&
    !CARD_LANDMARKS.has(qEmoji) &&
    !looked.includes(qEmoji)
      ? qEmoji
      : "";

  // SAVI PAVEIKSLĖLIAI vs. TEMOS ŽENKLIUKAS — niekada tuščia, niekada mišru.
  // Kiekvienam variantui SAVĄ, unikalų emoji rodom TIK kai VISI turi (allHaveEmoji),
  // VISI skirtingi (allDistinct) ir niekas neišduoda atsakymo (!reveals). KITAIP —
  // ne tuščia (kaip seniau), o VIENODAS temos ženkliukas ant VISŲ 6 (pvz. 🍃/🗺️/⚙️):
  // atrodo vientisai, niekada nelieka „be jokio paveikslėlio", o kadangi identiškas
  // visiems — neišduoda teisingo net spalvų/vėliavų klausimuose.
  const allHaveEmoji = numWithEmoji === options.length;
  const allDistinct = new Set(looked).size === looked.length;
  const realRow = allHaveEmoji && allDistinct && !reveals;
  const badge = THEME_BADGE[category ?? "nature"] ?? DEFAULT_BADGE;
  const optionEmojis: string[] = realRow
    ? (looked as string[])
    : options.map(() => badge);

  return {
    display: content.question,
    options,
    answer: content.correct,
    explanation: content.explanation,
    emoji: q.emoji,
    cardEmoji,
    optionEmojis,
  };
}
