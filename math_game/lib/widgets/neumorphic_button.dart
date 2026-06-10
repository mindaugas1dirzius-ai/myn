import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Daugkartinis Cyber-Neumorphism mygtukas (DIZAINAS.md, 8 sprendimas).
/// Naudojamas režimų pasirinkime, atsakymų variantuose ir kt.
///
/// - iškilęs paviršius su dvigubais šešėliais (tamsus apačia-dešinė,
///   šviesus viršus-kairė),
/// - švytinti neon briauna (spalva paduodama per [accent]).
class NeumorphicButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color accent;
  final EdgeInsetsGeometry padding;

  const NeumorphicButton({
    super.key,
    required this.child,
    required this.accent,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: padding,
        decoration: BoxDecoration(
          // Subtilus gradientas (šviesiau viršuje-kairėje) → tūrio pojūtis.
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.shadowLight, AppColors.surface],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withValues(alpha: 0.7), width: 1.5),
          boxShadow: [
            // Neumorfiniai šešėliai (gylis).
            const BoxShadow(
              color: AppColors.shadowDark,
              offset: Offset(5, 5),
              blurRadius: 12,
            ),
            const BoxShadow(
              color: AppColors.shadowLight,
              offset: Offset(-5, -5),
              blurRadius: 12,
            ),
            // Akcento švytėjimas — mygtukas „šviečia" savo spalva.
            BoxShadow(
              color: accent.withValues(alpha: 0.28),
              blurRadius: 18,
              spreadRadius: -3,
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
