/**
 * natureEmoji — BENDRAS leksikonas: atsakymo žodis → emoji (EN + LT).
 *
 * KAM: prie kiekvieno atsakymo varianto parodom mažą susijusį paveikslėlį
 * (emoji) — gražiau ir gyviau, vaikui lengviau nuskaityti.
 *
 * 🚨 SAUGIKLIS (kad NEIŠDUOTUME atsakymo): emoji rodomi TIK „viskas arba nieko"
 * principu (žr. triviaEngine.assembleOptions). Jei bent vienas variantas neturi
 * emoji — nerodom NEI VIENO. Taip niekada nebūna, kad vienas variantas
 * išsiskiria ikonėle. Be to, leksikonas sąmoningai turi tik KONKREČIUS gyvūnus/
 * augalus (ne skaičius, ne abstrakcijas), o tos pačios temos variantai gauna
 * tos pačios stilistikos ikonas — vizualinio užuominos nėra.
 *
 * Pakartotinis naudojimas: tas pats žodis (pvz. „Lion"/„Liūtas") vartojamas
 * daugelyje klausimų, bet apibrėžiamas ČIA vieną kartą.
 */

export const NATURE_EMOJI: Record<string, string> = {
  // ---------- Vabzdžiai / smulkūs gyviai ----------
  "Bee": "🐝", "Bitė": "🐝",
  "Ant": "🐜", "Skruzdėlė": "🐜",
  "Wasp": "🐝", "Vapsva": "🐝",
  "Butterfly": "🦋", "Drugelis": "🦋",
  "Beetle": "🪲", "Vabalas": "🪲",
  "Fly": "🪰", "Musė": "🪰",
  "Spider": "🕷️", "Voras": "🕷️",
  "Snail": "🐌", "Sraigė": "🐌",

  // ---------- Žinduoliai ----------
  "Giraffe": "🦒", "Žirafa": "🦒",
  "Elephant": "🐘", "Dramblys": "🐘",
  "African Elephant": "🐘", "Afrikinis dramblys": "🐘",
  "Horse": "🐴", "Arklys": "🐴",
  "Camel": "🐪", "Kupranugaris": "🐪",
  "Moose": "🦌", "Briedis": "🦌",
  "Cheetah": "🐆", "Gepardas": "🐆",
  "Lion": "🦁", "Liūtas": "🦁",
  "Leopard": "🐆", "Leopardas": "🐆",
  "Tiger": "🐅", "Tigras": "🐅",
  "Jaguar": "🐆", "Jaguaras": "🐆",
  "Lynx": "🐈", "Lūšis": "🐈",
  "Hippo": "🦛", "Begemotas": "🦛",
  "Rhino": "🦏", "Raganosis": "🦏",
  "Bison": "🦬", "Bizonas": "🦬",
  "Polar Bear": "🐻‍❄️", "Baltasis lokys": "🐻‍❄️",
  "Bear": "🐻", "Lokys": "🐻",
  "Wolf": "🐺", "Vilkas": "🐺",
  "Hyena": "🐺", "Hiena": "🐺",
  "Gorilla": "🦍", "Gorila": "🦍",
  "Chimpanzee": "🐒", "Šimpanzė": "🐒",
  "Monkey": "🐒", "Beždžionė": "🐒",
  "Raccoon": "🦝", "Meškėnas": "🦝",
  "Squirrel": "🐿️", "Voverė": "🐿️",
  "Sloth": "🦥", "Tinginys": "🦥",
  "Bat": "🦇", "Šikšnosparnis": "🦇",
  "Koala": "🐨",
  "Kangaroo": "🦘", "Kengūra": "🦘",
  "Zebra": "🦓", "Zebras": "🦓",
  "Panda": "🐼",
  "Rabbit": "🐰", "Triušis": "🐰",
  "Mouse": "🐭", "Pelė": "🐭",
  "Rat": "🐀", "Žiurkė": "🐀",
  "Dog": "🐕", "Šuo": "🐕",
  "Cat": "🐱", "Katė": "🐱",
  "Cow": "🐄", "Karvė": "🐄",
  "Pig": "🐷", "Kiaulė": "🐷",
  "Sheep": "🐑", "Avis": "🐑",
  "Goat": "🐐", "Ožka": "🐐",
  "Human": "🧑", "Žmogus": "🧑",
  "Dolphin": "🐬", "Delfinas": "🐬",
  "Greyhound": "🐕", "Kurtas": "🐕",
  "Pronghorn": "🦌", "Vilaragis": "🦌",

  // ---------- Paukščiai ----------
  "Eagle": "🦅", "Erelis": "🦅",
  "Golden Eagle": "🦅", "Kilnusis erelis": "🦅",
  "Peregrine Falcon": "🦅", "Sakalas keleivis": "🦅",
  "Sparrow": "🐦", "Žvirblis": "🐦",
  "Owl": "🦉", "Pelėda": "🦉",
  "Parrot": "🦜", "Papūga": "🦜",
  "Duck": "🦆", "Antis": "🦆",
  "Penguin": "🐧", "Pingvinas": "🐧",
  "Swan": "🦢", "Gulbė": "🦢",
  "Hen": "🐔", "Chicken": "🐔", "Višta": "🐔",
  "Goose": "🦆", "Žąsis": "🦆",
  "Pigeon": "🕊️", "Balandis": "🕊️",
  "Robin": "🐦", "Liepsnelė": "🐦",
  "Ostrich": "🐦", "Strutis": "🐦",
  "Flamingo": "🦩", "Flamingas": "🦩",
  "Turkey": "🦃", "Kalakutas": "🦃",
  "Crow": "🐦", "Varna": "🐦",

  // ---------- Ropliai / varliagyviai ----------
  "Frog": "🐸", "Varlė": "🐸",
  "Snake": "🐍", "Gyvatė": "🐍",
  "Turtle": "🐢", "Vėžlys": "🐢",
  "Tortoise": "🐢",
  "Crocodile": "🐊", "Krokodilas": "🐊",
  "Saltwater Crocodile": "🐊", "Jūrinis krokodilas": "🐊",
  "Nile Crocodile": "🐊", "Nilo krokodilas": "🐊",
  "Gecko": "🦎", "Gekonas": "🦎",
  "Chameleon": "🦎", "Chameleonas": "🦎",
  "Komodo Dragon": "🦎", "Komodo varanas": "🦎",
  "Green Anaconda": "🐍", "Žalioji anakonda": "🐍",
  "Reticulated Python": "🐍", "Tinklinis pitonas": "🐍",
  "Galápagos Tortoise": "🐢", "Galapagų vėžlys": "🐢",

  // ---------- Jūros gyviai ----------
  "Whale": "🐋", "Banginis": "🐋",
  "Blue Whale": "🐋", "Mėlynasis banginis": "🐋",
  "Sperm Whale": "🐋", "Kašalotas": "🐋",
  "Whale Shark": "🦈", "Banginryklis": "🦈",
  "Shark": "🦈", "Ryklys": "🦈",
  "Great White Shark": "🦈", "Baltasis ryklys": "🦈",
  "Octopus": "🐙", "Aštuonkojis": "🐙",
  "Starfish": "⭐", "Jūros žvaigždė": "⭐",
  "Colossal Squid": "🦑", "Milžiniškas kalmaras": "🦑",
  "Manta Ray": "🐟", "Manta": "🐟",
  "Marlin": "🐟", "Marlinas": "🐟",
  "Giant Grouper": "🐟", "Milžiniškas vėgėlys": "🐟",
  "Fish": "🐟", "Žuvis": "🐟",

  // ---------- Augalai / medžiai ----------
  "Oak": "🌳", "Ąžuolas": "🌳",
  "Maple": "🍁", "Klevas": "🍁",
  "Birch": "🌳", "Beržas": "🌳",
  "Pine": "🌲", "Pušis": "🌲",
  "Willow": "🌳", "Gluosnis": "🌳",
  "Chestnut": "🌰", "Kaštonas": "🌰",
  "Coast Redwood": "🌲", "Pajūrinė sekvoja": "🌲",
  "Giant Sequoia": "🌲", "Mamutmedis": "🌲",
  "Eucalyptus": "🌳", "Eukaliptas": "🌳",
  "Douglas Fir": "🌲", "Duglazija": "🌲",
  "Bamboo": "🎋", "Bambukas": "🎋",
  "Sunflower": "🌻", "Saulėgrąža": "🌻",
  "Aloe Vera": "🌿", "Alavijas": "🌿",
  "Dandelion": "🌼", "Kiaulpienė": "🌼",
  "Rose": "🌹", "Rožė": "🌹",
  "Cactus": "🌵", "Kaktusas": "🌵",
  "Venus Flytrap": "🪴", "Musėkautas": "🪴",
  "Fern": "🌿", "Paparčiai": "🌿",
  "Moss": "🌿", "Samanos": "🌿",
  "Grass": "🌱", "Žolė": "🌱",
  "Tree": "🌳", "Medis": "🌳",
  "Vine": "🌿", "Vijoklis": "🌿",
  "Tulip": "🌷", "Tulpė": "🌷",
  "Orchid": "🌸", "Orchidėja": "🌸",
  "Lotus": "🌺", "Lotosas": "🌺",
  "Rafflesia": "🌺", "Raflezija": "🌺",
  "Giant Water Lily": "🌺", "Milžiniškas vandens lelijas": "🌺",
  "Reed flower": "🌾", "Nendrinis žiedas": "🌾",

  // ---------- Pingvinų rūšys (visos 🐧 — lygiagretu, neišduoda) ----------
  "Emperor Penguin": "🐧", "Imperatoriškasis pingvinas": "🐧",
  "King Penguin": "🐧", "Karališkasis pingvinas": "🐧",
  "Gentoo Penguin": "🐧", "Asilinis pingvinas": "🐧",
  "Adélie Penguin": "🐧", "Adelės pingvinas": "🐧",
  "Macaroni Penguin": "🐧", "Auksaplaukis pingvinas": "🐧",
  "Little Blue Penguin": "🐧", "Mažasis pingvinas": "🐧",

  // ---------- Daugiau paukščių ----------
  "Albatross": "🐦", "Albatrosas": "🐦",
  "Arctic Tern": "🐦", "Poliarinė žuvėdra": "🐦",
  "Common Swift": "🐦", "Čiurlys": "🐦",
  "Hummingbird": "🐦", "Kolibris": "🐦",
  "Frigatebird": "🐦", "Fregata": "🐦",
  "Canada Goose": "🦆", "Kanadinė žąsis": "🦆",
  "Goshawk": "🦅", "Vištvanagis": "🦅",
  "Swallow": "🐦", "Kregždė": "🐦",
  "Stork": "🐦", "Gandras": "🐦",

  // ---------- Daugiau žinduolių ----------
  "Otter": "🦦", "Ūdra": "🦦",
  "Manatee": "🦭", "Lamantinas": "🦭",
  "Walrus": "🦭", "Vėplys": "🦭",
  "Seal": "🦭", "Ruonis": "🦭",
  "Buffalo": "🐃", "Buivolas": "🐃",
  "Water Buffalo": "🐃", "Azijinis buivolas": "🐃",
  "Ox": "🐂", "Jautis": "🐂",
  "Donkey": "🫏", "Asilas": "🫏",
  "Deer": "🦌", "Elnias": "🦌",
  "Reindeer": "🦌", "Šiaurės elnias": "🦌",
  "Fox": "🦊", "Lapė": "🦊",
  "Hedgehog": "🦔", "Ežys": "🦔",
  "Boar": "🐗", "Šernas": "🐗",
  "Llama": "🦙", "Lama": "🦙",
  "Alpaca": "🦙", "Alpaka": "🦙",
  "Ram": "🐏", "Avinas": "🐏",
  "Skunk": "🦨", "Skunkas": "🦨",
  "Badger": "🦡", "Barsukas": "🦡",
  "Beaver": "🦫", "Bebras": "🦫",
  "Mole": "🐀", "Kurmis": "🐀",
  "Orangutan": "🦧", "Orangutangas": "🦧",

  // ---------- Jūros gyviai (papildomi) ----------
  "Crab": "🦀", "Krabas": "🦀",
  "Lobster": "🦞", "Omaras": "🦞",
  "Shrimp": "🦐", "Krevetė": "🦐",
  "Jellyfish": "🪼", "Medūza": "🪼",
  "Seahorse": "🐠", "Jūrų arkliukas": "🐠",
  "Seal pup": "🦭", "Ruoniukas": "🦭",

  // ---------- Roplys / driežai (papildomi) ----------
  "Lizard": "🦎", "Driežas": "🦎",
  "Iguana": "🦎",

  // ---------- Išnykę / dinozaurai ----------
  // Emoji TIK du (🦖 plėšrūnai, 🦕 augalėdžiai/kiti) — bet vis tiek ĮVAIRIAU nei
  // tuščia: dino klausimuose variantai pasiskirsto, atrodo gyvai. (Taškai pagal
  // LAIKĄ, tad net jei spalva užsimena — sukčiui tai nieko neduoda.)
  "Tyrannosaurus rex": "🦖", "Tiranozauras reksas": "🦖",
  "T. rex": "🦖", "Tyrannosaurus": "🦖", "Tiranozauras": "🦖",
  "Velociraptor": "🦖", "Velokiraptorius": "🦖",
  "Spinosaurus": "🦖", "Spinozauras": "🦖",
  "Allosaurus": "🦖", "Alozauras": "🦖",
  "Triceratops": "🦕", "Triceratopsas": "🦕",
  "Stegosaurus": "🦕", "Stegozauras": "🦕",
  "Diplodocus": "🦕", "Diplodokas": "🦕",
  "Brachiosaurus": "🦕", "Brachiozauras": "🦕",
  "Ankylosaurus": "🦕", "Ankilozauras": "🦕",
  "Brontosaurus": "🦕", "Brontozauras": "🦕",
  "Iguanodon": "🦕", "Iguanodonas": "🦕",
  "Mammoth": "🦣", "Mamutas": "🦣",
  "Woolly mammoth": "🦣", "Vilnonis mamutas": "🦣",
  "Megalodon": "🦈", "Megalodonas": "🦈",
  // Ryklių rūšys → visos 🦈 (lygiagretu, NEišduoda: visi variantai rykliai).
  // Be šių „išnykęs ryklys" klausimas rodydavo 🦈 TIK ant Megalodono = atsakymo
  // išdavimas. Dabar visi 6 variantai turi 🦈 → „viskas arba nieko" suveikia.
  "Hammerhead": "🦈", "Plaktagalvis": "🦈", "Hammerhead shark": "🦈",
  "Tiger shark": "🦈", "Tigrinis ryklys": "🦈",
  "Bull shark": "🦈", "Bukasnukis ryklys": "🦈",
  "Mako": "🦈", "Mako shark": "🦈", "Mako ryklys": "🦈",
  "Reef shark": "🦈", "Rifinis ryklys": "🦈",
  "Dodo": "🦤",
  "Saber-toothed cat": "🐯", "Kardadantė katė": "🐯",
  "Pteranodon": "🦅", "Pteranodonas": "🦅",

  // ---------- Gyvūnų klasės (lygiagretu — neišduoda) ----------
  "Mammal": "🐾", "Žinduolis": "🐾",
  "Reptile": "🦎", "Roplys": "🦎",
  "Amphibian": "🐸", "Varliagyvis": "🐸",
  "Bird": "🐦", "Paukštis": "🐦",
  "Insect": "🐜", "Vabzdys": "🐜",

  // ---------- Mityba (lygiagretu — neišduoda) ----------
  "Carnivores": "🥩", "Mėsėdžiai": "🥩",
  "Herbivores": "🌿", "Žolėdžiai": "🌿",
  "Omnivores": "🍽️", "Visaėdžiai": "🍽️",
  "Insectivores": "🐜", "Vabzdžiaėdžiai": "🐜",
  "Scavengers": "🦅", "Maitėdos": "🦅",
  "Predators": "🦁", "Plėšrūnai": "🦁",

  // ---------- Spalvos (spalvotas kvadratas = pati spalva) ----------
  "White": "⬜", "Baltas": "⬜",
  "Black": "⬛", "Juodas": "⬛",
  "Brown": "🟫", "Rudas": "🟫",
  "Blue": "🟦", "Mėlynas": "🟦",
  "Green": "🟩", "Žalias": "🟩",
  "Grey": "🌫️", "Pilkas": "🌫️",

  // ---------- Maistas / medžiaga ----------
  "Honey": "🍯", "Medus": "🍯",
  "Meat": "🥩", "Mėsa": "🥩",
  "Fruit": "🍓", "Vaisiai": "🍓",
  "Water": "💧", "Vanduo": "💧",
  "Sunlight": "☀️", "Saulės šviesa": "☀️",

  // ---------- Metamorfozė (LT įnagininkas → tas pats gyvūnas) ----------
  "Drugeliu": "🦋",
  "Paukščiu": "🐦",
  "Voru": "🕷️",
  "Vabalu": "🪲",
  "Sraige": "🐌",
  "Bite": "🐝",
  "Buožgalvis": "🐸",
};

/** Grąžina emoji atsakymui arba undefined, jei žodžio nėra leksikone. */
export function emojiForOption(option: string): string | undefined {
  return NATURE_EMOJI[option.trim()];
}
