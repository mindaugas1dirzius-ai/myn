import 'package:flutter/widgets.dart';
import 'language_controller.dart';

/// Centralizuoti vertimai (LT + EN). 0 sprendimas DIZAINAS.md.
///
/// KODĖL: niekada nehardcodinam teksto ekranuose — visada per raktą,
/// kad pridėti kalbą ar pakeisti žodį būtų vienoje vietoje (2 ir 3 taisyklės).
///
/// Naudojimas ekrane:  AppStrings.of(context).pickOperation
enum AppLang { lt, en }

class AppStrings {
  final AppLang lang;
  const AppStrings(this.lang);

  /// Paima dabartinę kalbą iš medžio (kol nėra perjungiklio — pagal locale).
  static AppStrings of(BuildContext context) {
    final system = Localizations.maybeLocaleOf(context) ?? const Locale('lt');
    return AppStrings(languageController.resolve(system));
  }

  String _pick(String lt, String en) => lang == AppLang.lt ? lt : en;

  // --- Bendri ---
  String get appTitle => 'Math Game';
  String get pickOperation => _pick('Pasirink veiksmą', 'Pick an operation');
  String get pickLevel => _pick('Pasirink lygį', 'Pick a level');

  // --- Kategorijų meniu (pradinis langas: matematika / gamta / ...) ---
  String get appName => 'Minalect Arena';
  String get chooseCategory =>
      _pick('Pasirink temą', 'Choose a category');
  String get categoryMath => _pick('Matematika', 'Math');
  String get categoryMathDesc =>
      _pick('Skaičiavimas greičiui', 'Calculate against the clock');
  String get categoryNature => _pick('Gamta', 'Nature');
  String get categoryNatureDesc =>
      _pick('Gyvūnai, augalai, faktai', 'Animals, plants, facts');

  // --- Naujos temos (skeletas: kol kas užrakintos „Greitai") ---
  String get categoryPop => _pick('Pop kultūra', 'Pop culture');
  String get categoryPopDesc =>
      _pick('Filmai, muzika, pramogos', 'Movies, music, entertainment');
  String get categoryGeo => _pick('Geografija', 'Geography');
  String get categoryGeoDesc =>
      _pick('Šalys, sostinės, pasaulis', 'Countries, capitals, the world');
  String get categoryHistory => _pick('Istorija', 'History');
  String get categoryHistoryDesc =>
      _pick('Civilizacijos ir išradimai', 'Civilizations and inventions');
  String get categoryTech => _pick('Technologijos', 'Technology');
  String get categoryTechDesc =>
      _pick('Mokslas ir išradimai', 'Science and inventions');
  String get categoryFood => _pick('Maistas', 'Food');
  String get categoryFoodDesc =>
      _pick('Patiekalai ir gėrimai', 'Dishes and drinks');
  String get categorySport => _pick('Sportas', 'Sport');
  String get categorySportDesc =>
      _pick('Žaidimai ir rekordai', 'Games and records');
  String get categoryBody => _pick('Žmogaus kūnas', 'Human body');
  String get categoryBodyDesc =>
      _pick('Kaip veikia mūsų kūnas', 'How our body works');
  String get categoryCosmos => _pick('Kosmosas', 'Space');
  String get categoryCosmosDesc =>
      _pick('Planetos, žvaigždės ir misijos', 'Planets, stars and missions');
  String get categoryMythology => _pick('Mitologija', 'Mythology');
  String get categoryMythologyDesc =>
      _pick('Dievai, herojai ir legendos', 'Gods, heroes and legends');
  String get categoryRecords => _pick('Rekordai', 'Records');
  String get categoryRecordsDesc =>
      _pick('Rekordai ir nuostabios keistenybės', 'Records and amazing oddities');
  String get categoryBrands => _pick('Prekių ženklai', 'Brands');
  String get categoryBrandsDesc =>
      _pick('Garsių ženklų istorijos ir vardai', 'Famous brand stories and names');
  String get categoryTransport => _pick('Transportas', 'Transport');
  String get categoryTransportDesc =>
      _pick('Lėktuvai, laivai, traukiniai, kelionės', 'Planes, ships, trains, journeys');
  String get categoryExam => _pick('Egzaminų centras', 'Exam Center');
  String get categoryExamDesc =>
      _pick('Laikyk egzaminus, gauk diplomus', 'Take exams, earn diplomas');
  String get categoryBlitz => _pick('Blitz', 'Blitz');
  String get categoryBlitzDesc =>
      _pick('Taip ar ne — greičiui', 'Yes or no — beat the clock');
  String get categoryMyth => _pick('Tiesa ar mitas?', 'Fact or myth?');
  String get categoryMythDesc => _pick(
      'Patikrink, ar neapgauna mitai', 'Find out if myths are fooling you');
  String get lockedThemeNote => _pick(
      'Ši tema dar ruošiama — greitai!',
      'This theme is being prepared — coming soon!');
  String get penaltyExplain => _pick(
      'Kiekviena klaida nubraukia taškus',
      'Each mistake deducts points');
  String get quizRewardsNote => _pick(
      '🪙 Monetos ir 🔤 raidės skiriamos surinkus bent 4 teisingus',
      '🪙 Coins and 🔤 letters are awarded from 4 correct answers');
  String get mythRewardsNote => _pick(
      '🪙 Monetos skiriamos, kai teisingų daugiau nei klaidų',
      '🪙 Coins are awarded when correct answers outnumber mistakes');

