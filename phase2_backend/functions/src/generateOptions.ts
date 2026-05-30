/**
 * generateOptions — 6 atsakymų variantų generatorius (1 teisingas + 5 panašūs klaidingi).
 *
 * Naudojamas SERVERYJE (startGame metu). Telefonas gauna gatavą sumaišytą masyvą.
 * Veikia visiems 4 veiksmams (+, −, ×, ÷).
 *
 * Apsaugos (sutarta dizaine, žr. DIZAINAS.md, 4 sprendimas):
 *  - jokio dublikato ir jokio klaidingo == teisingam (Set + filtras)
 *  - tik teigiami sveiki skaičiai (c > 0, Number.isInteger)
 *  - skaitmenų sukeitimas tik kai answer >= 10
 *  - visada lygiai 6 variantai (saugus užpildymas, garantuotai baigiasi)
 *  - tikras Fisher-Yates maišymas (NE sort(()=>Math.random()-0.5))
 */

export function shuffle<T>(arr: T[]): T[] {
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}

export function generateOptions(
  a: number,
  b: number,
  answer: number,
  op: "+" | "-" | "*" | "/"
): number[] {
  const set = new Set<number>([answer]); // 1. teisingas atsakymas
  const candidates: number[] = [];

  // Operacijos-specifiniai „kaimyniniai" klaidingi (artimi, tikroviški)
  if (op === "*") {
    candidates.push((a + 1) * b, (a - 1) * b, a * (b + 1), a * (b - 1));
  }
  if (op === "/") {
    candidates.push(b);          // painioja daliklį su rezultatu (artima)
    candidates.push(answer + 2); // dar vienas artimas
  }

  // Skaitmenų sukeitimas — tik kai answer >= 10
  if (answer >= 10) {
    candidates.push(parseInt(String(answer).split("").reverse().join(""), 10));
  }

  // Bendros žmogiškos paklaidos — visiems veiksmams
  candidates.push(answer + 1, answer - 1, answer + 10, answer - 10, answer + 2, answer - 2);

  // Pildom Set unikaliais, teigiamais, sveikais, ne teisingais
  for (const c of candidates) {
    if (set.size === 6) break;
    if (c > 0 && c !== answer && Number.isInteger(c)) set.add(c);
  }

  // Saugus užpildymas (garantuotai baigiasi: answer+fallback auga be galo)
  let fallback = 1;
  while (set.size < 6) {
    set.add(answer + fallback);
    if (set.size < 6 && answer - fallback > 0) set.add(answer - fallback);
    fallback++;
  }

  return shuffle(Array.from(set)); // tikras Fisher-Yates
}
