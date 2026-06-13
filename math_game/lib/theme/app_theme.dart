import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';

/// Pagrindinių užrašų (pavadinimų, antraščių, didelių skaičių) šriftas.
/// „Kiber/neon" stilius — Orbitron. Ilgą tekstą (gamtos klausimus) paliekam
/// numatytuoju šriftu, kad gerai skaitytųsi.
const String kHeadingFont = 'Orbitron';

/// Cyber-Neumorphism paletė ir tema (DIZAINAS.md, 8 sprendimas).
/// Visos spalvos vienoje vietoje — niekur nehardcodinam (mūsų 2 ir 3 taisyklės).
class AppColors {
  AppColors._();

  // Pagrindas
  static const Color background = Color(0xFF121214); // kiber-anglis
  static const Color surface = Color(0xFF1A1A1E); // langeliai
  static const Color shadowDark = Color(0xFF0A0A0C); // neumorf. apačia-dešinė
  static const Color shadowLight = Color(0xFF232329); // neumorf. viršus-kairė

  // Tekstas
  static const Color textPrimary = Color(0xFFF5F7FA); // aukštas kontrastas
  static const Color textSecondary = Color(0xFF9AA0AD);

  // Lygių akcentai
  static const Color levelEasy = Color(0xFF3DF5A0); // mint
  static const Color levelMedium = Color(0xFFFFE03D); // elektrinė geltona
  static const Color levelHard = Color(0xFFFF4D8D); // neon rožinė
  static const Color levelExtreme = Color(0xFFB14EFF); // ultravioletinė
  static const Color neonBlue = Color(0xFF00E5FF); // mix režimas

  // --- Temų akcentai: kiekvienai pradinio meniu temai SAVA spalva (įvairovei).
  // Naudojama TIK theme_catalog.dart kortelių rėmui/švytėjimui.
  static const Color themeGeo = Color(0xFF1FE0C4); // turkis
  static const Color themeHistory = Color(0xFFFFB23D); // gintaras
  static const Color themeTech = Color(0xFF5B8CFF); // žydra
  static const Color themeFood = Color(0xFFFF7A3D); // oranžinė
  static const Color themeSport = Color(0xFF8DE63D); // laimo žalia
  static const Color themeBody = Color(0xFFFF6B6B); // koralinė
  static const Color themeCosmos = Color(0xFF6C5CE7); // indigo
  static const Color themeMyth = Color(0xFFE84DFF); // purpurinė

  // Būsenos
  static const Color correct = Color(0xFF2BD576); // teisinga (pulse)
  static const Color wrong = Color(0xFFFF3B5C); // klaida (shake blyksnis)
}

/// Žaidimo sunkumo lygiai (atitinka serverio mode: add_lengvas ir t.t.).
enum GameLevel { lengvas, vidutinis, sunkus, ekstremalus }

extension GameLevelX on GameLevel {
  /// Laikmačio laikas (ms) pagal lygį — atitinka serverio SCORING lentelę
  /// (DIZAINAS.md 5 sprendimas). Naudoja žiedas (G3). Galutinį laiką visada
  /// patvirtina serveris (maxTimeMs iš startGame), tai tik vizualui.
  int get maxTimeMs {
    switch (this) {
      case GameLevel.lengvas:
        return 3000;
      case GameLevel.vidutinis:
        return 4000;
      case GameLevel.sunkus:
        return 5000;
      case GameLevel.ekstremalus:
        return 6000;
    }
  }

  /// Akcento spalva pagal lygį.
  Color get color {
    switch (this) {
      case GameLevel.lengvas:
        return AppColors.levelEasy;
      case GameLevel.vidutinis:
        return AppColors.levelMedium;
      case GameLevel.sunkus:
        return AppColors.levelHard;
      case GameLevel.ekstremalus:
        return AppColors.levelExtreme;
    }
  }

  /// Pavadinimas ekranui — paimamas iš AppStrings (LT/EN).
  String title(AppStrings s) {
    switch (this) {
      case GameLevel.lengvas:
        return s.levelEasy;
      case GameLevel.vidutinis:
        return s.levelMedium;
      case GameLevel.sunkus:
        return s.levelHard;
      case GameLevel.ekstremalus:
        return s.levelExtreme;
    }
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          surface: AppColors.surface,
          primary: AppColors.levelEasy,
          error: AppColors.wrong,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontFamily: kHeadingFont,
          ),
          headlineMedium: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontFamily: kHeadingFont,
          ),
          titleLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontFamily: kHeadingFont,
          ),
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textSecondary),
        ),
      );
}
