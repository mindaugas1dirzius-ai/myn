/**
 * generateOptions — 6 atsakymų variantų generatorius (1 teisingas + 5 klaidingi).
 *
 * Naudojamas SERVERYJE (startGame). Telefonas gauna gatavą sumaišytą masyvą.
 * Universalus VISIEMS režimams (Etapas 2): dirba pagal `answer`.
 *
 * Parametrai:
 *  - answer: teisingas atsakymas
 *  - trap?:  viliojantis klaidingas (veiksmų eilės klaida) — jei yra,
 *            GARANTUOTAI įdedamas tarp 6 (Mix/skliaustai/algebra spąstai)
 *  - neighbors?: operacijos-specifiniai „kaimynai" (tik grynam ×/÷)
 *
 * Apsaugos (DIZAINAS.md, 4 sprendimas):
 *  - jokio dublikato, jokio klaidingo == teisingam
 *  - tik teigiami sveiki, skaitmenų sukeitimas tik kai answer >= 10
 *  - visada lygiai 6, tikras Fisher-Yates
 */

export function shuffle<T>(arr: T[]): T[] {
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}

export function generateOptions(
  answer: number,
  opts?: { trap?: number; neighbors?: number[] }
): number[] {
  const set = new Set<number>([answer]); // 1. teisingas
  const candidates: number[] = [];

  // SPĄSTAS pirmas — kad garantuotai patektų tarp 6 (jei tinkamas).
  if (opts?.trap !== undefined) candidates.push(opts.trap);

  // Operacijos-specifiniai kaimynai (tik ×/÷ — paduoda kviečiantis).
  if (opts?.neighbors) candidates.push(...opts.neighbors);

  // Skaitmenų sukeitimas — tik kai answer >= 10
  if (answer >= 10) {
    candidates.push(parseInt(String(answer).split("").reverse().join(""), 10));
  }

  // Bendros žmogiškos paklaidos — visiems režimams
  candidates.push(answer + 1, answer - 1, answer + 10, answer - 10, answer + 2, answer - 2);

  for (const c of candidates) {
    if (set.size === 6) break;
    if (c > 0 && c !== answer && Number.isInteger(c)) set.add(c);
  }

  // Saugus užpildymas (garantuotai baigiasi)
  let fallback = 1;
  while (set.size < 6) {
    set.add(answer + fallback);
    if (set.size < 6 && answer - fallback > 0) set.add(answer - fallback);
    fallback++;
  }

  return shuffle(Array.from(set));
}