  // --- ⚡ TAIP/NE Blitz ---
  String get blitzGetReady => _pick('Pasiruošk!', 'Get ready!');
  String get blitzYes => _pick('TAIP', 'YES');
  String get blitzNo => _pick('NE', 'NO');
  String get blitzCombo => _pick('Serija', 'Streak');
  String get blitzTimeUp => _pick('Laikas!', "Time's up!");
  String get blitzAnswered => _pick('Atsakyta', 'Answered');
  String get blitzCorrectLabel => _pick('Teisingi', 'Correct');
  String get blitzBestCombo => _pick('Geriausia serija', 'Best streak');
  String get blitzPlayAgain => _pick('Žaisti dar', 'Play again');
  String get blitzClose => _pick('Uždaryti', 'Close');
  String get blitzNewRecord => _pick('🏆 Naujas rekordas!', '🏆 New record!');
  String get blitzExpired => _pick(
      'Raundas nebegalioja (per ilga pauzė) — taškai neįskaityti.',
      'Round expired (paused too long) — score not counted.');
  String get blitzFinalX2 => _pick('FINALAS ×2!', 'FINALE ×2!');
  String get blitzPickDuration =>
      _pick('Pasirink raundo trukmę', 'Pick your round length');
  String get blitzStart => _pick('PRADĖTI', 'START');
  String get blitzChangeDuration => _pick('Keisti trukmę', 'Change length');
  String get blitzRuleCombo =>
      _pick('Serija be klaidų — taškai iki ×2', 'No-mistake streak — up to ×2 points');
  String get blitzRulePenalty => _pick(
      'Klaida — minus 200 (dviguba atsakymo vertė)! Per greiti nesiskaito',
      'A mistake costs 200 (double an answer)! Too-fast taps don\'t count');
  String get blitzRuleFinal =>
      _pick('Paskutinės 5 sek. — viskas ×2', 'Final 5 seconds — everything ×2');
  String get blitzRuleSwipe =>
      _pick('Spausk mygtukus arba brauk kortelę', 'Tap the buttons or swipe the card');
  String get blitzCoins => _pick('Monetos', 'Coins');
  String get blitzLetters => _pick('Raidės', 'Letters');
  String get blitzQuitTitle => _pick('Nutraukti raundą?', 'Quit the round?');
  String get blitzQuitBody => _pick(
      'Taškai nebus įskaityti.', 'Your score will not be counted.');
  String get blitzQuitStay => _pick('Likti', 'Stay');
  String get blitzQuitLeave => _pick('Nutraukti', 'Quit');

  // --- Gamtos žaidimas ---
  String get natureLoadError => _pick(
      'Nepavyko įkelti klausimų. Patikrink internetą ir bandyk dar.',
      'Could not load questions. Check your connection and try again.');
  String get retry => _pick('Bandyti dar', 'Try again');
  String get comingSoon => _pick('Greitai', 'Coming soon');
  String get lockedLevelNote => _pick(
      'Šis lygis dar ruošiamas — greitai!',
      'This level is being prepared — coming soon!');

