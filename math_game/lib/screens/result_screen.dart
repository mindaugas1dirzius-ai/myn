import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import '../widgets/neumorphic_button.dart';

/// G4/G5: rezultatų ekranas po 10 klausimų (švelnus modelis — visada pasiekiamas).
/// Taškai ČIA — kosmetiniai (oficialius J žingsnyje patvirtins serveris).
class ResultScreen extends StatelessWidget {
  final int correct;
  final int total;
  final int score;

  const ResultScreen({
    super.key,
    required this.correct,
    required this.total,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                s.resultTitle,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 28,
                      color: AppColors.levelEasy,
                    ),
              ),
              const SizedBox(height: 24),
              Text(
                '$correct / $total',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${s.score}: $score',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 220,
                child: NeumorphicButton(
                  accent: AppColors.levelEasy,
                  onTap: () => Navigator.of(context)
                      .popUntil((route) => route.isFirst),
                  child: Text(
                    s.playAgain,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
