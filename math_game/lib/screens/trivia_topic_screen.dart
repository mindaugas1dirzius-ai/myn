import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/neumorphic_button.dart';
import 'trivia_level_screen.dart';

/// UNIVERSALUS bendrų žinių temų POTEMIŲ pasirinkimas.
///
/// Srautas: tema → POTEMĖ → lygis → žaidimas (kaip gamtoje). Naudojam TIK toms
/// temoms, kurios serveryje turi registruotų potemių (žr. subThemeConfig.ts):
///   - tech → 🎮 Video žaidimų evoliucija (atvira), 🚀 Kosmosas / 🤖 AI (Greitai), 🎲 Mix;
///   - body → 🧠 Smegenų paslaptys, 💪 Raumenys ir fitnesas, 🧬 Biologiniai
///            kuriozai (=visi kiti kūno klausimai), 🎲 Mix;
///   - food → 🍕 Pasaulio virtuvės, 🧪 Maisto mokslas, 🌶️ Egzotiškas maistas, 🎲 Mix.
/// „facts" potemė = bendri temos klausimai (mode `<tema>_<lygis>`).
/// Kitos potemės → mode `<tema>_<potemė>_<lygis>` (startTriviaGame).
///
/// Užrakintos („Greitai") potemės dar be turinio — saugiklis, kad serveris
/// negrąžintų „Per mažai klausimų".
class TriviaTopicScreen extends StatelessWidget {
  /// Serverio temos kodas: "tech" | "body" (žr. theme_catalog).
  final String categoryCode;

  /// Antraštė viršuje (temos pavadinimas žaidėjo kalba).
  final String categoryTitle;

  const TriviaTopicScreen({
    super.key,
    required this.categoryCode,
    required this.categoryTitle,
  });

  /// Ar šiai temai apskritai rodom potemių parinkiklį?
  /// (Kitos temos eina tiesiai į lygių ekraną.)
  static bool hasSubThemes(String code) =>
      code == 'tech' ||
      code == 'body' ||
      code == 'food' ||
      code == 'geo' ||
      code == 'history' ||
      code == 'pop' ||
      code == 'sport' ||
      code == 'cosmos';

