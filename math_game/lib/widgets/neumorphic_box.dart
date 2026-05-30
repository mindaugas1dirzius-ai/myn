import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Centrinis klausimo langelis (DIZAINAS.md, 8 sprendimas).
/// Didelis iškilęs neumorfinis paviršius su švytinčia lygio briauna.
/// Žiedą (laikmatį) pridėsim G3 žingsnyje — todėl paliekam vietą aplink.
class NeumorphicBox extends StatelessWidget {
  final String text; // klausimas, pvz. "6 × 7"
  final Color accent; // pasirinkto lygio neon spalva

  const NeumorphicBox({super.key, required this.text, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: accent.withValues(alpha: 0.6), width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowDark,
            offset: Offset(8, 8),
            blurRadius: 18,
          ),
          BoxShadow(
            color: AppColors.shadowLight,
            offset: Offset(-8, -8),
            blurRadius: 18,
          ),
        ],
      ),
      // FittedBox saugiklis: ilgi klausimai (pvz. "124 + 58") nesulaužys dizaino —
      // tekstas tiesiog proporcingai sumažės, o ne keliasi į kitą eilutę.
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            maxLines: 1,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
