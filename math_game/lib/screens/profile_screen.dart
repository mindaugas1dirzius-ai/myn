import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/game_mode.dart';
import '../theme/app_theme.dart';
import '../widgets/neumorphic_button.dart';

/// Profilio ekranas (V2): 16 režimų tinklelis su asmeniniais rekordais.
/// Paspaudus režimą → rank + Top 10 (rank_detail_screen).
///
/// Kol kas KARKASAS: vardas + 16 režimų. Personal Best ir getMyRank
/// pajungsim kitame žingsnyje (reikia naujos Cloud Function).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(s.profile),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 16 režimų tinklelis (4 veiksmai × 4 lygiai).
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    for (final op in MathOp.values)
                      for (final level in GameLevel.values)
                        _modeTile(context, s, op, level),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeTile(
      BuildContext context, AppStrings s, MathOp op, GameLevel level) {
    return NeumorphicButton(
      accent: level.color,
      padding: const EdgeInsets.all(10),
      onTap: () {
        // Kitame žingsnyje: atidarysim rank + Top 10 detalų ekraną.
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${op.symbol} ${level.title(s)}',
              style: TextStyle(
                  color: level.color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(s.noRecord,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}