  // --- Gamtos potemės (tema „Gamta ir gyvūnai" → potemė → lygis → žaidimas) ---
  String get pickTopic => _pick('Pasirink potemę', 'Pick a topic');
  String get topicFacts => _pick('Įdomūs faktai', 'Fun facts');
  String get topicFactsDesc =>
      _pick('Gyvūnai, augalai ir daugiau', 'Animals, plants and more');
  String get topicExtinct => _pick('Išnykę gyvūnai', 'Extinct animals');
  String get topicExtinctDesc =>
      _pick('Dinozaurai ir prarasta gamta', 'Dinosaurs and lost nature');
  String get topicPlants => _pick('Augalai', 'Plants');
  String get topicPlantsDesc =>
      _pick('Medžiai, gėlės, grybai', 'Trees, flowers, fungi');
  String get topicMix => _pick('Viskas iš eilės', 'Mixed');
  String get topicMixDesc =>
      _pick('Klausimai iš visų potemių', 'Questions from all topics');
  String get lockedTopicNote => _pick(
      'Ši potemė dar ruošiama — greitai!',
      'This topic is being prepared — coming soon!');

  // --- Bendrų temų potemės (tech, žmogaus kūnas) ---
  // Tech
  String get subTechGames =>
      _pick('Video žaidimų evoliucija', 'Video game evolution');
  String get subTechGamesDesc =>
      _pick('Nuo Tetris iki Fortnite, esportas', 'From Tetris to Fortnite, esports');
  String get subTechMyths => _pick('Mitai ir išradimai', 'Myths & inventions');
  String get subTechMythsDesc => _pick(
      'Paplitę mitai ir išradimų istorijos', 'Common myths and invention stories');
  String get subTechSpace => _pick('Kosmoso lenktynės', 'Space race');
  String get subTechSpaceDesc =>
      _pick('SpaceX, NASA, Marsas, astronautai', 'SpaceX, NASA, Mars, astronauts');
  String get subTechAi => _pick('AI, robotai ir virusai', 'AI, robots & viruses');
  String get subTechAiDesc => _pick(
      'Dirbtinis intelektas, hakeriai, virusai', 'AI, hackers, computer viruses');
  // Kosmosas — potemės
  String get subCosmosPlanets =>
      _pick('Planetos ir Saulės sistema', 'Planets & Solar System');
  String get subCosmosPlanetsDesc =>
      _pick('Planetos, mėnuliai, žiedai, rekordai', 'Planets, moons, rings, records');
  String get subCosmosAstronauts =>
      _pick('Astronautai ir misijos', 'Astronauts & missions');
  String get subCosmosAstronautsDesc =>
      _pick('Žmonės kosmose, stotys, žygiai', 'People in space, stations, walks');
  String get subCosmosUniverse => _pick('Visata ir žvaigždės', 'Universe & stars');
  String get subCosmosUniverseDesc =>
      _pick('Galaktikos, juodosios skylės, žvaigždės', 'Galaxies, black holes, stars');
  String get subCosmosRockets => _pick('Raketos ir tyrimai', 'Rockets & exploration');
  String get subCosmosRocketsDesc =>
      _pick('Raketos, zondai, teleskopai', 'Rockets, probes, telescopes');
  // Mitologija — potemės
  String get subMythGreek => _pick('Graikų ir romėnų mitai', 'Greek & Roman myths');
  String get subMythGreekDesc =>
      _pick('Dzeusas, Olimpas, herojai, pabaisos', 'Zeus, Olympus, heroes, monsters');
  String get subMythNorse => _pick('Šiaurės mitai', 'Norse myths');
  String get subMythNorseDesc =>
      _pick('Toras, Odinas, Valhala, milžinai', 'Thor, Odin, Valhalla, giants');
  String get subMythEgypt => _pick('Egiptas ir Rytai', 'Egypt & the East');
  String get subMythEgyptDesc =>
      _pick('Anubis, Ra, dievai ir legendos', 'Anubis, Ra, gods and legends');
  String get subMythCreatures => _pick('Būtybės ir legendos', 'Beasts & legends');
  String get subMythCreaturesDesc =>
      _pick('Drakonai, Atlantida, karalius Artūras', 'Dragons, Atlantis, King Arthur');
  // Rekordai — potemės
  String get subRecHuman => _pick('Žmonių rekordai', 'Human records');
  String get subRecHumanDesc =>
      _pick('Aukščiausias, greičiausias, seniausias', 'Tallest, fastest, oldest');
  String get subRecWorld => _pick('Pasaulio rekordai', 'World records');
  String get subRecWorldDesc =>
      _pick('Statiniai, gamtos kraštutinumai', 'Structures, nature extremes');
  String get subRecLaws => _pick('Keisti įstatymai', 'Weird laws');
  String get subRecLawsDesc =>
      _pick('Keisčiausi pasaulio įstatymai ir tradicijos', 'The strangest laws and traditions');
  String get subRecObjects => _pick('Daiktų rekordai', 'Object records');
  String get subRecObjectsDesc =>
      _pick('Brangiausi, didžiausi daiktai ir maistas', 'Priciest, biggest things and food');
  // Prekių ženklai — potemės
  String get subBrandsFood => _pick('Maistas ir gėrimai', 'Food & drinks');
  String get subBrandsFoodDesc =>
      _pick('Coca-Cola, McDonald’s, šokoladai', 'Coca-Cola, McDonald’s, chocolate');
  String get subBrandsFashion => _pick('Mada ir daiktai', 'Fashion & objects');
  String get subBrandsFashionDesc =>
      _pick('Adidas, LEGO, IKEA, žaislai', 'Adidas, LEGO, IKEA, toys');
  String get subBrandsCars => _pick('Automobiliai', 'Cars & machines');
  String get subBrandsCarsDesc =>
      _pick('Mašinų ženklų vardų kilmės', 'Where car badge names come from');
  String get subBrandsNames => _pick('Vardų paslaptys', 'Name secrets');
  String get subBrandsNamesDesc =>
      _pick('Kodėl Apple, Google, Bluetooth', 'Why Apple, Google, Bluetooth');
  // Transportas — potemės
  String get subTransTrains => _pick('Traukiniai ir metro', 'Trains & metro');
  String get subTransTrainsDesc =>
      _pick('Greitieji, garlaiviai, požeminis', 'Bullet trains, steam, the Tube');
  String get subTransAviation => _pick('Aviacija', 'Aviation');
  String get subTransAviationDesc =>
      _pick('Lėktuvai, sraigtasparniai, oro uostai', 'Planes, helicopters, airports');
  String get subTransShips => _pick('Laivai ir jūros', 'Ships & seas');
  String get subTransShipsDesc =>
      _pick('Burlaiviai, Titanikas, kanalai', 'Sailing ships, Titanic, canals');
  String get subTransRoutes => _pick('Garsieji maršrutai', 'Famous routes');
  String get subTransRoutesDesc =>
      _pick('Šilko kelias, Route 66, Orient Express', 'Silk Road, Route 66, Orient Express');
  // Žmogaus kūnas — potemės „protmūšio" stiliumi (įdomu, ne vadovėlis)
  String get subBodyBrain => _pick('Smegenų paslaptys', 'Brain secrets');
  String get subBodyBrainDesc =>
      _pick('Iliuzijos, sapnai, atminties ribos', 'Illusions, dreams, memory limits');
  String get subBodyBones => _pick('Raumenys ir fitnesas', 'Muscle & fitness');
  String get subBodyBonesDesc =>
      _pick('Kaulai, ištvermė, kūno supergalios', 'Bones, endurance, body superpowers');
  String get subBodyBio => _pick('Biologiniai kuriozai', 'Biology oddities');
  String get subBodyBioDesc =>
      _pick('Keista medicina, DNR, kūno paslaptys', 'Strange medicine, DNA, body secrets');
  // Maistas — potemės „protmūšio" stiliumi
  String get subFoodWorld => _pick('Pasaulio virtuvės', 'World cuisines');
  String get subFoodWorldDesc =>
      _pick('Patiekalų kilmė ir garsiausi skoniai', 'Dish origins and famous flavors');
  String get subFoodScience => _pick('Maisto mokslas', 'Food science');
  String get subFoodScienceDesc =>
      _pick('Kas vyksta keptuvėje, ingredientų chemija', 'Kitchen chemistry of ingredients');
  String get subFoodProduction => _pick('Gamybos paslaptys', 'Production secrets');
  String get subFoodProductionDesc =>
      _pick('Kaip gaminamas mūsų maistas', 'How our food is made');
  String get subFoodExotic => _pick('Egzotiškas maistas', 'Exotic food');
  String get subFoodExoticDesc =>
      _pick('Drąsiausi patiekalai iš viso pasaulio', 'The boldest dishes worldwide');
  // Geografija — potemės (pagal žaidėjo planą)
  String get subGeoNature => _pick('Gamtos stebuklai', 'Natural wonders');
  String get subGeoNatureDesc =>
      _pick('Kanjonai, vulkanai, gelmės, rekordai', 'Canyons, volcanoes, depths, records');
  String get subGeoMegapolis => _pick('Megapoliai', 'Megacities');
  String get subGeoMegapolisDesc => _pick(
      'Didmiesčiai, dangoraižiai, požemiai, pamesti miestai',
      'Megacities, skyscrapers, underground, lost cities');
  String get subGeoCulture => _pick('Kultūra ir festivaliai', 'Culture & festivals');
  String get subGeoCultureDesc =>
      _pick('Keisti įpročiai, festivaliai, tradicijos', 'Odd customs, festivals, traditions');
  String get subGeoParadox => _pick('Geografiniai paradoksai', 'Geographic paradoxes');
  String get subGeoParadoxDesc => _pick(
      'Enklavai, sienos, laiko juostos, žemėlapiai', 'Enclaves, borders, time zones, maps');
  // Istorija — potemės
  String get subHistoryAncient => _pick('Senovės pasaulis', 'Ancient world');
  String get subHistoryAncientDesc =>
      _pick('Antika, viduramžiai, renesansas', 'Antiquity, Middle Ages, Renaissance');
  String get subHistoryModern => _pick('Naujieji laikai', 'Modern era');
  String get subHistoryModernDesc =>
      _pick('Atradimai, išradimai, įvykiai', 'Discoveries, inventions, events');
  String get subHistoryEngineering => _pick('Senovės inžinerija', 'Ancient engineering');
  String get subHistoryEngineeringDesc => _pick(
      'Piramidės, akvedukai, prarasti statiniai', 'Pyramids, aqueducts, lost structures');
  String get subHistoryRulers => _pick('Ekscentriški valdovai', 'Eccentric rulers');
  String get subHistoryRulersDesc => _pick(
      'Keisti karaliai, imperatoriai, jų užgaidos', 'Strange kings, emperors and their whims');
  String get subHistoryMyths => _pick('Istoriniai mitai', 'Historical myths');
  String get subHistoryMythsDesc =>
      _pick('Populiarūs klaidingi įsitikinimai', 'Popular misconceptions debunked');
  // Pop kultūra — potemės
  String get subPopFilms => _pick('Filmai', 'Movies');
  String get subPopFilmsDesc =>
      _pick('Kinas, aktoriai, animacija', 'Cinema, actors, animation');
  String get subPopTv => _pick('TV ir serialai', 'TV & series');
  String get subPopTvDesc =>
      _pick('Serialai, laidos, TV istorija', 'Series, shows, TV history');
  String get subPopMusic => _pick('Muzika', 'Music');
  String get subPopMusicDesc =>
      _pick('Atlikėjai, instrumentai, klasika', 'Artists, instruments, classics');
  String get subPopStories => _pick('Herojai ir istorijos', 'Heroes & stories');
  String get subPopStoriesDesc =>
      _pick('Knygos, personažai, mitai, menas', 'Books, characters, myths, art');
  // Sportas — potemės
  String get subSportRacing => _pick('Lenktynės', 'Racing');
  String get subSportRacingDesc =>
      _pick('Formulė 1, ralis, trasos, greitis', 'Formula 1, rally, tracks, speed');
  String get subSportGym => _pick('Gimnastika', 'Gymnastics');
  String get subSportGymDesc =>
      _pick('Prietaisai, akrobatika, įvertinimai', 'Apparatus, acrobatics, scoring');
  String get subSportOlympics => _pick('Olimpiada', 'Olympics');
  String get subSportOlympicsDesc =>
      _pick('Žiedai, ugnis, medaliai, istorija', 'Rings, flame, medals, history');
  String get subSportMartial => _pick('Kovos menai', 'Martial arts');
  String get subSportMartialDesc =>
      _pick('Dziudo, boksas, karatė, diržai', 'Judo, boxing, karate, belts');
  String get subSportRules => _pick('Taisyklės ir technika', 'Rules & technique');
  String get subSportRulesDesc =>
      _pick('Žaidimo taisyklės ir inventorius', 'Game rules and equipment');
  String get subSportDisciplines => _pick('Šakos ir varžybos', 'Disciplines & games');
  String get subSportDisciplinesDesc =>
      _pick('Olimpinės, futbolas, istorija', 'Olympics, football, history');

