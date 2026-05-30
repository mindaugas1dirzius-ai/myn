import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Gyvas taškų skaitiklis (V2 idėja): rodo, kiek taškų gausi, JEI atsakysi DABAR.
/// Mažėja tiksint laikui pagal formulę max(10, 100 − sekundės × 3).
/// Tik vizualas (kosmetika) — oficialius taškus skaičiuoja serveris.
///
/// [running] — ar laikas tiksi (sustabdom, kai atsakyta).
class LivePoints extends StatefulWidget {
  final bool running;
  final int resetKey; // pakeitus — skaitiklis prasideda iš naujo

  const LivePoints({super.key, required this.running, required this.resetKey});

  @override
  State<LivePoints> createState() => _LivePointsState();
}

class _LivePointsState extends State<LivePoints>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    // 30s trukmė — kad sutaptų su langelio riba.
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    if (widget.running) _ctrl.forward();
  }

  @override
  void didUpdateWidget(LivePoints old) {
    super.didUpdateWidget(old);
    if (widget.resetKey != old.resetKey) {
      _ctrl.forward(from: 0); // naujas klausimas — iš naujo
    }
    if (widget.running && !_ctrl.isAnimating) {
      _ctrl.forward();
    } else if (!widget.running && _ctrl.isAnimating) {
      _ctrl.stop(); // atsakyta — sustabdom (užfiksuojam taškus)
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Taškai pagal praėjusį laiką: max(10, 100 − sek × 3).
  int _points() {
    final seconds = _ctrl.value * 30; // 0..30
    final p = 100 - seconds * 3;
    return p < 10 ? 10 : p.floor();
  }

  Color _color(int p) {
    if (p > 70) return AppColors.levelEasy; // žalia
    if (p > 40) return AppColors.levelMedium; // geltona
    return AppColors.wrong; // raudona
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final p = _points();
        final c = _color(p);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt, color: c, size: 18),
            const SizedBox(width: 4),
            Text('+$p',
                style: TextStyle(
                    color: c, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        );
      },
    );
  }
}
