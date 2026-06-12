import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

/// VIENA vieta, kur aprašytos VISOS žaidimo temos (griaučiai).
///
/// KODĖL: kad pridėti/atrakinti temą būtų 1 eilutė — pradinis ekranas, srautai
/// ir užraktai skaito IŠ ČIA, o ne kiekvienas atskirai. Atrakinti temą =
/// pakeisti `open: false → true` (kai turėsim klausimų).
///
/// SVARBU: `code` yra STABILUS serverio kodas (Top 10 lentelėms). NIEKADA
/// nekeičiam jau paskelbto kodo.

/// Kokio TIPO tema — nuo to priklauso, koks ekranas atsidaro paspaudus.
enum ThemeKind {
  math,    // matematika (generuojama) → veiksmų ekranas
  nature,  // gamta (trivija su potemėmis) → potemių ekranas
  mystery, // „Atspėk paslaptį" (meta-žaidimas) → paslapties ekranas
  trivia,  // bendra žinių trivija → universalus lygių ekranas
  blitz,   // ⚡ „Taip/Ne" greitis (30 s / 1 min raundai)
  myth,    // 🧐 „Tiesa ar mitas?" (mūsų paruošti teiginiai + paaiškinimai)
}

/// Vienos temos aprašas pradiniam ekranui ir maršrutams.
class GameTheme {
  /// Serverio kategorijos kodas (pvz. "tech"). Matematikai/paslapčiai/blitz —
  /// vidinis žymeklis (jų srautai atskiri, kodo serveriui nereikia taip pat).
  final String code;

  /// Iliustracinis emoji kortelei.
  final String emoji;

  /// Akcento spalva (atrakintai temai). Užrakinta visada rodoma pilka.
  final Color accent;

  /// Temos tipas (lemia maršrutą).
  final ThemeKind kind;

  /// Ar tema atrakinta žaidėjui. false → kortelė pilka su „Greitai".
  final bool open;

  /// Pavadinimas ir paaiškinimas — per AppStrings (LT/EN).
  final String Function(AppStrings) title;
  final String Function(AppStrings) subtitle;

  const GameTheme({
    required this.code,
    required this.emoji,
    required this.accent,
    required this.kind,
    required this.open,
    required this.title,
    required this.subtitle,
  });
}

/// Visų 11 temų katalogas (tvarka = rodymo eilė pradiniame ekrane).
///
/// VEIKIA (open): Matematika, Gamta, Atspėk paslaptį.
/// UŽRAKINTA (open:false, „Greitai"): 7 trivijos temos + Blitz — atrakinsim po
/// vieną, kai pripildysim klausimų ir patvirtinsim turinio taisykles.
final List<GameTheme> kThemes = <GameTheme>[
  GameTheme(
    code: 'math',
    emoji: '🧮',
    accent: AppColors.levelEasy,
    kind: ThemeKind.math,
    open: true,
    title: (s) => s.categoryMath,
    subtitle: (s) => s.categoryMathDesc,
  ),
  GameTheme(
    code: 'nature',
    emoji: '🌿',
    accent: AppColors.levelExtreme,
    kind: ThemeKind.nature,
    open: true,
    title: (s) => s.categoryNature,
    subtitle: (s) => s.categoryNatureDesc,
  ),
  GameTheme(
    code: 'mystery',
    emoji: '🕵️',
    accent: AppColors.neonBlue,
    kind: ThemeKind.mystery,
    open: true,
    title: (s) => s.lang == AppLang.lt ? 'Atspėk paslaptį' : 'Guess the Mystery',
    subtitle: (s) => s.lang == AppLang.lt
        ? 'Rink raides žaisdamas ir spėk posakį'
        : 'Earn letters by playing and guess the phrase',
  ),
  GameTheme(
    code: 'pop',
    emoji: '🎬',
    accent: AppColors.levelHard,
    kind: ThemeKind.trivia,
    open: true, // TESTAS (tik kūrime) — prieš paleidimą peržiūrėti
    title: (s) => s.categoryPop,
    subtitle: (s) => s.categoryPopDesc,
  ),
  GameTheme(
    code: 'geo',
    emoji: '🌍',
    accent: AppColors.levelEasy,
    kind: ThemeKind.trivia,
    open: true, // TESTAS (tik kūrime) — prieš paleidimą peržiūrėti
    title: (s) => s.categoryGeo,
    subtitle: (s) => s.categoryGeoDesc,
  ),
  GameTheme(
    code: 'history',
    emoji: '🏛️',
    accent: AppColors.levelMedium,
    kind: ThemeKind.trivia,
    open: true, // TESTAS (tik kūrime) — prieš paleidimą peržiūrėti
    title: (s) => s.categoryHistory,
    subtitle: (s) => s.categoryHistoryDesc,
  ),
  GameTheme(
    code: 'tech',
    emoji: '🔬',
    accent: AppColors.neonBlue,
    kind: ThemeKind.trivia,
    open: true, // TESTAS (tik kūrime) — prieš paleidimą peržiūrėti
    title: (s) => s.categoryTech,
    subtitle: (s) => s.categoryTechDesc,
  ),
  GameTheme(
    code: 'food',
    emoji: '🍔',
    accent: AppColors.levelHard,
    kind: ThemeKind.trivia,
    open: true, // TESTAS (tik kūrime) — prieš paleidimą peržiūrėti
    title: (s) => s.categoryFood,
    subtitle: (s) => s.categoryFoodDesc,
  ),
  GameTheme(
    code: 'sport',
    emoji: '⚽',
    accent: AppColors.levelEasy,
    kind: ThemeKind.trivia,
    open: true, // TESTAS (tik kūrime) — prieš paleidimą peržiūrėti
    title: (s) => s.categorySport,
    subtitle: (s) => s.categorySportDesc,
  ),
  GameTheme(
    code: 'body',
    emoji: '🧠',
    accent: AppColors.levelExtreme,
    kind: ThemeKind.trivia,
    open: true, // TESTAS (tik kūrime) — prieš paleidimą peržiūrėti
    title: (s) => s.categoryBody,
    subtitle: (s) => s.categoryBodyDesc,
  ),
  GameTheme(
    code: 'blitz',
    emoji: '⚡',
    accent: AppColors.levelMedium,
    kind: ThemeKind.blitz,
    open: true, // ⚡ TAIP/NE blitz VEIKIA (2026-06-12)
    title: (s) => s.categoryBlitz,
    subtitle: (s) => s.categoryBlitzDesc,
  ),
  GameTheme(
    code: 'myth',
    emoji: '🧐',
    accent: AppColors.neonBlue,
    kind: ThemeKind.myth,
    open: true, // 🧐 Tiesa ar mitas? VEIKIA (2026-06-12)
    title: (s) => s.categoryMyth,
    subtitle: (s) => s.categoryMythDesc,
  ),
];