  // --- Veiksmai ---
  String get opAdd => _pick('Sudėtis', 'Addition');
  String get opSub => _pick('Atimtis', 'Subtraction');
  String get opMul => _pick('Daugyba', 'Multiplication');
  String get opDiv => _pick('Dalyba', 'Division');
  String get opMix2 => _pick('Mix Blitz', 'Mix Blitz');
  String get opBrackets => _pick('Skliaustai', 'Brackets');
  String get opAlgebra => _pick('Algebra X', 'Algebra X');

  // --- Lygiai ---
  String get levelEasy => _pick('Lengvas', 'Easy');
  String get levelMedium => _pick('Vidutinis', 'Medium');
  String get levelHard => _pick('Sunkus', 'Hard');
  String get levelExtreme => _pick('Ekstremalus', 'Extreme');

  // --- Rezultatai ---
  String get resultTitle => _pick('Rezultatas', 'Result');
  String get score => _pick('Taškai', 'Score');
  String get playAgain => _pick('Žaisti dar', 'Play again');
  String get toMenu => _pick('Į meniu', 'To menu');

  // --- Offline įspėjimai (taškai/monetos įskaitomi tik prisijungus) ---
  String get offlinePlaying => _pick(
      '⚠️ Žaidi neprisijungęs — taškai ir monetos neįsiskaitys',
      '⚠️ Playing offline — score and coins won\'t count');
  String get offlineResultNote => _pick(
      'Žaista neprisijungus: rezultatas neįrašytas į Top 10 ir monetų negavai. '
          'Prisijunk prie interneto, kad taškai įsiskaitytų.',
      'Played offline: result was not saved to Top 10 and no coins were earned. '
          'Connect to the internet so your scores count.');

