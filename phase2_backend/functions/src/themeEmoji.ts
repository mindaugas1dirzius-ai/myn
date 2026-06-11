/**
 * themeEmoji — atsakymų paveikslėliai NE gamtos temoms + temos atsarginis ženklas.
 *
 * DU dalykai:
 *  1) Leksikonai (EN + LT): konkreti SĄVOKA/ĮRENGINYS → emoji (pvz. Chatbot → 🤖,
 *     Naršyklė → 🌐). Įmonės/metai/asmenys SĄMONINGAI be emoji — jiems prasmingo
 *     paveikslėlio nėra, tad jie krenta į temos atsarginį ženklą.
 *  2) themeFallback(category) — kai variantas neturi konkretaus paveikslėlio,
 *     rodom PAGAL TEMĄ neutralų ženklą (NE lapuką visur). Gamta = 🍃, tech = 🔹...
 *     Atsarginis ženklas NIEKADA nėra nė vienas atsakymas (neišduoda).
 *
 * Paieška (emojiForOption) sulieja VISŲ temų leksikonus į vieną žemėlapį —
 * tas pats žodis (pvz. „Telefonas") tinka bet kurioje temoje, apibrėžtas kartą.
 */

import { NATURE_EMOJI } from "./natureEmoji";
import { TriviaCategory } from "./triviaTypes";

/**
 * Temos atsarginis ženklas — rodomas, kai konkretaus paveikslėlio nėra.
 * 🚨 NE lapukai visur: kiekvienai temai savas neutralus, su tema siejamas ženklas,
 * kuris NĖRA nė vienas iš atsakymų (tad neišduoda) ir vienodas ant visų → neišskiria.
 */
const THEME_FALLBACK: Record<TriviaCategory, string> = {
  nature: "🍃",
  tech: "🔹",
  geo: "📍",
  history: "⏳",
  food: "🍴",
  sport: "🏅",
  body: "⚕️",
  pop: "⭐",
};

export function themeFallback(category: TriviaCategory): string {
  return THEME_FALLBACK[category] ?? "🔹";
}

/**
 * TECH atsakymų leksikonas (EN + LT). Tik tai, kas turi PRASMINGĄ, neišduodantį
 * paveikslėlį: įrenginiai, sąvokos, internetas, kosmosas, kasdieniai veiksmai.
 * Įmonės (Apple/Google…), metai (2007…), asmenys (Bill Gates…), santrumpos
 * (CPU/RAM…) ČIA NEDEDAMI — jie gaus temos atsarginį ženklą 🔹.
 */
export const TECH_EMOJI: Record<string, string> = {
  // ---------- Įrenginiai / periferija ----------
  "Laptop": "💻", "Nešiojamas kompiuteris": "💻",
  "Desktop": "🖥️", "Stalinis": "🖥️", "Stalinis kompiuteris": "🖥️",
  "Monitor": "🖥️", "Monitorius": "🖥️",
  "Server": "🗄️", "Serveris": "🗄️",
  "Router": "📡", "Maršrutizatorius": "📡",
  "Printer": "🖨️", "Spausdintuvas": "🖨️",
  "Phone": "📱", "A phone": "📱", "Telefonas": "📱",
  "Smartphone": "📱", "Išmanusis telefonas": "📱",
  "Keyboard": "⌨️", "Klaviatūra": "⌨️",
  "Mouse": "🖱️", "Pelė": "🖱️",
  "Battery": "🔋", "The battery": "🔋", "Baterija": "🔋", "Bateriją": "🔋",
  "Camera": "📷", "Kamera": "📷",
  "Speaker": "🔊", "Garsiakalbis": "🔊",
  "Headphones": "🎧", "Ausinės": "🎧",
  "Smartwatch": "⌚", "Išmanusis laikrodis": "⌚",
  "Robot": "🤖", "Robotas": "🤖",
  "USB drive": "💾", "USB atmintukas": "💾",

  // ---------- Sąvokos / programinė ----------
  "Chatbot": "🤖", "Pokalbių robotas": "🤖",
  "Browser": "🌐", "Naršyklė": "🌐",
  "Firewall": "🧱", "Ugniasienė": "🧱",
  "Database": "🗄️", "Duomenų bazė": "🗄️",
  "Spreadsheet": "📊", "Skaičiuoklė": "📊",
  "Compiler": "⚙️", "Kompiliatorius": "⚙️",
  "The cursor": "🖱️", "Cursor": "🖱️", "Žymeklį": "🖱️", "Žymeklis": "🖱️",
  "Artificial Intelligence": "🤖", "Dirbtinis intelektas": "🤖",
  "Password": "🔑", "Slaptažodis": "🔑",
  "Code": "💻", "Kodas": "💻",
  "Math": "🧮", "Skaičiavimu": "🧮", "Skaičiavimas": "🧮",

  // ---------- Internetas / paštas ----------
  "Email": "📧", "Electronic mail": "📧", "Elektroninis paštas": "📧",
  "World Wide Web": "🌐",
  "Web pages": "🌐", "Interneto puslapius": "🌐", "Interneto puslapiai": "🌐",
  "A web address": "🔗", "Web address": "🔗", "Interneto adresas": "🔗",

  // ---------- Kosmosas / dangus ----------
  "The Moon": "🌙", "Mėnulis": "🌙", "Mėnulyje": "🌙",
  "The Sun": "☀️", "Saulė": "☀️", "Saulėje": "☀️",
  "Sunlight": "☀️", "Saulės šviesa": "☀️",
  "Earth": "🌍", "Žemė": "🌍", "Žemėje": "🌍",
  "Mars": "🔴", "Marsas": "🔴", "Marse": "🔴",
  "Jupiter": "🪐", "Jupiteris": "🪐", "Jupiteryje": "🪐",
  "Saturn": "🪐", "Saturnas": "🪐", "Saturne": "🪐",
  "Rocket": "🚀", "Raketa": "🚀",
  "Satellite": "🛰️", "Palydovas": "🛰️",

  // ---------- Medžiagos ----------
  "Diamond": "💎", "Deimantas": "💎",

  // ---------- Kasdieniai veiksmai (lengvi „ką daro?" klausimai) ----------
  "Cleans floors": "🧹", "Valo grindis": "🧹",
  "Cooks food": "🍳", "Gamina maistą": "🍳", "Gamina vakarienę": "🍳",
  "Washes clothes": "🧺", "Skalbia": "🧺", "Skalbia drabužius": "🧺",
  "Mows grass": "🌿", "Pjauna žolę": "🌿",
  "Paints walls": "🖌️", "Dažo sienas": "🖌️",
  "Drives cars": "🚗", "Vairuoja": "🚗",
  "Prints on paper": "🖨️", "Spausdina ant popieriaus": "🖨️",
  "Connects devices": "🔌", "Sujungia įrenginius": "🔌",
  "Stores power": "🔋", "Kaupia energiją": "🔋",
  "Refills the battery": "🔋", "Papildo bateriją": "🔋",
  "Tells the time": "⏰", "Rodo laiką": "⏰",
  "Makes coffee": "☕", "Verda kavą": "☕",
  "Waters plants": "🪴", "Laisto augalus": "🪴",
  "Boils water": "💧", "Verda vandenį": "💧",
  "Takes photos": "📷", "Photos": "📷", "Nuotraukas": "📷",
};

