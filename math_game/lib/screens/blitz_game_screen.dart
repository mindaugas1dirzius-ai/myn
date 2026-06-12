import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_strings.dart';
import '../models/blitz_models.dart';
import '../services/game_api.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/banner_ad_widget.dart';

/// ⚡ TAIP/NE BLITZ — 30 s raundas prieš laikrodį.
///
/// Teiginiai krenta vienas po kito: klausimas + 👉 kandidatas. Žaidėjas
/// spaudžia TAIP (kandidatas teisingas) arba NE (distraktorius). VIENAS
/// bendras laikmatis; klaida = 0 ir kombo nulinasi; paskutinės 5 s ×2.
///
/// VISA TIESA SERVERYJE: paketą paruošia startBlitz, vertina submitBlitzScore
/// pagal savo isTrue[]; čia tik eilė, laikrodis ir atsakymų sąrašas.
class BlitzGameScreen extends StatefulWidget {
  const BlitzGameScreen({super.key});

  @override
  State<BlitzGameScreen> createState() => _BlitzGameScreenState();
}

enum _Phase { loading, error, countdown, playing, submitting, done }

class _BlitzGameScreenState extends State<BlitzGameScreen> {
  static const _accent = AppColors.levelMedium; // ⚡ geltona

  _Phase _phase = _Phase.loading;
  BlitzSession? _session;
  Timer? _ticker;

  int _countdown = 3; // 3-2-1 prieš startą
  DateTime? _roundStart;
  int _idx = 0; // rodomas teiginys
  final List<BlitzAnswer> _answers = [];
  int _streak = 0;
  int _bestCombo = 0;
  int _liveScore = 0; // kliento veidrodis (tikrą skaičiuoja serveris)
  bool _lastWrong = false; // raudonas blyksnis po klaidos
  bool _answerLock = false; // apsauga nuo dvigubo paspaudimo

  AppLang _appLang = AppLang.en;
  AppStrings get _s => AppStrings.of(context);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appLang = AppStrings.of(context).lang;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  int get _durationMs => _session?.durationMs ?? 30000;

  int get _elapsedMs => _roundStart == null
      ? 0
      : DateTime.now().difference(_roundStart!).inMilliseconds;

  int get _remainingMs => (_durationMs - _elapsedMs).clamp(0, 1 << 31);

  bool get _finalPhase =>
      _phase == _Phase.playing && _elapsedMs >= 25000 && _remainingMs > 0;

  Future<void> _load() async {
    setState(() {
      _phase = _Phase.loading;
      _answers.clear();
      _idx = 0;
      _streak = 0;
      _bestCombo = 0;
      _liveScore = 0;
      _lastWrong = false;
      _answerLock = false;
    });
    try {
      final lang = _appLang == AppLang.lt ? 'lt' : 'en';
      final s = await GameApi.startBlitz(lang);
      if (!mounted) return;
      if (s.statements.isEmpty) {
        setState(() => _phase = _Phase.error);
        return;
      }
      setState(() {
        _session = s;
        _phase = _Phase.countdown;
        _countdown = 3;
      });
      _runCountdown();
    } catch (_) {
      if (!mounted) return;
      setState(() => _phase = _Phase.error);
    }
  }

