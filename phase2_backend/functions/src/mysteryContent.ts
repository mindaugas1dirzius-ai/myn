/**
 * mysteryContent — „Atspėk paslaptį / Cyber-Ratelis" TURINYS (patikrintas, #2).
 *
 * TARPTAUTINIS turinys: pasaulinės citatos, universalios patarlės, istorinės
 * frazės ir ĮDOMŪS KLAUSIMAI („Laimės rato" stilius), kurie PILNAI ir natūraliai
 * išsiverčia į visas kalbas. Vengiame grynai vienos tautos folkloro be atitikmens.
 *
 * Struktūra plečiama: `texts` yra Partial<Record<Lang, ...>> — pridėti naują
 * kalbą reiškia tik įrašyti dar vieną raktą.
 *
 * Kiekvienas vienetas turi:
 *   - level (1..4) — banko (galimo laimėjimo) dydžiui;
 *   - hint  — NEMOKAMA, visada matoma užuomina/klausimas;
 *   - hint1/hint2 — PAPILDOMOS užuominos (perkamos už raktus), pasako daugiau;
 *   - sourceVerified — šaltinis (taisyklė #2: faktai 100% tikri).
 */

import { Lang } from "./triviaTypes";
import { MysteryItem, MysteryText } from "./mysteryTypes";