/**
 * SPORT atsakymų leksikonas (EN + LT). Sporto ŠAKOS ir INVENTORIUS — saugu, nes
 * paveikslėlis tik ILIUSTRUOJA atsakymo žodį (pvz. 🏒 prie „Ledo ritulys"), o NE
 * išduoda, kuris teisingas (žaidėjas vis tiek turi žinoti faktą). Skaičiai, vietos
 * (Tokijas, Paryžius), terminai (Deuce, Ace) ČIA NEDEDAMI — jie gauna temos ženklą 🏅.
 *
 * 🚨 Maistui SĄMONINGAI NĖRA leksikono: maisto klausimai dažnai skiria pagal SPALVĄ
 * ar formą („kuris RAUDONAS vaisius?"), tad 🍒🍋🥝 IŠDUOTŲ atsakymą per spalvą
 * (kaip spalvų kvadratai). Maistas → temos ženklas 🍴.
 */
export const SPORT_EMOJI: Record<string, string> = {
  // ---------- Kamuoliniai ----------
  "Football": "⚽", "Soccer": "⚽", "Futbolas": "⚽",
  "Basketball": "🏀", "Krepšinis": "🏀",
  "American football": "🏈", "Amerikietiškas futbolas": "🏈",
  "Baseball": "⚾", "Beisbolas": "⚾",
  "Tennis": "🎾", "Tenisas": "🎾",
  "Volleyball": "🏐", "Tinklinis": "🏐",
  "Table tennis": "🏓", "Stalo tenisas": "🏓", "Ping pong": "🏓",
  "Badminton": "🏸", "Badmintonas": "🏸",
  "Rugby": "🏉", "Regbis": "🏉",
  "Cricket": "🏏", "Kriketas": "🏏",
  "Handball": "🤾", "Rankinis": "🤾",
  "Golf": "⛳", "Golfas": "⛳",
  "Bowling": "🎳", "Boulingas": "🎳",
  "Field hockey": "🏑", "Žolės riedulys": "🏑", "Žolės ritulys": "🏑",

  // ---------- Ant ledo / sniego ----------
  "Ice hockey": "🏒", "Ledo ritulys": "🏒",
  "Figure skating": "⛸️", "Dailusis čiuožimas": "⛸️",
  "Skiing": "⛷️", "Slidinėjimas": "⛷️",
  "Snowboarding": "🏂", "Snieglentės": "🏂", "Snieglenčių sportas": "🏂",

  // ---------- Atletika / bėgimas ----------
  "Running": "🏃", "Bėgimas": "🏃", "Bėgimą": "🏃",
  "Athletics": "🏃", "Lengvoji atletika": "🏃",
  "Sprinting": "🏃", "Sprintas": "🏃", "Sprinte": "🏃",
  "Marathon": "🏃", "Maratonas": "🏃",
  "High jump": "🤸", "Šuolis į aukštį": "🤸",
  "Long jump": "🤸", "Šuolis į tolį": "🤸",
  "Gymnastics": "🤸", "Gimnastika": "🤸",

  // ---------- Vandens ----------
  "Swimming": "🏊", "Plaukimas": "🏊", "Plaukimą": "🏊",
  "Surfing": "🏄", "Banglentės": "🏄", "Banglenčių sportas": "🏄",
  "Rowing": "🚣", "Irklavimas": "🚣",
  "Sailing": "⛵", "Buriavimas": "⛵",
  "Diving": "🤿", "Nardymas": "🤿",
  "Water polo": "🤽", "Vandensvydis": "🤽",

  // ---------- Dviračiai / variklis ----------
  "Cycling": "🚴", "Dviračių sportas": "🚴", "Dviračių": "🚴", "Dviračiai": "🚴",
  "Car racing": "🏎️", "Automobilių lenktynės": "🏎️", "Formula 1": "🏎️",
  "Motorsport": "🏎️", "Motorsportas": "🏎️",
  "Horse racing": "🏇", "Žirgų lenktynės": "🏇", "Jojimas": "🏇", "Equestrian": "🏇",

  // ---------- Kovos ----------
  "Boxing": "🥊", "Boksas": "🥊",
  "Wrestling": "🤼", "Imtynės": "🤼",
  "Judo": "🥋", "Dziudo": "🥋",
  "Karate": "🥋", "Karatė": "🥋",
  "Taekwondo": "🥋", "Tekvondo": "🥋",
  "Fencing": "🤺", "Fechtavimas": "🤺", "Fechtavimasis": "🤺",

  // ---------- Taiklumas / kita ----------
  "Archery": "🏹", "Šaudymas iš lanko": "🏹",
  "Weightlifting": "🏋️", "Sunkioji atletika": "🏋️",
  "Chess": "♟️", "Šachmatai": "♟️",
  "Climbing": "🧗", "Laipiojimas": "🧗", "Alpinizmas": "🧗",
  "Skateboarding": "🛹", "Riedlentės": "🛹",
  "Darts": "🎯", "Smiginis": "🎯",
  "Billiards": "🎱", "Biliardas": "🎱",

  // ---------- Inventorius / sąvokos ----------
  "Racket": "🎾", "Raketė": "🎾", "Rakete": "🎾",
  "Bat": "🏏", "Bita": "🏏", "Lazda": "🏏",
  "Puck": "🏒", "Ritulys": "🏒", "Ritulį": "🏒",
  "Net": "🥅", "Tinklas": "🥅", "Tinklą": "🥅",
  "Goal": "🥅", "A goal": "🥅", "Įvartis": "🥅",
  "Shuttlecock": "🏸", "Plunksniukas": "🏸", "Plunksniuką": "🏸",
  "Whistle": "📣", "Švilpukas": "📣", "Švilpuką": "📣",
  "Medal": "🏅", "Medals": "🏅", "Medalis": "🏅", "Medalius": "🏅",
  "Gold": "🥇", "Auksas": "🥇", "Aukso medalis": "🥇",
  "Silver": "🥈", "Sidabras": "🥈",
  "Bronze": "🥉", "Bronza": "🥉",
  "Trophy": "🏆", "Taurė": "🏆",
};

