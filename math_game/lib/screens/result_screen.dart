import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/game_mode.dart';
import '../theme/app_theme.dart';
import '../services/ad_service.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/neumorphic_button.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';

/// G5: rezultatų ekranas po 10 klausimų (švelnus modelis — visada pasiekiamas).
/// Taškai ČIA — kosmetiniai (oficialius J žingsnyje patvirtins serveris).
class ResultScreen extends StatelessWidget {
  final MathOp op;
  final GameLevel level;
  final String modeId;
  final int correct;
  final int total;
  final int score;
  final bool online; // ar žaista prisijungus (rodyti Top 10?)

  const ResultScreen({
    super.key,
    required this.op,
    required this.level,
    required this.modeId,
    required this.correct,
    required this.total,
    required this.score,
    this.online = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final accent = level.color;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Text(
                s.resultTitle,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 26,
                      letterSpacing: 2,
                      color: accent,
                    ),
              ),
              const SizedBox(height: 8),
              Text(_rating(s), style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 16)),
              const SizedBox(height: 32),

              // Teisingų santykis
              Text('$correct / $total', style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 52, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Animuotas taškų skaičius (0 -> score), dopamino efektas
              Text(s.score, style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14, letterSpacing: 2)),
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: score),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOut,
                builder: (context, value, _) => Text(
                  '$value',
                  style: TextStyle(
                    color: accent,
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Top 10 lentelė (tik online; offline — kvietimas prisijungti)
              LeaderboardView(mode: modeId, accent: accent, online: online),

              const SizedBox(height: 32),

              // Žaisti dar — to paties režimo (interstitial su cooldown PRIEŠ)
              SizedBox(
                width: 240,
                child: NeumorphicButton(
                  accent: accent,
                  onTap: () {
                    AdService.maybeShowInterstitial(); // tik po sesijos, su cooldown
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) =>
                            GameScreen(modeId: modeId, op: op, level: level),
                      ),
                    );
                  },
                  child: Text(s.playAgain, style: TextStyle(
                    color: accent, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),

              // Į meniu (interstitial su cooldown PRIEŠ)
              SizedBox(
                width: 240,
                child: NeumorphicButton(
                  accent: AppColors.textSecondary,
                  onTap: () {
                    AdService.maybeShowInterstitial();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text(s.toMenu, style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 16)),
                ),
              ),

              const SizedBox(height: 24),
              // Banner — rezultatų ekrane (leista; ne žaidimo metu)
              const BannerAdWidget(),
            ],
          ),
        ),
      ),
    );
  }

  /// Įvertinimo žinutė pagal teisingų skaičių.
  String _rating(AppStrings s) {
    if (correct == total) return s.ratingPerfect;
    if (correct >= total * 0.7) return s.ratingGood;
    if (correct >= total * 0.4) return s.ratingOk;
    return s.ratingTryAgain;
  }
}
