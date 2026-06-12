/**
 * detectiveContent — 🕵️ DETEKTYVO BYLOS (slapti žodžiai + perkamų klausimų turgus).
 *
 * TAISYKLĖS (savininko, galioja VISKAM):
 *  - lygiai pagal AMŽIAUS skalę: 1 = 9–12 m. vaikas atspėja, 2 = paaugliai,
 *    3 = suaugę, 4 = žinovai;
 *  - faktai 100 % tikri (kiekvienas klausimo atsakymas patikrinamas);
 *  - universalu visoms šalims, nieko neįžeidžia, jokios politikos/religijos;
 *  - klausimai įdomūs, IŠ GYVENIMO; t3 klausimai beveik pasako atsakymą.
 *  - 9 klausimai byloje: po 3 kiekvieno kainos lygio (1 pigus / 2 vid. / 3 brangus).
 *
 * Žodis perdega po vieno žaidimo (users.detectiveSolved) — pildant turinį
 * naujos bylos tiesiog dedamos į šį masyvą (id auga toliau).
 */

import { DetectiveCase } from "./detectiveTypes";
import { Lang } from "./triviaTypes";

export const DETECTIVE_CASES: DetectiveCase[] = [
  // ── L1 — vaikai (9–12 m.) ─────────────────────────────────────────────
  {
    id: "det_001",
    level: 1,
    texts: {
      lt: {
        word: "Žirafa",
        categoryLabel: "Gyvūnas",
        questions: [
          { t: 1, q: "Ar tai gyva būtybė?", a: true },
          { t: 1, q: "Ar tai galima rasti namuose?", a: false },
          { t: 1, q: "Ar tai galima suvalgyti?", a: false },
          { t: 2, q: "Ar šis gyvūnas gyvena Afrikoje?", a: true },
          { t: 2, q: "Ar jis moka skraidyti?", a: false },
          { t: 2, q: "Ar jis didesnis už žmogų?", a: true },
          { t: 3, q: "Ar tai aukščiausias pasaulio gyvūnas?", a: true },
          { t: 3, q: "Ar jo kaklas labai ilgas?", a: true },
          { t: 3, q: "Ar jis dryžuotas kaip zebras?", a: false },
        ],
      },
      en: {
        word: "Giraffe",
        categoryLabel: "Animal",
        questions: [
          { t: 1, q: "Is it a living creature?", a: true },
          { t: 1, q: "Can you find it in a house?", a: false },
          { t: 1, q: "Can you eat it?", a: false },
          { t: 2, q: "Does this animal live in Africa?", a: true },
          { t: 2, q: "Can it fly?", a: false },
          { t: 2, q: "Is it bigger than a human?", a: true },
          { t: 3, q: "Is it the tallest animal in the world?", a: true },
          { t: 3, q: "Does it have a very long neck?", a: true },
          { t: 3, q: "Is it striped like a zebra?", a: false },
        ],
      },
    },
  },
  {
    id: "det_002",
    level: 1,
    texts: {
      lt: {
        word: "Ugnikalnis",
        categoryLabel: "Gamta",
        questions: [
          { t: 1, q: "Ar tai gyvūnas?", a: false },
          { t: 1, q: "Ar tai yra gamtoje?", a: true },
          { t: 1, q: "Ar gali jį pakelti rankomis?", a: false },
          { t: 2, q: "Ar jis didelis kaip kalnas?", a: true },
          { t: 2, q: "Ar jo viduje labai karšta?", a: true },
          { t: 2, q: "Ar jis būna tik po vandeniu?", a: false },
          { t: 3, q: "Ar iš jo gali veržtis lava?", a: true },
          { t: 3, q: "Ar jis gali išsiveržti?", a: true },
          { t: 3, q: "Ar Vezuvijus yra vienas iš jų?", a: true },
        ],
      },
      en: {
        word: "Volcano",
        categoryLabel: "Nature",
        questions: [
          { t: 1, q: "Is it an animal?", a: false },
          { t: 1, q: "Is it found in nature?", a: true },
          { t: 1, q: "Can you lift it with your hands?", a: false },
          { t: 2, q: "Is it as big as a mountain?", a: true },
          { t: 2, q: "Is it very hot inside?", a: true },
          { t: 2, q: "Is it found only underwater?", a: false },
          { t: 3, q: "Can lava erupt from it?", a: true },
          { t: 3, q: "Can it erupt?", a: true },
          { t: 3, q: "Is Vesuvius one of these?", a: true },
        ],
      },
    },
  },
  {
    id: "det_003",
    level: 1,
    texts: {
      lt: {
        word: "Ledai",
        categoryLabel: "Maistas",
        questions: [
          { t: 1, q: "Ar tai valgoma?", a: true },
          { t: 1, q: "Ar tai gyvūnas?", a: false },
          { t: 1, q: "Ar tai karšta?", a: false },
          { t: 2, q: "Ar tai saldu?", a: true },
          { t: 2, q: "Ar tai laikoma šaldiklyje?", a: true },
          { t: 2, q: "Ar tai geriama kaip sultys?", a: false },
          { t: 3, q: "Ar dažniausiai jų valgome vasarą?", a: true },
          { t: 3, q: "Ar jie tirpsta saulėje?", a: true },
          { t: 3, q: "Ar jie dažniausiai gaminami iš pieno?", a: true },
        ],
      },
      en: {
        word: "Ice cream",
        categoryLabel: "Food",
        questions: [
          { t: 1, q: "Can you eat it?", a: true },
          { t: 1, q: "Is it an animal?", a: false },
          { t: 1, q: "Is it hot?", a: false },
          { t: 2, q: "Is it sweet?", a: true },
          { t: 2, q: "Is it kept in a freezer?", a: true },
          { t: 2, q: "Do you drink it like juice?", a: false },
          { t: 3, q: "Do we eat it mostly in summer?", a: true },
          { t: 3, q: "Does it melt in the sun?", a: true },
          { t: 3, q: "Is it usually made from milk?", a: true },
        ],
      },
    },
  },
  // ── L2 — paaugliai (12–18 m.) ─────────────────────────────────────────
  {
    id: "det_004",
    level: 2,
    texts: {
      lt: {
        word: "Piramidė",
        categoryLabel: "Statinys",
        questions: [
          { t: 1, q: "Ar tai pastatė žmonės?", a: true },
          { t: 1, q: "Ar tai gyva?", a: false },
          { t: 1, q: "Ar tai telpa kambaryje?", a: false },
          { t: 2, q: "Ar garsiausios iš jų yra Egipte?", a: true },
          { t: 2, q: "Ar jos statytos prieš tūkstančius metų?", a: true },
          { t: 2, q: "Ar jose dabar gyvena žmonės?", a: false },
          { t: 3, q: "Ar jos viršūnė smaila?", a: true },
          { t: 3, q: "Ar jose buvo laidojami faraonai?", a: true },
          { t: 3, q: "Ar didžiausia iš jų stovi Gizoje?", a: true },
        ],
      },
      en: {
        word: "Pyramid",
        categoryLabel: "Structure",
        questions: [
          { t: 1, q: "Was it built by people?", a: true },
          { t: 1, q: "Is it alive?", a: false },
          { t: 1, q: "Does it fit inside a room?", a: false },
          { t: 2, q: "Are the most famous ones in Egypt?", a: true },
          { t: 2, q: "Were they built thousands of years ago?", a: true },
          { t: 2, q: "Do people live in them today?", a: false },
          { t: 3, q: "Is its top pointed?", a: true },
          { t: 3, q: "Were pharaohs buried inside them?", a: true },
          { t: 3, q: "Is the biggest one in Giza?", a: true },
        ],
      },
    },
  },
  {
    id: "det_005",
    level: 2,
    texts: {
      lt: {
        word: "Delfinas",
        categoryLabel: "Gyvūnas",
        questions: [
          { t: 1, q: "Ar tai gyvūnas?", a: true },
          { t: 1, q: "Ar jis gyvena sausumoje?", a: false },
          { t: 1, q: "Ar jis mažesnis už katę?", a: false },
          { t: 2, q: "Ar jis gyvena vandenyje?", a: true },
          { t: 2, q: "Ar jis yra žuvis?", a: false },
          { t: 2, q: "Ar jis kvėpuoja oru?", a: true },
          { t: 3, q: "Ar jis laikomas vienu protingiausių gyvūnų?", a: true },
          { t: 3, q: "Ar jis bendrauja švilpesiais ir spragsėjimais?", a: true },
          { t: 3, q: "Ar jis turi žiaunas?", a: false },
        ],
      },
      en: {
        word: "Dolphin",
        categoryLabel: "Animal",
        questions: [
          { t: 1, q: "Is it an animal?", a: true },
          { t: 1, q: "Does it live on land?", a: false },
          { t: 1, q: "Is it smaller than a cat?", a: false },
          { t: 2, q: "Does it live in water?", a: true },
          { t: 2, q: "Is it a fish?", a: false },
          { t: 2, q: "Does it breathe air?", a: true },
          { t: 3, q: "Is it considered one of the smartest animals?", a: true },
          { t: 3, q: "Does it talk with whistles and clicks?", a: true },
          { t: 3, q: "Does it have gills?", a: false },
        ],
      },
    },
  },
  {
    id: "det_006",
    level: 2,
    texts: {
      lt: {
        word: "Kompasas",
        categoryLabel: "Daiktas",
        questions: [
          { t: 1, q: "Ar tai daiktas?", a: true },
          { t: 1, q: "Ar jis valgomas?", a: false },
          { t: 1, q: "Ar jis didesnis už žmogų?", a: false },
          { t: 2, q: "Ar jį naudoja keliautojai?", a: true },
          { t: 2, q: "Ar jam būtinai reikia baterijų?", a: false },
          { t: 2, q: "Ar jis telpa delne?", a: true },
          { t: 3, q: "Ar jo rodyklė rodo šiaurę?", a: true },
          { t: 3, q: "Ar jis veikia dėl Žemės magnetinio lauko?", a: true },
          { t: 3, q: "Ar juo matuojamas laikas?", a: false },
        ],
      },
      en: {
        word: "Compass",
        categoryLabel: "Object",
        questions: [
          { t: 1, q: "Is it an object?", a: true },
          { t: 1, q: "Can you eat it?", a: false },
          { t: 1, q: "Is it bigger than a person?", a: false },
          { t: 2, q: "Do travelers use it?", a: true },
          { t: 2, q: "Does it need batteries to work?", a: false },
          { t: 2, q: "Does it fit in your palm?", a: true },
          { t: 3, q: "Does its needle point north?", a: true },
          { t: 3, q: "Does it work thanks to Earth's magnetic field?", a: true },
          { t: 3, q: "Is it used to measure time?", a: false },
        ],
      },
    },
  },
  // ── L3 — suaugę ───────────────────────────────────────────────────────
  {
    id: "det_007",
    level: 3,
    texts: {
      lt: {
        word: "Gladiatorius",
        categoryLabel: "Istorija",
        questions: [
          { t: 1, q: "Ar tai žmogus?", a: true },
          { t: 1, q: "Ar tai šių laikų profesija?", a: false },
          { t: 1, q: "Ar tai daiktas?", a: false },
          { t: 2, q: "Ar jis susijęs su Senovės Roma?", a: true },
          { t: 2, q: "Ar jis kovodavo dėl žiūrovų pramogos?", a: true },
          { t: 2, q: "Ar jis gydydavo žmones?", a: false },
          { t: 3, q: "Ar jis kovojo Koliziejuje?", a: true },
          { t: 3, q: "Ar daugelis jų buvo vergai?", a: true },
          { t: 3, q: "Ar jo kovas stebėdavo minios?", a: true },
        ],
      },
      en: {
        word: "Gladiator",
        categoryLabel: "History",
        questions: [
          { t: 1, q: "Is it a person?", a: true },
          { t: 1, q: "Is it a modern-day profession?", a: false },
          { t: 1, q: "Is it an object?", a: false },
          { t: 2, q: "Is it connected to Ancient Rome?", a: true },
          { t: 2, q: "Did he fight to entertain crowds?", a: true },
          { t: 2, q: "Did he heal people?", a: false },
          { t: 3, q: "Did he fight in the Colosseum?", a: true },
          { t: 3, q: "Were many of them slaves?", a: true },
          { t: 3, q: "Did crowds watch his fights?", a: true },
        ],
      },
    },
  },
  {
    id: "det_008",
    level: 3,
    texts: {
      lt: {
        word: "Marsas",
        categoryLabel: "Kosmosas",
        questions: [
          { t: 1, q: "Ar tai yra Žemėje?", a: false },
          { t: 1, q: "Ar tai galima pamatyti danguje?", a: true },
          { t: 1, q: "Ar tai žvaigždė?", a: false },
          { t: 2, q: "Ar tai planeta?", a: true },
          { t: 2, q: "Ar ji arčiau Saulės nei Žemė?", a: false },
          { t: 2, q: "Ar į ją žmonija siuntė robotus?", a: true },
          { t: 3, q: "Ar ji vadinama Raudonąja planeta?", a: true },
          { t: 3, q: "Ar ji turi du palydovus?", a: true },
          { t: 3, q: "Ar joje yra aukščiausias Saulės sistemos ugnikalnis?", a: true },
        ],
      },
      en: {
        word: "Mars",
        categoryLabel: "Space",
        questions: [
          { t: 1, q: "Is it on Earth?", a: false },
          { t: 1, q: "Can you see it in the sky?", a: true },
          { t: 1, q: "Is it a star?", a: false },
          { t: 2, q: "Is it a planet?", a: true },
          { t: 2, q: "Is it closer to the Sun than Earth?", a: false },
          { t: 2, q: "Has humanity sent robots there?", a: true },
          { t: 3, q: "Is it called the Red Planet?", a: true },
          { t: 3, q: "Does it have two moons?", a: true },
          { t: 3, q: "Does it have the tallest volcano in the Solar System?", a: true },
        ],
      },
    },
  },
  // ── L4 — žinovai ──────────────────────────────────────────────────────
  {
    id: "det_009",
    level: 4,
    texts: {
      lt: {
        word: "Stalagmitas",
        categoryLabel: "Gamta",
        questions: [
          { t: 1, q: "Ar tai gyva?", a: false },
          { t: 1, q: "Ar tai sutinkama po atviru dangumi?", a: false },
          { t: 1, q: "Ar tai akmeninis darinys?", a: true },
          { t: 2, q: "Ar tai randama urvuose?", a: true },
          { t: 2, q: "Ar tai susidaro per tūkstančius metų?", a: true },
          { t: 2, q: "Ar tai kabo nuo lubų?", a: false },
          { t: 3, q: "Ar jis auga nuo grindų į viršų?", a: true },
          { t: 3, q: "Ar jį formuoja lašantis vanduo?", a: true },
          { t: 3, q: "Ar jis gali suaugti su stalaktitu į koloną?", a: true },
        ],
      },
      en: {
        word: "Stalagmite",
        categoryLabel: "Nature",
        questions: [
          { t: 1, q: "Is it alive?", a: false },
          { t: 1, q: "Is it found out in the open air?", a: false },
          { t: 1, q: "Is it a rocky formation?", a: true },
          { t: 2, q: "Is it found in caves?", a: true },
          { t: 2, q: "Does it form over thousands of years?", a: true },
          { t: 2, q: "Does it hang from the ceiling?", a: false },
          { t: 3, q: "Does it grow upward from the floor?", a: true },
          { t: 3, q: "Is it formed by dripping water?", a: true },
          { t: 3, q: "Can it merge with a stalactite into a column?", a: true },
        ],
      },
    },
  },
  {
    id: "det_010",
    level: 4,
    texts: {
      lt: {
        word: "Metronomas",
        categoryLabel: "Daiktas",
        questions: [
          { t: 1, q: "Ar tai daiktas?", a: true },
          { t: 1, q: "Ar jis valgomas?", a: false },
          { t: 1, q: "Ar jis didesnis už spintą?", a: false },
          { t: 2, q: "Ar jis susijęs su muzika?", a: true },
          { t: 2, q: "Ar juo grojamos melodijos?", a: false },
          { t: 2, q: "Ar jį naudoja muzikantai?", a: true },
          { t: 3, q: "Ar jis skaičiuoja muzikos tempą?", a: true },
          { t: 3, q: "Ar jis tiksi vienodu ritmu?", a: true },
          { t: 3, q: "Ar jo greitis matuojamas dūžiais per minutę?", a: true },
        ],
      },
      en: {
        word: "Metronome",
        categoryLabel: "Object",
        questions: [
          { t: 1, q: "Is it an object?", a: true },
          { t: 1, q: "Can you eat it?", a: false },
          { t: 1, q: "Is it bigger than a wardrobe?", a: false },
          { t: 2, q: "Is it connected to music?", a: true },
          { t: 2, q: "Do you play melodies on it?", a: false },
          { t: 2, q: "Do musicians use it?", a: true },
          { t: 3, q: "Does it count the tempo of music?", a: true },
          { t: 3, q: "Does it tick in a steady rhythm?", a: true },
          { t: 3, q: "Is its speed measured in beats per minute?", a: true },
        ],
      },
    },
  },
];

/** Suranda bylą pagal ID. */
export function findDetectiveCase(id: string): DetectiveCase | undefined {
  return DETECTIVE_CASES.find((c) => c.id === id);
}

/**
 * Parenka neperdegusią bylą žaidėjo kalba ir lygiu.
 *  - tik tos kalbos bylos (EN atsarga, jei kalbos nėra);
 *  - vengiam perdegusių (solvedIds); jei TO lygio visos perdegė — null
 *    (klientui aiški žinutė; kartoti NEgalima — žodis jau žinomas).
 */
export function pickDetectiveCase(
  lang: Lang,
  level: number,
  solvedIds: string[]
): { item: DetectiveCase; lang: Lang } | null {
  const solved = new Set(solvedIds);
  const tryLang = (l: Lang) => {
    const pool = DETECTIVE_CASES.filter(
      (c) => c.level === level && c.texts[l] && !solved.has(c.id)
    );
    if (pool.length === 0) return null;
    return pool[Math.floor(Math.random() * pool.length)];
  };
  const own = tryLang(lang);
  if (own) return { item: own, lang };
  const en = tryLang("en");
  if (en) return { item: en, lang: "en" };
  return null;
}