/**
 * FOOD atsakymų leksikonas (EN + LT). Konkretūs VAISIAI, DARŽOVĖS, ŪKIO GYVŪNAI —
 * saugu, nes paveikslėlis tik ILIUSTRUOJA paties varianto žodį (🍎 prie „Obuolys",
 * 🥕 prie „Morka"), o NE išduoda, kuris teisingas (žaidėjas vis tiek turi žinoti
 * faktą — pvz. „iš ko sidras? → Obuolys"). „Viskas arba nieko" taisyklė
 * (triviaEngine) pasirūpina, kad paveikslėliai atsirastų TIK kai VISI 6 variantai
 * juos turi — kitaip visi gauna temos ženklą 🍴.
 *
 * 🚨 SPALVŲ klausimai („kokios spalvos morka?") naudoja spalvų ŽODŽIUS kaip variantus
 * (Oranžinė/Žalia/…), o jų ČIA NĖRA → krenta į 🍴 (jokio spalvos išdavimo).
 * Šalys, miestai, prieskoniai be aiškaus piešinio (Šafranas…) — irgi be emoji → 🍴.
 *
 * Pastaba: keletas vaisių neturi savo Unicode emoji (slyva, figa). Slyvai imam
 * artimiausią tamsų/violetinį vaisių 🫐, kad pilni „vaisių" klausimai (pvz. sidras)
 * vis tiek pražystų. Figa lieka be emoji → toks klausimas gauna 🍴 (saugu).
 */
