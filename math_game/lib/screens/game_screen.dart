import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/neumorphic_box.dart';
import '../widgets/neumorphic_button.dart';

/// G2: žaidimo ekrano vizualas — klausimo langelis + 6 atsakymų mygtukai.
///
/// KOL KAS naudoja laikinus duomenis (placeholder klausimą ir variantus),
/// kad pamatytume išvaizdą. G4 žingsnyje prijungsim tikrus serverio duomenis
/// (GameSession), laikmatį (G3) ir teisinga/klaida animacijas.
class GameScreen extends StatelessWidget {
  final String modeId; // pvz. "mul_sunkus" — iš ko paimsim lygio spalvą
  final GameLevel level;

  const GameScreen({super.key, required this.modeId, required this.level});

  // Laikini duomenys (G4 pakeis serverio atsakymais).
  static const String _demoQuestion = '6 × 7';
  static const List<int> _demoOptions = [35, 44, 42, 13, 24, 48];

  @override
  Widget build(BuildContext context) {
    final accent = level.color;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Spacer(),
              // Klausimo langelis
              NeumorphicBox(text: _demoQuestion, accent: accent),
              const Spacer(),
              // 6 atsakymai — 2×3 tinklelis
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.3,
                children: _demoOptions
                    .map((value) => _buildAnswer(context, value, accent))
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswer(BuildContext context, int value, Color accent) {
    return NeumorphicButton(
      accent: accent,
      padding: const EdgeInsets.all(8),
      onTap: () {
        // G4: čia bus atsakymo tikrinimas + animacija. Kol kas tik vizualas.
      },
      child: Text(
        '$value',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
