import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/neumorphic_button.dart';

/// „Blitz" vietos rezervas (griaučiai).
///
/// Blitz — ATSKIRA mechanika (Taip/Ne, 2 mygtukai, 2–3 s laikmatis, gyvybės/
/// serija), todėl jos NEGALIMA daryti per bendrą trivijos variklį. Kol logika
/// dar nesukurta, šis ekranas paaiškina, kad „Greitai". Struktūrinė vieta jau
/// yra — kai darysim mechaniką, tiesiog pakeisim šio ekrano vidų.
class BlitzPlaceholderScreen extends StatelessWidget {
  const BlitzPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        title: Text(s.categoryBlitz,
            style: const TextStyle(color: AppColors.textPrimary)),
      ),
      body: AppBackground(
        accent: AppColors.levelMedium,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('⚡', style: TextStyle(fontSize: 72)),
                const SizedBox(height: 20),
                Text(
                  s.categoryBlitz,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  s.blitzComingSoonBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 15, height: 1.4),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 220,
                  child: NeumorphicButton(
                    accent: AppColors.levelMedium,
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      s.toMenu,
                      style: const TextStyle(
                          color: AppColors.levelMedium,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