  void _runCountdown() {
    _ticker?.cancel();
    SoundService.instance.tap();
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_countdown <= 1) {
        t.cancel();
        _startRound();
      } else {
        SoundService.instance.tap();
        setState(() => _countdown--);
      }
    });
  }

  void _startRound() {
    SoundService.instance.swoosh();
    setState(() {
      _phase = _Phase.playing;
      _roundStart = DateTime.now();
    });
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted || _phase != _Phase.playing) return;
      setState(() {});
      if (_remainingMs <= 0) _endRound();
    });
  }

  /// Kliento taškų veidrodis — TA PATI formulė kaip serveryje (rodymui).
  int _pointsFor(int streakNow, int tMs) {
    var pts = 100 * (1 + 0.1 * (streakNow - 1).clamp(0, 10));
    if (tMs >= 25000) pts *= 2;
    return pts.round();
  }

  void _answer(bool val) {
    if (_phase != _Phase.playing || _answerLock) return;
    final st = _session!.statements;
    if (_idx >= st.length) return;
    final tMs = _elapsedMs.clamp(0, _durationMs);
    final ok = st[_idx].isTrue == val;
    _answers.add(BlitzAnswer(i: _idx, val: val, tMs: tMs));
    if (ok) {
      HapticFeedback.lightImpact();
      SoundService.instance.points();
      _streak++;
      if (_streak > _bestCombo) _bestCombo = _streak;
      _liveScore += _pointsFor(_streak, tMs);
    } else {
      HapticFeedback.heavyImpact();
      SoundService.instance.wrong();
      _streak = 0;
    }
    setState(() {
      _lastWrong = !ok;
      _idx++;
      _answerLock = true;
    });
    // Trumpa pauzė tarp teiginių, kad blyksnis matytųsi (ne stabdo laikrodžio).
    Timer(const Duration(milliseconds: 160), () {
      if (mounted) setState(() => _answerLock = false);
    });
    if (_idx >= st.length) _endRound(); // paketas baigėsi anksčiau laiko
  }

  Future<void> _endRound() async {
    if (_phase != _Phase.playing) return;
    _ticker?.cancel();
    SoundService.instance.swoosh();
    setState(() => _phase = _Phase.submitting);
    try {
      final r = await GameApi.submitBlitzScore(_session!.gameId, _answers);
      if (!mounted) return;
      setState(() => _phase = _Phase.done);
      if (r.isNewRecord) SoundService.instance.win();
      await _showResultDialog(r);
    } catch (_) {
      if (!mounted) return;
      setState(() => _phase = _Phase.done);
      await _showExpiredDialog();
    }
  }

  Future<void> _showResultDialog(BlitzResult r) async {
    final again = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final s = AppStrings.of(ctx);
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('⚡ ${s.blitzTimeUp}',
              style: const TextStyle(color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${r.finalScore}',
                  style: const TextStyle(
                      color: _accent,
                      fontSize: 40,
                      fontWeight: FontWeight.bold)),
              if (r.isNewRecord)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(s.blitzNewRecord,
                      style: const TextStyle(
                          color: AppColors.correct,
                          fontWeight: FontWeight.bold)),
                ),
              const SizedBox(height: 10),
              Text(
                '${s.blitzCorrectLabel}: ${r.correct} / ${r.answered}',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              Text(
                '${s.blitzBestCombo}: ${r.bestCombo}',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text('+${r.coinsEarned} 🪙   +${r.earnedLetters} 🔤',
                  style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(s.blitzClose)),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(s.blitzPlayAgain,
                    style: const TextStyle(
                        color: AppColors.correct,
                        fontWeight: FontWeight.bold))),
          ],
        );
      },
    );
    if (!mounted) return;
    if (again == true) {
      _load();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _showExpiredDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final s = AppStrings.of(ctx);
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('⚡ ${s.blitzTimeUp}',
              style: const TextStyle(color: AppColors.wrong)),
          content: Text(s.blitzExpired,
              style: const TextStyle(color: AppColors.textSecondary)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(s.blitzClose)),
          ],
        );
      },
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<bool> _confirmQuit() async {
    if (_phase != _Phase.playing) return true;
    final s = _s;
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(s.blitzQuitTitle,
            style: const TextStyle(color: AppColors.textPrimary)),
        content: Text(s.blitzQuitBody,
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(s.blitzQuitStay)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(s.blitzQuitLeave,
                  style: const TextStyle(color: AppColors.wrong))),
        ],
      ),
    );
    return leave == true;
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    final s = _s;
    return PopScope(
      canPop: _phase != _Phase.playing,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await _confirmQuit()) navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textSecondary),
          title: Text('⚡ ${s.categoryBlitz}',
              style: const TextStyle(color: AppColors.textPrimary)),
        ),
        body: AppBackground(
          accent: _accent,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(child: _body(s)),
                const BannerAdWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(AppStrings s) {
    switch (_phase) {
      case _Phase.loading:
        return const Center(
            child: CircularProgressIndicator(color: _accent));
      case _Phase.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(s.natureLoadError,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                TextButton(onPressed: _load, child: Text(s.retry)),
              ],
            ),
          ),
        );
      case _Phase.countdown:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(s.blitzGetReady,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 18)),
              const SizedBox(height: 12),
              Text('$_countdown',
                  style: const TextStyle(
                      color: _accent,
                      fontSize: 80,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        );
      case _Phase.playing:
      case _Phase.submitting:
      case _Phase.done:
        return _round(s);
    }
  }

  Widget _round(AppStrings s) {
    final st = _session!.statements;
    final secs = (_remainingMs / 1000).ceil();
    final urgent = _remainingMs <= 5000 || _finalPhase;
    final frac = (_remainingMs / _durationMs).clamp(0.0, 1.0).toDouble();
    final current = _idx < st.length ? st[_idx] : null;
    final waiting = _phase != _Phase.playing;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Column(
        children: [
          // Tirpstanti laiko juosta + skaitliukai.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('⏱ $secs s',
                  style: TextStyle(
                      color: urgent ? AppColors.wrong : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 22)),
              if (_finalPhase)
                Text(s.blitzFinalX2,
                    style: const TextStyle(
                        color: AppColors.wrong,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              Text('$_liveScore',
                  style: const TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 22)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: frac,
              minHeight: 10,
              backgroundColor: AppColors.shadowDark,
              valueColor: AlwaysStoppedAnimation(
                  urgent ? AppColors.wrong : _accent),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${s.blitzAnswered}: ${_answers.length}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
              Text(
                _streak >= 2 ? '🔥 ${s.blitzCombo} ×$_streak' : '',
                style: const TextStyle(
                    color: AppColors.correct,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Teiginio kortelė.
          Expanded(
            child: waiting
                ? const Center(
                    child: CircularProgressIndicator(color: _accent))
                : current == null
                    ? const SizedBox.shrink()
                    : AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: _lastWrong && _answerLock
                                ? AppColors.wrong
                                : _accent.withValues(alpha: 0.5),
                            width: _answerLock ? 2.5 : 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AutoSizeText(
                              current.q,
                              maxLines: 4,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 18),
                            AutoSizeText(
                              '👉 ${current.cand}',
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: _accent,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
          ),
          const SizedBox(height: 12),
          // Du DIDELI mygtukai: NE (kairė, raudona) / TAIP (dešinė, žalia).
          Row(
            children: [
              Expanded(
                  child: _bigButton(
                      label: '✕ ${s.blitzNo}',
                      color: AppColors.wrong,
                      onTap: waiting || current == null
                          ? null
                          : () => _answer(false))),
              const SizedBox(width: 12),
              Expanded(
                  child: _bigButton(
                      label: '✓ ${s.blitzYes}',
                      color: AppColors.correct,
                      onTap: waiting || current == null
                          ? null
                          : () => _answer(true))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bigButton(
      {required String label, required Color color, VoidCallback? onTap}) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 86,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: enabled ? color : AppColors.textSecondary, width: 2),
          boxShadow: enabled
              ? [
                  BoxShadow(
                      color: color.withValues(alpha: 0.25),
                      blurRadius: 14,
                      spreadRadius: 1),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: enabled ? color : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