  // --- Įvertinimai ---
  String get ratingPerfect => _pick('Tobula! 🎉', 'Perfect! 🎉');
  String get ratingGood => _pick('Puiku!', 'Great!');
  String get ratingOk => _pick('Neblogai', 'Not bad');
  String get ratingTryAgain => _pick('Bandyk dar', 'Try again');

  // --- Atsakymų apžvalga (gamta: ko teisinga / kodėl) ---
  String get reviewTitle => _pick('Atsakymų apžvalga', 'Answer review');
  String get reviewCorrectLabel => _pick('Teisingas:', 'Correct:');
  String get reviewYourAnswer => _pick('Tavo atsakymas:', 'Your answer:');
  String get reviewSkipped => _pick('Praleista', 'Skipped');

  // --- Lyderių lentelė ---
  String get leaderboardTitle => _pick('Top 10', 'Top 10');
  String get leaderboardEmpty =>
      _pick('Dar nėra rezultatų — būk pirmas!', 'No scores yet — be the first!');
  String get leaderboardError =>
      _pick('Nepavyko įkelti lentelės', 'Could not load leaderboard');
  String get leaderboardOffline => _pick(
      'Prisijunk prie tinklo, kad varžytumeisi Top 10 lentelėje',
      'Connect to the internet to compete on the Top 10');

