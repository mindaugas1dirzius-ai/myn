import 'package:flutter/material.dart';

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

  // Būsenos
  static const Color correct = Color(0xFF2BD576); // teisinga (pulse)
  static const Color wrong = Color(0xFFFF3B5C); // klaida (shake blyksnis)
}

/// Žaidimo sunkumo lygiai (atitinka serverio mode: add_lengvas ir t.t.).
enum GameLevel { lengvas, vidutinis, sunkus, ekstremalus }

extension GameLevelX on GameLevel {
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

  /// Lietuviškas pavadinimas ekranui.
  String get title {
    switch (this) {
      case GameLevel.lengvas:
        return 'Lengvas';
      case GameLevel.vidutinis:
        return 'Vidutinis';
      case GameLevel.sunkus:
        return 'Sunkus';
      case GameLevel.ekstremalus:
        return 'Ekstremalus';
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
          ),
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textSecondary),
        ),
      );
}
