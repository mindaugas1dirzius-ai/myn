import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/neumorphic_button.dart';
import 'nature_game_screen.dart';

/// Gamtos lygio pasirinkimas (vienai potemei).
///
/// Atidaroma iš potemių ekrano (NatureTopicScreen) → gauna `topicId`
/// ("facts" | "extinct" | "plants" | "mix") ir antraštę. Visi 4 lygiai atviri
/// potemei, kuri turi turinį (žemiau už tai atsako potemių ekrano saugiklis).
/// SKIRTUMAS nuo matematikos: čia NĖRA monetų/reklamų ekonomikos.
class NatureLevelScreen extends StatelessWidget {
  /// Potemės kodas serveriui: "facts" | "extinct" | "plants" | "mix".
  final String topicId;

  /// Antraštė viršuje (potemės pavadinimas žaidėjo kalba).
  final String topicTitle;

  const NatureLevelScreen({
    super.key,
    required this.topicId,
    required this.topicTitle,
  });

  /// Serverio mode kodas. „facts" lieka SENU formatu `nature_<lygis>` —
  /// kad nesugadintume esamų Top 10 lentelių ir rotacijos istorijos.
  /// Kitos potemės naudoja naują `nature_<potemė>_<lygis>` kodą.
  String _modeIdFor(GameLevel lvl) => topicId == 'facts'
      ? 'nature_${lvl.name}'
      : 'nature_${topicId}_${lvl.name}';

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        title: Text(topicTitle,
            style: const TextStyle(color: AppColors.textPrimary)),
      ),
      body: AppBackground(
        accent: AppColors.levelExtreme,
        child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(s.pickLevel,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: GameLevel.values
                      .map((lvl) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _levelTile(context, lvl, s),
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

  Widget _levelTile(BuildContext context, GameLevel lvl, AppStrings s) {
    final accent = lvl.color;

    return NeumorphicButton(
      accent: accent,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NatureGameScreen(
              modeId: _modeIdFor(lvl),
              accent: accent,
            ),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            lvl.title(s),
            style: TextStyle(
              color: accent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: kHeadingFont,
            ),
          ),
        ],
      ),
    );
  }
}
