import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/banner_ad_widget.dart';
import 'melt_setup_screen.dart';
import 'mystery_screen.dart';

/// „Atspėk paslaptį" režimo pasirinkimas — PILNAS ekranas tuo pačiu stiliumi
/// kaip temų/potemių parinkikliai (neoninės kortelės, didelės raidės).
class MysteryModeScreen extends StatelessWidget {
  const MysteryModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final isLt = s.lang == AppLang.lt;
    String t(String lt, String en) => isLt ? lt : en;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        title: Text(t('Atspėk paslaptį', 'Guess the Mystery'),
            style: const TextStyle(color: AppColors.textPrimary)),
      ),
      body: AppBackground(
        accent: AppColors.neonBlue,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                  child: Column(
                    children: [
                      Text(
                        t('Pasirink režimą', 'Choose a mode'),
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 16),
                      _modeCard(
                        context,
                        emoji: '🕵️',
                        title: t('Klasikinis', 'Classic'),
                        subtitle: t(
                            'Rink raides žaisdamas kitas temas ir spėk posakį savo tempu',
                            'Earn letters in other games and guess at your own pace'),
                        accent: AppColors.neonBlue,
                        builder: (_) => const MysteryScreen(),
                      ),
                      const SizedBox(height: 14),
                      _modeCard(
                        context,
                        emoji: '⏳',
                        title: t('Raidžių tirpimas', 'Letter Melt'),
                        subtitle: t(
                            'Prieš laikrodį — pats pasirink lygį ir tempą, raidės tirpsta savaime',
                            'Beat the clock — pick your level and pace as letters melt away'),
                        accent: AppColors.levelMedium,
                        builder: (_) => const MeltSetupScreen(),
                      ),
                    ],
                  ),
                ),
              ),
              const BannerAdWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeCard(
    BuildContext context, {
    required String emoji,
    required String title,
    required String subtitle,
    required Color accent,
    required WidgetBuilder builder,
  }) {
    return GestureDetector(
      onTap: () =>
          Navigator.of(context).push(MaterialPageRoute(builder: builder)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border:
              Border.all(color: accent.withValues(alpha: 0.7), width: 1.6),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.18),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 23,
                        letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13.5),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: accent.withValues(alpha: 0.8), size: 26),
          ],
        ),
      ),
    );
  }
}
