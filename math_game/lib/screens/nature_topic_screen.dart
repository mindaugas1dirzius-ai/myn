import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/neumorphic_button.dart';
import 'nature_level_screen.dart';

/// Gamtos POTEMIŲ pasirinkimas (tema „Gamta ir gyvūnai").
///
/// Srautas: Gamta → POTEMĖ → lygis → žaidimas. Kiekviena potemė turi savo
/// neoninį akcentą ir emoji. Potemės be turinio užrakintos („Greitai") —
/// saugiklis, kad serveris negrąžintų „Per mažai klausimų".
///
/// Potemių serverio kodai: "facts" | "extinct" | "plants" | "mix".
/// „facts" lieka senu `nature_<lygis>` kodu (žr. NatureLevelScreen).
class NatureTopicScreen extends StatelessWidget {
  const NatureTopicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    // Potemių sąrašas. `open` = turi patvirtintų klausimų (kitaip „Greitai").
    // Atviri: „faktai" (600), „išnykę gyvūnai" (60: 15×4 lygiai),
    // „augalai" (60: 15×4 lygiai) ir „mix" (traukia iš visų potemių).
    final topics = <_TopicEntry>[
      _TopicEntry(
        id: 'facts',
        emoji: '💡',
        title: s.topicFacts,
        subtitle: s.topicFactsDesc,
        accent: AppColors.levelExtreme,
        open: true,
      ),
      _TopicEntry(
        id: 'extinct',
        emoji: '🦕',
        title: s.topicExtinct,
        subtitle: s.topicExtinctDesc,
        accent: AppColors.levelHard,
        open: true,
      ),
      _TopicEntry(
        id: 'plants',
        emoji: '🌱',
        title: s.topicPlants,
        subtitle: s.topicPlantsDesc,
        accent: AppColors.levelEasy,
        open: true,
      ),
      _TopicEntry(
        id: 'superpowers',
        emoji: '🧬',
        title: s.topicSuperpowers,
        subtitle: s.topicSuperpowersDesc,
        accent: AppColors.levelHard,
        open: true,
      ),
      _TopicEntry(
        id: 'minds',
        emoji: '🧠',
        title: s.topicMinds,
        subtitle: s.topicMindsDesc,
        accent: AppColors.themeTech,
        open: true,
      ),
      _TopicEntry(
        id: 'mix',
        emoji: '🎲',
        title: s.topicMix,
        subtitle: s.topicMixDesc,
        accent: AppColors.neonBlue,
        open: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        title: Text(s.categoryNature,
            style: const TextStyle(color: AppColors.textPrimary)),
      ),
      body: AppBackground(
        accent: AppColors.levelExtreme,
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
                    children: topics
                        .map((t) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _topicTile(context, t, s),
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

  Widget _topicTile(BuildContext context, _TopicEntry t, AppStrings s) {
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
            builder: (_) => NatureLevelScreen(
              topicId: t.id,
              topicTitle: t.title,
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
class _TopicEntry {
  final String id; // serverio kodas: facts/extinct/plants/mix
  final String emoji;
  final String title;
  final String subtitle;
  final Color accent;
  final bool open; // turi turinio? (false → „Greitai")

  const _TopicEntry({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.open,
  });
}