export const MYSTERIES: MysteryItem[] = [
  // ----------------------------- Pasaulinės citatos --------------------------
  {
    id: "mys_cit_001",
    category: "citata",
    level: 2,
    sourceVerified: "Sokratui priskiriama (Platonas, Sokrato apologija)",
    texts: {
      en: {
        text: "I know that I know nothing",
        hint: "Words of the philosopher Socrates",
        hint1: "About humility — admitting how little we truly understand.",
        hint2: "A wise person is the one who recognises their own limits.",
      },
      lt: {
        text: "Žinau, kad nieko nežinau",
        hint: "Filosofo Sokrato mintis",
        hint1: "Apie nuolankumą — kad išmintinga pripažinti savo ribotumą.",
        hint2: "Išmintingas tas, kuris suvokia savo paties ribas.",
      },
    },
  },
  {
    id: "mys_cit_002",
    category: "citata",
    level: 2,
    sourceVerified: "Rene Dekartas, 1637 (Cogito ergo sum)",
    texts: {
      en: {
        text: "I think therefore I am",
        hint: "A famous line by Descartes",
        hint1: "The idea that thinking proves one's own existence.",
        hint2: "In Latin: cogito ergo sum.",
      },
      lt: {
        text: "Mąstau, vadinasi, esu",
        hint: "Garsi Dekarto frazė",
        hint1: "Mintis, kad mąstymas įrodo paties egzistavimą.",
        hint2: "Lotyniškai: cogito ergo sum.",
      },
    },
  },
  {
    id: "mys_cit_003",
    category: "citata",
    level: 1,
    sourceVerified: "Frensiui Baconui priskiriama (scientia potentia est)",
    texts: {
      en: {
        text: "Knowledge is power",
        hint: "On the strength that learning gives",
        hint1: "The more you understand, the more you can achieve.",
        hint2: "Education is what lets a person shape the world around them.",
      },
      lt: {
        text: "Žinios yra galia",
        hint: "Apie stiprybę, kurią suteikia mokymasis",
        hint1: "Kuo daugiau supranti, tuo daugiau gali pasiekti.",
        hint2: "Išsilavinimas leidžia žmogui keisti aplinką.",
      },
    },
  },
  {
    id: "mys_cit_004",
    category: "citata",
    level: 3,
    sourceVerified: "Albertas Einsteinas, 1929 m. interviu (Saturday Evening Post)",
    texts: {
      en: {
        text: "Imagination is more important than knowledge",
        hint: "Einstein on what drives discovery",
        hint1: "He believed creativity matters more than memorised facts.",
        hint2: "New ideas come from dreaming, not only from what we already learned.",
      },
      lt: {
        text: "Vaizduotė svarbiau už žinias",
        hint: "Einšteinas apie tai, kas skatina atradimus",
        hint1: "Jis tikėjo, kad kūrybiškumas svarbesnis nei iškalti faktai.",
        hint2: "Naujos idėjos gimsta iš svajojimo, o ne tik iš to, ką jau išmokome.",
      },
    },
  },
  {
    id: "mys_cit_005",
    category: "citata",
    level: 4,
    sourceVerified: "Izaokas Niutonas, 1675 m. laiskas R. Hooke'ui",
    texts: {
      en: {
        text: "If I have seen further it is by standing on the shoulders of giants",
        hint: "Newton on building on earlier work",
        hint1: "Every new discovery rests on what great thinkers achieved before.",
        hint2: "We reach higher because others lifted us up first.",
      },
      lt: {
        text: "Jei mačiau toliau, tai tik todėl, kad stovėjau ant milžinų pečių",
        hint: "Niutonas apie pirmtakų darbą",
        hint1: "Kiekvienas naujas atradimas remiasi tuo, ką pasiekė didieji pirmtakai.",
        hint2: "Pasiekiame aukščiau, nes kiti mus pirmiau pakėlė.",
      },
    },
  },
  {
    id: "mys_cit_006",
    category: "citata",
    level: 3,
    sourceVerified: "Galilejui priskiriama, legendine (E pur si muove)",
    texts: {
      en: {
        text: "And yet it moves",
        hint: "Attributed to Galileo about the Earth",
        hint1: "About the Earth, which moves around the Sun.",
        hint2: "In Latin: E pur si muove.",
      },
      lt: {
        text: "Ir vis dėlto ji sukasi",
        hint: "Galilėjui priskiriama apie Žemę",
        hint1: "Apie Žemę, kuri juda aplink Saulę.",
        hint2: "Lotyniškai: E pur si muove.",
      },
    },
  },

  // ---------------------------- Universalios patarlės ------------------------
  {
    id: "mys_pat_001",
    category: "patarle",
    level: 2,
    sourceVerified: "Tarptautine patarle (All that glitters is not gold)",
    texts: {
      en: {
        text: "All that glitters is not gold",
        hint: "A proverb about appearances",
        hint1: "Appearances can be deceiving — shiny is not always valuable.",
        hint2: "A precious metal is the symbol here, but the point is about false shine.",
      },
      lt: {
        text: "Ne viskas auksas, kas auksu žiba",
        hint: "Patarlė apie apgaulingą blizgesį",
        hint1: "Blizgesys gali apgauti — ne viskas vertinga, kas spindi.",
        hint2: "Simbolis čia – brangus metalas, bet esmė apie apgaulingą spindesį.",
      },
    },
  },
  {
    id: "mys_pat_002",
    category: "patarle",
    level: 1,
    sourceVerified: "Tarptautine patarle (Better late than never)",
    texts: {
      en: {
        text: "Better late than never",
        hint: "A proverb about timing",
        hint1: "Doing something behind schedule still beats not doing it at all.",
        hint2: "Encourages you to act even when the right moment has passed.",
      },
      lt: {
        text: "Geriau vėliau negu niekada",
        hint: "Patarlė apie vėlavimą",
        hint1: "Padaryti pavėluotai vis tiek geriau nei visai nepadaryti.",
        hint2: "Ragina veikti net praėjus tinkamam momentui.",
      },
    },
  },
  {
    id: "mys_pat_003",
    category: "patarle",
    level: 2,
    sourceVerified: "Tarptautine patarle (The apple does not fall far from the tree)",
    texts: {
      en: {
        text: "The apple never falls far from the tree",
        hint: "A proverb about family resemblance",
        hint1: "Children tend to resemble their parents.",
        hint2: "Uses a fruit and the plant it grows on as a symbol of family.",
      },
      lt: {
        text: "Obuolys nuo obels netoli krinta",
        hint: "Patarlė apie panašumą į tėvus",
        hint1: "Vaikai dažnai panašūs į savo tėvus.",
        hint2: "Šeimos panašumą vaizduoja vaisius ir augalas, ant kurio jis auga.",
      },
    },
  },
  {
    id: "mys_pat_004",
    category: "patarle",
    level: 2,
    sourceVerified: "Tarptautine patarle (There is no smoke without fire)",
    texts: {
      en: {
        text: "There is no smoke without fire",
        hint: "A proverb about rumours",
        hint1: "Rumours usually have at least some basis in truth.",
        hint2: "Uses what you see rising and what causes it as a sign that something is real.",
      },
      lt: {
        text: "Nėra dūmų be ugnies",
        hint: "Patarlė apie gandus",
        hint1: "Gandai paprastai turi bent dalį tiesos.",
        hint2: "Tai, kas kyla, ir jo priežastis yra ženklas, kad kažkas tikrai vyksta.",
      },
    },
  },
  {
    id: "mys_pat_005",
    category: "patarle",
    level: 3,
    sourceVerified: "Tarptautine patarle (Measure twice, cut once)",
    texts: {
      en: {
        text: "Measure twice cut once",
        hint: "A proverb about careful planning",
        hint1: "Be careful before doing something you cannot undo.",
        hint2: "A tailor's or carpenter's habit: check carefully, then act just once.",
      },
      lt: {
        text: "Devynis kartus matuok, vieną kartą kirpk",
        hint: "Patarlė apie apdairumą",
        hint1: "Pagalvok atidžiai prieš nepataisomą veiksmą.",
        hint2: "Siuvėjo ar staliaus įprotis: kruopščiai patikrink, tada daryk tik kartą.",
      },
    },
  },
  {
    id: "mys_pat_006",
    category: "patarle",
    level: 1,
    sourceVerified: "Tarptautine patarle; angl. Time is money (B. Franklin, 1748)",
    texts: {
      en: {
        text: "Time is money",
        hint: "A proverb about time",
        hint1: "Every wasted hour is like throwing away something valuable.",
        hint2: "Compares the passing hours to wealth, to show how precious they are.",
      },
      lt: {
        text: "Laikas yra pinigai",
        hint: "Patarlė apie laiką",
        hint1: "Kiekviena iššvaistyta valanda – tarsi išmestas turtas.",
        hint2: "Bėgančias valandas lygina su turtu, kad parodytų jų vertę.",
      },
    },
  },

  // ------------------------------ Istorinės frazės ---------------------------
  {
    id: "mys_ist_001",
    category: "istorija",
    level: 2,
    sourceVerified: "Julijus Cezaris, 47 m. pr. Kr. (Veni vidi vici)",
    texts: {
      en: {
        text: "I came I saw I conquered",
        hint: "A Roman general's boast",
        hint1: "A report of a swift, total victory.",
        hint2: "In Latin: Veni, vidi, vici.",
      },
      lt: {
        text: "Atėjau, pamačiau, nugalėjau",
        hint: "Romos karvedžio frazė",
        hint1: "Pranešimas po greitos, visiškos pergalės.",
        hint2: "Lotyniškai: Veni, vidi, vici.",
      },
    },
  },
  {
    id: "mys_ist_002",
    category: "istorija",
    level: 4,
    sourceVerified: "Neilas Armstrongas, 1969 m. nusileidimas i Menuli",
    texts: {
      en: {
        text: "One small step for man one giant leap for mankind",
        hint: "First words on the Moon",
        hint1: "Spoken by the first person to step onto the Moon.",
        hint2: "Contrasts one person's tiny move with a huge advance for all of humanity.",
      },
      lt: {
        text: "Mažas žingsnis žmogui, milžiniškas šuolis žmonijai",
        hint: "Pirmieji žodžiai Mėnulyje",
        hint1: "Ištarta pirmojo žmogaus, žengusio ant Mėnulio.",
        hint2: "Lygina vieno žmogaus mažytį judesį su didžiuliu šuoliu visai žmonijai.",
      },
    },
  },

  // -------------------- Klausimai-paslaptys („Laimės ratas") -----------------
  // hint = klausimas (nemokamas); hint1/hint2 = perkamos užuominos (vis aiškiau).
  {
    id: "mys_klaus_001",
    category: "klausimas",
    level: 2,
    sourceVerified: "Atminties tyrimai: auksinė žuvelė įsimena dalykus mėnesiais",
    texts: {
      en: {
        text: "Goldfish",
        hint: "Which popular aquarium pet actually remembers things for months, busting the 3-second memory myth?",
        hint1: "A common pet kept in small glass bowls.",
        hint2: "In fairy tales it grants three wishes.",
      },
      lt: {
        text: "Auksinė žuvelė",
        hint: "Koks populiarus akvariumo gyvūnas iš tikrųjų atsimena dalykus mėnesiais, paneigdamas 3 sekundžių atminties mitą?",
        hint1: "Dažnas augintinis mažuose stikliniuose akvariumuose.",
        hint2: "Pasakose ji išpildo tris norus.",
      },
    },
  },
  {
    id: "mys_klaus_002",
    category: "klausimas",
    level: 1,
    sourceVerified: "Astronomija: Marsas — Raudonoji planeta (geležies oksidas)",
    texts: {
      en: {
        text: "Mars",
        hint: "Which planet is called the Red Planet because of iron oxide on its surface?",
        hint1: "The fourth planet from the Sun.",
        hint2: "It has two small moons: Phobos and Deimos.",
      },
      lt: {
        text: "Marsas",
        hint: "Kuri planeta vadinama Raudonąja dėl geležies oksido jos paviršiuje?",
        hint1: "Ketvirta planeta nuo Saulės.",
        hint2: "Turi du mažus palydovus: Fobą ir Deimą.",
      },
    },
  },
  {
    id: "mys_klaus_003",
    category: "klausimas",
    level: 1,
    sourceVerified: "Astronomija: Jupiteris — didžiausia Saulės sistemos planeta",
    texts: {
      en: {
        text: "Jupiter",
        hint: "Which is the largest planet in the Solar System?",
        hint1: "A gas giant with the Great Red Spot.",
        hint2: "Named after the king of the Roman gods.",
      },
      lt: {
        text: "Jupiteris",
        hint: "Kuri yra didžiausia planeta Saulės sistemoje?",
        hint1: "Dujų milžinė su Didžiąja raudonąja dėme.",
        hint2: "Pavadinta romėnų dievų karaliaus vardu.",
      },
    },
  },
  {
    id: "mys_klaus_004",
    category: "klausimas",
    level: 1,
    sourceVerified: "Anatomija: oda — didžiausias žmogaus organas",
    texts: {
      en: {
        text: "Skin",
        hint: "What is the largest organ of the human body?",
        hint1: "It covers your entire body.",
        hint2: "It protects from germs and regulates temperature.",
      },
      lt: {
        text: "Oda",
        hint: "Koks yra didžiausias žmogaus kūno organas?",
        hint1: "Dengia visą tavo kūną.",
        hint2: "Apsaugo nuo mikrobų ir reguliuoja temperatūrą.",
      },
    },
  },
  {
    id: "mys_klaus_005",
    category: "klausimas",
    level: 3,
    sourceVerified: "Geografija: Maču Pikču — inkų miestas Peru (ne Brazilijoje)",
    texts: {
      en: {
        text: "Machu Picchu",
        hint: "Which lost Inca city high in the Andes is often wrongly placed in Brazil?",
        hint1: "An ancient Inca city set high in the mountains.",
        hint2: "It is located in Peru, not Brazil.",
      },
      lt: {
        text: "Maču Pikču",
        hint: "Koks prarastas inkų miestas aukštai Anduose dažnai klaidingai priskiriamas Brazilijai?",
        hint1: "Senovės inkų miestas aukštai kalnuose.",
        hint2: "Jis yra Peru, ne Brazilijoje.",
      },
    },
  },
  {
    id: "mys_klaus_006",
    category: "klausimas",
    level: 2,
    sourceVerified: "Geografija: Everestas — aukščiausia viršukalnė (~8849 m)",
    texts: {
      en: {
        text: "Everest",
        hint: "Which mountain is Earth's highest peak above sea level?",
        hint1: "It lies in the Himalayas.",
        hint2: "It rises about 8849 metres tall.",
      },
      lt: {
        text: "Everestas",
        hint: "Kuris kalnas yra aukščiausia Žemės viršukalnė virš jūros lygio?",
        hint1: "Jis yra Himalajuose.",
        hint2: "Jo aukštis apie 8849 metrai.",
      },
    },
  },
  {
    id: "mys_klaus_007",
    category: "klausimas",
    level: 2,
    sourceVerified: "Geografija: Ramusis vandenynas — didžiausias ir giliausias",
    texts: {
      en: {
        text: "The Pacific Ocean",
        hint: "What is the largest and deepest ocean on Earth?",
        hint1: "It separates Asia from the Americas.",
        hint2: "It holds the Mariana Trench, the deepest point.",
      },
      lt: {
        text: "Ramusis vandenynas",
        hint: "Koks yra didžiausias ir giliausias Žemės vandenynas?",
        hint1: "Skiria Aziją nuo Amerikų.",
        hint2: "Jame yra Marianų įduba — giliausia vieta.",
      },
    },
  },
  {
    id: "mys_klaus_008",
    category: "klausimas",
    level: 2,
    sourceVerified: "Mineralogija: deimantas — kiečiausia natūrali medžiaga",
    texts: {
      en: {
        text: "Diamond",
        hint: "Which natural material is the hardest known in nature?",
        hint1: "It is made of pure carbon.",
        hint2: "Used for gemstones and cutting tools.",
      },
      lt: {
        text: "Deimantas",
        hint: "Kokia natūrali medžiaga yra kiečiausia žinoma gamtoje?",
        hint1: "Sudaryta iš grynos anglies.",
        hint2: "Naudojamas brangakmeniams ir pjovimo įrankiams.",
      },
    },
  },
  {
    id: "mys_klaus_009",
    category: "klausimas",
    level: 3,
    sourceVerified: "Geografija: Drūkšiai — didžiausias Lietuvos ežeras",
    texts: {
      // LT-specifinis (Lietuvos žinios) — anglakalbiams neparenkam.
      lt: {
        text: "Drūkšiai",
        hint: "Koks yra didžiausias Lietuvos ežeras?",
        hint1: "Yra šalies šiaurės rytuose, prie sienos.",
        hint2: "Prie jo veikė Ignalinos atominė elektrinė.",
      },
    },
  },

  // -- Ilgesni (daugiažodžiai) atsakymai — „Laimės rato" stiliaus iššūkiai --
  {
    id: "mys_klaus_010",
    category: "klausimas",
    level: 3,
    sourceVerified: "Istorija/architektūra: Didžioji kinų siena (tūkst. km)",
    texts: {
      en: {
        text: "The Great Wall of China",
        hint: "Which massive structure, built over many centuries, winds for thousands of kilometres across northern China?",
        hint1: "It was built to defend against invaders from the north.",
        hint2: "It is often (wrongly) said to be visible from the Moon.",
      },
      lt: {
        text: "Didžioji kinų siena",
        hint: "Koks milžiniškas statinys, statytas daugelį amžių, vingiuoja tūkstančius kilometrų per šiaurės Kiniją?",
        hint1: "Statyta gintis nuo įsibrovėlių iš šiaurės.",
        hint2: "Klaidingai sakoma, kad ją galima matyti iš Mėnulio.",
      },
    },
  },
  {
    id: "mys_klaus_011",
    category: "klausimas",
    level: 3,
    sourceVerified: "Istorija: Laisvės statula — Prancūzijos dovana JAV, 1886",
    texts: {
      en: {
        text: "The Statue of Liberty",
        hint: "Which monument, a gift from France in 1886, stands in New York harbour holding up a torch?",
        hint1: "It stands on an island near New York City.",
        hint2: "France gave it to the United States as a gift.",
      },
      lt: {
        text: "Laisvės statula",
        hint: "Koks paminklas, 1886 m. Prancūzijos dovana, stovi Niujorko uoste iškėlęs deglą?",
        hint1: "Stovi saloje prie Niujorko.",
        hint2: "Prancūzija padovanojo jį Jungtinėms Valstijoms.",
      },
    },
  },
  {
    id: "mys_klaus_012",
    category: "klausimas",
    level: 2,
    sourceVerified: "Istorija: Eifelio bokštas — 1889 m. pasaulinei parodai",
    texts: {
      en: {
        text: "The Eiffel Tower",
        hint: "Which iron tower in Paris was built for the 1889 World's Fair?",
        hint1: "It is the best-known symbol of Paris.",
        hint2: "It is named after the engineer who built it.",
      },
      lt: {
        text: "Eifelio bokštas",
        hint: "Koks geležinis bokštas Paryžiuje pastatytas 1889 m. pasaulinei parodai?",
        hint1: "Žinomiausias Paryžiaus simbolis.",
        hint2: "Pavadintas jį pastačiusio inžinieriaus vardu.",
      },
    },
  },
  {
    id: "mys_klaus_013",
    category: "klausimas",
    level: 3,
    sourceVerified: "Fizika/astronomija: šiaurės pašvaistė (aurora borealis)",
    texts: {
      en: {
        text: "The Northern Lights",
        hint: "What is the colourful natural glow that lights up the night sky near the North Pole?",
        hint1: "It happens when particles from the Sun hit the atmosphere.",
        hint2: "Its Latin name is aurora borealis.",
      },
      lt: {
        text: "Šiaurės pašvaistė",
        hint: "Kaip vadinamas spalvingas natūralus švytėjimas, nušviečiantis nakties dangų prie šiaurės ašigalio?",
        hint1: "Atsiranda, kai Saulės dalelės atsitrenkia į atmosferą.",
        hint2: "Lotyniškai vadinama aurora borealis.",
      },
    },
  },
  {
    id: "mys_klaus_014",
    category: "klausimas",
    level: 3,
    sourceVerified: "Fizika: šviesos greitis ~299 792 km/s (apie 300 000 km/s)",
    texts: {
      en: {
        text: "Speed of Light",
        hint: "What is the fastest speed known in the universe, about 300,000 kilometres per second?",
        hint1: "Nothing with mass can ever reach it.",
        hint2: "It takes about 8 minutes to travel from the Sun to Earth.",
      },
      lt: {
        text: "Šviesos greitis",
        hint: "Koks yra greičiausias žinomas greitis visatoje — apie 300 000 kilometrų per sekundę?",
        hint1: "Nieko, kas turi masę, jo nepasiekia.",
        hint2: "Nuo Saulės iki Žemės keliauja apie 8 minutes.",
      },
    },
  },
  {
    id: "mys_klaus_015",
    category: "klausimas",
    level: 3,
    sourceVerified: "Geografija: Sacharos dykuma — didžiausia karštoji dykuma",
    texts: {
      en: {
        text: "The Sahara Desert",
        hint: "What is the largest hot desert on Earth, covering much of North Africa?",
        hint1: "It is famous for its endless sand dunes.",
        hint2: "It is roughly the size of the United States.",
      },
      lt: {
        text: "Sacharos dykuma",
        hint: "Kokia yra didžiausia karštoji dykuma Žemėje, dengianti didelę Šiaurės Afrikos dalį?",
        hint1: "Garsėja begalinėmis smėlio kopomis.",
        hint2: "Jos plotas maždaug kaip Jungtinių Valstijų.",
      },
    },
  },
  {
    id: "mys_klaus_016",
    category: "klausimas",
    level: 2,
    sourceVerified: "Astronomija: Saulės sistema (Saulė + 8 planetos)",
    texts: {
      en: {
        text: "The Solar System",
        hint: "What do we call the Sun together with all the planets that orbit around it?",
        hint1: "It has eight planets.",
        hint2: "We live on its third planet.",
      },
      lt: {
        text: "Saulės sistema",
        hint: "Kaip vadiname Saulę kartu su visomis aplink ją skriejančiomis planetomis?",
        hint1: "Joje yra aštuonios planetos.",
        hint2: "Gyvename jos trečioje planetoje.",
      },
    },
  },
  {
    id: "mys_klaus_017",
    category: "klausimas",
    level: 2,
    sourceVerified: "Biologija: mėlynasis banginis — didžiausias kada nors gyvenęs gyvūnas",
    texts: {
      en: {
        text: "Blue Whale",
        hint: "What is the largest animal ever known to have lived on Earth?",
        hint1: "It is a marine mammal, not a fish.",
        hint2: "Its heart alone can weigh as much as a small car.",
      },
      lt: {
        text: "Mėlynasis banginis",
        hint: "Koks yra didžiausias gyvūnas, kada nors gyvenęs Žemėje?",
        hint1: "Tai jūros žinduolis, ne žuvis.",
        hint2: "Vien jo širdis gali sverti kaip mažas automobilis.",
      },
    },
  },
  {
    id: "mys_klaus_018",
    category: "klausimas",
    level: 3,
    sourceVerified: "Geografija: Amazonės upė — daugiausia vandens nešanti upė",
    texts: {
      en: {
        text: "The Amazon River",
        hint: "Which South American river carries more water than any other river on Earth?",
        hint1: "It flows mostly through Brazil.",
        hint2: "It runs through the world's largest rainforest.",
      },
      lt: {
        text: "Amazonės upė",
        hint: "Kuri Pietų Amerikos upė neša daugiau vandens nei bet kuri kita upė Žemėje?",
        hint1: "Daugiausia teka per Braziliją.",
        hint2: "Teka per didžiausią pasaulio atogrąžų mišką.",
      },
    },
  },
  {
    id: "mys_klaus_019",
    category: "klausimas",
    level: 3,
    sourceVerified: "Menas: Mona Liza — Leonardo da Vinčio portretas, Luvras",
    texts: {
      en: {
        text: "Mona Lisa",
        hint: "Which famous portrait, painted by Leonardo da Vinci, hangs in the Louvre in Paris?",
        hint1: "It is known for the woman's mysterious smile.",
        hint2: "It hangs in a museum in Paris.",
      },
      lt: {
        text: "Mona Liza",
        hint: "Koks garsus portretas, nutapytas Leonardo da Vinčio, kabo Luvre Paryžiuje?",
        hint1: "Garsėja paslaptinga moters šypsena.",
        hint2: "Kabo muziejuje Paryžiuje.",
      },
    },
  },

  // ----------------------------- Įdomūs faktai -------------------------------
  {
    id: "mys_fakt_001",
    category: "faktas",
    level: 2,
    sourceVerified: "Maisto chemija: medus dėl mažo drėgnumo ir rūgštumo negenda; rasta valgomo 3000 m. senumo medaus",
    texts: {
      en: {
        text: "Honey never spoils",
        hint: "A surprising fact about a sweet food",
        hint1: "Jars of it, thousands of years old, were still edible.",
        hint2: "It is made by bees.",
      },
      lt: {
        text: "Medus niekada negenda",
        hint: "Netikėtas faktas apie saldų maistą",
        hint1: "Rasta net tūkstančių metų senumo, vis dar valgomo.",
        hint2: "Jį gamina bitės.",
      },
    },
  },
  {
    id: "mys_fakt_002",
    category: "faktas",
    level: 2,
    sourceVerified: "Jūrų biologija: aštuonkojai turi tris širdis (dvi žiaunoms, viena kūnui)",
    texts: {
      en: {
        text: "Octopuses have three hearts",
        hint: "A fact about a clever sea animal's body",
        hint1: "Two of them pump blood to the gills.",
        hint2: "The animal has eight arms.",
      },
      lt: {
        text: "Aštuonkojai turi tris širdis",
        hint: "Faktas apie gudraus jūrų gyvūno kūną",
        hint1: "Dvi iš jų varo kraują į žiaunas.",
        hint2: "Šis gyvūnas turi aštuonias rankas.",
      },
    },
  },
  {
    id: "mys_fakt_003",
    category: "faktas",
    level: 2,
    sourceVerified: "Botanika: bananas botaniškai yra uoga, o braškė – ne",
    texts: {
      en: {
        text: "Bananas are berries",
        hint: "A surprising fact from botany",
        hint1: "Botanically, this yellow fruit counts as a berry.",
        hint2: "Strawberries, oddly, do not.",
      },
      lt: {
        text: "Bananai yra uogos",
        hint: "Netikėtas faktas iš botanikos",
        hint1: "Botaniškai šis geltonas vaisius laikomas uoga.",
        hint2: "O braškės – keista, bet ne.",
      },
    },
  },
  {
    id: "mys_fakt_004",
    category: "faktas",
    level: 3,
    sourceVerified: "Paleontologija: rykliai atsirado ~450 mln. m., pirmieji medžiai ~390 mln. m.",
    texts: {
      en: {
        text: "Sharks are older than trees",
        hint: "A fact comparing two very old things",
        hint1: "These ocean predators appeared before forests did.",
        hint2: "One of them has fins; the other has leaves.",
      },
      lt: {
        text: "Rykliai senesni už medžius",
        hint: "Faktas, lyginantis du labai senus dalykus",
        hint1: "Šie vandenyno plėšrūnai atsirado anksčiau nei miškai.",
        hint2: "Vieni turi pelekus, kiti – lapus.",
      },
    },
  },
  {
    id: "mys_fakt_005",
    category: "faktas",
    level: 4,
    sourceVerified: "Astronomija: Veneros apsisukimas ~243 d., orbita aplink Saulę ~225 d.",
    texts: {
      en: {
        text: "A day on Venus is longer than its year",
        hint: "A strange fact about a planet's time",
        hint1: "This planet spins slower than it orbits the Sun.",
        hint2: "It is the second planet from the Sun.",
      },
      lt: {
        text: "Diena Veneroje ilgesnė už metus",
        hint: "Keistas faktas apie planetos laiką",
        hint1: "Ši planeta sukasi lėčiau, nei apskrieja Saulę.",
        hint2: "Tai antroji planeta nuo Saulės.",
      },
    },
  },
  {
    id: "mys_fakt_006",
    category: "faktas",
    level: 4,
    sourceVerified: "Fizika: žaibo kanalas ~30 000 K, Saulės paviršius ~5 500 K",
    texts: {
      en: {
        text: "Lightning is hotter than the Sun's surface",
        hint: "A fact about a flash in the sky",
        hint1: "A lightning bolt can reach about 30,000 degrees.",
        hint2: "It happens during a thunderstorm.",
      },
      lt: {
        text: "Žaibas karštesnis už Saulės paviršių",
        hint: "Faktas apie blyksnį danguje",
        hint1: "Žaibo kanalas gali įkaisti iki maždaug 30 000 laipsnių.",
        hint2: "Tai nutinka per perkūniją.",
      },
    },
  },
  {
    id: "mys_fakt_007",
    category: "faktas",
    level: 3,
    sourceVerified: "Fizika: geležis plečiasi karštyje – Eifelio bokštas vasarą paaukštėja ~15 cm",
    texts: {
      en: {
        text: "The Eiffel Tower grows in summer",
        hint: "A fact about a famous iron landmark",
        hint1: "Heat makes its metal expand, so it gets taller.",
        hint2: "This landmark stands in Paris.",
      },
      lt: {
        text: "Eifelio bokštas vasarą paaukštėja",
        hint: "Faktas apie garsų geležinį statinį",
        hint1: "Nuo karščio metalas plečiasi, tad jis tampa aukštesnis.",
        hint2: "Šis statinys stovi Paryžiuje.",
      },
    },
  },
  {
    id: "mys_fakt_008",
    category: "faktas",
    level: 3,
    sourceVerified: "Zoologija: sraigės sausros/šalčio metu gali užmigti (estivacija) iki ~3 metų",
    texts: {
      en: {
        text: "Snails can sleep for three years",
        hint: "A fact about a very slow animal",
        hint1: "In dry weather it can stay asleep for a very long time.",
        hint2: "This animal carries its house on its back.",
      },
      lt: {
        text: "Sraigės gali miegoti trejus metus",
        hint: "Faktas apie labai lėtą gyvūną",
        hint1: "Sausros metu gali užmigti labai ilgam.",
        hint2: "Šis gyvūnas neša namelį ant nugaros.",
      },
    },
  },

  // ----------------------------- Istorinės frazės ----------------------------
  {
    id: "mys_ist_003",
    category: "istorija",
    level: 3,
    sourceVerified: "Julijui Cezariui priskiriama, 49 m. pr. Kr. peržengiant Rubikoną (Alea iacta est)",
    texts: {
      en: {
        text: "The die is cast",
        hint: "Said by Julius Caesar at a point of no return",
        hint1: "He said it crossing the river Rubicon.",
        hint2: "In Latin: Alea iacta est.",
      },
      lt: {
        text: "Kauliukai mesti",
        hint: "Julijaus Cezario žodžiai, kai nebebuvo kelio atgal",
        hint1: "Pasakyta peržengiant Rubikono upę.",
        hint2: "Lotyniškai: Alea iacta est.",
      },
    },
  },
  {
    id: "mys_ist_004",
    category: "istorija",
    level: 1,
    sourceVerified: "Archimedui priskiriama (radus tūrio nustatymo būdą)",
    texts: {
      en: {
        text: "Eureka",
        hint: "A famous shout of discovery by Archimedes",
        hint1: "It means 'I have found it' in Greek.",
        hint2: "He supposedly shouted it in a bath.",
      },
      lt: {
        text: "Eureka",
        hint: "Garsus Archimedo atradimo šūksnis",
        hint1: "Graikiškai reiškia „radau”.",
        hint2: "Pasakojama, kad jis tai sušuko vonioje.",
      },
    },
  },
  {
    id: "mys_ist_005",
    category: "istorija",
    level: 3,
    sourceVerified: "Neilas Armstrongas, 1969 m., pirmas žmogus Mėnulyje (Apollo 11)",
    texts: {
      en: {
        text: "One small step for man",
        hint: "Said by the first person to walk on the Moon",
        hint1: "Spoken by Neil Armstrong in 1969.",
        hint2: "The next words were 'one giant leap for mankind'.",
      },
      lt: {
        text: "Mažas žingsnis žmogui",
        hint: "Pirmojo žmogaus Mėnulyje žodžiai",
        hint1: "Ištarė Neilas Armstrongas 1969 m.",
        hint2: "Toliau – „milžiniškas šuolis žmonijai”.",
      },
    },
  },
  {
    id: "mys_ist_006",
    category: "istorija",
    level: 2,
    sourceVerified: "Martinas Liuteris Kingas, 1963 m. kalba (I Have a Dream)",
    texts: {
      en: {
        text: "I have a dream",
        hint: "The famous start of a 1963 speech about equality",
        hint1: "Spoken by Martin Luther King Jr.",
        hint2: "It is about a dream of equality for all people.",
      },
      lt: {
        text: "Aš turiu svajonę",
        hint: "Garsi 1963 m. kalbos apie lygybę pradžia",
        hint1: "Ištarė Martinas Liuteris Kingas.",
        hint2: "Tai svajonė apie visų žmonių lygybę.",
      },
    },
  },
  {
    id: "mys_ist_007",
    category: "istorija",
    level: 3,
    sourceVerified: "Apollo 13 misija, 1970 m. (populiari frazės forma)",
    texts: {
      en: {
        text: "Houston we have a problem",
        hint: "A famous line from a 1970 space mission",
        hint1: "Sent by astronauts to mission control on Earth.",
        hint2: "Houston is the city where control was based.",
      },
      lt: {
        text: "Hjustone, turime problemą",
        hint: "Garsi frazė iš 1970 m. kosmoso misijos",
        hint1: "Astronautai ją perdavė skrydžių valdymui Žemėje.",
        hint2: "Hjustonas – miestas, kuriame buvo valdymo centras.",
      },
    },
  },

  // -------------------------- Daugiau patarlių -------------------------------
  {
    id: "mys_pat_007",
    category: "patarle",
    level: 2,
    sourceVerified: "Tarptautinė patarlė (Better late than never)",
    texts: {
      en: {
        text: "Better late than never",
        hint: "A proverb about doing things eventually",
        hint1: "It is better to act behind schedule than not at all.",
        hint2: "Reassures that a delayed deed still has value.",
      },
      lt: {
        text: "Geriau vėliau negu niekada",
        hint: "Patarlė apie tai, kad geriau bent kada",
        hint1: "Geriau padaryti pavėluotai nei visai nepadaryti.",
        hint2: "Ramina, kad uždelstas darbas vis tiek vertingas.",
      },
    },
  },
  {
    id: "mys_pat_008",
    category: "patarle",
    level: 3,
    sourceVerified: "Tarptautinė patarlė (Time heals all wounds)",
    texts: {
      en: {
        text: "Time heals all wounds",
        hint: "A proverb about pain fading with time",
        hint1: "Given enough time, sorrows ease.",
        hint2: "Whatever passes by the day and the clock is the great healer here.",
      },
      lt: {
        text: "Laikas gydo visas žaizdas",
        hint: "Patarlė apie tai, kaip skausmas blėsta",
        hint1: "Praėjus laikui, sielvartas atlėgsta.",
        hint2: "Tai, ką matuoja laikrodis ir dienos, čia ir yra didysis gydytojas.",
      },
    },
  },
  {
    id: "mys_pat_009",
    category: "patarle",
    level: 3,
    sourceVerified: "Tarptautinė patarlė (Where there is a will there is a way)",
    texts: {
      en: {
        text: "Where there is a will there is a way",
        hint: "A proverb about determination",
        hint1: "If you truly want something, you find a path to it.",
        hint2: "Strong desire always opens up a route to the goal.",
      },
      lt: {
        text: "Kur noras, ten ir kelias",
        hint: "Patarlė apie ryžtą",
        hint1: "Jei tikrai nori, atrandi būdą tai pasiekti.",
        hint2: "Stiprus troškimas visada atveria taką iki tikslo.",
      },
    },
  },
  {
    id: "mys_pat_010",
    category: "patarle",
    level: 2,
    sourceVerified: "Tarptautinė patarlė (Practice makes perfect)",
    texts: {
      en: {
        text: "Practice makes perfect",
        hint: "A proverb about getting better by repeating",
        hint1: "The more you train, the better you get.",
        hint2: "Repeating a skill over and over is what leads to mastery.",
      },
      lt: {
        text: "Praktika daro meistrą",
        hint: "Patarlė apie tobulėjimą kartojant",
        hint1: "Kuo daugiau treniruojiesi, tuo geriau sekasi.",
        hint2: "Tik nuolat kartojant įgūdį pasiekiamas meistriškumas.",
      },
    },
  },
  {
    id: "mys_pat_011",
    category: "patarle",
    level: 3,
    sourceVerified: "Tarptautinė patarlė (Honesty is the best policy)",
    texts: {
      en: {
        text: "Honesty is the best policy",
        hint: "A proverb about telling the truth",
        hint1: "Being truthful pays off in the long run.",
        hint2: "Always telling the truth is the wisest approach in life.",
      },
      lt: {
        text: "Sąžiningumas yra geriausia politika",
        hint: "Patarlė apie tiesos sakymą",
        hint1: "Būti tiesiam ilgainiui apsimoka.",
        hint2: "Visada sakyti tiesą – išmintingiausias kelias gyvenime.",
      },
    },
  },

  // --------------------------- Daugiau citatų --------------------------------
  {
    id: "mys_cit_007",
    category: "citata",
    level: 2,
    sourceVerified: "Viljamas Šekspyras, „Hamletas” (To be or not to be)",
    texts: {
      en: {
        text: "To be or not to be",
        hint: "The opening of a famous Shakespeare line",
        hint1: "It is the start of Hamlet's most famous speech.",
        hint2: "It asks about existing — or not.",
      },
      lt: {
        text: "Būti ar nebūti",
        hint: "Garsios Šekspyro eilutės pradžia",
        hint1: "Tai garsiausios Hamleto kalbos pradžia.",
        hint2: "Klausiama apie buvimą – ar nebuvimą.",
      },
    },
  },
  {
    id: "mys_cit_008",
    category: "citata",
    level: 3,
    sourceVerified: "Frydrichas Nyčė, „Stabų saulėlydis”",
    texts: {
      en: {
        text: "That which does not kill us makes us stronger",
        hint: "A quote by the philosopher Nietzsche",
        hint1: "About how hardship can make a person tougher.",
        hint2: "Suffering that we survive leaves us more resilient than before.",
      },
      lt: {
        text: "Kas mūsų nežudo, tas mus stiprina",
        hint: "Filosofo Nyčės citata",
        hint1: "Apie tai, kaip sunkumai gali užgrūdinti žmogų.",
        hint2: "Išgyventi išbandymai palieka mus atsparesnius nei buvome.",
      },
    },
  },
  {
    id: "mys_cit_009",
    category: "citata",
    level: 4,
    sourceVerified: "Sokratui priskiriama (Platonas, Sokrato apologija)",
    texts: {
      en: {
        text: "The unexamined life is not worth living",
        hint: "A deep quote attributed to Socrates",
        hint1: "It says we should question and reflect on our lives.",
        hint2: "A life lived without reflection, it claims, has little value.",
      },
      lt: {
        text: "Neapmąstytas gyvenimas nevertas gyventi",
        hint: "Gili Sokratui priskiriama citata",
        hint1: "Sako, kad savo gyvenimą reikia apmąstyti ir nagrinėti.",
        hint2: "Gyvenimas be apmąstymo, anot jos, turi mažai vertės.",
      },
    },
  },
  {
    id: "mys_cit_010",
    category: "citata",
    level: 3,
    sourceVerified: "Muhammadui Ali priskiriama (sukūrė Drew Bundini Brown)",
    texts: {
      en: {
        text: "Float like a butterfly sting like a bee",
        hint: "A boxer's famous saying about his style",
        hint1: "Said by Muhammad Ali about how he fought.",
        hint2: "Light and graceful when moving, sharp and sudden when striking.",
      },
      lt: {
        text: "Plazdėk kaip drugelis, gelk kaip bitė",
        hint: "Garsus boksininko posakis apie savo stilių",
        hint1: "Muhammado Ali žodžiai apie tai, kaip jis kovojo.",
        hint2: "Lengvas ir grakštus judant, aštrus ir staigus smogiant.",
      },
    },
  },
  {
    id: "mys_cit_011",
    category: "citata",
    level: 3,
    sourceVerified: "„Whole Earth Catalog”, išpopuliarino Steve'as Jobsas (2005 m. Stanfordo kalba)",
    texts: {
      en: {
        text: "Stay hungry stay foolish",
        hint: "A motto made famous by Steve Jobs",
        hint1: "Advice to keep learning and taking chances.",
        hint2: "Never feel too satisfied or too clever to keep growing.",
      },
      lt: {
        text: "Būk alkanas, būk kvailas",
        hint: "Šūkis, kurį išgarsino Steve'as Jobsas",
        hint1: "Raginimas nuolat mokytis ir rizikuoti.",
        hint2: "Niekada nesijausk per daug patenkintas ar per daug protingas, kad nustotum augti.",
      },
    },
  },

  // ------------------------ Daugiau klausimų (Laimės ratas) ------------------
  {
    id: "mys_klaus_020",
    category: "klausimas",
    level: 3,
    sourceVerified: "Geografija/architektūra: Pizos bokštas, Italija",
    texts: {
      en: {
        text: "The Leaning Tower of Pisa",
        hint: "Which Italian tower is famous for tilting to one side?",
        hint1: "It stands in the city of Pisa.",
        hint2: "It leans because of soft ground beneath it.",
      },
      lt: {
        text: "Pizos bokštas",
        hint: "Koks Italijos bokštas garsėja tuo, kad pasviręs į vieną pusę?",
        hint1: "Jis stovi Pizos mieste.",
        hint2: "Pasviro dėl minkšto grunto po juo.",
      },
    },
  },
  {
    id: "mys_klaus_021",
    category: "klausimas",
    level: 3,
    sourceVerified: "Geografija: Didysis barjerinis rifas, Australija (didžiausia koralų sistema)",
    texts: {
      en: {
        text: "The Great Barrier Reef",
        hint: "What is the world's largest coral reef system, near Australia?",
        hint1: "It is so big it can be seen from space.",
        hint2: "It lies off the coast of Australia.",
      },
      lt: {
        text: "Didysis barjerinis rifas",
        hint: "Kokia didžiausia pasaulyje koralų rifų sistema, prie Australijos?",
        hint1: "Toks didelis, kad matomas iš kosmoso.",
        hint2: "Yra prie Australijos krantų.",
      },
    },
  },
  {
    id: "mys_klaus_022",
    category: "klausimas",
    level: 2,
    sourceVerified: "Geografija: Niagaros krioklys, JAV–Kanados siena",
    texts: {
      en: {
        text: "Niagara Falls",
        hint: "Which famous waterfall sits on the border of the USA and Canada?",
        hint1: "Millions of tourists visit it every year.",
        hint2: "Boat tours sail right up to its thundering wall of water.",
      },
      lt: {
        text: "Niagaros krioklys",
        hint: "Koks garsus krioklys yra ant JAV ir Kanados sienos?",
        hint1: "Kasmet jį aplanko milijonai turistų.",
        hint2: "Laiveliai su turistais plaukia tiesiai prie griaudžiančios vandens sienos.",
      },
    },
  },
  {
    id: "mys_klaus_023",
    category: "klausimas",
    level: 2,
    sourceVerified: "Astronomija: mūsų galaktika – Paukščių Takas",
    texts: {
      en: {
        text: "The Milky Way",
        hint: "What is the name of the galaxy our Solar System is in?",
        hint1: "On a dark night it looks like a band of light across the sky.",
        hint2: "A popular chocolate bar shares its name.",
      },
      lt: {
        text: "Paukščių Takas",
        hint: "Kaip vadinasi galaktika, kurioje yra mūsų Saulės sistema?",
        hint1: "Tamsią naktį atrodo kaip šviesos juosta danguje.",
        hint2: "Tą patį pavadinimą turi populiarus šokoladukas.",
      },
    },
  },
  {
    id: "mys_klaus_024",
    category: "klausimas",
    level: 3,
    sourceVerified: "Astrofizika: juodoji skylė – objektas, iš kurio neištrūksta net šviesa",
    texts: {
      en: {
        text: "Black Hole",
        hint: "What space object is so dense that not even light can escape it?",
        hint1: "Its gravity is extremely strong.",
        hint2: "It swallows everything nearby and gives off no light at all.",
      },
      lt: {
        text: "Juodoji skylė",
        hint: "Koks kosmoso objektas toks tankus, kad iš jo neištrūksta net šviesa?",
        hint1: "Jo gravitacija nepaprastai stipri.",
        hint2: "Jis praryja viską aplinkui ir visiškai neskleidžia šviesos.",
      },
    },
  },
  {
    id: "mys_klaus_025",
    category: "klausimas",
    level: 3,
    sourceVerified: "Botanika: Veneros musgaudė – vabzdžiaėdis augalas",
    texts: {
      en: {
        text: "Venus Flytrap",
        hint: "Which plant catches and eats insects by snapping shut?",
        hint1: "Its leaves close like a small trap when touched.",
        hint2: "It is named after the planet known as the goddess of love.",
      },
      lt: {
        text: "Veneros musgaudė",
        hint: "Koks augalas gaudo ir ėda vabzdžius užsiverdamas?",
        hint1: "Palietus lapai užsiveria kaip mažos žnyplės.",
        hint2: "Pavadintas pagal planetą, vadinamą meilės deive.",
      },
    },
  },
  {
    id: "mys_fakt_009",
    category: "faktas",
    level: 2,
    sourceVerified: "Zoologija: vombatų išmatos kubo formos dėl žarnyno sandaros (Tasmanijos univ. tyrimas, 2018)",
    texts: {
      en: {
        text: "Wombat poop is cube-shaped",
        hint: "A surprising fact about an Australian animal's droppings",
        hint1: "Its shape is geometric, not round.",
        hint2: "The animal is a stocky Australian marsupial.",
      },
      lt: {
        text: "Vombatų išmatos yra kubo formos",
        hint: "Netikėtas faktas apie australiško gyvūno išmatas",
        hint1: "Jų forma geometrinė, ne apvali.",
        hint2: "Gyvūnas – stambus australiškas sterblinis.",
      },
    },
  },
  {
    id: "mys_fakt_010",
    category: "faktas",
    level: 2,
    sourceVerified: "Bestuburių anatomija: krevetės širdis yra galvoje (galvakrūtinėje)",
    texts: {
      en: {
        text: "A shrimp's heart is in its head",
        hint: "A surprising fact about a small sea creature's body",
        hint1: "Its heart is not where you would expect.",
        hint2: "It is a small pink shellfish people often eat.",
      },
      lt: {
        text: "Krevetės širdis yra galvoje",
        hint: "Netikėtas faktas apie mažo jūros gyvio kūną",
        hint1: "Jos širdis yra ne ten, kur tikėtumeisi.",
        hint2: "Tai mažas rausvas vėžiagyvis, kurį žmonės valgo.",
      },
    },
  },
  {
    id: "mys_fakt_011",
    category: "faktas",
    level: 2,
    sourceVerified: "Ornitologija: stručio akis (~5 cm) didesnė už jo smegenis",
    texts: {
      en: {
        text: "An ostrich's eye is bigger than its brain",
        hint: "A surprising fact about the world's largest bird",
        hint1: "It compares two parts of its head.",
        hint2: "The bird cannot fly but runs very fast.",
      },
      lt: {
        text: "Stručio akis didesnė už jo smegenis",
        hint: "Netikėtas faktas apie didžiausią pasaulio paukštį",
        hint1: "Lyginamos dvi jo galvos dalys.",
        hint2: "Paukštis neskraido, bet labai greitai bėga.",
      },
    },
  },
  {
    id: "mys_ist_008",
    category: "istorija",
    level: 3,
    sourceVerified: "Istorija: F. D. Roosevelto inauguracinė kalba, 1933 m.",
    texts: {
      en: {
        text: "The only thing we have to fear is fear itself",
        hint: "A famous line from a 1933 inaugural speech about courage",
        hint1: "It says the real enemy is an emotion, not any outside threat.",
        hint2: "Panic itself, it warns, does more harm than the danger we dread.",
      },
      lt: {
        text: "Vienintelis dalykas, kurio turime bijoti, yra pati baimė",
        hint: "Garsi 1933 m. inauguracinės kalbos frazė apie drąsą",
        hint1: "Joje sakoma, kad tikrasis priešas – emocija, o ne išorinė grėsmė.",
        hint2: "Pati panika, įspėja ji, kenkia labiau nei pavojus, kurio bijome.",
      },
    },
  },
  {
    id: "mys_ist_009",
    category: "istorija",
    level: 3,
    sourceVerified: "Istorija: Dž. F. Kenedžio inauguracinė kalba, 1961 m.",
    texts: {
      en: {
        text: "Ask not what your country can do for you",
        hint: "The opening of a famous 1961 inaugural call to service",
        hint1: "It urges people to give, not just receive.",
        hint2: "Think of what you can contribute to your nation, rather than demand from it.",
      },
      lt: {
        text: "Klausk ne, ką tavo šalis gali padaryti dėl tavęs",
        hint: "Garsus 1961 m. inauguracinės kalbos raginimas tarnauti",
        hint1: "Ji ragina duoti, o ne tik gauti.",
        hint2: "Galvok, ką gali duoti savo valstybei, o ne ko iš jos reikalauti.",
      },
    },
  },
  {
    id: "mys_pat_012",
    category: "patarle",
    level: 2,
    sourceVerified: "Tarptautinė patarlė: darbai svarbesni už žodžius",
    texts: {
      en: {
        text: "Actions speak louder than words",
        hint: "A proverb about doing versus talking",
        hint1: "It values deeds over promises.",
        hint2: "What you do proves far more than anything you merely say.",
      },
      lt: {
        text: "Ne žodžiai, o darbai",
        hint: "Patarlė apie veiksmus ir kalbėjimą",
        hint1: "Ji vertina darbus labiau nei pažadus.",
        hint2: "Ką darai, įrodo kur kas daugiau nei tai, ką tik pasakai.",
      },
    },
  },
  {
    id: "mys_pat_013",
    category: "patarle",
    level: 2,
    sourceVerified: "Lietuvių liaudies patarlė apie ankstų kėlimąsi",
    texts: {
      en: {
        text: "The early bird catches the worm",
        hint: "A proverb about waking up early",
        hint1: "Being first brings the reward.",
        hint2: "Rise before everyone else and the best chances are still yours to take.",
      },
      lt: {
        text: "Kas anksti kelias, tas duoną valgo",
        hint: "Patarlė apie ankstų kėlimąsi",
        hint1: "Kas pirmas, tas laimi.",
        hint2: "Atsikelk anksčiau už visus ir geriausios progos – tavo.",
      },
    },
  },
  {
    id: "mys_pat_014",
    category: "patarle",
    level: 2,
    sourceVerified: "Tarptautinė patarlė: nevertink pagal išvaizdą",
    texts: {
      en: {
        text: "Don't judge a book by its cover",
        hint: "A proverb about not judging by appearance",
        hint1: "What is inside matters more than the outside.",
        hint2: "A dull-looking object on a shelf can hold a wonderful story within.",
      },
      lt: {
        text: "Nevertink knygos pagal viršelį",
        hint: "Patarlė apie tai, kad nereikia vertinti pagal išvaizdą",
        hint1: "Svarbiau, kas viduje, nei išorė.",
        hint2: "Kukliai atrodantis daiktas lentynoje viduje gali slėpti nuostabią istoriją.",
      },
    },
  },
  {
    id: "mys_pat_015",
    category: "patarle",
    level: 2,
    sourceVerified: "Tarptautinė patarlė: bendradarbiavimas naudingas",
    texts: {
      en: {
        text: "Two heads are better than one",
        hint: "A proverb about working together",
        hint1: "Two people solve a problem better than one.",
        hint2: "When minds join forces, the answer comes more easily.",
      },
      lt: {
        text: "Viena galva gerai, o dvi geriau",
        hint: "Patarlė apie bendrą darbą",
        hint1: "Dviese problemą išspręsti lengviau nei vienam.",
        hint2: "Kai protai susivienija, sprendimas randamas lengviau.",
      },
    },
  },
  {
    id: "mys_cit_012",
    category: "citata",
    level: 3,
    sourceVerified: "Citata: Lao Dzė (Dao De Dzin) – apie kelionės pradžią",
    texts: {
      en: {
        text: "A journey of a thousand miles begins with a single step",
        hint: "An ancient saying about how big journeys start",
        hint1: "Even huge goals start small.",
        hint2: "However far the destination, you reach it only by taking the first move.",
      },
      lt: {
        text: "Tūkstančio mylių kelionė prasideda nuo vieno žingsnio",
        hint: "Senovinė mintis apie tai, kaip prasideda didelės kelionės",
        hint1: "Net dideli tikslai prasideda nuo mažo.",
        hint2: "Kad ir koks tolimas tikslas, jį pasieki tik pradėjęs nuo pirmo judesio.",
      },
    },
  },
  {
    id: "mys_cit_013",
    category: "citata",
    level: 3,
    sourceVerified: "Citata, priskiriama A. Einšteinui – apie galimybes sunkumuose",
    texts: {
      en: {
        text: "In the middle of difficulty lies opportunity",
        hint: "A quote about finding chances in hard times",
        hint1: "Hard times can hide something good.",
        hint2: "Right in the heart of a struggle, a chance to grow is often waiting.",
      },
      lt: {
        text: "Sunkumų viduryje slypi galimybė",
        hint: "Citata apie galimybes sunkiais laikais",
        hint1: "Sunkumai gali slėpti kažką gero.",
        hint2: "Pačiame sunkmečio viduryje dažnai laukia proga augti.",
      },
    },
  },
  {
    id: "mys_klaus_026",
    category: "klausimas",
    level: 2,
    sourceVerified: "Istorija/architektūra: Gizos piramidės Egipte",
    texts: {
      en: {
        text: "The Pyramids of Giza",
        hint: "Which ancient stone monuments in Egypt were tombs for pharaohs?",
        hint1: "They have a triangular shape.",
        hint2: "They rise from the desert sands just outside Egypt's capital.",
      },
      lt: {
        text: "Gizos piramidės",
        hint: "Kokie senoviniai akmens paminklai Egipte buvo faraonų kapavietės?",
        hint1: "Jų forma trikampė.",
        hint2: "Jos kyla iš dykumos smėlio visai prie Egipto sostinės.",
      },
    },
  },
  {
    id: "mys_klaus_027",
    category: "klausimas",
    level: 1,
    sourceVerified: "Fizika/optika: vaivorykštė – šviesos lūžimas vandens lašeliuose",
    texts: {
      en: {
        text: "Rainbow",
        hint: "What colorful arc appears in the sky after rain when the sun shines?",
        hint1: "It usually has seven colors.",
        hint2: "You often see it after rain.",
      },
      lt: {
        text: "Vaivorykštė",
        hint: "Koks spalvotas lankas pasirodo danguje po lietaus, kai šviečia saulė?",
        hint1: "Ją paprastai sudaro septynios spalvos.",
        hint2: "Dažnai matoma po lietaus.",
      },
    },
  },
  {
    id: "mys_klaus_028",
    category: "klausimas",
    level: 2,
    sourceVerified: "Geologija: ugnikalnis – kalnas, išmetantis lavą",
    texts: {
      en: {
        text: "Volcano",
        hint: "What kind of mountain can erupt and pour out hot lava?",
        hint1: "It can explode with smoke and fire.",
        hint2: "Famous examples are Vesuvius and Etna.",
      },
      lt: {
        text: "Ugnikalnis",
        hint: "Koks kalnas gali išsiveržti ir lieti karštą lavą?",
        hint1: "Jis gali sprogti su dūmais ir ugnimi.",
        hint2: "Garsūs pavyzdžiai – Vezuvijus ir Etna.",
      },
    },
  },

  // ===== ĮDOMIOSIOS MĮSLĖS (2026-06-12): orientyrai, kosmosas, gyvūnai =====
  {
    id: "mys_klaus_029",
    category: "klausimas",
    level: 3,
    sourceVerified: "Bermudų trikampis — Atlanto regionas, garsus dingimų legendomis",
    texts: {
      en: {
        text: "The Bermuda Triangle",
        hint: "In which legendary ocean area are ships and planes said to vanish?",
        hint1: "It is in the Atlantic Ocean.",
        hint2: "It is named after an island and has three corners.",
      },
      lt: {
        text: "Bermudų trikampis",
        hint: "Kurioje legendinėje vandenyno zonoje esą paslaptingai dingsta laivai ir lėktuvai?",
        hint1: "Ji yra Atlanto vandenyne.",
        hint2: "Pavadinta pagal salą ir turi tris kampus.",
      },
    },
  },
  {
    id: "mys_klaus_030",
    category: "klausimas",
    level: 2,
    sourceVerified: "Didysis kanjonas — Kolorado upės išgraužtas tarpeklis JAV",
    texts: {
      en: {
        text: "The Grand Canyon",
        hint: "Which giant US gorge was carved by the Colorado River?",
        hint1: "It is in Arizona.",
        hint2: "It is up to 1.8 km deep.",
      },
      lt: {
        text: "Didysis kanjonas",
        hint: "Kokį milžinišką tarpeklį JAV išgraužė Kolorado upė?",
        hint1: "Jis yra Arizonoje.",
        hint2: "Jo gylis siekia iki 1,8 km.",
      },
    },
  },
  {
    id: "mys_klaus_031",
    category: "klausimas",
    level: 3,
    sourceVerified: "Terakotos armija saugo imperatoriaus Cin Ši Huangdžio kapą",
    texts: {
      en: {
        text: "The Terracotta Army",
        hint: "What clay guardians were buried with China's first emperor?",
        hint1: "There are about 8,000 of them.",
        hint2: "Each soldier has a different face.",
      },
      lt: {
        text: "Terakotos armija",
        hint: "Kokie moliniai sargybiniai palaidoti su pirmuoju Kinijos imperatoriumi?",
        hint1: "Jų yra apie 8000.",
        hint2: "Kiekvieno kario veidas skirtingas.",
      },
    },
  },
  {
    id: "mys_klaus_032",
    category: "klausimas",
    level: 1,
    sourceVerified: "Žemės drebėjimų stiprumas matuojamas Richterio skale",
    texts: {
      en: {
        text: "An earthquake",
        hint: "Which natural event is measured on the Richter scale?",
        hint1: "The ground shakes during it.",
        hint2: "Strong ones can topple buildings.",
      },
      lt: {
        text: "Žemės drebėjimas",
        hint: "Koks gamtos reiškinys matuojamas Richterio skale?",
        hint1: "Jo metu dreba žemė.",
        hint2: "Stiprus gali nugriauti pastatus.",
      },
    },
  },
  {
    id: "mys_klaus_033",
    category: "klausimas",
    level: 1,
    sourceVerified: "Saulės užtemimas — Mėnulis uždengia Saulę",
    texts: {
      en: {
        text: "A solar eclipse",
        hint: "What happens when the Moon hides the Sun in the middle of the day?",
        hint1: "The day suddenly becomes dark.",
        hint2: "You must never watch it without protection.",
      },
      lt: {
        text: "Saulės užtemimas",
        hint: "Kas vyksta, kai Mėnulis vidury dienos uždengia Saulę?",
        hint1: "Diena staiga aptemsta.",
        hint2: "Į jį negalima žiūrėti be apsaugos.",
      },
    },
  },
  {
    id: "mys_klaus_034",
    category: "klausimas",
    level: 2,
    sourceVerified: "Meteorų lietus — daug „krentančių žvaigždžių” vienu metu",
    texts: {
      en: {
        text: "A meteor shower",
        hint: "What do we call a night when many shooting stars streak across the sky?",
        hint1: "People make wishes when they see them.",
        hint2: "They are space dust burning in the air.",
      },
      lt: {
        text: "Meteorų lietus",
        hint: "Kaip vadinama naktis, kai dangumi krenta daugybė „žvaigždžių”?",
        hint1: "Žmonės jas pamatę sugalvoja norą.",
        hint2: "Tai ore sudegančios kosmoso dulkės.",
      },
    },
  },
  {
    id: "mys_klaus_035",
    category: "klausimas",
    level: 2,
    sourceVerified: "Didžiojo sprogimo teorija aiškina Visatos pradžią",
    texts: {
      en: {
        text: "The Big Bang",
        hint: "What is the theory about the very beginning of the Universe called?",
        hint1: "It happened about 13.8 billion years ago.",
        hint2: "The Universe has been expanding ever since.",
      },
      lt: {
        text: "Didysis sprogimas",
        hint: "Kaip vadinama teorija apie pačią Visatos pradžią?",
        hint1: "Tai įvyko maždaug prieš 13,8 mlrd. metų.",
        hint2: "Nuo tada Visata vis plečiasi.",
      },
    },
  },
  {
    id: "mys_klaus_036",
    category: "klausimas",
    level: 2,
    sourceVerified: "Stounhendžas — priešistorinis akmenų ratas Anglijoje",
    texts: {
      en: {
        text: "Stonehenge",
        hint: "What mysterious ring of giant stones stands in England?",
        hint1: "It is about 5,000 years old.",
        hint2: "Nobody knows exactly how it was built.",
      },
      lt: {
        text: "Stounhendžas",
        hint: "Koks paslaptingas milžiniškų akmenų ratas stovi Anglijoje?",
        hint1: "Jam apie 5000 metų.",
        hint2: "Niekas tiksliai nežino, kaip jis pastatytas.",
      },
    },
  },
  {
    id: "mys_klaus_037",
    category: "klausimas",
    level: 2,
    sourceVerified: "Trojos arklys — graikų gudrybė Trojos karui laimėti",
    texts: {
      en: {
        text: "The Trojan Horse",
        hint: "With what wooden gift did the Greeks trick the city of Troy?",
        hint1: "Soldiers were hiding inside it.",
        hint2: "The city pulled it through its own gates.",
      },
      lt: {
        text: "Trojos arklys",
        hint: "Kokia medine dovana graikai apgavo Trojos miestą?",
        hint1: "Jos viduje slėpėsi kariai.",
        hint2: "Miestas pats įsitempė ją pro vartus.",
      },
    },
  },
  {
    id: "mys_klaus_038",
    category: "klausimas",
    level: 1,
    sourceVerified: "Saturnas garsėja ryškiausiais žiedais Saulės sistemoje",
    texts: {
      en: {
        text: "The rings of Saturn",
        hint: "What famous 'jewelry' circles the sixth planet from the Sun?",
        hint1: "They are made of ice and rock.",
        hint2: "You can see them through a small telescope.",
      },
      lt: {
        text: "Saturno žiedai",
        hint: "Koks garsus „papuošalas” juosia šeštąją planetą nuo Saulės?",
        hint1: "Jie sudaryti iš ledo ir uolienų.",
        hint2: "Juos matysi net pro nedidelį teleskopą.",
      },
    },
  },
  {
    id: "mys_klaus_039",
    category: "klausimas",
    level: 3,
    sourceVerified: "TKS — didžiausias žmonijos statinys Žemės orbitoje",
    texts: {
      en: {
        text: "The space station",
        hint: "What is the biggest structure humans have built in orbit?",
        hint1: "Astronauts live there for months.",
        hint2: "It circles the Earth every 90 minutes.",
      },
      lt: {
        text: "Kosminė stotis",
        hint: "Koks didžiausias žmonijos statinys skrieja orbitoje aplink Žemę?",
        hint1: "Astronautai joje gyvena mėnesius.",
        hint2: "Žemę ji apskrieja kas 90 minučių.",
      },
    },
  },
  {
    id: "mys_klaus_040",
    category: "klausimas",
    level: 3,
    sourceVerified: "Galapagų salos įkvėpė Darvino evoliucijos teoriją",
    texts: {
      en: {
        text: "The Galapagos Islands",
        hint: "Which islands with giant tortoises inspired Darwin's big idea?",
        hint1: "They belong to Ecuador.",
        hint2: "Many animals there live nowhere else.",
      },
      lt: {
        text: "Galapagų salos",
        hint: "Kurios salos su milžiniškais vėžliais įkvėpė Darvino teoriją?",
        hint1: "Jos priklauso Ekvadorui.",
        hint2: "Daug ten gyvenančių gyvūnų daugiau niekur nerasi.",
      },
    },
  },
  {
    id: "mys_klaus_041",
    category: "klausimas",
    level: 3,
    sourceVerified: "Sikstos koplyčios lubas ištapė Mikelandželas",
    texts: {
      en: {
        text: "The Sistine Chapel",
        hint: "On whose famous ceiling did Michelangelo paint for four years?",
        hint1: "It is in the Vatican.",
        hint2: "He painted it lying on scaffolding.",
      },
      lt: {
        text: "Sikstos koplyčia",
        hint: "Kieno garsiąsias lubas Mikelandželas tapė ketverius metus?",
        hint1: "Ji yra Vatikane.",
        hint2: "Tapė gulėdamas ant pastolių.",
      },
    },
  },
  {
    id: "mys_klaus_042",
    category: "klausimas",
    level: 2,
    sourceVerified: "Atlantida — Platono aprašytas legendinis nuskendęs miestas",
    texts: {
      en: {
        text: "Atlantis",
        hint: "What legendary island city is said to have sunk into the sea?",
        hint1: "The ancient Greek Plato wrote about it.",
        hint2: "People still search for it today.",
      },
      lt: {
        text: "Atlantida",
        hint: "Koks legendinis salos miestas esą nugrimzdo į jūrą?",
        hint1: "Apie jį rašė senovės graikas Platonas.",
        hint2: "Žmonės jo ieško iki šiol.",
      },
    },
  },
  {
    id: "mys_fakt_012",
    category: "faktas",
    level: 3,
    sourceVerified: "Aštuonkojų kraujas mėlynas dėl hemocianino",
    texts: {
      en: {
        text: "Octopus blood is blue",
        hint: "A surprising fact about the blood of an eight-armed sea creature.",
        hint1: "It is about a color.",
        hint2: "Copper, not iron, carries its oxygen.",
      },
      lt: {
        text: "Aštuonkojo kraujas yra mėlynas",
        hint: "Stebinantis faktas apie aštuonrankio jūrų gyvūno kraują.",
        hint1: "Tai apie spalvą.",
        hint2: "Deguonį jame nešioja varis, ne geležis.",
      },
    },
  },
  {
    id: "mys_fakt_013",
    category: "faktas",
    level: 3,
    sourceVerified: "Antarktida — didžiausia dykuma pagal kritulių kiekį",
    texts: {
      en: {
        text: "Antarctica is the largest desert",
        hint: "A surprising fact about the coldest continent and deserts.",
        hint1: "Deserts are defined by lack of rain, not heat.",
        hint2: "It beats the Sahara in size.",
      },
      lt: {
        text: "Antarktida yra didžiausia dykuma",
        hint: "Stebinantis faktas apie šalčiausią žemyną ir dykumas.",
        hint1: "Dykumą apibrėžia kritulių trūkumas, ne karštis.",
        hint2: "Dydžiu ji lenkia Sacharą.",
      },
    },
  },
  {
    id: "mys_fakt_014",
    category: "faktas",
    level: 3,
    sourceVerified: "Venera sukasi priešinga kryptimi nei dauguma planetų",
    texts: {
      en: {
        text: "Venus spins backwards",
        hint: "A strange fact about how one planet rotates.",
        hint1: "There the Sun rises in the west.",
        hint2: "It is the second planet from the Sun.",
      },
      lt: {
        text: "Venera sukasi atbulai",
        hint: "Keistas faktas apie vienos planetos sukimąsi.",
        hint1: "Ten Saulė pateka vakaruose.",
        hint2: "Tai antroji planeta nuo Saulės.",
      },
    },
  },
  {
    id: "mys_fakt_015",
    category: "faktas",
    level: 2,
    sourceVerified: "Drambliai — vieninteliai žinduoliai, negalintys pašokti",
    texts: {
      en: {
        text: "Elephants cannot jump",
        hint: "A fun fact about the biggest land animal and jumping.",
        hint1: "Their legs are built only for walking.",
        hint2: "They always keep one foot on the ground.",
      },
      lt: {
        text: "Drambliai negali pašokti",
        hint: "Smagus faktas apie didžiausią sausumos gyvūną ir šuolius.",
        hint1: "Jų kojos skirtos tik vaikščioti.",
        hint2: "Viena koja visada lieka ant žemės.",
      },
    },
  },
  {
    id: "mys_fakt_016",
    category: "faktas",
    level: 4,
    sourceVerified: "Perlai sudaryti iš kalcio karbonato, kurį actas ištirpdo",
    texts: {
      en: {
        text: "Pearls dissolve in vinegar",
        hint: "A surprising fact about precious sea gems and a kitchen liquid.",
        hint1: "Cleopatra allegedly used this trick.",
        hint2: "They are made of the same stuff as chalk.",
      },
      lt: {
        text: "Perlai ištirpsta acte",
        hint: "Stebinantis faktas apie brangius jūros perlus ir virtuvės skystį.",
        hint1: "Šį triuką esą naudojo Kleopatra.",
        hint2: "Jie sudaryti iš tos pačios medžiagos kaip kreida.",
      },
    },
  },
  {
    id: "mys_fakt_017",
    category: "faktas",
    level: 3,
    sourceVerified: "Bitės „šokio” judesiais praneša kitoms kelią iki nektaro",
    texts: {
      en: {
        text: "Bees dance to give directions",
        hint: "A wonderful fact about how striped insects share a map.",
        hint1: "It is called the waggle dance.",
        hint2: "The dance shows direction and distance to flowers.",
      },
      lt: {
        text: "Bitės šokiu rodo kryptį",
        hint: "Nuostabus faktas apie tai, kaip dryžuoti vabzdžiai dalijasi žemėlapiu.",
        hint1: "Tai vadinama bičių šokiu.",
        hint2: "Šokis parodo kryptį ir atstumą iki žiedų.",
      },
    },
  },
  {
    id: "mys_fakt_018",
    category: "faktas",
    level: 3,
    sourceVerified: "Mėnulis kasmet nutolsta nuo Žemės ~3,8 cm",
    texts: {
      en: {
        text: "The Moon drifts away from Earth",
        hint: "A quiet fact about our night companion slowly leaving.",
        hint1: "About four centimeters every year.",
        hint2: "Astronauts left mirrors there to measure it.",
      },
      lt: {
        text: "Mėnulis tolsta nuo Žemės",
        hint: "Tylus faktas apie pamažu besitraukiantį nakties palydovą.",
        hint1: "Maždaug po keturis centimetrus kasmet.",
        hint2: "Astronautai ten paliko veidrodžius matavimams.",
      },
    },
  },
  {
    id: "mys_fakt_019",
    category: "faktas",
    level: 3,
    sourceVerified: "Tigrų dryžuota ne tik kailis, bet ir oda",
    texts: {
      en: {
        text: "Tiger skin is striped too",
        hint: "A hidden fact about the big striped cat under its fur.",
        hint1: "It is not only about the fur.",
        hint2: "Even shaved, the pattern would remain.",
      },
      lt: {
        text: "Tigro oda taip pat dryžuota",
        hint: "Paslėptas faktas apie didžiąją dryžuotą katę po jos kailiu.",
        hint1: "Kalbama ne tik apie kailį.",
        hint2: "Net nuskustas raštas išliktų.",
      },
    },
  },
  {
    id: "mys_fakt_020",
    category: "faktas",
    level: 2,
    sourceVerified: "Koalos miega iki 20 valandų per parą",
    texts: {
      en: {
        text: "Koalas sleep almost all day",
        hint: "A sleepy fact about a gray tree-hugging animal.",
        hint1: "Up to 20 hours daily.",
        hint2: "Their eucalyptus food gives little energy.",
      },
      lt: {
        text: "Koalos miega beveik visą parą",
        hint: "Mieguistas faktas apie pilką medžių gyventoją.",
        hint1: "Iki 20 valandų kasdien.",
        hint2: "Jų eukaliptų maistas duoda mažai energijos.",
      },
    },
  },
  {
    id: "mys_fakt_021",
    category: "faktas",
    level: 3,
    sourceVerified: "Delfinai miega pakaitomis viena smegenų puse, akis atmerkta",
    texts: {
      en: {
        text: "Dolphins sleep with one eye open",
        hint: "A clever fact about how sea acrobats rest.",
        hint1: "Half of the brain stays awake.",
        hint2: "Otherwise they would forget to breathe.",
      },
      lt: {
        text: "Delfinai miega atmerkę vieną akį",
        hint: "Gudrus faktas apie tai, kaip ilsisi jūros akrobatai.",
        hint1: "Pusė smegenų lieka budri.",
        hint2: "Kitaip jie pamirštų kvėpuoti.",
      },
    },
  },
  {
    id: "mys_fakt_022",
    category: "faktas",
    level: 3,
    sourceVerified: "Bananas botaniškai auga ant žolinio augalo, ne medžio",
    texts: {
      en: {
        text: "Bananas grow on giant herbs",
        hint: "A twisty fact about where a yellow fruit really grows.",
        hint1: "It is not a tree, despite its size.",
        hint2: "The 'trunk' is made of tightly rolled leaves.",
      },
      lt: {
        text: "Bananai auga ant milžiniškos žolės",
        hint: "Netikėtas faktas apie tai, kur iš tiesų auga geltonas vaisius.",
        hint1: "Tai ne medis, nors ir didelis.",
        hint2: "„Kamienas” — iš susisukusių lapų.",
      },
    },
  },
];