export const FOOD_EMOJI: Record<string, string> = {
  // ---------- Vaisiai ----------
  "Apple": "🍎", "Obuolys": "🍎",
  "Green apple": "🍏", "Žalias obuolys": "🍏",
  "Pear": "🍐", "Kriaušė": "🍐",
  "Grape": "🍇", "Grapes": "🍇", "Vynuogė": "🍇", "Vynuogės": "🍇",
  "Cherry": "🍒", "Cherries": "🍒", "Vyšnia": "🍒", "Vyšnios": "🍒",
  "Peach": "🍑", "Persikas": "🍑",
  "Plum": "🫐", "Slyva": "🫐",
  "Banana": "🍌", "Bananas": "🍌",
  "Strawberry": "🍓", "Braškė": "🍓",
  "Lemon": "🍋", "Citrina": "🍋",
  "Orange": "🍊", "Apelsinas": "🍊",
  "Tangerine": "🍊", "Mandarinas": "🍊",
  "Kiwi": "🥝", "Kivis": "🥝",
  "Watermelon": "🍉", "Arbūzas": "🍉",
  "Melon": "🍈", "Melionas": "🍈",
  "Pineapple": "🍍", "Ananasas": "🍍",
  "Mango": "🥭",
  "Coconut": "🥥", "Kokosas": "🥥",

  // ---------- Daržovės ----------
  "Onion": "🧅", "Onions": "🧅", "Svogūnas": "🧅", "Svogūnai": "🧅",
  "Carrot": "🥕", "Carrots": "🥕", "Morka": "🥕", "Morkos": "🥕",
  "Potato": "🥔", "Potatoes": "🥔", "Bulvė": "🥔", "Bulvės": "🥔",
  "Tomato": "🍅", "Tomatoes": "🍅", "Pomidoras": "🍅", "Pomidorai": "🍅",
  "Cabbage": "🥬", "Kopūstas": "🥬",
  "Pepper": "🫑", "Peppers": "🫑", "Paprika": "🫑", "Paprikos": "🫑",
  "Cucumber": "🥒", "Cucumbers": "🥒", "Agurkas": "🥒", "Agurkai": "🥒",
  "Corn": "🌽", "Kukurūzas": "🌽", "Kukurūzai": "🌽",
  "Garlic": "🧄", "Česnakas": "🧄",
  "Eggplant": "🍆", "Baklažanas": "🍆",
  "Broccoli": "🥦", "Brokolis": "🥦",

  // ---------- Ūkio gyvūnai (mėsos/produktų kilmė) ----------
  "Cow": "🐄", "Karvė": "🐄",
  "Pig": "🐷", "Kiaulė": "🐷",
  "Chicken": "🐔", "Višta": "🐔",
  "Sheep": "🐑", "Avis": "🐑",
  "Goat": "🐐", "Ožka": "🐐",

  // ---------- Riešutai (VISI vienas ženklas 🥜) ----------
  // Unicode neturi atskiro emoji kiekvienai riešutų rūšiai (migdolas≠pistacija≠
  // pekanas), todėl VISOS rūšys → 🥜. Taip „tik riešutų" klausimuose (marcipanas,
  // pesto) visi 6 variantai gauna tą patį 🥜 → NIEKADA neišduoda teisingo (VISKAS-
  // ARBA-NIEKO suveikia, nes vienodas ženklas nekoreliuoja su atsakymu). SVARBU:
  // bendrinis žodis „Nuts"/„Riešutai" SĄMONINGAI neįtrauktas (kad mišriuose
  // klausimuose, pvz. „iš kurios augalo dalies?", kristų į saugų 🍴 ženklą).
  "Almond": "🥜", "Almonds": "🥜", "Migdolas": "🥜", "Migdolai": "🥜", "Migdolų": "🥜",
  "Walnut": "🥜", "Walnuts": "🥜", "Graikinis riešutas": "🥜",
  "Graikiniai riešutai": "🥜", "Graikinių": "🥜",
  "Peanut": "🥜", "Peanuts": "🥜", "Žemės riešutas": "🥜",
  "Žemės riešutai": "🥜", "Žemės riešutų": "🥜",
  "Cashew": "🥜", "Cashews": "🥜", "Anakardis": "🥜",
  "Anakardžiai": "🥜", "Anakardžių": "🥜",
  "Pistachio": "🥜", "Pistachios": "🥜", "Pistacija": "🥜",
  "Pistacijos": "🥜", "Pistacijų": "🥜",
  "Pecan": "🥜", "Pecans": "🥜", "Pekanas": "🥜", "Pekanai": "🥜", "Pekano": "🥜",
  "Hazelnut": "🥜", "Hazelnuts": "🥜", "Lazdyno riešutas": "🥜",
  "Lazdynų riešutai": "🥜", "Lazdynų": "🥜",
  "Pine nut": "🥜", "Pine nuts": "🥜", "Pinijų riešutai": "🥜", "Pinijų": "🥜",

  // ---------- Pagrindiniai produktai / skysčiai (kasdieniai – TURI paveikslėlį) ----------
  // Kiekvienas rodo SAVO daiktą (kaip 🦇 prie „Šikšnosparnis") → iliustruoja žodį,
  // NEišduoda atsakymo. „iš ko gaminama…" klausimuose variantai būna kilmininku
  // (Pieno, Miltų…), todėl įtraukiam ir vns/dgs vardininką, ir kilmininką.
  "Milk": "🥛", "Pienas": "🥛", "Pieno": "🥛",
  "Water": "💧", "Vanduo": "💧", "Vandens": "💧",
  "Honey": "🍯", "Medus": "🍯", "Medaus": "🍯",
  "Egg": "🥚", "Eggs": "🥚", "Kiaušinis": "🥚", "Kiaušiniai": "🥚",
  "Kiaušinių": "🥚", "Kiaušinio": "🥚",
  "Oil": "🫗", "Aliejus": "🫗", "Aliejaus": "🫗",
  "Flour": "🌾", "Miltai": "🌾", "Miltų": "🌾",
  "Salt": "🧂", "Druska": "🧂", "Druskos": "🧂",
  "Butter": "🧈", "Sviestas": "🧈", "Sviesto": "🧈",
  "Bread": "🍞", "Duona": "🍞", "Duonos": "🍞",
  "Cheese": "🧀", "Sūris": "🧀", "Sūrio": "🧀", "Sūrį": "🧀",
  "Rice": "🍚", "Ryžiai": "🍚", "Ryžių": "🍚",
  "Meat": "🥩", "Mėsa": "🥩", "Mėsos": "🥩",
  "Soup": "🍲", "Sriuba": "🍲", "Sriubos": "🍲",
  "Pasta": "🍝", "Makaronai": "🍝", "Makaronų": "🍝",
  "Pizza": "🍕", "Pica": "🍕", "Picos": "🍕",
  "Cake": "🍰", "Tortas": "🍰", "Torto": "🍰", "Pyragas": "🍰", "Pyrago": "🍰",
  "Chocolate": "🍫", "Šokoladas": "🍫", "Šokolado": "🍫",
  "Ice cream": "🍦", "Ledai": "🍦", "Ledų": "🍦",
  "Coffee": "☕", "Kava": "☕", "Kavos": "☕",
  "Tea": "🍵", "Arbata": "🍵", "Arbatos": "🍵",
  "Juice": "🧃", "Sultys": "🧃", "Sulčių": "🧃",

  // ---------- Patiekalai / gėrimai / saldumynai (kasdieniai) ----------
  "Salad": "🥗", "Salotos": "🥗", "Salotų": "🥗", "Salota": "🥗",
  "Stew": "🥘", "Troškinys": "🥘", "Troškinio": "🥘",
  "Sandwich": "🥪", "Sumuštinis": "🥪", "Sumuštinio": "🥪",
  "Pancake": "🥞", "Pancakes": "🥞", "Blynas": "🥞", "Blynai": "🥞", "Blynų": "🥞",
  "Dumpling": "🥟", "Dumplings": "🥟", "Koldūnas": "🥟", "Koldūnai": "🥟",
  "Koldūnų": "🥟", "Virtinukai": "🥟",
  "Cookie": "🍪", "Cookies": "🍪", "Sausainis": "🍪", "Sausainiai": "🍪", "Sausainių": "🍪",
  "Candy": "🍬", "Saldainis": "🍬", "Saldainiai": "🍬", "Saldainių": "🍬",
  "Donut": "🍩", "Doughnut": "🍩", "Spurga": "🍩", "Spurgos": "🍩",
  "Wine": "🍷", "Vynas": "🍷", "Vyno": "🍷",
  "Beer": "🍺", "Alus": "🍺", "Alaus": "🍺",
  "Fresh meat": "🥩", "Šviežia mėsa": "🥩",
  "Lettuce": "🥬", "Spinach": "🥬", "Špinatai": "🥬",
  "Beans": "🫘", "Pupelės": "🫘", "Pupelių": "🫘",
  "Seeds": "🌱", "Sėklos": "🌱", "Sėklų": "🌱",
  "Mushroom": "🍄", "Mushrooms": "🍄", "Grybas": "🍄", "Grybai": "🍄", "Grybų": "🍄",

  // ---------- Egzotiški vaisiai / daržovės + linksniai (potemėms) ----------
  // „iš kurio vaisiaus…" klausimuose variantai būna kilmininku (Avokado, Laimo,
  // Pomidoro…), tad įtraukiam vardininką IR linksnius, kad pilna eilė nušvistų.
  "Avocado": "🥑", "Avokadas": "🥑", "Avokado": "🥑", "Avokadų": "🥑",
  "Lime": "🍋", "Laimas": "🍋", "Laimo": "🍋", "Laimai": "🍋",
  "Olive": "🫒", "Olives": "🫒", "Alyvuogė": "🫒", "Alyvuogės": "🫒", "Alyvuogių": "🫒",
  "Ginger": "🫚", "Imbieras": "🫚", "Imbiero": "🫚",
  "Pomidoro": "🍅",
  "Agurko": "🥒", "Agurkų": "🥒",
  "Bulvių": "🥔",
  "Kukurūzų": "🌽",
  "Kopūsto": "🥬", "Kopūstų": "🥬",

  // ---------- Pasaulio virtuvių patiekalai (kiekvienas SAVO piešinys) ----------
  "Sushi": "🍣", "Sušis": "🍣", "Sušio": "🍣", "Sušį": "🍣",
  "Taco": "🌮", "Tacos": "🌮", "Takas": "🌮", "Takai": "🌮", "Tako": "🌮", "Takų": "🌮",
  "Curry": "🍛", "Karis": "🍛", "Kario": "🍛", "Karį": "🍛",
  "Burger": "🍔", "Hamburger": "🍔", "Mėsainis": "🍔", "Mėsainį": "🍔",
  "Hot dog": "🌭", "Dešrainis": "🌭",
  "Fries": "🍟", "Bulvytės": "🍟",
  "Burrito": "🌯", "Buritas": "🌯",
  "Ramen": "🍜", "Ramenas": "🍜",
  "Croissant": "🥐", "Kruasanas": "🥐",

  // ---------- Egzotiškos jūros gėrybės / baltymai (kiekvienas SAVO gyvūnas) ----------
  // Vienaskaitos dalis jau yra gamtos žodyne; čia – daugiskaita ir trūkstamos rūšys,
  // kad „iš ko gaminamas… ?" egzotikos klausimai (escargot ir pan.) nušvistų.
  "Sraigės": "🐌", "Snails": "🐌",
  "Varlės": "🐸", "Frogs": "🐸",
  "Oyster": "🦪", "Oysters": "🦪", "Austrė": "🦪", "Austrės": "🦪",
  "Clam": "🐚", "Clams": "🐚", "Geldelė": "🐚", "Geldelės": "🐚",
  "Squid": "🦑", "Kalmaras": "🦑", "Kalmarai": "🦑",
  "Eel": "🐟", "Ungurys": "🐟", "Unguriai": "🐟",
  "Aštuonkojai": "🐙", "Krabai": "🦀", "Krevetės": "🦐", "Shrimps": "🦐",
  "Kopūstai": "🥬",
};

