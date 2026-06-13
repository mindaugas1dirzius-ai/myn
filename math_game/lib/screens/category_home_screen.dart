import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme_catalog.dart';
import '../l10n/app_strings.dart';
import '../l10n/language_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/neumorphic_button.dart';
import '../services/mystery_api.dart';
import 'blitz_game_screen.dart';
import 'myth_game_screen.dart';
import 'home_screen.dart';
import 'mystery_mode_screen.dart';
import 'nature_topic_screen.dart';
import 'profile_screen.dart';
import 'trivia_level_screen.dart';
import 'trivia_topic_screen.dart';

/// PRADINIS langas — temų pasirinkimas (kad nebūtų chaoso).
///
/// Kiekviena tema = atskira kortelė su sava spalva ir ikona. Paspaudus
/// atsidaro tos temos meniu (matematika → veiksmai; gamta → lygiai).
/// Statistika/Top 10 lieka kiekvienoje temoje atskirai (per profilį/rezultatus).
///
/// STATEFUL: užkraunam „Atspėk paslaptį" statusą (kiek laukia neatvertų
/// raidžių), kad ant kortelės parodytume raudoną pranešimų ženkliuką.
class CategoryHomeScreen extends StatefulWidget {
  const CategoryHomeScreen({super.key});

  @override
  State<CategoryHomeScreen> createState() => _CategoryHomeScreenState();
}

class _CategoryHomeScreenState extends State<CategoryHomeScreen> {
  int _pendingLetters = 0;

  @override
  void initState() {
    super.initState();
    _loadMysteryStatus();
  }

  /// Tyliai užkraunam paslapties statusą (klaida → ženkliuko tiesiog nėra).
  Future<void> _loadMysteryStatus() async {
    final status = await MysteryApi.status();
    if (!mounted || status == null) return;
    setState(() => _pendingLetters = status.pendingLetters);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Viršutinė juosta: Profilis (kairėje) + MAŽAS logotipas (centre,
              // ANTRAEILIS — temos svarbiausios) + kalbos jungiklis (dešinėje).
              // Logotipas juostoje → jokio tuščio tarpo viršuje, daugiau vietos temoms.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    ),
                    icon: const Icon(Icons.person,
                        color: AppColors.textSecondary, size: 20),
                    label: Text(s.profile,
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold)),
                  ),
                  Image.asset(
                    'assets/images/logo.png',
                    height: 52,
                    fit: BoxFit.contain,
                  ),
                  TextButton.icon(
                    onPressed: () => languageController.toggle(s.lang),
                    icon: const Icon(Icons.language,
                        color: AppColors.textSecondary, size: 20),
                    label: Text(
                      s.lang == AppLang.lt ? 'LT' : 'EN',
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                // VISOS 11 temų rodomos iš vieno katalogo (theme_catalog.dart).
                // Atrakinti temą = pakeisti `open: true` kataloge — čia nieko.
                child: ListView(
                  children: [
                    for (var i = 0; i < kThemes.length; i++) ...[
                      if (i > 0) const SizedBox(height: 14),
                      _themeTile(context, kThemes[i], s),
                    ],
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => SystemNavigator.pop(),
                icon: const Icon(Icons.exit_to_app,
                    color: AppColors.textSecondary, size: 18),
                label: Text(s.exitApp,
                    style: const TextStyle(color: AppColors.textSecondary)),
              ),
              const Text('v10-skeleton',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 10)),
              const SizedBox(height: 4),
              const BannerAdWidget(),
            ],
          ),
        ),
        ),
      ),
    );
  }

  /// Viena temos kortelė iš katalogo: atrakinta → spalvota + maršrutas;
  /// užrakinta → pilka su „Greitai".
  Widget _themeTile(BuildContext context, GameTheme t, AppStrings s) {
    if (!t.open) return _lockedThemeCard(context, t, s);
    // Mystery rodo raudoną ženkliuką (kiek laukia neatvertų raidžių).
    final badge = t.kind == ThemeKind.mystery ? _pendingLetters : 0;
    return _categoryCard(
      context: context,
      accent: t.accent,
      emoji: t.emoji,
      title: t.title(s),
      subtitle: t.subtitle(s),
      badgeCount: badge,
      onTap: () => _onThemeTap(context, t),
    );
  }

  /// Atrakintos temos maršrutas pagal jos tipą.
  Future<void> _onThemeTap(BuildContext context, GameTheme t) async {
    switch (t.kind) {
      case ThemeKind.math:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        break;
      case ThemeKind.nature:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NatureTopicScreen()),
        );
        break;
      case ThemeKind.mystery:
        // Režimo pasirinkimas — PILNAS ekranas (kaip kiti parinkikliai).
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MysteryModeScreen()),
        );
        // Grįžus — atnaujinam ženkliuką (galėjo atverti/išspręsti raides).
        _loadMysteryStatus();
        break;
      case ThemeKind.trivia:
        // Temos su potemėmis (tech, žmogaus kūnas) → potemių parinkiklis;
        // kitos → tiesiai į lygių ekraną (kaip seniau).
        final hasSubs = TriviaTopicScreen.hasSubThemes(t.code);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => hasSubs
                ? TriviaTopicScreen(
                    categoryCode: t.code,
                    categoryTitle: t.title(AppStrings.of(context)),
                  )
                : TriviaLevelScreen(
                    categoryCode: t.code,
                    categoryTitle: t.title(AppStrings.of(context)),
                  ),
          ),
        );
        break;
      case ThemeKind.blitz:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BlitzGameScreen()),
        );
        break;
      case ThemeKind.myth:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MythGameScreen()),
        );
        break;
      case ThemeKind.exam:
        // 🎓 Egzaminų centras — placeholder. Kol open:false, ši šaka nepasiekiama;
        // mechanika bus pridėta vėliau (docs/planai/EGZAMINU_CENTRAS_PLANAS.md).
        break;
    }
  }

  Widget _categoryCard({
    required BuildContext context,
    required Color accent,
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    int badgeCount = 0, // raudonas pranešimų ženkliukas (0 = nerodom)
  }) {
    return NeumorphicButton(
      accent: accent,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      onTap: onTap,
      child: Row(
        children: [
          // Emoji + raudonas ženkliukas viršuje dešinėje (jei badgeCount > 0).
          Stack(
            clipBehavior: Clip.none,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 44)),
              if (badgeCount > 0)
                Positioned(
                  right: -6,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    constraints: const BoxConstraints(minWidth: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF5350),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: AppColors.surface, width: 1.5),
                    ),
                    child: Text(
                      '$badgeCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: accent,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: kHeadingFont)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  /// Užrakintos temos kortelė (skeletas). Pilka, su spynele ir „· Greitai".
  /// Paspaudus — tik žinutė (jokio serverio kvietimo — turinio dar nėra).
  Widget _lockedThemeCard(BuildContext context, GameTheme t, AppStrings s) {
    return NeumorphicButton(
      accent: AppColors.textSecondary,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.lockedThemeNote),
            backgroundColor: AppColors.surface,
          ),
        );
      },
      child: Row(
        children: [
          Text(t.emoji, style: const TextStyle(fontSize: 44)),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(t.title(s),
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: kHeadingFont)),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.lock_outline,
                        color: AppColors.textSecondary, size: 16),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${t.subtitle(s)} · ${s.comingSoon}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
