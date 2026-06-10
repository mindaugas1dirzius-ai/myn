/* Vienkartinis generatorius: kompaktiškus duomenis paverčia natureContent.ts
 * blokais ir įterpia prieš galinį `];`. Automatinė patikra:
 *  - lygiai 5 distractors
 *  - kiekvienas variantas (correct + 5) ≤ 46 simbolių (telpa mygtuke)
 *  - LT laukuose NĖRA ASCII " (turi būti garbanotos „ ")
 *  - EN correct nesidubliuoja su jau esamais TO LYGIO atsakymais
 *  - EN correct unikalus pačiame pakete
 *  - ID auto-priskiriamas: <prefix><maxEsamo+1>
 * Jei randa klaidą — NIEKO nerašo, tik praneša.
 */
const fs = require("fs");
const FILE = "src/natureContent.ts";
const s = fs.readFileSync(FILE, "utf8");

// ---- KONFIG ----
const LEVEL = "lengvas";
const PREFIX = "nat_le_";

// ---- DUOMENYS ----
// q=klausimas, c=correct, d=[5 distractors], e=explanation
const DATA = [
  { sub: "animals", emoji: "🐮",
    enQ: "What is a baby cow called?", enC: "A calf",
    enD: ["A foal", "A piglet", "A lamb", "A kitten", "A chick"],
    enE: "A young cow is called a calf.",
    ltQ: "Kaip vadinamas karvės jauniklis?", ltC: "Veršiukas",
    ltD: ["Kumeliukas", "Paršiukas", "Ėriukas", "Kačiukas", "Viščiukas"],
    ltE: "Karvės jauniklis vadinamas veršiuku." },

  { sub: "animals", emoji: "🐴",
    enQ: "What is a baby horse called?", enC: "A foal",
    enD: ["A calf", "A lamb", "A piglet", "A cub", "A joey"],
    enE: "A young horse is called a foal.",
    ltQ: "Kaip vadinamas arklio jauniklis?", ltC: "Kumeliukas",
    ltD: ["Veršiukas", "Ėriukas", "Paršiukas", "Meškiukas", "Kengūriukas"],
    ltE: "Arklio jauniklis vadinamas kumeliuku." },

  { sub: "animals", emoji: "🦘",
    enQ: "What is a baby kangaroo called?", enC: "A joey",
    enD: ["A cub", "A calf", "A chick", "A foal", "A piglet"],
    enE: "A baby kangaroo is called a joey.",
    ltQ: "Kaip vadinamas kengūros jauniklis?", ltC: "Kengūriukas",
    ltD: ["Meškiukas", "Veršiukas", "Viščiukas", "Kumeliukas", "Paršiukas"],
    ltE: "Kengūros jauniklis vadinamas kengūriuku." },

  { sub: "animals", emoji: "🐺",
    enQ: "What do we call a group of wolves?", enC: "A pack",
    enD: ["A herd", "A flock", "A school", "A swarm", "A pride"],
    enE: "A group of wolves is called a pack.",
    ltQ: "Kaip vadinama vilkų grupė?", ltC: "Gauja",
    ltD: ["Banda", "Pulkas", "Būrys", "Spiečius", "Kaimenė"],
    ltE: "Vilkų grupė vadinama gauja." },

  { sub: "animals", emoji: "🐟",
    enQ: "What do we call a group of fish swimming together?", enC: "A school",
    enD: ["A pack", "A herd", "A flock", "A swarm", "A pride"],
    enE: "A group of fish swimming together is called a school.",
    ltQ: "Kaip vadinama kartu plaukiojanti žuvų grupė?", ltC: "Būrys",
    ltD: ["Gauja", "Banda", "Pulkas", "Spiečius", "Kaimenė"],
    ltE: "Kartu plaukiojančių žuvų grupė vadinama būriu." },

  { sub: "animals", emoji: "🐶",
    enQ: "Which animal is often called man's best friend?", enC: "The dog",
    enD: ["The cat", "The horse", "The cow", "The rabbit", "The parrot"],
    enE: "Dogs are loyal companions, so they are called man's best friend.",
    ltQ: "Kuris gyvūnas dažnai vadinamas geriausiu žmogaus draugu?", ltC: "Šuo",
    ltD: ["Katė", "Arklys", "Karvė", "Triušis", "Papūga"],
    ltE: "Šunys yra ištikimi, todėl vadinami geriausiais žmogaus draugais." },

  { sub: "animals", emoji: "🐱",
    enQ: "Which pet purrs and likes to chase mice?", enC: "The cat",
    enD: ["The dog", "The rabbit", "The fox", "The tiger", "The mouse"],
    enE: "Cats purr when content and often chase mice.",
    ltQ: "Kuris augintinis murkia ir mėgsta gaudyti peles?", ltC: "Katė",
    ltD: ["Šuo", "Triušis", "Lapė", "Tigras", "Pelė"],
    ltE: "Katės murkia, kai joms gera, ir dažnai gaudo peles." },

  { sub: "animals", emoji: "🐑",
    enQ: "Which farm animal gives us wool?", enC: "The sheep",
    enD: ["The cow", "The pig", "The goat", "The horse", "The duck"],
    enE: "Sheep grow thick wool that we shear and use for clothes.",
    ltQ: "Kuris ūkio gyvūnas duoda mums vilną?", ltC: "Avis",
    ltD: ["Karvė", "Kiaulė", "Ožka", "Arklys", "Antis"],
    ltE: "Avys augina storą vilną, kurią kerpame ir naudojame drabužiams." },

  { sub: "animals", emoji: "🦩",
    enQ: "Which pink bird often stands on one leg?", enC: "The flamingo",
    enD: ["The swan", "The stork", "The crane", "The peacock", "The duck"],
    enE: "Flamingos are pink and often rest while standing on one leg.",
    ltQ: "Kuris rožinis paukštis dažnai stovi ant vienos kojos?", ltC: "Flamingas",
    ltD: ["Gulbė", "Gandras", "Gervė", "Povas", "Antis"],
    ltE: "Flamingai yra rožiniai ir dažnai ilsisi stovėdami ant vienos kojos." },

  { sub: "animals", emoji: "🦚",
    enQ: "Which bird is famous for its colourful fan-shaped tail?", enC: "The peacock",
    enD: ["The parrot", "The flamingo", "The swan", "The turkey", "The pigeon"],
    enE: "Male peacocks spread a large, colourful tail to attract a mate.",
    ltQ: "Kuris paukštis garsus spalvinga vėduoklės formos uodega?", ltC: "Povas",
    ltD: ["Papūga", "Flamingas", "Gulbė", "Kalakutas", "Balandis"],
    ltE: "Povų patinai išskleidžia didelę spalvingą uodegą patelei privilioti." },

  { sub: "animals", emoji: "🐠",
    enQ: "Which small pet fish is often kept in a bowl?", enC: "The goldfish",
    enD: ["The shark", "The dolphin", "The whale", "The eel", "The crab"],
    enE: "Goldfish are small, hardy fish often kept as pets in bowls or tanks.",
    ltQ: "Kuri maža žuvelė dažnai laikoma kaip augintinė akvariume?", ltC: "Auksinė žuvelė",
    ltD: ["Ryklys", "Delfinas", "Banginis", "Ungurys", "Krabas"],
    ltE: "Auksinės žuvelės yra mažos, atsparios ir dažnai laikomos akvariumuose." },

  { sub: "animals", emoji: "🐿️",
    enQ: "Which bushy-tailed animal stores nuts for winter?", enC: "The squirrel",
    enD: ["The mouse", "The rabbit", "The fox", "The beaver", "The hedgehog"],
    enE: "Squirrels gather and hide nuts to eat during winter.",
    ltQ: "Kuris pūkuotauodegis gyvūnas kaupia riešutus žiemai?", ltC: "Voverė",
    ltD: ["Pelė", "Triušis", "Lapė", "Bebras", "Ežys"],
    ltE: "Voverės renka ir slepia riešutus, kad turėtų ką valgyti žiemą." },

  { sub: "animals", emoji: "🦊",
    enQ: "Which wild animal has orange fur and a bushy tail?", enC: "The fox",
    enD: ["The wolf", "The squirrel", "The cat", "The dog", "The rabbit"],
    enE: "The red fox has orange fur and a thick, bushy tail.",
    ltQ: "Kuris laukinis gyvūnas turi rudą kailį ir pūkuotą uodegą?", ltC: "Lapė",
    ltD: ["Vilkas", "Voverė", "Katė", "Šuo", "Triušis"],
    ltE: "Rudoji lapė turi rusvai oranžinį kailį ir storą pūkuotą uodegą." },

  { sub: "animals", emoji: "🐟",
    enQ: "What covers the body of most fish?", enC: "Scales",
    enD: ["Fur", "Feathers", "Hair", "Shells", "Spines"],
    enE: "Most fish are covered in small, overlapping scales that protect them.",
    ltQ: "Kas dengia daugumos žuvų kūną?", ltC: "Žvynai",
    ltD: ["Kailis", "Plunksnos", "Plaukai", "Kriauklės", "Spygliai"],
    ltE: "Daugumą žuvų dengia maži, vienas ant kito užeinantys žvynai." },

  { sub: "animals", emoji: "🐨",
    enQ: "What do koalas mainly eat?", enC: "Eucalyptus leaves",
    enD: ["Bamboo", "Grass", "Fish", "Fruit", "Meat"],
    enE: "Koalas feed almost only on the leaves of eucalyptus trees.",
    ltQ: "Kuo daugiausia minta koalos?", ltC: "Eukalipto lapais",
    ltD: ["Bambukais", "Žole", "Žuvimi", "Vaisiais", "Mėsa"],
    ltE: "Koalos minta beveik vien eukalipto medžių lapais." },
];

