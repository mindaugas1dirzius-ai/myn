import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/game_mode.dart';
import '../theme/app_theme.dart';
import '../widgets/neumorphic_button.dart';
import 'game_screen.dart';

/// G1, 2-as žingsnis: pasirinkus veiksmą — renkamės sunkumo lygį.
/// Lygiai generuojami dinamiškai iš GameLevel.values (jokio dubliavimo).
class LevelSelectScreen extends StatelessWidget {
  final MathOp op;

  const LevelSelectScreen({super.key, required this.op});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('${op.label(s)}  ${op.symbol}'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                s.pickLevel,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: GameLevel.values.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, i) {
                    final level = GameLevel.values[i];
                    return NeumorphicButton(
                      accent: level.color,
                      onTap: () => _onLevelTap(context, level),
                      child: Text(
                        level.title(s),
                        style: TextStyle(
                          color: level.color,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onLevelTap(BuildContext context, GameLevel level) {
    final modeId = buildModeId(op, level); // pvz. "mul_sunkus" — serverio kalba
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(modeId: modeId, op: op, level: level),
      ),
    );
  }
}