  // --- Išėjimas / mygtukai ---
  String get quitTitle => _pick('Nori pasiduoti?', 'Give up?');
  String get quitBody => _pick(
      'Šios sesijos taškai bus prarasti ir į Top 10 nepateksi.',
      'This session\'s score will be lost and won\'t count for the Top 10.');
  String get stayInGame => _pick('Likti žaidime', 'Stay in game');
  String get quitYes => _pick('Taip, išeiti', 'Yes, quit');
  String get exitApp => _pick('Išeiti iš žaidimo', 'Exit game');

  // --- Užraktai (Etapas 3 — paketų modelis: 1 atrakinimas = 2 žaidimai) ---
  String get unlockTitle => _pick('Atrakinti 2 žaidimus', 'Unlock 2 plays');
  String unlockWithCoins(int cost) =>
      _pick('2 žaidimai už $cost 🪙', '2 plays for $cost 🪙');
  String get unlockWithAd =>
      _pick('Žiūrėk reklamą → 2 žaidimai', 'Watch an ad → 2 plays');
  String get notEnoughCoins =>
      _pick('Per mažai monetų — pažaisk dar!', 'Not enough coins — play more!');
  String get packUnlocked =>
      _pick('2 žaidimai atrakinti! 🎉', '2 plays unlocked! 🎉');
  String get adLimitReached => _pick(
      'Šiandien reklamų limitas pasiektas. Bandyk rytoj!',
      'Daily ad limit reached. Try again tomorrow!');
  String get adFailed => _pick(
      'Nepavyko atrakinti. Patikrink ryšį ir bandyk dar.',
      'Unlock failed. Check your connection and try again.');
  String playsLeft(int n) => _pick('Liko: $n/2', 'Left: $n/2');
  String get yourCoins => _pick('Tavo monetos', 'Your coins');