// ---- PATIKRA ----
const existingIds = new Set([...s.matchAll(/id:\s*"([^"]+)"/g)].map((m) => m[1]));
// EN correct pagal lygį
const blocks = s.split(/\n  \{\n/).slice(1);
const correctByLevel = {};
blocks.forEach((b) => {
  const lm = b.match(/level:\s*"(\w+)"/);
  if (!lm) return;
  const en = b.match(/en:\s*\{([\s\S]*?)\n      \}/);
  if (!en) return;
  const cm = en[1].match(/correct:\s*"((?:[^"\\]|\\.)*)"/);
  if (!cm) return;
  (correctByLevel[lm[1]] = correctByLevel[lm[1]] || new Set()).add(
    cm[1].toLowerCase()
  );
});
const existingCorrect = correctByLevel[LEVEL] || new Set();

const errors = [];
const batchCorrect = new Set();
DATA.forEach((q, i) => {
  const tag = "#" + (i + 1) + " (" + q.enC + ")";
  if (q.enD.length !== 5) errors.push(tag + " EN distractorių ne 5");
  if (q.ltD.length !== 5) errors.push(tag + " LT distractorių ne 5");
  [q.enC, ...q.enD, q.ltC, ...q.ltD].forEach((o) => {
    if (o.length > 46) errors.push(tag + " variantas per ilgas (" + o.length + "): " + o);
  });
  [q.ltQ, q.ltC, ...q.ltD, q.ltE].forEach((t) => {
    if (t.includes('"')) errors.push(tag + " LT yra ASCII kabutė: " + t);
  });
  const lc = q.enC.toLowerCase();
  if (existingCorrect.has(lc)) errors.push(tag + " EN correct JAU yra tame lygyje");
  if (batchCorrect.has(lc)) errors.push(tag + " EN correct kartojasi pakete");
  batchCorrect.add(lc);
});

