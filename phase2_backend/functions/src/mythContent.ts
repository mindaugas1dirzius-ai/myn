/**
 * mythContent — 🧐 „TIESA AR MITAS?" teiginiai (MŪSŲ PARUOŠTI, ne generuojami).
 *
 * Savininko užsakymas 2026-06-12: atskiras TAIP/NE žaidimas su ranka
 * paruoštais teiginiais. Žaidėjas mato TEIGINĮ ir sprendžia: ✅ TIESA ar
 * ❌ MITAS. Po atsakymo — trumpas paaiškinimas KODĖL (mokomasis efektas).
 *
 * TAISYKLĖS (galioja visam turiniui):
 *  - lygiai pagal AMŽIAUS skalę (1 vaikai … 4 žinovai);
 *  - faktai 100 % patikrinti; teiginys VIENAREIKŠMIS (be „dažniausiai" dviprasmybių);
 *  - universalu visoms šalims, nieko neįžeidžia; populiarūs MITAI — geriausi
 *    („False Friend" efektas: atrodo logiška, bet netiesa);
 *  - paaiškinimas trumpas ir įdomus („oho" faktas).
 */

import { Level } from "./gameConfig";
import { Lang } from "./triviaTypes";

export interface MythText {
  st: string;  // teiginys
  ex: string;  // paaiškinimas (kodėl tiesa/mitas)
}

export interface MythStatement {
  id: string;          // pvz. "myt_001"
  level: Level;
  isTrue: boolean;     // ✅ tiesa ar ❌ mitas
  /** Teiginio SUBJEKTO emoji (🐝/🌙/⚡) — kortelės vaizdui. Neutralus:
   *  rodo apie ką teiginys, bet NIEKADA neišduoda, tiesa tai ar mitas. */
  emoji: string;
  texts: Partial<Record<Lang, MythText>>;
}

