import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/neumorphic_button.dart';
import 'nature_game_screen.dart';

/// UNIVERSALUS lygio pasirinkimas BET KURIAI naujai žinių temai
/// (pop/geo/history/tech/food/sport/body).
///
/// Srautas: tema → lygis → žaidimas. Skiriasi nuo gamtos tuo, kad ČIA NĖRA
/// potemių (kol kas) — visa tema vienas baseinas. Mode: `kodas_lygis`
/// (pvz. "tech_lengvas"), kviečiamas startTriviaGame.
///
/// Žaidimo ekraną naudojam tą patį (NatureGameScreen) su useTrivia:true —
/// taip visa nupoliruota žaidimo logika (žiedas, taškai, peržiūra) veikia be
/// dublikatų. Gamta lieka nepaliesta.
class TriviaLevelScreen extends StatelessWidget {
  /// Serverio temos kodas: "tech" | "geo" | ... (žr. theme_catalog).
  final String categoryCode;

  /// Antraštė viršuje (temos pavadinimas žaidėjo kalba).
  final String categoryTitle;

  const TriviaLevelScreen({
    super.key,
    required this.categoryCode,
    required this.categoryTitle,
  });

  /// Mode serveriui: `kodas_lygis` (švarus, be potemės segmento).
  String _modeIdFor(GameLevel lvl) => '${categoryCode}_${lvl.name}';

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
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
              useTrivia: true,
              scenes: kTriviaScenes,
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

/// Neutralūs „vaizdai" klausimo kortelei bendrose temose. SVARBU: nė vienas
/// neturi išduoti atsakymo — tik bendri „žinių/protmūšio" motyvai. Vėliau
/// galėsim parinkti emoji pagal konkrečią temą.
const List<String> kTriviaScenes = [
  '❓', '💡', '🧠', '📚', '🎯', '🔎', '✨', '🧩', '🏆', '⭐',
  '📖', '🗺️', '🔭', '🎓', '🧪', '⚙️', '📝', '🌐', '🕹️', '🎲',
];
