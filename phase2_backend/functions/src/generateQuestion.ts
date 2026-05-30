/**
 * generateQuestion — vienas variklis visiems 16 režimų (2 sprendimas).
 * Generuoja veiksmą + teisingą atsakymą pagal op + level.
 * Dalyba visada duoda sveiką skaičių (atvirkštinė daugyba).
 */

import { Op, Level } from "./gameConfig";

export interface Question {
  action: string; // pvz. "6x7" (rodoma žaidėjui)
  answer: number; // 42 (NIEKADA nesiunčiama klientui)
  a: number;
  b: number;
  op: Op;
}

function rnd(min: number, max: number): number {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

const SYMBOL: Record<Op, string> = { "+": "+", "-": "−", "*": "×", "/": "÷" };

/** Sudėties operandai pagal lygį. */
function addOperands(level: Level): [number, number] {
  switch (level) {
    case "lengvas": return [rnd(1, 9), rnd(1, 9)];
    case "vidutinis": return [rnd(10, 99), rnd(1, 9)];
    case "sunkus": return [rnd(10, 99), rnd(10, 99)];
    case "ekstremalus": return [rnd(100, 999), rnd(10, 99)];
  }
}

/** Daugybos operandai pagal lygį. */
function mulOperands(level: Level): [number, number] {
  switch (level) {
    case "lengvas": return [rnd(2, 5), rnd(2, 5)];
    case "vidutinis": return [rnd(2, 10), rnd(2, 10)];
    case "sunkus": return [rnd(2, 12), rnd(2, 12)];
    case "ekstremalus": return [rnd(13, 25), rnd(3, 9)];
  }
}

export function generateQuestion(op: Op, level: Level): Question {
  let a: number;
  let b: number;
  let answer: number;

  if (op === "+") {
    [a, b] = addOperands(level);
    answer = a + b;
  } else if (op === "-") {
    // atimtis = sudėties atvirkštinė (rezultatas visada >= 0)
    const [x, y] = addOperands(level);
    a = x + y;
    b = y;
    answer = x;
  } else if (op === "*") {
    [a, b] = mulOperands(level);
    answer = a * b;
  } else {
    // dalyba = daugybos atvirkštinė (sveikas rezultatas, daliklis != 0)
    const [x, y] = mulOperands(level);
    answer = x;
    b = y;
    a = x * y;
  }

  return { action: `${a}${SYMBOL[op]}${b}`, answer, a, b, op };
}