  // --- Premium prenumerata (Etapas B — 2.99 €/mėn = viskas atrakinta mėnesiui) ---
  String get subscribeTitle => _pick('Premium prenumerata', 'Premium subscription');
  String get subscribeOffer => _pick(
      '2.99 €/mėn — atrakink VISKĄ mėnesiui (visi lygiai, be reklamų užraktų).',
      '€2.99/mo — unlock EVERYTHING for a month (all levels, no unlock walls).');
  String get subscribeBtn => _pick('Prenumeruoti', 'Subscribe');
  String subscribeActiveUntil(String date) =>
      _pick('✅ Premium aktyvi iki $date', '✅ Premium active until $date');
  String get subscribeComingSoon => _pick(
      'Prenumerata įsijungs, kai žaidimas bus paskelbtas Google Play parduotuvėje. '
          'Tada čia galėsi saugiai sumokėti per Google.',
      'Subscriptions activate once the game is published on the Google Play store. '
          'You\'ll then be able to pay securely through Google here.');

  // --- Profilis ---
  String get profile => _pick('Profilis', 'Profile');
  String get enterName => _pick('Įvesk savo vardą', 'Enter your name');
  String get save => _pick('Išsaugoti', 'Save');
  String get personalBest => _pick('Tavo rekordas', 'Personal best');
  String get noRecord => _pick('Dar nežaista', 'Not played yet');
  String yourRank(int pos, int total) =>
      _pick('Tavo pozicija: $pos iš $total', 'Your rank: $pos of $total');

  // --- Profilio statistika (avatarai + kaupiami taškai) ---
  String get totalPoints => _pick('Bendri taškai', 'Total points');
  String get coins => _pick('Monetos', 'Coins');
  String get learnedFacts => _pick('Išmokti faktai', 'Facts learned');
  String get streakDays => _pick('Serija', 'Streak');
  String dayShort(int n) => _pick('$n d.', '$n d');
  String get planLabel => _pick('Planas', 'Plan');
  String get planFree => _pick('Nemokamas', 'Free');
  String get planPremium => _pick('Premium', 'Premium');
  String get resultsByTheme =>
      _pick('Rezultatai pagal temą', 'Results by theme');
  String get avatarsTitle => _pick('Avatarai', 'Avatars');
  String get yourAvatar => _pick('Tavo avataras', 'Your avatar');
  String get nextAvatar => _pick('Kitas avataras', 'Next avatar');
  String get maxAvatarReached =>
      _pick('Pasiekei viršūnę! 🌌', 'You reached the top! 🌌');
  String pointsToNext(int n) =>
      _pick('dar $n tšk.', '$n pts to go');
  String freePlaysPerMonth(int n) =>
      _pick('$n nemok. žaid./mėn', '$n free plays/mo');
  String freePlaysLeft(int left, int total) =>
      _pick('Nemokami žaidimai: $left/$total', 'Free plays: $left/$total');
  String get avatarLockedHint =>
      _pick('Surink bendrų taškų, kad atrakintum', 'Earn total points to unlock');
  String avatarUnlockedAt(int n) =>
      _pick('Atrakinta nuo $n tšk.', 'Unlocks at $n pts');

  // --- Top 10 raginimas įvesti vardą (variantas C) ---
  String get top10Title => _pick('🏆 Patekai į Top 10!', '🏆 You made the Top 10!');
  String get top10Body => _pick(
      'Įrašyk savo vardą, kad visi matytų tavo rezultatą!',
      'Enter your name so everyone sees your score!');
  String get enterNameBtn => _pick('Įvesti vardą ✏️', 'Enter name ✏️');
  String get later => _pick('Vėliau', 'Later');
  String get coinsEarned => _pick('Monetos', 'Coins');
}
