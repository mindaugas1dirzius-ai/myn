import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/game_mode.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/exit_dialog.dart';
import '../widgets/live_points.dart';
import '../widgets/neon_timer_ring.dart';
import '../widgets/neumorphic_box.dart';
import '../widgets/neumorphic_button.dart';
import 'result_screen.dart';

/// G4: žaidimo ekranas — sujungia langelį, žiedą, atsakymus ir LOGIKĄ.
/// Būseną valdo GameProvider (lokalūs klausimai; serveris — J žingsnyje).
class GameScreen extends StatefulWidget {
  final String modeId;
  final MathOp op;
  final GameLevel level;

  const GameScreen({
    super.key,
    required this.modeId,
    required this.op,
    required this.level,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final GameProvider _game;
  late final AnimationController _shake;
  final Stopwatch _stopwatch = Stopwatch();
  int _ringKey = 0; // perkrauna žiedą kiekvienam klausimui

  @override
  void initState() {
    super.initState();
    _game = GameProvider(
      op: widget.op,
      level: widget.level,
      modeId: widget.modeId,
    );
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _startQuestion() {
    _stopwatch
      ..reset()
      ..start();
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  void _onAnswer(int value) {
    if (_game.isBusy) return;
    _stopwatch.stop();
    _game.answer(value, _stopwatch.elapsedMilliseconds);
    _afterResolve();
  }

  void _onTimeout() {
    if (_game.isBusy) return;
    _stopwatch.stop();
    _game.timeout();
    _afterResolve();
  }

  /// ✕ paspaustas — patvirtinimas, tada grįžtam į meniu (nieko nesiunčiam).
  Future<void> _onQuitPressed() async {
    final quit = await showQuitDialog(context);
    if (quit && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  /// Po atsakymo: animacija, pauzė, tada kitas klausimas arba rezultatai.
  Future<void> _afterResolve() async {
    if (_game.state == CellState.wrong) {
      await _shake.forward(from: 0);
    }
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    _game.next();
    if (_game.finished) {
      // Siunčiam rezultatą serveriui (jei server režimas); gaunam oficialų score.
      final serverScore = await _game.submitToServer();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            op: widget.op,
            level: widget.level,
            modeId: widget.modeId,
            correct: _game.correctCount,
            total: _game.total,
            score: serverScore ?? _game.score,
            online: _game.source == Source.server,
          ),
        ),
      );
    } else {
      setState(() => _ringKey++); // naujas žiedas naujam klausimui
      _startQuestion();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.level.color;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _game,
          builder: (context, _) {
            // Kraunasi — kol serveris generuoja klausimus.
            if (_game.loadState == LoadState.loading) {
              return Center(
                child: CircularProgressIndicator(color: accent),
              );
            }
            // Pirmas kadras po pakrovimo — paleidžiam langelio laikmatį.
            if (!_stopwatch.isRunning && _game.state == CellState.idle) {
              _startQuestion();
            }
            final q = _game.current;
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Viršutinė juosta: gyvi taškai (kairėje) + ✕ Baigti (dešinėje).
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LivePoints(
                        running: _game.state == CellState.idle,
                        resetKey: _ringKey,
                      ),
                      IconButton(
                        icon: Icon(Icons.close,
                            color: AppColors.textSecondary, size: 28),
                        onPressed: _onQuitPressed,
                      ),
                    ],
                  ),
                  _ProgressBar(index: _game.index, total: _game.total),
                  if (_game.source == Source.offline) _offlineBadge(),
                  const Spacer(),
                  _buildBoxWithRing(q.text, accent),
                  const Spacer(),
                  _buildAnswers(q.options, accent),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Ženklas, kad žaidžiama offline (rezultatas neįrašomas į Top 10).
  Widget _offlineBadge() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        'Offline',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
    );
  }

  Widget _buildBoxWithRing(String text, Color accent) {
    // Shake animacija (klaida): langelis kruta į šonus.
    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        final dx = math.sin(_shake.value * math.pi * 8) * 10 * (1 - _shake.value);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          NeonTimerRing(
            key: ValueKey(_ringKey),
            durationMs: _game.maxTimeMs,
            size: 240,
            running: !_game.isBusy,
            onTimeout: _onTimeout,
          ),
          NeumorphicBox(text: text, accent: _boxAccent(accent)),
        ],
      ),
    );
  }

  /// Langelio briaunos spalva pagal būseną (teisinga=žalia, klaida=raudona).
  Color _boxAccent(Color accent) {
    switch (_game.state) {
      case CellState.correct:
        return AppColors.correct;
      case CellState.wrong:
        return AppColors.wrong;
      case CellState.idle:
        return accent;
    }
  }

  Widget _buildAnswers(List<int> options, Color accent) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.3,
      children: options.map((v) => _answerButton(v, accent)).toList(),
    );
  }

  Widget _answerButton(int value, Color accent) {
    // Po atsakymo paryškinam: teisingą — žaliai, paspaustą klaidingą — raudonai.
    Color c = accent;
    if (_game.state != CellState.idle) {
      if (value == _game.current.answer) {
        c = AppColors.correct;
      } else if (value == _game.pickedOption) {
        c = AppColors.wrong;
      }
    }
    return NeumorphicButton(
      accent: c,
      padding: const EdgeInsets.all(8),
      onTap: () => _onAnswer(value),
      child: Text(
        '$value',
        style: TextStyle(
          color: c == accent ? AppColors.textPrimary : c,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Progreso juosta viršuje (kelintas klausimas iš 10).
class _ProgressBar extends StatelessWidget {
  final int index;
  final int total;
  const _ProgressBar({required this.index, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('${index + 1} / $total',
            style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (index + 1) / total,
              backgroundColor: AppColors.shadowLight,
              color: AppColors.levelEasy,
              minHeight: 6,
            ),
          ),
        ),
      ],
    );
  }
}
