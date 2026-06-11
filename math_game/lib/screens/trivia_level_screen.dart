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

  /// Potemės kodas (jei tema turi potemes): "games" | "brain" | "mix" | ...
  /// Tuščias arba "facts" → tema be potemės (senas 2 dalių mode).
  final String? subThemeId;

  const TriviaLevelScreen({
    super.key,
    required this.categoryCode,
    required this.categoryTitle,
    this.subThemeId,
  });

  /// Mode serveriui:
  ///   - be potemės / „facts" → `kodas_lygis` (2 dalys, suderinamumas);
  ///   - su poteme            → `kodas_potemė_lygis` (3 dalys, startTriviaGame).
  String _modeIdFor(GameLevel lvl) {
    final sub = subThemeId;
    if (sub == null || sub.isEmpty || sub == 'facts') {
      return '${categoryCode}_${lvl.name}';
    }
    return '${categoryCode}_${sub}_${lvl.name}';
  }

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
              scenes: triviaScenesFor(categoryCode),
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

/// Neutralūs „vaizdai" klausimo kortelei — atsarga, jei temos savo rinkinio nėra.
/// SVARBU: nė vienas NEturi išduoti atsakymo — tik bendri „žinių/protmūšio" motyvai.
const List<String> kTriviaScenes = [
  '❓', '💡', '🧠', '📚', '🎯', '🔎', '✨', '🧩', '🏆', '⭐',
  '📖', '🗺️', '🔭', '🎓', '🧪', '⚙️', '📝', '🌐', '🕹️', '🎲',
];

/// TEMINIAI klausimo kortelės „vaizdai" pagal temos kodą. 🚨 Kiekvienas rinkinys —
/// SU TEMA susiję, ĮVAIRŪS, bet BENDRI motyvai, kurie NIEKADA neišduoda atsakymo
/// (jokio konkretaus daikto, kuris būtų teisingas variantas). Tik dekoracija,
/// kad kortelė atrodytų gyvai ir žaidėjas jaustų, kokios temos klausimas.
const Map<String, List<String>> _kThemeScenes = {
  // 🚨 Tech: kortelėje VENGTI konkrečių įrenginių (💻📱🤖🌐⌨️🖱️), nes lengvi tech
  // klausimai PATYS klausia apie įrenginį (pvz. „kas yra pokalbių robotas?" → 🤖
  // išduotų). Vietoj to — BENDRI mokslo/inžinerijos/kosmoso motyvai.
  'tech': [
    '⚙️', '🛰️', '🔌', '🎮', '🕹️', '📡', '🔭', '🚀', '🧑‍💻', '🔬',
    '🧪', '⚗️', '🧮', '📐', '📊', '💡', '🛸', '🔢', '💿', '🧲',
  ],
  'geo': [
    '🗺️', '🌍', '🌎', '🌏', '🧭', '⛰️', '🏔️', '🏝️', '🌋', '🏜️',
    '🏞️', '🌊', '🧊', '🏙️', '🚩', '🌐', '🗿', '🏖️', '🏕️', '⛺',
  ],
  'history': [
    '🏛️', '📜', '⚔️', '🏺', '🗿', '👑', '🛡️', '🏰', '⛩️', '🪓',
    '🗝️', '🕰️', '📯', '⚱️', '🪔', '🏹', '🛕', '🧭', '⚜️', '📖',
  ],
  // 🚨 Maistas: kortelėje JOKIŲ konkrečių maisto produktų! Klausimai PATYS yra apie
  // maistą (pvz. „kuris RAUDONAS vaisius?"), tad 🍓🍎 prie klausimo IŠDUODA atsakymą
  // (per spalvą/formą) arba prieštarauja. Vietoj to — BENDRI virtuvės/valgymo motyvai
  // (įrankiai, puodai, procesai), kurie niekada nėra nė vienas iš 6 atsakymų.
  'food': [
    '🍽️', '🍴', '🥄', '🔪', '🍳', '🧑‍🍳', '👨‍🍳', '👩‍🍳', '🥢', '🧂',
    '🥣', '⏲️', '🫕', '🛒', '🧊', '🔥', '🫗', '🧑‍🌾', '🥡', '🍶',
  ],
  // 🚨 Sportas: kortelėje JOKIŲ konkrečių sporto šakų! Klausimai PATYS yra apie šakas
  // (pvz. „kurioje šakoje Stenlio taurė?"), tad ⚽🏒 prie klausimo IŠDUODA/prieštarauja.
  // Vietoj to — BENDRI sporto motyvai (taurės, medaliai, stadionas, švilpukas, kt.).
  'sport': [
    '🏆', '🥇', '🥈', '🥉', '🏅', '🎖️', '📣', '🏟️', '⏱️', '📋',
    '🎯', '🚩', '🏁', '🔔', '📊', '🎫', '💪', '🥤', '🧢', '👟',
  ],
  // 🚨 Žmogaus kūno tema: kortelėje JOKIŲ konkrečių kūno dalių/organų! Klausimai
  // PATYS yra apie kūno dalis, tad 🦵 prie klausimo „sąnarys rankoje?" atrodo
  // melagingai IR pakiša kitą atsakymą (🦵→„Kelis"). Vietoj to — BENDRI
  // medicinos/biologijos motyvai (stetoskopas, DNR, mikroskopas), kurie niekada
  // nėra nė vienas iš 6 atsakymų ir neprieštarauja klausimui.
  'body': [
    '🩺', '🧬', '🔬', '🩻', '💊', '🧪', '🏥', '⚕️', '🩹', '🌡️',
    '💉', '🧫', '🥼', '❤️‍🩹', '📋', '⚗️', '🩼', '🦠', '🫧', '🧴',
  ],
  'pop': [
    '🎬', '🎵', '🎤', '🎸', '🎮', '🎨', '🎭', '🎧', '🌟', '🎞️',
    '📺', '🎷', '🥁', '🎹', '📀', '🎼', '🪩', '🎟️', '🎫', '📽️',
  ],
};

/// Grąžina temos kortelės „vaizdų" rinkinį (arba bendrą atsargą, jei temos nėra).
List<String> triviaScenesFor(String categoryCode) =>
    _kThemeScenes[categoryCode] ?? kTriviaScenes;
