/**
 * questionRegistry — VIENAS registras visiems žaidimo režimams (Etapas 2).
 *
 * Kiekviena "šeima" (add/sub/mul/div/mix/...) = funkcija (level) => GenQuestion.
 * Pridėti naują temą = pridėti vieną įrašą čia. Jokio dubliavimo, jokio eval.
 *
 * GenQuestion:
 *  - display: ką matys žaidėjas ("7+3×4")
 *  - answer:  teisingas (serveris pats apskaičiuoja kode)
 *  - trap?:   viliojantis klaidingas (pvz. veiksmų eilės klaida) — įdedamas
 *             į 6 variantus, jei yra.
 */

import { Level } from "./gameConfig";

export interface GenQuestion {
  display: string;
  answer: number;
  trap?: number; // neprivalomas spąstas (Mix/skliaustai/algebra)
  neighbors?: number[]; // papildomi „gundantys" variantai (pvz. kaimyniniai x)
}

function rnd(min: number, max: number): number {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

// --- Skaičių rėžiai pagal lygį (bendri, kad nesidubliuotų) ---
function addRange(level: Level): [number, number] {
  switch (level) {
    case "lengvas": return [rnd(1, 9), rnd(1, 9)];
    case "vidutinis": return [rnd(10, 99), rnd(1, 9)];
    case "sunkus": return [rnd(10, 99), rnd(10, 99)];
    case "ekstremalus": return [rnd(100, 999), rnd(10, 99)];
  }
}

// Daugyba/dalyba ribojama nedidelių skaičių — tad anksčiau pool'as buvo
// per mažas ir klausimai kartojosi. Praplėsta įvairovei IŠLAIKANT aiškią
// sunkumo tvarką (kiekvienas lygis sunkesnis už ankstesnį):
//   lengvas    [2..9]×[2..9]  = 64 deriniai (pilna lentelė iki 9 — vis tiek lengva)
//   vidutinis  [2..12]×[2..12] = 144 deriniai (lentelė iki 12)
//   sunkus     [11..25]×[2..12] = 165 deriniai (dviženklis × lentelė, didesnės sandaugos)
//   ekstremalus [12..50]×[6..19] = 546 deriniai (V3)
function mulRange(level: Level): [number, number] {
  switch (level) {
    case "lengvas": return [rnd(2, 9), rnd(2, 9)];
    case "vidutinis": return [rnd(2, 12), rnd(2, 12)];
    case "sunkus": return [rnd(11, 25), rnd(2, 12)];
    case "ekstremalus": return [rnd(12, 50), rnd(6, 19)]; // V3 praplėstas
  }
}

// --- Baziniai 4 veiksmai (perkelti iš generateQuestion) ---
function genAdd(level: Level): GenQuestion {
  const [a, b] = addRange(level);
  return { display: `${a}+${b}`, answer: a + b };
}

function genSub(level: Level): GenQuestion {
  const [x, y] = addRange(level); // atvirkštinė → rezultatas >= 0
  return { display: `${x + y}−${y}`, answer: x };
}

function genMul(level: Level): GenQuestion {
  const [a, b] = mulRange(level);
  return { display: `${a}×${b}`, answer: a * b };
}

function genDiv(level: Level): GenQuestion {
  const [x, y] = mulRange(level); // atvirkštinė → sveika
  return { display: `${x * y}÷${y}`, answer: x };
}

// --- MIX BLITZ (naujas, Etapas 2) ---
function genMix(level: Level): GenQuestion {
  switch (level) {
    case "lengvas":
    case "vidutinis": {
      // Vieno veiksmo miksas (atsitiktinė operacija).
      const ops = [genAdd, genSub, genMul, genDiv];
      const lvl = level === "lengvas" ? "lengvas" : "vidutinis";
      return ops[rnd(0, 3)](lvl);
    }
    case "sunkus": {
      // 2 veiksmai be skliaustų — veiksmų eilės tvarkos spąstai.
      if (Math.random() < 0.5) {
        // A + B×C  (skubantis sudės A+B → spąstas)
        const a = rnd(10, 50), b = rnd(2, 9), c = rnd(2, 9);
        return {
          display: `${a}+${b}×${c}`,
          answer: a + b * c,
          trap: (a + b) * c, // tipinė klaida
        };
      } else {
        // A×B − C (C < A×B, kad rezultatas teigiamas)
        const a = rnd(2, 12), b = rnd(2, 9);
        const product = a * b;
        const c = rnd(1, product - 1);
        return { display: `${a}×${b}−${c}`, answer: product - c };
      }
    }
    case "ekstremalus": {
      // 3 veiksmai: A×B + C÷D (C÷D garantuotai sveika).
      const a = rnd(3, 12), b = rnd(2, 9);
      const d = rnd(2, 9), q = rnd(2, 12);
      const c = d * q; // → c/d = q (sveika)
      // Spąstas: skubantis padaugina A×B, prideda C, pamiršta dalybą → (a*b+c).
      return {
        display: `${a}×${b}+${c}÷${d}`,
        answer: a * b + q,
        trap: a * b + c, // tipinė klaida: nepadalino
      };
    }
  }
}

// --- SKLIAUSTŲ LABIRINTAS (skliaustai keičia veiksmų eilę) ---
function genBrackets(level: Level): GenQuestion {
  switch (level) {
    case "lengvas": {
      // (A+B)×C arba (A−B)×C, maži skaičiai. Spąstas: standartinė eilė.
      const a = rnd(2, 9), b = rnd(1, 5), c = rnd(2, 5);
      if (Math.random() < 0.5) {
        return { display: `(${a}+${b})×${c}`, answer: (a + b) * c, trap: a + b * c };
      }
      const big = a + b; // (big−b)×c, rezultatas teigiamas
      return { display: `(${big}−${b})×${c}`, answer: a * c, trap: big - b * c };
    }
    case "vidutinis": {
      // A×(B−C) arba A+(B÷C) (dalyba sveika). Spąstas: be skliaustų.
      if (Math.random() < 0.5) {
        const a = rnd(3, 9), c = rnd(2, 9), b = c + rnd(1, 9); // b>c
        return { display: `${a}×(${b}−${c})`, answer: a * (b - c), trap: a * b - c };
      }
      const a = rnd(5, 30), c = rnd(2, 6), q = rnd(2, 9);
      const b = c * q; // b÷c = q sveika
      return { display: `${a}+(${b}÷${c})`, answer: a + q, trap: (a + b) / c };
    }
    case "sunkus": {
      // (A+B)×(C−D)
      const a = rnd(5, 20), b = rnd(2, 15);
      const d = rnd(2, 10), c = d + rnd(1, 10); // c>d
      return { display: `(${a}+${b})×(${c}−${d})`, answer: (a + b) * (c - d) };
    }
    case "ekstremalus": {
      // A×(B−(C+D))  — skliaustai skliaustuose. B > C+D.
      const c = rnd(2, 10), d = rnd(2, 10);
      const inner = c + d;
      const b = inner + rnd(2, 15);
      const a = rnd(2, 9);
      return {
        display: `${a}×(${b}−(${c}+${d}))`,
        answer: a * (b - inner),
        trap: a * (b - c + d), // klaida su vidiniu skliaustu
      };
    }
  }
}

// --- ALGEBRA X (rask x; mokykliniai spąstai) ---
function genAlgebra(level: Level): GenQuestion {
  switch (level) {
    case "lengvas": {
      // x+B=C arba B−x=C (x>0)
      const x = rnd(1, 9);
      if (Math.random() < 0.5) {
        const b = rnd(1, 9);
        return { display: `x+${b}=${x + b}`, answer: x, trap: x + b };
      }
      const b = x + rnd(1, 9); // b−x = b-x >0
      return { display: `${b}−x=${b - x}`, answer: x, trap: b };
    }
    case "vidutinis": {
      // A×x=C arba x÷A=C
      const x = rnd(2, 12);
      if (Math.random() < 0.5) {
        const a = rnd(2, 9);
        return { display: `${a}×x=${a * x}`, answer: x, trap: a * x };
      }
      const a = rnd(2, 9);
      return { display: `x÷${a}=${x}`, answer: x * a, trap: x };
    }
    case "sunkus": {
      // A×x+B=C. Mokyklinis spąstas: C+B arba C−B.
      const a = rnd(2, 6), x = rnd(2, 12), b = rnd(2, 15);
      const c = a * x + b;
      return { display: `${a}x+${b}=${c}`, answer: x, trap: c + b };
    }
    case "ekstremalus": {
      if (Math.random() < 0.5) {
        // x²+A=B. Spąstai: kaimynai (x±1, x±2) IR x² (sumaišo x su x²).
        const x = rnd(2, 12), a = rnd(1, 20);
        return {
          display: `x²+${a}=${x * x + a}`,
          answer: x,
          trap: x * x, // dažna klaida: pamiršo šaknį
          neighbors: [x + 1, x - 1, x + 2, x - 2], // gretimi (visi >0 filtruoja later)
        };
      }
      // A×(x−B)=C
      const a = rnd(2, 5), b = rnd(2, 9), q = rnd(2, 12);
      const x = b + q;
      return { display: `${a}×(x−${b})=${a * q}`, answer: x, trap: a * q };
    }
  }
}

// --- REGISTRAS: šeima → generatorius ---
// (Kids — Grupė B, reikia ikonų piešimo; pridėsim vėliau su tekstiniu kontraktu.)
export type Family =
  | "add" | "sub" | "mul" | "div" | "mix" | "brackets" | "algebra";

export const QUESTION_GENERATORS: Record<
  Family,
  (level: Level) => GenQuestion
> = {
  add: genAdd,
  sub: genSub,
  mul: genMul,
  div: genDiv,
  mix: genMix,
  brackets: genBrackets,
  algebra: genAlgebra,
};

export function isFamily(x: string): x is Family {
  return x in QUESTION_GENERATORS;
}

// =================================================================
// PASIKARTOJIMŲ VENGIMAS (generuojamiems klausimams)
// -----------------------------------------------------------------
// Matematika generuojama, tad nėra „sąrašo" kaip Gamtoj. Anksčiau buvo
// „atsitiktinis + atmesk neseniai matytą", bet mažam fondui (pvz. lengva
// daugyba/dalyba = 64 deriniai) atmintis (150) viršija fondą → po kelių
// žaidimų kone viskas „matyta" ir tekdavo kartoti.
//
// Sprendimas — tas pats principas kaip Gamtoj (`pickQuestions`):
//   1) surenkam fondą (unikalūs display'ai), mažam fondui sustojam kai
//      prisotinama (nebėra naujų);
//   2) LANKSTUS atminties langas: vengiam tik tiek neseniai matytų, kad
//      visada liktų bent `count` + atsarga ŠVIEŽIŲ;
//   3) sumaišom ir dalinam — šviežius pirma.
// Mažam fondui tai reiškia: išdalinami VISI prieš bet kuriam pasikartojant.
// Dideliam fondui elgesys nepablogėja (vengiam visus ~150 neseniai matytų).
// =================================================================

/** Šviežių atsarga virš `count`, kad būtų iš ko maišyti (kaip Gamtoj). */
const FRESH_MARGIN = 5;
/** Tiek bandymų iš eilės be naujo display'o → laikom, kad fondas išsemtas. */
const SATURATION_LIMIT = 500;
/** Absoliuti bandymų riba (saugiklis nuo begalinio ciklo). */
const MAX_ATTEMPTS = 6000;

function shuffleGen<T>(arr: T[]): T[] {
  const a = arr.slice();
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

export function pickGenerated(
  generator: (level: Level) => GenQuestion,
  level: Level,
  recentIds: string[],
  count: number
): GenQuestion[] {
  // 1) Surenkam fondą (display → GenQuestion). display vienareikšmiškai
  //    nusako klausimą (atsakymą/spąstą), tad dedup pagal display saugu.
  const byDisplay = new Map<string, GenQuestion>();
  const target = count + Math.min(recentIds.length, 150) + FRESH_MARGIN;
  let attempts = 0;
  let sinceNew = 0;
  while (
    byDisplay.size < target &&
    sinceNew < SATURATION_LIMIT &&
    attempts < MAX_ATTEMPTS
  ) {
    attempts++;
    const q = generator(level);
    if (byDisplay.has(q.display)) {
      sinceNew++;
      continue;
    }
    byDisplay.set(q.display, q);
    sinceNew = 0;
  }

  // 2) Lankstus atminties langas — niekada nevengiam tiek, kad neliktų
  //    bent count + atsarga šviežių (mažam fondui langas susitraukia).
  const poolSize = byDisplay.size;
  const maxAvoid = Math.max(0, poolSize - count - FRESH_MARGIN);
  const avoid = new Set(recentIds.slice(0, maxAvoid));

  const keys = Array.from(byDisplay.keys());
  const fresh = shuffleGen(keys.filter((d) => !avoid.has(d)));
  const stale = shuffleGen(keys.filter((d) => avoid.has(d)));
  const ordered = [...fresh, ...stale]; // šviežius pirma

  // 3) Dalinam be pasikartojimo; jei fondas < count (teoriškai ne) — papildom.
  const out: GenQuestion[] = [];
  for (const d of ordered) {
    if (out.length >= count) break;
    out.push(byDisplay.get(d)!);
  }
  while (out.length < count && ordered.length > 0) {
    out.push(byDisplay.get(ordered[out.length % ordered.length])!);
  }
  return out;
}
