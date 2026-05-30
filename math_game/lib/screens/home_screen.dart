import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/game_mode.dart';
import '../theme/app_theme.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/neumorphic_button.dart';
import 'level_select_screen.dart';

/// G1, 1-as žingsnis: pradinis ekranas — pasirenkam matematinį veiksmą.
/// Veiksmai generuojami dinamiškai iš MathOp.values (jokio dubliavimo).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'MATH GAME',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 34,
                      letterSpacing: 4,
                      color: AppColors.levelEasy,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                s.pickOperation,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children:
                      MathOp.values.map((op) => _buildOpTile(op, s)).toList(),
                ),
              ),
              // Banner meniu apačioje (leista; ne žaidimo metu)
              const SizedBox(height: 8),
              const BannerAdWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpTile(MathOp op, AppStrings s) {
    // Kiekvienam veiksmui parenkam akcentą iš lygių paletės (vizualinė įvairovė).
    const accents = [
      AppColors.levelEasy,
      AppColors.levelMedium,
      AppColors.levelHard,
      AppColors.levelExtreme,
    ];
    final accent = accents[op.index];

    return Builder(
      builder: (context) => NeumorphicButton(
        accent: accent,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => LevelSelectScreen(op: op)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              op.symbol,
              style: TextStyle(
                color: accent,
                fontSize: 44,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              op.label(s),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
