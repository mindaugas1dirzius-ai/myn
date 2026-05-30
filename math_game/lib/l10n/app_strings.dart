import 'package:flutter/widgets.dart';

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
    final code = Localizations.maybeLocaleOf(context)?.languageCode ?? 'lt';
    return AppStrings(code == 'en' ? AppLang.en : AppLang.lt);
  }

  String _pick(String lt, String en) => lang == AppLang.lt ? lt : en;

  // --- Bendri ---
  String get appTitle => 'Math Game';
  String get pickOperation => _pick('Pasirink veiksmą', 'Pick an operation');
  String get pickLevel => _pick('Pasirink lygį', 'Pick a level');

  // --- Veiksmai ---
  String get opAdd => _pick('Sudėtis', 'Addition');
  String get opSub => _pick('Atimtis', 'Subtraction');
  String get opMul => _pick('Daugyba', 'Multiplication');
  String get opDiv => _pick('Dalyba', 'Division');

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

  // --- Įvertinimai ---
  String get ratingPerfect => _pick('Tobula! 🎉', 'Perfect! 🎉');
  String get ratingGood => _pick('Puiku!', 'Great!');
  String get ratingOk => _pick('Neblogai', 'Not bad');
  String get ratingTryAgain => _pick('Bandyk dar', 'Try again');

  // --- Lyderių lentelė ---
  String get leaderboardTitle => _pick('Top 10', 'Top 10');
  String get leaderboardEmpty =>
      _pick('Dar nėra rezultatų — būk pirmas!', 'No scores yet — be the first!');
  String get leaderboardError =>
      _pick('Nepavyko įkelti lentelės', 'Could not load leaderboard');
  String get leaderboardOffline => _pick(
      'Prisijunk prie tinklo, kad varžytumeisi Top 10 lentelėje',
      'Connect to the internet to compete on the Top 10');
}