if (errors.length) {
  console.log("KLAIDOS (" + errors.length + ") — NIEKAS nerašyta:");
  errors.forEach((e) => console.log("  - " + e));
  process.exit(1);
}

// ---- ID auto-priskyrimas ----
let maxN = 0;
existingIds.forEach((id) => {
  if (id.startsWith(PREFIX)) {
    const n = parseInt(id.slice(PREFIX.length), 10);
    if (!isNaN(n) && n > maxN) maxN = n;
  }
});

// ---- FORMATAVIMAS ----
const J = (x) => JSON.stringify(x);
function arr(a) {
  return "[" + a.map(J).join(", ") + "]";
}
function block(q, id) {
  return [
    "  {",
    "    id: " + J(id) + ",",
    '    category: "nature",',
    "    subTheme: " + J(q.sub) + ",",
    "    level: " + J(LEVEL) + ",",
    "    isTrap: false,",
    '    sourceVerified: "General nature knowledge (everyday animals)",',
    "    emoji: " + J(q.emoji) + ",",
    "    translations: {",
    "      en: {",
    "        question: " + J(q.enQ) + ",",
    "        correct: " + J(q.enC) + ",",
    "        distractors: " + arr(q.enD) + ",",
    "        explanation: " + J(q.enE) + ",",
    "      },",
    "      lt: {",
    "        question: " + J(q.ltQ) + ",",
    "        correct: " + J(q.ltC) + ",",
    "        distractors: " + arr(q.ltD) + ",",
    "        explanation: " + J(q.ltE) + ",",
    "      },",
    "    },",
    "  },",
  ].join("\n");
}

const newBlocks = DATA.map((q, i) =>
  block(q, PREFIX + String(maxN + 1 + i).padStart(3, "0"))
).join("\n");

// Įterpiam prieš galinį "];"
const idx = s.lastIndexOf("\n];");
if (idx < 0) {
  console.log("Nerastas masyvo galas '];'");
  process.exit(1);
}
const out = s.slice(0, idx) + "\n" + newBlocks + s.slice(idx);
fs.writeFileSync(FILE, out, "utf8");
console.log(
  "OK: pridėta " + DATA.length + " klausimų, ID " +
  PREFIX + String(maxN + 1).padStart(3, "0") + " .. " +
  PREFIX + String(maxN + DATA.length).padStart(3, "0")
);
