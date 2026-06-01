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

function mulRange(level: Level): [number, number] {
  switch (level) {
    case "lengvas": return [rnd(2, 5), rnd(2, 5)];
    case "vidutinis": return [rnd(2, 10), rnd(2, 10)];
    case "sunkus": return [rnd(2, 12), rnd(2, 12)];
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
        // A×B − C
        const a = rnd(2, 12), b = rnd(2, 9), c = rnd(2, 30);
        return { display: `${a}×${b}−${c}`, answer: a * b - c };
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

// --- REGISTRAS: šeima → generatorius ---
export type Family = "add" | "sub" | "mul" | "div" | "mix";

export const QUESTION_GENERATORS: Record<
  Family,
  (level: Level) => GenQuestion
> = {
  add: genAdd,
  sub: genSub,
  mul: genMul,
  div: genDiv,
  mix: genMix,
};

export function isFamily(x: string): x is Family {
  return x in QUESTION_GENERATORS;
}