/**
 * ŠALIŲ vėliavos (EN + LT, su linksniais). Kilmės/virtuvių klausimuose variantai
 * yra ŠALYS (Italija, Ispanija…). Vėliava SAUGI — ji iliustruoja šalies PAVADINIMĄ,
 * o NE išduoda, kuri teisinga (žaidėjas vis tiek turi žinoti, iš kur kilo patiekalas),
 * lygiai kaip 🦁 prie „Liūtas". IŠIMTIS: „kuri šalis turi ŠIĄ vėliavą?" klausimas
 * vis tiek išduotų — jį gaudo triviaEngine `flagQuestion` saugiklis (jokio emoji).
 */
export const COUNTRY_EMOJI: Record<string, string> = {
  "Italy": "🇮🇹", "Italija": "🇮🇹", "Italijos": "🇮🇹", "Italijoje": "🇮🇹",
  "Spain": "🇪🇸", "Ispanija": "🇪🇸", "Ispanijos": "🇪🇸", "Ispanijoje": "🇪🇸",
  "France": "🇫🇷", "Prancūzija": "🇫🇷", "Prancūzijos": "🇫🇷", "Prancūzijoje": "🇫🇷",
  "Greece": "🇬🇷", "Graikija": "🇬🇷", "Graikijos": "🇬🇷", "Graikijoje": "🇬🇷",
  "Japan": "🇯🇵", "Japonija": "🇯🇵", "Japonijos": "🇯🇵", "Japonijoje": "🇯🇵",
  "Brazil": "🇧🇷", "Brazilija": "🇧🇷", "Brazilijos": "🇧🇷", "Brazilijoje": "🇧🇷",
  "Mexico": "🇲🇽", "Meksika": "🇲🇽", "Meksikos": "🇲🇽", "Meksikoje": "🇲🇽",
  "Vietnam": "🇻🇳", "Vietnamas": "🇻🇳", "Vietnamo": "🇻🇳", "Vietname": "🇻🇳",
  "India": "🇮🇳", "Indija": "🇮🇳", "Indijos": "🇮🇳", "Indijoje": "🇮🇳",
  "Germany": "🇩🇪", "Vokietija": "🇩🇪", "Vokietijos": "🇩🇪", "Vokietijoje": "🇩🇪",
  "Egypt": "🇪🇬", "Egiptas": "🇪🇬", "Egipto": "🇪🇬", "Egipte": "🇪🇬",
  "China": "🇨🇳", "Kinija": "🇨🇳", "Kinijos": "🇨🇳", "Kinijoje": "🇨🇳",
  "Thailand": "🇹🇭", "Tailandas": "🇹🇭", "Tailando": "🇹🇭", "Tailande": "🇹🇭",
  "Korea": "🇰🇷", "South Korea": "🇰🇷", "Korėja": "🇰🇷", "Korėjos": "🇰🇷", "Korėjoje": "🇰🇷",
  "Poland": "🇵🇱", "Lenkija": "🇵🇱", "Lenkijos": "🇵🇱", "Lenkijoje": "🇵🇱",
  "Portugal": "🇵🇹", "Portugalija": "🇵🇹", "Portugalijos": "🇵🇹", "Portugalijoje": "🇵🇹",
  "Austria": "🇦🇹", "Austrija": "🇦🇹", "Austrijos": "🇦🇹", "Austrijoje": "🇦🇹",
  "Belgium": "🇧🇪", "Belgija": "🇧🇪", "Belgijos": "🇧🇪", "Belgijoje": "🇧🇪",
  "Turkey": "🇹🇷", "Turkija": "🇹🇷", "Turkijos": "🇹🇷", "Turkijoje": "🇹🇷",
  "Peru": "🇵🇪",
  "Morocco": "🇲🇦", "Marokas": "🇲🇦", "Maroko": "🇲🇦", "Maroke": "🇲🇦",
  "Hungary": "🇭🇺", "Vengrija": "🇭🇺", "Vengrijos": "🇭🇺", "Vengrijoje": "🇭🇺",
  "Czechia": "🇨🇿", "Czech Republic": "🇨🇿", "Čekija": "🇨🇿", "Čekijos": "🇨🇿", "Čekijoje": "🇨🇿",
  "Lebanon": "🇱🇧", "Libanas": "🇱🇧", "Libano": "🇱🇧", "Libane": "🇱🇧",
  "Cyprus": "🇨🇾", "Kipras": "🇨🇾", "Kipro": "🇨🇾", "Kipre": "🇨🇾",
  "Colombia": "🇨🇴", "Kolumbija": "🇨🇴", "Kolumbijos": "🇨🇴", "Kolumbijoje": "🇨🇴",
  "Canada": "🇨🇦", "Kanada": "🇨🇦", "Kanados": "🇨🇦", "Kanadoje": "🇨🇦",
  "USA": "🇺🇸", "United States": "🇺🇸", "JAV": "🇺🇸",
  "Netherlands": "🇳🇱", "Nyderlandai": "🇳🇱", "Nyderlandų": "🇳🇱", "Nyderlanduose": "🇳🇱", "Olandija": "🇳🇱",
  "Lithuania": "🇱🇹", "Lietuva": "🇱🇹", "Lietuvos": "🇱🇹", "Lietuvoje": "🇱🇹",
  "England": "🇬🇧", "United Kingdom": "🇬🇧", "Britain": "🇬🇧", "Anglija": "🇬🇧",
  "Anglijos": "🇬🇧", "Anglijoje": "🇬🇧", "Didžioji Britanija": "🇬🇧", "Jungtinė Karalystė": "🇬🇧",
  "Switzerland": "🇨🇭", "Šveicarija": "🇨🇭", "Šveicarijos": "🇨🇭", "Šveicarijoje": "🇨🇭",
  "Mongolia": "🇲🇳", "Mongolija": "🇲🇳", "Mongolijos": "🇲🇳", "Mongolijoje": "🇲🇳",
  "Romania": "🇷🇴", "Rumunija": "🇷🇴", "Rumunijos": "🇷🇴", "Rumunijoje": "🇷🇴",
  "Croatia": "🇭🇷", "Kroatija": "🇭🇷", "Kroatijos": "🇭🇷", "Kroatijoje": "🇭🇷",
  "Sweden": "🇸🇪", "Švedija": "🇸🇪", "Švedijos": "🇸🇪", "Švedijoje": "🇸🇪",
  "Laos": "🇱🇦", "Laosas": "🇱🇦", "Laoso": "🇱🇦", "Laose": "🇱🇦",
  // Papildomos – naudingos geografijos temai (kilmės klausimai jų neturi, bet nekenkia)
  "Russia": "🇷🇺", "Rusija": "🇷🇺", "Rusijos": "🇷🇺",
  "Norway": "🇳🇴", "Norvegija": "🇳🇴", "Norvegijos": "🇳🇴",
  "Finland": "🇫🇮", "Suomija": "🇫🇮", "Suomijos": "🇫🇮",
  "Denmark": "🇩🇰", "Danija": "🇩🇰", "Danijos": "🇩🇰",
  "Ireland": "🇮🇪", "Airija": "🇮🇪", "Airijos": "🇮🇪",
  "Australia": "🇦🇺", "Australija": "🇦🇺", "Australijos": "🇦🇺",
  "Argentina": "🇦🇷", "Argentinos": "🇦🇷",
  "Chile": "🇨🇱", "Čilė": "🇨🇱", "Čilės": "🇨🇱",
  "Ukraine": "🇺🇦", "Ukraina": "🇺🇦", "Ukrainos": "🇺🇦",
  "Latvia": "🇱🇻", "Latvija": "🇱🇻", "Latvijos": "🇱🇻",
  "Estonia": "🇪🇪", "Estija": "🇪🇪", "Estijos": "🇪🇪",
  "Ethiopia": "🇪🇹", "Etiopija": "🇪🇹", "Etiopijos": "🇪🇹",
  "Indonesia": "🇮🇩", "Indonezija": "🇮🇩", "Indonezijos": "🇮🇩",
};