/**
 * Parenka paslaptį žaidėjui JO kalba. Jokio kalbų maišymo:
 *   1) imam tik tos kalbos vienetus;
 *   2) jei tos kalbos nėra nė vieno — TIK tada anglų atsarga.
 * Vengiama jau išspręstų; jei visos išspręstos — leidžiama kartoti.
 */
/**
 * ĮDOMUMO SVORIS (savininko pastaba 2026-06-12: „citatos/posakiai neįdomu"):
 * ~80 % partijų parenkama iš įdomiųjų kategorijų (klausimas/faktas — orientyrai,
 * kosmosas, gyvūnai, „oho" faktai), o citatos/patarlės/istorijos lieka retu
 * paįvairinimu (~20 %). Jei įdomiųjų fonde nebėra — krentam į visą fondą.
 */
const FUN_CATEGORIES = new Set<string>(["klausimas", "faktas"]);
function preferFun(pool: MysteryItem[]): MysteryItem[] {
  if (Math.random() >= 0.8) return pool; // ~20 % — bet kuri kategorija
  const fun = pool.filter((m) => FUN_CATEGORIES.has(m.category));
  return fun.length > 0 ? fun : pool;
}

export function pickMystery(
  lang: Lang,
  solvedIds: string[]
): { item: MysteryItem; lang: Lang; content: MysteryText } | null {
  const solved = new Set(solvedIds);

  // 1) Griežtai tos kalbos vienetai (be maišymo).
  let usable = MYSTERIES.filter((m) => m.texts[lang]);
  let useLangBase: Lang = lang;

  // 2) Saugiklis: jei tos kalbos visai nėra — anglų atsarga.
  if (usable.length === 0) {
    usable = MYSTERIES.filter((m) => m.texts.en);
    useLangBase = "en";
  }
  if (usable.length === 0) return null;

  // Pirmenybė neišspręstoms; jei visos išspręstos — visos tinka (kartojam).
  const fresh = usable.filter((m) => !solved.has(m.id));
  const pool = preferFun(fresh.length > 0 ? fresh : usable);

  const item = pool[Math.floor(Math.random() * pool.length)];
  const content = item.texts[useLangBase]!;
  return { item, lang: useLangBase, content };
}

