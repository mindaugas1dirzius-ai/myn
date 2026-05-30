import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Neoninis laikmačio žiedas (DIZAINAS.md, 7 sprendimas).
/// Apgaubia klausimo langelį, tolygiai tuštėja, keičia spalvą
/// žalia → geltona → raudona, < 1.5 s pulsuoja.
///
/// [durationMs] — pilnas laikas pagal lygį (3000/4000/5000/6000).
/// [onTimeout]  — iškviečiamas, kai laikas pasibaigia (G4 panaudos kaip klaidą).
/// [running]    — ar žiedas sukasi (G4 pristabdys tarp klausimų).
class NeonTimerRing extends StatefulWidget {
  final int durationMs;
  final double size;
  final VoidCallback? onTimeout;
  final bool running;

  const NeonTimerRing({
    super.key,
    required this.durationMs,
    this.size = 220,
    this.onTimeout,
    this.running = true,
  });

  @override
  State<NeonTimerRing> createState() => _NeonTimerRingState();
}

class _NeonTimerRingState extends State<NeonTimerRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationMs),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onTimeout?.call();
      });
    if (widget.running) _controller.forward();
  }

  @override
  void didUpdateWidget(NeonTimerRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    // G4: leidžia pristabdyti/tęsti žiedą be jo perkūrimo.
    if (widget.running && !_controller.isAnimating) {
      _controller.forward();
    } else if (!widget.running && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Spalva pagal praėjusią dalį: žalia → geltona → raudona (V2: tiksi aukštyn).
  Color _colorFor(double elapsed) {
    if (elapsed < 0.5) return AppColors.levelEasy; // žalia (greita)
    if (elapsed < 0.8) return AppColors.levelMedium; // geltona
    return AppColors.wrong; // raudona (artėja 30s riba)
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final elapsed = _controller.value; // 0 → 1 (žiedas PILNĖJA)
        final color = _colorFor(elapsed);
        // Pulsavimas artėjant 30s ribai (paskutinės ~5 s).
        final nearLimit = elapsed > (1 - 5000 / widget.durationMs);
        final pulse = nearLimit
            ? 1.0 + 0.06 * math.sin(_controller.value * math.pi * 16)
            : 1.0;

        return Transform.scale(
          scale: pulse,
          child: CustomPaint(
            size: Size.square(widget.size),
            painter: _RingPainter(progress: elapsed, color: color),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress; // 0 → 1 (praėjusi dalis, žiedas pilnėja)
  final Color color;

  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 6;

    // Pilkas fono žiedas (takelis).
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = AppColors.shadowLight;
    canvas.drawCircle(center, radius, track);

    // Aktyvus neoninis lankas su švytėjimu.
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final sweep = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // pradžia viršuje
      sweep,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
