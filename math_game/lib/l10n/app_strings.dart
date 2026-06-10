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
  String get appName => 'BRAIN ARENA';
  String get chooseCategory =>
      _pick('Pasirink temą', 'Choose a category');
  String get categoryMath => _pick('Matematika', 'Math');
  String get categoryMathDesc =>
      _pick('Skaičiavimas greičiui', 'Calculate against the clock');
  String get categoryNature => _pick('Gamta', 'Nature');
  String get categoryNatureDesc =>
      _pick('Gyvūnai, augalai, faktai', 'Animals, plants, facts');

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
