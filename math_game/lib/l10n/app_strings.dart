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

  // --- Laikinas G1 pranešimas ---
  String modeChosen(String mode) =>
      _pick('Režimas: $mode (žaidimas — G4)', 'Mode: $mode (game — step G4)');
}