/** Suranda paslaptį pagal ID (guess/reveal metu — kai jau žinome ID). */
export function findMystery(id: string): MysteryItem | undefined {
  return MYSTERIES.find((m) => m.id === id);
}

/**
 * Parenka paslaptį „Raidžių tirpimo" režimui: kaip pickMystery, bet
 *  - tinka tik frazės su 12–40 raidžių (trumpos tirpsta žiauriai, ilgos
 *    citatos beveik neįmenamos);
 *  - jei nurodytas level (1..4) — pirmenybė TO sunkumo paslaptims (žaidėjas
 *    pats renkasi lygį). Jei to lygio tinkamų nėra — švelnūs atsitraukimai:
 *    ilgio filtras be lygio → bet kuri frazė.
 */
export function pickMeltMystery(
  lang: Lang,
  solvedIds: string[],
  minLetters: number,
  maxLetters: number,
  level?: number
): { item: MysteryItem; lang: Lang; content: MysteryText } | null {
  const solved = new Set(solvedIds);
  const countLetters = (s: string) =>
    [...s].filter((ch) => /\p{L}/u.test(ch)).length;
  const fitsLen = (m: MysteryItem, l: Lang) => {
    const n = countLetters(m.texts[l]!.text);
    return n >= minLetters && n <= maxLetters;
  };

  const tryPick = (filter: (m: MysteryItem, l: Lang) => boolean) => {
    let usable = MYSTERIES.filter((m) => m.texts[lang] && filter(m, lang));
    let useLangBase: Lang = lang;
    if (usable.length === 0) {
      usable = MYSTERIES.filter((m) => m.texts.en && filter(m, "en"));
      useLangBase = "en";
    }
    if (usable.length === 0) return null;
    const fresh = usable.filter((m) => !solved.has(m.id));
    const pool = preferFun(fresh.length > 0 ? fresh : usable);
    const item = pool[Math.floor(Math.random() * pool.length)];
    return { item, lang: useLangBase, content: item.texts[useLangBase]! };
  };

  // 1) lygis + ilgis → 2) tik ilgis → 3) bet kas (saugiklis).
  if (level) {
    const r = tryPick((m, l) => m.level === level && fitsLen(m, l));
    if (r) return r;
  }
  return tryPick((m, l) => fitsLen(m, l)) ?? pickMystery(lang, solvedIds);
}
