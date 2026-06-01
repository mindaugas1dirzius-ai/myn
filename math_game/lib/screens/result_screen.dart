import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/game_mode.dart';
import '../theme/app_theme.dart';
import '../services/ad_service.dart';
import '../services/profile_api.dart';
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
  final int coinsEarned; // šioje sesijoje uždirbtos monetos
  final bool promptName; // raginti įvesti vardą (Top 10 + dar auto-vardas)

  const ResultScreen({
    super.key,
    required this.op,
    required this.level,
    required this.modeId,
    required this.correct,
    required this.total,
    required this.score,
    this.online = false,
    this.coinsEarned = 0,
    this.promptName = false,
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

              // Uždirbtos monetos (jei online)
              if (online && coinsEarned > 0) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.monetization_on,
                        color: AppColors.levelMedium, size: 20),
                    const SizedBox(width: 6),
                    Text('+$coinsEarned ${s.coinsEarned}',
                        style: const TextStyle(
                            color: AppColors.levelMedium,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],

              // 🏆 Raginimas įvesti vardą (variantas C: Top 10 + dar auto-vardas)
              if (promptName) ...[
                const SizedBox(height: 20),
                _Top10Prompt(accent: accent),
              ],

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

/// Raginimas įvesti vardą patekus į Top 10 (variantas C).
/// Dingsta po sėkmingo įvedimo (todėl Stateful).
class _Top10Prompt extends StatefulWidget {
  final Color accent;
  const _Top10Prompt({required this.accent});

  @override
  State<_Top10Prompt> createState() => _Top10PromptState();
}

class _Top10PromptState extends State<_Top10Prompt> {
  bool _done = false;

  Future<void> _enterName() async {
    final s = AppStrings.of(context);
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(s.enterName,
            style: const TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          maxLength: 16,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(s.save,
                style: const TextStyle(color: AppColors.levelEasy)),
          ),
        ],
      ),
    );
    if (name != null && name.length >= 2) {
      await ProfileApi.saveUsername(name);
      if (mounted) setState(() => _done = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return const SizedBox.shrink();
    final s = AppStrings.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.accent.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
              color: widget.accent.withValues(alpha: 0.2),
              blurRadius: 12,
              spreadRadius: 1),
        ],
      ),
      child: Column(
        children: [
          Text(s.top10Title,
              style: TextStyle(
                  color: widget.accent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(s.top10Body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => setState(() => _done = true),
                child: Text(s.later,
                    style: const TextStyle(color: AppColors.textSecondary)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _enterName,
                style: ElevatedButton.styleFrom(
                    backgroundColor: widget.accent.withValues(alpha: 0.2)),
                child: Text(s.enterNameBtn,
                    style: TextStyle(color: widget.accent)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