export const MYTH_STATEMENTS: MythStatement[] = [
  // ── L1 lengvas (vaikai 9–12) ──────────────────────────────────────────
  {
    id: "myt_001", level: "lengvas", isTrue: true, emoji: "🐝",
    texts: {
      lt: { st: "Bitės gamina medų.", ex: "Tiesa! Bitės renka nektarą ir paverčia jį medumi avilyje." },
      en: { st: "Bees make honey.", ex: "True! Bees collect nectar and turn it into honey in the hive." },
    },
  },
  {
    id: "myt_002", level: "lengvas", isTrue: false, emoji: "☀️",
    texts: {
      lt: { st: "Saulė sukasi aplink Žemę.", ex: "Mitas! Yra atvirkščiai — Žemė apskrieja Saulę per metus." },
      en: { st: "The Sun goes around the Earth.", ex: "Myth! It's the other way round — Earth orbits the Sun once a year." },
    },
  },
  {
    id: "myt_003", level: "lengvas", isTrue: false, emoji: "🐧",
    texts: {
      lt: { st: "Pingvinai gyvena prie Šiaurės ašigalio.", ex: "Mitas! Pingvinai gyvena pietuose (pvz., Antarktidoje), o šiaurėje — baltosios meškos." },
      en: { st: "Penguins live at the North Pole.", ex: "Myth! Penguins live in the south (like Antarctica) — the north has polar bears." },
    },
  },
  {
    id: "myt_004", level: "lengvas", isTrue: true, emoji: "🕷️",
    texts: {
      lt: { st: "Voras turi aštuonias kojas.", ex: "Tiesa! Vabzdžiai turi 6 kojas, o vorai — 8." },
      en: { st: "A spider has eight legs.", ex: "True! Insects have 6 legs, but spiders have 8." },
    },
  },
  {
    id: "myt_005", level: "lengvas", isTrue: true, emoji: "🐟",
    texts: {
      lt: { st: "Žuvys kvėpuoja žiaunomis.", ex: "Tiesa! Žiaunos paima deguonį tiesiai iš vandens." },
      en: { st: "Fish breathe with gills.", ex: "True! Gills take oxygen straight from the water." },
    },
  },
  {
    id: "myt_006", level: "lengvas", isTrue: false, emoji: "🌙",
    texts: {
      lt: { st: "Mėnulis šviečia savo paties šviesa.", ex: "Mitas! Mėnulis tik atspindi Saulės šviesą — pats jis nešviečia." },
      en: { st: "The Moon shines with its own light.", ex: "Myth! The Moon only reflects sunlight — it makes no light of its own." },
    },
  },
  {
    id: "myt_007", level: "lengvas", isTrue: true, emoji: "🐘",
    texts: {
      lt: { st: "Dramblys yra didžiausias sausumos gyvūnas.", ex: "Tiesa! Afrikinis dramblys sveria iki 6 tonų — sausumos rekordininkas." },
      en: { st: "The elephant is the largest land animal.", ex: "True! The African elephant weighs up to 6 tonnes — the land record holder." },
    },
  },
  {
    id: "myt_008", level: "lengvas", isTrue: false, emoji: "🦇",
    texts: {
      lt: { st: "Šikšnosparnis yra paukštis.", ex: "Mitas! Šikšnosparnis — vienintelis skraidantis ŽINDUOLIS." },
      en: { st: "A bat is a bird.", ex: "Myth! The bat is the only flying MAMMAL." },
    },
  },
  {
    id: "myt_009", level: "lengvas", isTrue: true, emoji: "🧊",
    texts: {
      lt: { st: "Ledas plaukia vandens paviršiuje.", ex: "Tiesa! Ledas lengvesnis už vandenį, todėl neskęsta." },
      en: { st: "Ice floats on water.", ex: "True! Ice is lighter than water, so it doesn't sink." },
    },
  },
  {
    id: "myt_010", level: "lengvas", isTrue: false, emoji: "🥕",
    texts: {
      lt: { st: "Morkos užaugina naktinį matymą.", ex: "Mitas! Morkos naudingos akims, bet matyti tamsoje kaip pelėda neišmokysi." },
      en: { st: "Carrots give you night vision.", ex: "Myth! Carrots are good for eyes, but they won't make you see in the dark." },
    },
  },
  // ── L2 vidutinis (paaugliai) ──────────────────────────────────────────
  {
    id: "myt_011", level: "vidutinis", isTrue: false, emoji: "⚡",
    texts: {
      lt: { st: "Žaibas niekada netrenkia du kartus į tą pačią vietą.", ex: "Mitas! Trenkia — aukšti bokštai žaibą „gaudo” dešimtis kartų per metus." },
      en: { st: "Lightning never strikes the same place twice.", ex: "Myth! It does — tall towers get struck dozens of times a year." },
    },
  },
  {
    id: "myt_012", level: "vidutinis", isTrue: false, emoji: "🧱",
    texts: {
      lt: { st: "Didžioji kinų siena matoma iš kosmoso plika akimi.", ex: "Mitas! Astronautai patvirtina: plika akimi jos nesimato." },
      en: { st: "The Great Wall of China is visible from space with the naked eye.", ex: "Myth! Astronauts confirm: you can't see it with the naked eye." },
    },
  },
  {
    id: "myt_013", level: "vidutinis", isTrue: false, emoji: "🐠",
    texts: {
      lt: { st: "Auksinė žuvelė viską pamiršta per tris sekundes.", ex: "Mitas! Tyrimai rodo, kad ji atsimena ištisus mėnesius." },
      en: { st: "A goldfish forgets everything in three seconds.", ex: "Myth! Studies show goldfish remember things for months." },
    },
  },
  {
    id: "myt_014", level: "vidutinis", isTrue: true, emoji: "🔊",
    texts: {
      lt: { st: "Garsas vandenyje sklinda greičiau nei ore.", ex: "Tiesa! Vandenyje garsas lekia maždaug 4 kartus greičiau." },
      en: { st: "Sound travels faster in water than in air.", ex: "True! In water, sound moves about 4 times faster." },
    },
  },
  {
    id: "myt_015", level: "vidutinis", isTrue: false, emoji: "🐭",
    texts: {
      lt: { st: "Pelės labiausiai mėgsta sūrį.", ex: "Mitas! Pelės labiau renkasi grūdus ir vaisius — sūris joms per stiprus." },
      en: { st: "Mice love cheese more than anything.", ex: "Myth! Mice prefer grains and fruit — cheese is too strong for them." },
    },
  },
  {
    id: "myt_016", level: "vidutinis", isTrue: false, emoji: "🐂",
    texts: {
      lt: { st: "Bulių siutina raudona spalva.", ex: "Mitas! Buliai raudonos neskiria — juos erzina mojuojantis audeklas." },
      en: { st: "The colour red makes bulls angry.", ex: "Myth! Bulls can't see red — it's the waving cape that annoys them." },
    },
  },
  {
    id: "myt_017", level: "vidutinis", isTrue: false, emoji: "🐦",
    texts: {
      lt: { st: "Išsigandęs strutis slepia galvą smėlyje.", ex: "Mitas! Strutis bėga (iki 70 km/val.) arba ginasi kojomis — galvos neslepia." },
      en: { st: "A scared ostrich buries its head in the sand.", ex: "Myth! Ostriches run (up to 70 km/h) or kick — they never bury their heads." },
    },
  },
  {
    id: "myt_018", level: "vidutinis", isTrue: false, emoji: "🧠",
    texts: {
      lt: { st: "Žmogus naudoja tik dešimtadalį smegenų.", ex: "Mitas! Skenavimai rodo, kad dirba VISOS smegenų sritys — tik ne visos vienu metu." },
      en: { st: "Humans use only ten percent of their brain.", ex: "Myth! Scans show ALL brain areas work — just not all at once." },
    },
  },
  {
    id: "myt_019", level: "vidutinis", isTrue: true, emoji: "🍌",
    texts: {
      lt: { st: "Bananai auga ne ant medžių, o ant milžiniškos žolės.", ex: "Tiesa! Bananas — žolinis augalas; jo „kamienas” yra iš susisukusių lapų." },
      en: { st: "Bananas grow on a giant herb, not a tree.", ex: "True! The banana plant is a herb — its \"trunk\" is made of rolled leaves." },
    },
  },
  {
    id: "myt_020", level: "vidutinis", isTrue: true, emoji: "🍅",
    texts: {
      lt: { st: "Pomidoras botaniškai yra uoga.", ex: "Tiesa! Botanikoje pomidoras — uoga, kaip ir bananas ar kivis." },
      en: { st: "Botanically, a tomato is a berry.", ex: "True! In botany the tomato is a berry — just like bananas and kiwis." },
    },
  },
  // ── L3 sunkus (suaugę) ────────────────────────────────────────────────
  {
    id: "myt_021", level: "sunkus", isTrue: false, emoji: "🎖️",
    texts: {
      lt: { st: "Napoleonas buvo neįprastai žemo ūgio.", ex: "Mitas! Jis buvo ~169 cm — vidutinis to meto ūgis. Mitą sukūrė karikatūros." },
      en: { st: "Napoleon was unusually short.", ex: "Myth! He was ~169 cm — average for his time. Caricatures created the myth." },
    },
  },
  {
    id: "myt_022", level: "sunkus", isTrue: false, emoji: "🛡️",
    texts: {
      lt: { st: "Vikingai nešiojo šalmus su ragais.", ex: "Mitas! Archeologai raguotų kovos šalmų nerado — ragai atėjo iš XIX a. operų." },
      en: { st: "Vikings wore horned helmets.", ex: "Myth! Archaeologists found no horned battle helmets — the horns came from 19th-century operas." },
    },
  },
  {
    id: "myt_023", level: "sunkus", isTrue: false, emoji: "🎓",
    texts: {
      lt: { st: "Einšteinui mokykloje nesisekė matematika.", ex: "Mitas! Matematika jam sekėsi puikiai — būdamas 15 jis jau mokėjo aukštąją." },
      en: { st: "Einstein was bad at math in school.", ex: "Myth! He excelled at it — by 15 he had mastered calculus." },
    },
  },
  {
    id: "myt_024", level: "sunkus", isTrue: false, emoji: "🩸",
    texts: {
      lt: { st: "Kraujas venose yra mėlynas.", ex: "Mitas! Kraujas visada raudonas — venos tik ATRODO melsvos pro odą." },
      en: { st: "Blood in your veins is blue.", ex: "Myth! Blood is always red — veins only LOOK bluish through the skin." },
    },
  },
  {
    id: "myt_025", level: "sunkus", isTrue: false, emoji: "🪒",
    texts: {
      lt: { st: "Nuskusti plaukai atauga storesni.", ex: "Mitas! Skutimas plauko šaknies nekeičia — ataugęs galiukas tik atrodo šiurkštesnis." },
      en: { st: "Shaved hair grows back thicker.", ex: "Myth! Shaving doesn't change the root — the regrown tip just feels coarser." },
    },
  },
  {
    id: "myt_026", level: "sunkus", isTrue: true, emoji: "☕",
    texts: {
      lt: { st: "Kavos pupelės yra vaisiaus sėklos.", ex: "Tiesa! Kavos „pupelės” — kavamedžio uogų sėklos." },
      en: { st: "Coffee beans are the seeds of a fruit.", ex: "True! Coffee \"beans\" are the seeds of coffee cherries." },
    },
  },
  {
    id: "myt_027", level: "sunkus", isTrue: true, emoji: "🗼",
    texts: {
      lt: { st: "Eifelio bokštas vasarą būna aukštesnis.", ex: "Tiesa! Karštyje metalas plečiasi — bokštas paauga iki ~15 cm." },
      en: { st: "The Eiffel Tower is taller in summer.", ex: "True! Metal expands in heat — the tower grows up to ~15 cm." },
    },
  },
  {
    id: "myt_028", level: "sunkus", isTrue: true, emoji: "🦪",
    texts: {
      lt: { st: "Perlas acte pamažu ištirpsta.", ex: "Tiesa! Perlas — kalcio karbonatas, kurį acto rūgštis lėtai ištirpdo." },
      en: { st: "A pearl slowly dissolves in vinegar.", ex: "True! Pearls are calcium carbonate, which vinegar's acid slowly dissolves." },
    },
  },
  {
    id: "myt_029", level: "sunkus", isTrue: true, emoji: "❄️",
    texts: {
      lt: { st: "Antarktida yra didžiausia dykuma pasaulyje.", ex: "Tiesa! Dykumą apibrėžia kritulių trūkumas — o Antarktidoje jų beveik nėra." },
      en: { st: "Antarctica is the largest desert on Earth.", ex: "True! Deserts are defined by lack of precipitation — and Antarctica gets almost none." },
    },
  },
  {
    id: "myt_030", level: "sunkus", isTrue: false, emoji: "🦁",
    texts: {
      lt: { st: "Liūtų būryje medžioja daugiausia patinai.", ex: "Mitas! Apie 90 % medžioklių atlieka liūtės — patinai saugo teritoriją." },
      en: { st: "In a pride, male lions do most of the hunting.", ex: "Myth! Lionesses do about 90% of the hunting — males guard the territory." },
    },
  },
  // ── L4 ekstremalus (žinovai) ──────────────────────────────────────────
  {
    id: "myt_031", level: "ekstremalus", isTrue: true, emoji: "🐙",
    texts: {
      lt: { st: "Aštuonkojo kraujas yra mėlynas.", ex: "Tiesa! Vietoj geležies jo kraujyje varis (hemocianinas) — todėl mėlynas." },
      en: { st: "An octopus has blue blood.", ex: "True! Its blood uses copper (hemocyanin) instead of iron — hence the blue colour." },
    },
  },
  {
    id: "myt_032", level: "ekstremalus", isTrue: false, emoji: "🪟",
    texts: {
      lt: { st: "Stiklas yra labai lėtai tekantis skystis.", ex: "Mitas! Stiklas — amorfinis kietasis kūnas. Seni langai storesni apačioje dėl gamybos, ne tekėjimo." },
      en: { st: "Glass is a very slowly flowing liquid.", ex: "Myth! Glass is an amorphous solid. Old windows are thicker at the bottom due to manufacturing, not flow." },
    },
  },
  {
    id: "myt_033", level: "ekstremalus", isTrue: true, emoji: "🧬",
    texts: {
      lt: { st: "Daugiau nei pusė žmogaus genų sutampa su banano genais.", ex: "Tiesa! Apie 60 % mūsų genų turi atitikmenis banane — gyvybė labai gimininga." },
      en: { st: "More than half of human genes have a match in bananas.", ex: "True! About 60% of our genes have a banana counterpart — life is deeply related." },
    },
  },
  {
    id: "myt_034", level: "ekstremalus", isTrue: true, emoji: "🍯",
    texts: {
      lt: { st: "Tinkamai laikomas medus nesugenda tūkstantmečius.", ex: "Tiesa! Faraonų kapuose rastas medus vis dar buvo valgomas." },
      en: { st: "Properly stored honey stays good for thousands of years.", ex: "True! Honey found in pharaohs' tombs was still edible." },
    },
  },
  {
    id: "myt_035", level: "ekstremalus", isTrue: true, emoji: "🌕",
    texts: {
      lt: { st: "Mėnulis kasmet tolsta nuo Žemės.", ex: "Tiesa! Lazeriniai matavimai rodo: ~3,8 cm per metus." },
      en: { st: "The Moon drifts away from Earth every year.", ex: "True! Laser measurements show ~3.8 cm per year." },
    },
  },
  {
    id: "myt_036", level: "ekstremalus", isTrue: false, emoji: "💅",
    texts: {
      lt: { st: "Plaukai ir nagai auga ir po mirties.", ex: "Mitas! Tai iliuzija — oda susitraukia, todėl nagai tik ATRODO ilgesni." },
      en: { st: "Hair and nails keep growing after death.", ex: "Myth! It's an illusion — skin shrinks, so nails only LOOK longer." },
    },
  },
  {
    id: "myt_037", level: "ekstremalus", isTrue: true, emoji: "🥤",
    texts: {
      lt: { st: "Šviesa vandenyje sklinda lėčiau nei vakuume.", ex: "Tiesa! Vandenyje šviesa lėtėja ~25 % — todėl šiaudelis stiklinėje „lūžta”." },
      en: { st: "Light travels slower in water than in a vacuum.", ex: "True! Light slows ~25% in water — that's why a straw looks \"bent\" in a glass." },
    },
  },
  {
    id: "myt_038", level: "ekstremalus", isTrue: true, emoji: "🪸",
    texts: {
      lt: { st: "Didysis barjerinis rifas — didžiausia gyvų organizmų sukurta struktūra.", ex: "Tiesa! ~2 300 km ilgio rifą pastatė milijardai mažyčių koralų polipų." },
      en: { st: "The Great Barrier Reef is the largest structure built by living things.", ex: "True! The ~2,300 km reef was built by billions of tiny coral polyps." },
    },
  },
  {
    id: "myt_039", level: "ekstremalus", isTrue: true, emoji: "🪐",
    texts: {
      lt: { st: "Venera karštesnė už Merkurijų, nors yra toliau nuo Saulės.", ex: "Tiesa! Tirštas Veneros CO₂ apvalkalas veikia kaip šiltnamis — ~465 °C." },
      en: { st: "Venus is hotter than Mercury despite being farther from the Sun.", ex: "True! Venus's thick CO₂ blanket works like a greenhouse — ~465 °C." },
    },
  },
  {
    id: "myt_040", level: "ekstremalus", isTrue: false, emoji: "🖐️",
    texts: {
      lt: { st: "Žmogus turi lygiai penkis pojūčius.", ex: "Mitas! Turime ir pusiausvyrą, kūno padėties, temperatūros, skausmo jutimus — gerokai daugiau nei 5." },
      en: { st: "Humans have exactly five senses.", ex: "Myth! We also sense balance, body position, temperature, pain — far more than 5." },
    },
  },
];
