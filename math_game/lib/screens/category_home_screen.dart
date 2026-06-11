import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_strings.dart';
import '../l10n/language_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/neumorphic_button.dart';
import '../services/mystery_api.dart';
import 'home_screen.dart';
import 'mystery_screen.dart';
import 'nature_topic_screen.dart';
import 'profile_screen.dart';

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

    // Užrakintos temos (skeletas). Kol turinio nėra, jos rodomos pilkos su
    // „Greitai" — paspaudus parodom žinutę, NIEKO nekviečiam serverio. Eilė ir
    // spalvos pagal manifestą; „Blitz" — atskira mechanika (irgi „Greitai").
    final lockedThemes = <_LockedTheme>[
      _LockedTheme('🎬', s.categoryPop, s.categoryPopDesc),
      _LockedTheme('🌍', s.categoryGeo, s.categoryGeoDesc),
      _LockedTheme('🏛️', s.categoryHistory, s.categoryHistoryDesc),
      _LockedTheme('🔬', s.categoryTech, s.categoryTechDesc),
      _LockedTheme('🍔', s.categoryFood, s.categoryFoodDesc),
      _LockedTheme('⚽', s.categorySport, s.categorySportDesc),
      _LockedTheme('🧠', s.categoryBody, s.categoryBodyDesc),
      _LockedTheme('⚡', s.categoryBlitz, s.categoryBlitzDesc),
    ];

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Viršutinė juosta: Profilis (kairėje) + kalbos jungiklis (dešinėje).
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              const SizedBox(height: 12),
              Text(
                s.appName,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 34,
                      letterSpacing: 4,
                      color: AppColors.neonBlue,
                    ),
              ),
              const SizedBox(height: 8),
              Text(s.chooseCategory,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 28),
              Expanded(
                child: ListView(
                  children: [
                    _categoryCard(
                      context: context,
                      accent: AppColors.levelEasy,
                      emoji: '🧮',
                      title: s.categoryMath,
                      subtitle: s.categoryMathDesc,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _categoryCard(
                      context: context,
                      accent: AppColors.levelExtreme,
                      emoji: '🌿',
                      title: s.categoryNature,
                      subtitle: s.categoryNatureDesc,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const NatureTopicScreen()),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // „Atspėk paslaptį" — skėtinis meta-žaidimas (raidės renkamos
                    // žaidžiant kitas temas). Atskira kortelė.
                    _categoryCard(
                      context: context,
                      accent: AppColors.neonBlue,
                      emoji: '🕵️',
                      title: s.lang == AppLang.lt
                          ? 'Atspėk paslaptį'
                          : 'Guess the Mystery',
                      subtitle: s.lang == AppLang.lt
                          ? 'Rink raides žaisdamas ir spėk posakį'
                          : 'Earn letters by playing and guess the phrase',
                      // Raudonas ženkliukas: kiek laukia neatvertų raidžių.
                      badgeCount: _pendingLetters,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const MysteryScreen()),
                        );
                        // Grįžus iš paslapties lango — atnaujinam ženkliuką
                        // (žaidėjas galėjo atverti/išspręsti raides).
                        _loadMysteryStatus();
                      },
                    ),
                    // Užrakintos temos (skeletas) — kiekviena su „Greitai".
                    for (final t in lockedThemes) ...[
                      const SizedBox(height: 18),
                      _lockedThemeCard(context, t, s),
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
  /// Paspaudus — TIK žinutė; jokio serverio kvietimo (turinio dar nėra).
  Widget _lockedThemeCard(
      BuildContext context, _LockedTheme t, AppStrings s) {
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
                      child: Text(t.title,
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
                Text('${t.subtitle} · ${s.comingSoon}',
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

/// Vienos užrakintos temos aprašas (vidinis — tik šiam ekranui).
class _LockedTheme {
  final String emoji;
  final String title;
  final String subtitle;
  const _LockedTheme(this.emoji, this.title, this.subtitle);
}
