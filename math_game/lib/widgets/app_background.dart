import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Gražus fonas visiems ekranams: tamsus diagonalus gradientas +
/// du minkšti neon „švytėjimai" (radial gradient blob'ai).
///
/// KODĖL: plokščias #121214 fonas atrodė blankus. Švytėjimai prideda gylio ir
/// gyvybės, bet PIGIAI (be BackdropFilter blur — radial gradientas yra greitas).
/// [accent] nuspalvina viršutinį švytėjimą pagal ekrano kontekstą (lygį/temą),
/// kad kiekvienas ekranas turėtų savo „nuotaiką".
class AppBackground extends StatelessWidget {
  final Widget child;
  final Color accent;

  const AppBackground({
    super.key,
    required this.child,
    this.accent = AppColors.neonBlue,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF17171F), Color(0xFF0B0B0F)],
        ),
      ),
      child: Stack(
        children: [
          // Viršutinis-dešinys švytėjimas — akcento spalva (ekrano nuotaika).
          Positioned(
            top: -130,
            right: -90,
            child: _glow(accent.withValues(alpha: 0.22), 300),
          ),
          // Apatinis-kairys švytėjimas — ultravioletinis (kontrastui).
          Positioned(
            bottom: -150,
            left: -110,
            child:
                _glow(AppColors.levelExtreme.withValues(alpha: 0.15), 340),
          ),
          child,
        ],
      ),
    );
  }

  /// Minkštas apvalus švytėjimas (radial gradientas → skaidrumas kraštuose).
  Widget _glow(Color color, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