/**
 * KŪNO atsakymų leksikonas (EN + LT, su linksniais). TIK tos anatominės dalys, kurios
 * turi aiškų Unicode emoji: organai (širdis🫀, smegenys🧠, plaučiai🫁), juslės
 * (akis👁️, ausis👂, nosis👃, liežuvis👅), galūnės, dantis, kaulas. Konkrečių emoji
 * NETURINTYS (kepenys, inkstas, skrandis, blužnis, smegenų sritys, kaulų pavadinimai,
 * kraujo ląstelės) SĄMONINGAI praleisti → tokie klausimai rodo švarų tekstą.
 * Juslių klausimuose variantai būna ĮNAGININKU (Akimi, Ausimis, Nosimi) ar vietininku.
 */
export const BODY_EMOJI: Record<string, string> = {
  // Organai (su aiškiu emoji)
  "Heart": "🫀", "Širdis": "🫀", "Širdį": "🫀",
  "Brain": "🧠", "Smegenys": "🧠", "Smegenų": "🧠",
  "Lungs": "🫁", "Lung": "🫁", "Plaučiai": "🫁", "Plautis": "🫁", "Plaučius": "🫁", "Plaučių": "🫁",
  "Skull": "💀", "Kaukolė": "💀", "Kaukolę": "💀",
  "Tooth": "🦷", "Teeth": "🦷", "Dantis": "🦷", "Dantys": "🦷", "Dantį": "🦷", "Dantų": "🦷",
  "Bone": "🦴", "Blood": "🩸", "Kraujas": "🩸", "Kraują": "🩸", "Kraujo": "🩸",
  "Nails": "💅", "Nagai": "💅", "Nagas": "💅",
  "Muscle": "💪", "Muscles": "💪", "Raumuo": "💪", "Raumenys": "💪", "Bicepsas": "💪",
  // Juslės (vardininkas + įnagininkas + vietininkas)
  "Eye": "👁️", "Akis": "👁️", "Akį": "👁️", "Akimi": "👁️", "Akimis": "👁️", "Akyje": "👁️",
  "Ear": "👂", "Ausis": "👂", "Ausį": "👂", "Ausimi": "👂", "Ausimis": "👂", "Ausyje": "👂",
  "Nose": "👃", "Nosis": "👃", "Nosį": "👃", "Nosimi": "👃", "Nosyje": "👃",
  "Tongue": "👅", "Liežuvis": "👅", "Liežuvį": "👅", "Liežuviu": "👅",
  "Mouth": "👄", "Burna": "👄", "Burną": "👄",
  // Galūnės
  "Hand": "✋", "Hands": "✋", "Ranka": "✋", "Ranką": "✋", "Rankos": "✋", "Rankomis": "✋",
  "Leg": "🦵", "Legs": "🦵", "Koja": "🦵", "Koją": "🦵", "Kojos": "🦵", "Kojomis": "🦵",
  "Foot": "🦶", "Feet": "🦶", "Pėda": "🦶", "Pėdą": "🦶",
};

