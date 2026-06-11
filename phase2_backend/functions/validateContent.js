/* Trivijos turinio validatorius. Naudojimas: node validateContent.js src/historyContent.ts */
const fs = require("fs");
const path = process.argv[2];
if (!path) { console.error("Reikia kelio iki failo"); process.exit(1); }
const src = fs.readFileSync(path, "utf8");

const errors = [];
const warn = [];

// 1) id unikalumas
const ids = [...src.matchAll(/id:\s*"([^"]+)"/g)].map((m) => m[1]);
const seen = new Set();
for (const id of ids) {
  if (seen.has(id)) errors.push(`Dublikatas id: ${id}`);
  seen.add(id);
}

// 2) distractors masyvai — turi būti po 5, visi variantai ≤46 simbolių, be dublikatų su correct
const blocks = [...src.matchAll(/correct:\s*("(?:[^"\\]|\\.)*")\s*,\s*\n\s*distractors:\s*\[([^\]]*)\]/g)];
let optionSets = 0;
for (const b of blocks) {
  optionSets++;
  const correct = JSON.parse(b[1]);
  const raw = b[2];
  const distractors = [...raw.matchAll(/"((?:[^"\\]|\\.)*)"/g)].map((m) => JSON.parse('"' + m[1] + '"'));
  if (distractors.length !== 5) errors.push(`distractors != 5 (${distractors.length}) prie "${correct}"`);
  const all = [correct, ...distractors];
  for (const o of all) {
    if (o.length > 46) errors.push(`Variantas > 46 simb. (${o.length}): "${o}"`);
  }
  const set = new Set(all.map((s) => s.toLowerCase().trim()));
  if (set.size !== all.length) errors.push(`Dublikatas variantuose prie "${correct}": ${all.join(" | ")}`);
}

// 3) ASCII kabutė po LT atidaromosios „
const lines = src.split("\n");
lines.forEach((line, i) => {
  // praleisti komentarus
  const trimmed = line.trim();
  const isComment = trimmed.startsWith("*") || trimmed.startsWith("//") || trimmed.startsWith("/*");
  if (isComment) return;
  // Blogai TIK jei „ uždaroma ASCII " be tarp jų esančios teisingos ” kabutės.
  if (/„[^”"]*"/.test(line)) {
    errors.push(`ASCII uždaromoji kabutė po „ (eil. ${i + 1}): ${line.trim()}`);
  }
});

console.log(`Failas: ${path}`);
console.log(`Klausimų (option-sets): ${optionSets}`);
console.log(`Unikalių id: ${seen.size} / viso ${ids.length}`);
if (errors.length === 0) {
  console.log("VALIDACIJA OK — klaidų nėra.");
} else {
  console.log(`KLAIDOS (${errors.length}):`);
  errors.forEach((e) => console.log("  - " + e));
  process.exit(1);
}