  /// Tos temos potemių sąrašas žaidėjo kalba.
  List<_SubTheme> _subThemesFor(AppStrings s) {
    switch (categoryCode) {
      case 'tech':
        return [
          _SubTheme(
            id: 'facts',
            emoji: '🔬',
            title: s.categoryTech,
            subtitle: s.categoryTechDesc,
            accent: AppColors.neonBlue,
            open: true,
          ),
          _SubTheme(
            id: 'games',
            emoji: '🎮',
            title: s.subTechGames,
            subtitle: s.subTechGamesDesc,
            accent: AppColors.levelHard,
            open: true,
          ),
          _SubTheme(
            id: 'myths',
            emoji: '💻',
            title: s.subTechMyths,
            subtitle: s.subTechMythsDesc,
            accent: AppColors.levelMedium,
            open: true,
          ),
          // „Kosmoso lenktynės" potemė PERKELTA į Kosmoso temą (2026-06-13).
          _SubTheme(
            id: 'ai',
            emoji: '🤖',
            title: s.subTechAi,
            subtitle: s.subTechAiDesc,
            accent: AppColors.levelMedium,
            open: false,
          ),
          _SubTheme(
            id: 'mix',
            emoji: '🎲',
            title: s.topicMix,
            subtitle: s.topicMixDesc,
            accent: AppColors.neonBlue,
            open: true,
          ),
        ];
      case 'body':
        return [
          _SubTheme(
            id: 'brain',
            emoji: '🧠',
            title: s.subBodyBrain,
            subtitle: s.subBodyBrainDesc,
            accent: AppColors.levelHard,
            open: true,
          ),
          _SubTheme(
            id: 'bones',
            emoji: '💪',
            title: s.subBodyBones,
            subtitle: s.subBodyBonesDesc,
            accent: AppColors.levelEasy,
            open: true,
          ),
          // 'facts' = visi KITI kūno klausimai (širdis, organai, juslės,
          // fiziologija, anatomija) → biologijos / medicinos kuriozai.
          _SubTheme(
            id: 'facts',
            emoji: '🧬',
            title: s.subBodyBio,
            subtitle: s.subBodyBioDesc,
            accent: AppColors.levelMedium,
            open: true,
          ),
          _SubTheme(
            id: 'mix',
            emoji: '🎲',
            title: s.topicMix,
            subtitle: s.topicMixDesc,
            accent: AppColors.neonBlue,
            open: true,
          ),
        ];
      case 'food':
        return [
          _SubTheme(
            id: 'world',
            emoji: '🍕',
            title: s.subFoodWorld,
            subtitle: s.subFoodWorldDesc,
            accent: AppColors.levelHard,
            open: true,
          ),
          _SubTheme(
            id: 'science',
            emoji: '🧪',
            title: s.subFoodScience,
            subtitle: s.subFoodScienceDesc,
            accent: AppColors.levelMedium,
            open: true,
          ),
          _SubTheme(
            id: 'exotic',
            emoji: '🌶️',
            title: s.subFoodExotic,
            subtitle: s.subFoodExoticDesc,
            accent: AppColors.levelExtreme,
            open: true,
          ),
          _SubTheme(
            id: 'production',
            emoji: '🍳',
            title: s.subFoodProduction,
            subtitle: s.subFoodProductionDesc,
            accent: AppColors.neonBlue,
            open: true,
          ),
          _SubTheme(
            id: 'mix',
            emoji: '🎲',
            title: s.topicMix,
            subtitle: s.topicMixDesc,
            accent: AppColors.neonBlue,
            open: true,
          ),
        ];
      case 'cosmos':
        return [
          _SubTheme(
            id: 'planets',
            emoji: '🪐',
            title: s.subCosmosPlanets,
            subtitle: s.subCosmosPlanetsDesc,
            accent: AppColors.levelHard,
            open: true,
          ),
          _SubTheme(
            id: 'spacerace',
            emoji: '🚀',
            title: s.subTechSpace,
            subtitle: s.subTechSpaceDesc,
            accent: AppColors.levelMedium,
            open: true,
          ),
          _SubTheme(
            id: 'astronauts',
            emoji: '🧑‍🚀',
            title: s.subCosmosAstronauts,
            subtitle: s.subCosmosAstronautsDesc,
            accent: AppColors.levelMedium,
            open: true,
          ),
          _SubTheme(
            id: 'universe',
            emoji: '🔭',
            title: s.subCosmosUniverse,
            subtitle: s.subCosmosUniverseDesc,
            accent: AppColors.levelExtreme,
            open: false,
          ),
          _SubTheme(
            id: 'rockets',
            emoji: '🛰️',
            title: s.subCosmosRockets,
            subtitle: s.subCosmosRocketsDesc,
            accent: AppColors.neonBlue,
            open: false,
          ),
          _SubTheme(
            id: 'mix',
            emoji: '🎲',
            title: s.topicMix,
            subtitle: s.topicMixDesc,
            accent: AppColors.neonBlue,
            open: true,
          ),
        ];
      case 'geo':
        return [
          _SubTheme(
            id: 'nature',
            emoji: '🏞️',
            title: s.subGeoNature,
            subtitle: s.subGeoNatureDesc,
            accent: AppColors.levelEasy,
            open: true,
          ),
          _SubTheme(
            id: 'megapolis',
            emoji: '🏙️',
            title: s.subGeoMegapolis,
            subtitle: s.subGeoMegapolisDesc,
            accent: AppColors.neonBlue,
            open: true,
          ),
          _SubTheme(
            id: 'culture',
            emoji: '🗼',
            title: s.subGeoCulture,
            subtitle: s.subGeoCultureDesc,
            accent: AppColors.levelMedium,
            open: true,
          ),
          _SubTheme(
            id: 'paradox',
            emoji: '🗺️',
            title: s.subGeoParadox,
            subtitle: s.subGeoParadoxDesc,
            accent: AppColors.levelHard,
            open: true,
          ),
          _SubTheme(
            id: 'mix',
            emoji: '🎲',
            title: s.topicMix,
            subtitle: s.topicMixDesc,
            accent: AppColors.neonBlue,
            open: true,
          ),
        ];
      case 'history':
        return [
          _SubTheme(
            id: 'engineering',
            emoji: '🗿',
            title: s.subHistoryEngineering,
            subtitle: s.subHistoryEngineeringDesc,
            accent: AppColors.levelHard,
            open: true,
          ),
          _SubTheme(
            id: 'rulers',
            emoji: '👑',
            title: s.subHistoryRulers,
            subtitle: s.subHistoryRulersDesc,
            accent: AppColors.levelExtreme,
            open: true,
          ),
          _SubTheme(
            id: 'myths',
            emoji: '🔍',
            title: s.subHistoryMyths,
            subtitle: s.subHistoryMythsDesc,
            accent: AppColors.levelMedium,
            open: true,
          ),
          _SubTheme(
            id: 'mix',
            emoji: '🎲',
            title: s.topicMix,
            subtitle: s.topicMixDesc,
            accent: AppColors.neonBlue,
            open: true,
          ),
        ];
      case 'pop':
        return [
          _SubTheme(
            id: 'films',
            emoji: '🎥',
            title: s.subPopFilms,
            subtitle: s.subPopFilmsDesc,
            accent: AppColors.levelExtreme,
            open: true,
          ),
          _SubTheme(
            id: 'tv',
            emoji: '📺',
            title: s.subPopTv,
            subtitle: s.subPopTvDesc,
            accent: AppColors.neonBlue,
            open: true,
          ),
          _SubTheme(
            id: 'music',
            emoji: '🎵',
            title: s.subPopMusic,
            subtitle: s.subPopMusicDesc,
            accent: AppColors.levelEasy,
            open: true,
          ),
          _SubTheme(
            id: 'stories',
            emoji: '📚',
            title: s.subPopStories,
            subtitle: s.subPopStoriesDesc,
            accent: AppColors.levelMedium,
            open: true,
          ),
          _SubTheme(
            id: 'mix',
            emoji: '🎲',
            title: s.topicMix,
            subtitle: s.topicMixDesc,
            accent: AppColors.neonBlue,
            open: true,
          ),
        ];
      case 'sport':
        return [
          _SubTheme(
            id: 'racing',
            emoji: '🏎️',
            title: s.subSportRacing,
            subtitle: s.subSportRacingDesc,
            accent: AppColors.levelHard,
            open: true,
          ),
          _SubTheme(
            id: 'gymnastics',
            emoji: '🤸',
            title: s.subSportGym,
            subtitle: s.subSportGymDesc,
            accent: AppColors.levelMedium,
            open: true,
          ),
          _SubTheme(
            id: 'olympics',
            emoji: '🏅',
            title: s.subSportOlympics,
            subtitle: s.subSportOlympicsDesc,
            accent: AppColors.levelExtreme,
            open: true,
          ),
          _SubTheme(
            id: 'martial',
            emoji: '🥋',
            title: s.subSportMartial,
            subtitle: s.subSportMartialDesc,
            accent: AppColors.neonBlue,
            open: true,
          ),
          _SubTheme(
            id: 'rules',
            emoji: '🏆',
            title: s.subSportRules,
            subtitle: s.subSportRulesDesc,
            accent: AppColors.levelHard,
            open: true,
          ),
          _SubTheme(
            id: 'disciplines',
            emoji: '⚽',
            title: s.subSportDisciplines,
            subtitle: s.subSportDisciplinesDesc,
            accent: AppColors.levelEasy,
            open: true,
          ),
          _SubTheme(
            id: 'mix',
            emoji: '🎲',
            title: s.topicMix,
            subtitle: s.topicMixDesc,
            accent: AppColors.neonBlue,
            open: true,
          ),
        ];
      default:
        return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final subs = _subThemesFor(s);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        title: Text(categoryTitle,
            style: const TextStyle(color: AppColors.textPrimary)),
      ),
      body: AppBackground(
        accent: AppColors.neonBlue,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(s.pickTopic,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: subs
                        .map((t) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _subTile(context, t, s),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 4),
                const BannerAdWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _subTile(BuildContext context, _SubTheme t, AppStrings s) {
    final accent = t.open ? t.accent : AppColors.textSecondary;

    return NeumorphicButton(
      accent: accent,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
      onTap: () {
        if (!t.open) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(s.lockedTopicNote),
              backgroundColor: AppColors.surface,
            ),
          );
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TriviaLevelScreen(
              categoryCode: categoryCode,
              categoryTitle: t.title,
              subThemeId: t.id,
            ),
          ),
        );
      },
      child: Row(
        children: [
          Text(t.emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        t.title,
                        style: TextStyle(
                          color: accent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: kHeadingFont,
                        ),
                      ),
                    ),
                    if (!t.open) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.lock_outline,
                          color: AppColors.textSecondary, size: 16),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  t.open ? t.subtitle : '${t.subtitle} · ${s.comingSoon}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          if (t.open)
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

/// Vienos potemės aprašas (vidinis — tik šiam ekranui).
class _SubTheme {
  final String id; // serverio kodas: facts/games/space/ai/brain/bones/mix
  final String emoji;
  final String title;
  final String subtitle;
  final Color accent;
  final bool open; // turi turinio? (false → „Greitai")

  const _SubTheme({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.open,
  });
}