/**
 * POP kultūros atsakymų leksikonas — MUZIKOS INSTRUMENTAI (kiekvienas turi aiškų emoji).
 * Saugu: 🎸 iliustruoja žodį „Gitara", o ne išduoda, kuris atsakymas teisingas.
 * Kompozitoriai, dainininkai, filmai, knygos, mitų herojai — TIKRINIAI VARDAI, be emoji.
 */
export const POP_EMOJI: Record<string, string> = {
  "Guitar": "🎸", "Gitara": "🎸", "Gitarą": "🎸",
  "Violin": "🎻", "Smuikas": "🎻", "Smuiką": "🎻",
  "Piano": "🎹", "Pianinas": "🎹", "Pianiną": "🎹", "Fortepijonas": "🎹",
  "Drums": "🥁", "Drum": "🥁", "Būgnai": "🥁", "Būgnas": "🥁", "Būgną": "🥁",
  "Flute": "🪈", "Fleita": "🪈", "Fleitą": "🪈",
  "Trumpet": "🎺", "Trimitas": "🎺", "Trimitą": "🎺",
  "Saxophone": "🎷", "Saksofonas": "🎷", "Saksofoną": "🎷",
  "Accordion": "🪗", "Akordeonas": "🪗", "Akordeoną": "🪗",
  "Microphone": "🎤", "Mikrofonas": "🎤", "Mikrofoną": "🎤",
};

/**
 * GAMTOS papildomi gyvūnai/vabzdžiai, turintys ATSKIRĄ emoji (užpildo natureEmoji spragas).
 * Tos pačios rūšies bendras emoji (pvz. visos žuvys 🐟) NEDEDAMAS — kitaip mišriame
 * klausime visi gautų vienodą → „viskas arba nieko" vis tiek saugiai paliktų tekstą.
 */
export const NATURE_EXTRA_EMOJI: Record<string, string> = {
  "Mosquito": "🦟", "Uodas": "🦟", "Uodą": "🦟",
  "Tarantula": "🕷️", "Tarantulas": "🕷️",
  "Cricket": "🦗", "Grasshopper": "🦗", "Žiogas": "🦗",
  "Caterpillar": "🐛", "Vikšras": "🐛",
  "Earthworm": "🪱", "Worm": "🪱", "Sliekas": "🪱", "Dėlė": "🪱",
  "Clownfish": "🐠", "Klounžuvė": "🐠",
  "Orca": "🐋", "Killer whale": "🐋", "Orka": "🐋",
};

/** Sulietas VISŲ temų leksikonas (gamta + tech + sportas + maistas + šalys + kūnas + pop + …). Paskutinė tema laimi raktą. */
const ALL_EMOJI: Record<string, string> = {
  ...NATURE_EMOJI,
  ...TECH_EMOJI,
  ...SPORT_EMOJI,
  ...FOOD_EMOJI,
  ...COUNTRY_EMOJI,
  ...BODY_EMOJI,
  ...POP_EMOJI,
  ...NATURE_EXTRA_EMOJI,
};

/** Atsakymo žodis → emoji (arba undefined). Apkarpo tarpus, kaip ir anksčiau. */
export function emojiForOption(option: string): string | undefined {
  return ALL_EMOJI[option.trim()];
}
