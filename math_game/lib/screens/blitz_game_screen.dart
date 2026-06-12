import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme_catalog.dart';
import '../l10n/app_strings.dart';
import '../models/blitz_models.dart';
import '../services/game_api.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/banner_ad_widget.dart';

/// ⚡ TAIP/NE BLITZ — 30 s arkadinis raundas prieš laikrodį.
///
/// DIZAINAS (savininko prašymu — įdomu, profesionalu, patogu):
///  - teiginio KORTELĖ įskrenda su animacija; galima atsakyti DIDELIAIS
///    mygtukais (✕ NE / ✓ TAIP nykščio zonoje) ARBA BRAUKIANT kortelę
///    (← NE, TAIP →);
///  - per atsakymą — didelis ✓/✕ blyksnis + skrendantys taškai + vibracija;
///  - 🔥 serijos ženkliukas rodo daugiklį; paskutinės 5 s — raudonas
///    pulsuojantis FINALAS ×2;
///  - pabaigoje — rezultatų panelė su skaičiuojančiais taškais.
///
/// VISA TIESA SERVERYJE: paketą paruošia startBlitz, vertina submitBlitzScore
/// pagal savo isTrue[]; čia tik eilė, laikrodis ir atsakymų sąrašas.
class BlitzGameScreen extends StatefulWidget {
  const BlitzGameScreen({super.key});

  @override
  State<BlitzGameScreen> createState() => _BlitzGameScreenState();
}

enum _Phase { pick, loading, error, countdown, playing, submitting, result }

class _BlitzGameScreenState extends State<BlitzGameScreen> {
  static const _accent = AppColors.levelMedium; // ⚡ geltona

  _Phase _phase = _Phase.pick; // pirmiausia — trukmės pasirinkimas
  int _chosenDuration = 60; // savininko pastaba: 30 s per greit — default 1 min
  BlitzSession? _session;
  BlitzResult? _result;
  Timer? _ticker;

  int _countdown = 3; // 3-2-1 prieš startą
  DateTime? _roundStart;
  int _idx = 0; // rodomas teiginys
  final List<BlitzAnswer> _answers = [];
  int _streak = 0;
  int _bestCombo = 0;
  int _liveScore = 0; // kliento veidrodis (tikrą skaičiuoja serveris)
  int _lastGain = 0; // skrendantys taškai (+130)
  int _prevTMs = -600; // ankstesnio atsakymo laikas (spaudinėjimo saugiklis)
  bool? _lastOk; // ✓/✕ blyksniui (null — dar nieko)
  int _flashSeq = 0; // animacijų raktas (kiekvienam atsakymui naujas)
  bool _pressedYes = false; // mygtukų paspaudimo animacijai
  bool _pressedNo = false;

  AppLang _appLang = AppLang.en;
  AppStrings get _s => AppStrings.of(context);

  // SVARBU: kalba žinoma tik po didChangeDependencies — užklausos eina vėliau
  // (žaidėjui pasirinkus trukmę), tad klausimai visada teisinga kalba.
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
      _phase == _Phase.playing &&
      _elapsedMs >= _durationMs - 5000 &&
      _remainingMs > 0;

  /// Dabartinis kombo daugiklis (rodymui): 1.0 → 2.0.
  double get _multiplier => 1 + 0.1 * (_streak - 1).clamp(0, 10);

  Future<void> _load() async {
    setState(() {
      _phase = _Phase.loading;
      _result = null;
      _answers.clear();
      _idx = 0;
      _streak = 0;
      _bestCombo = 0;
      _liveScore = 0;
      _lastGain = 0;
      _prevTMs = -600;
      _lastOk = null;
      _flashSeq = 0;
    });
    try {
      final lang = _appLang == AppLang.lt ? 'lt' : 'en';
      final s = await GameApi.startBlitz(lang, _chosenDuration);
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
    if (tMs >= _durationMs - 5000) pts *= 2;
    return pts.round();
  }

  void _answer(bool val) {
    if (_phase != _Phase.playing) return;
    final st = _session!.statements;
    if (_idx >= st.length) return;
    final tMs = _elapsedMs.clamp(0, _durationMs);
    final ok = st[_idx].isTrue == val;
    // Spaudinėjimo saugiklis (veidrodis serverio): atsakymas greičiau nei
    // per 0,6 s po ankstesnio TAŠKŲ NEDUODA (žmogus tiek neperskaito).
    final gapOk = tMs - _prevTMs >= 600;
    _prevTMs = tMs;
    _answers.add(BlitzAnswer(i: _idx, val: val, tMs: tMs));
    if (ok) {
      HapticFeedback.lightImpact();
      if (gapOk) {
        SoundService.instance.points();
        _streak++;
        if (_streak > _bestCombo) _bestCombo = _streak;
        _lastGain = _pointsFor(_streak, tMs);
        _liveScore += _lastGain;
      } else {
        SoundService.instance.tap();
        _lastGain = 0; // per greitai — be taškų, kombo nesikeičia
      }
    } else {
      HapticFeedback.heavyImpact();
      SoundService.instance.wrong();
      _streak = 0;
      // BAUDA už klaidą (veidrodis serverio formulės): spaudinėjimas
      // nebeapsimoka. Eigoje suma gali būti minusinė — rodome nuo 0.
      _lastGain = -150;
      _liveScore -= 150;
    }
    setState(() {
      _lastOk = ok;
      _flashSeq++;
      _idx++;
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
      if (r.isNewRecord) SoundService.instance.win();
      setState(() {
        _result = r;
        _phase = _Phase.result;
      });
    } catch (_) {
      if (!mounted) return;
      await _showExpiredDialog();
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

  // ─────────────────────────── UI ───────────────────────────

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
      case _Phase.pick:
        return _pickView(s);
      case _Phase.loading:
        return const Center(child: CircularProgressIndicator(color: _accent));
      case _Phase.error:
        return _errorView(s);
      case _Phase.countdown:
        return _countdownView(s);
      case _Phase.playing:
      case _Phase.submitting:
        return _roundView(s);
      case _Phase.result:
        return _resultView(s, _result!);
    }
  }

  /// Trukmės pasirinkimas (savininkas: „30 sek labai greitai praeina").
  Widget _pickView(AppStrings s) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Column(
        children: [
          const Text('⚡', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 6),
          Text(
            s.blitzPickDuration,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                letterSpacing: 1.2),
          ),
          const SizedBox(height: 14),
          // TAS PATS žaidimas — tik trukmės jungiklis (30 s / 1 min).
          Row(
            children: [
              Expanded(child: _durationChip('⚡ 30 s', 30)),
              const SizedBox(width: 10),
              Expanded(child: _durationChip('⏱ 1 min.', 60)),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              SoundService.instance.tap();
              _load();
            },
            child: Container(
              width: double.infinity,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _accent, width: 2),
                boxShadow: [
                  BoxShadow(
                      color: _accent.withValues(alpha: 0.25),
                      blurRadius: 16),
                ],
              ),
              child: Text('▶ ${s.blitzStart}',
                  style: const TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      letterSpacing: 1.4)),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _accent.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ruleRow('🔥', s.blitzRuleCombo),
                const SizedBox(height: 6),
                _ruleRow('💥', s.blitzRulePenalty),
                const SizedBox(height: 6),
                _ruleRow('⚡', s.blitzRuleFinal),
                const SizedBox(height: 6),
                _ruleRow('👆', s.blitzRuleSwipe),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _durationChip(String label, int durationSec) {
    final selected = _chosenDuration == durationSec;
    return GestureDetector(
      onTap: () {
        SoundService.instance.tap();
        setState(() => _chosenDuration = durationSec);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              selected ? _accent.withValues(alpha: 0.18) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected
                  ? _accent
                  : AppColors.textSecondary.withValues(alpha: 0.5),
              width: selected ? 2 : 1.2),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _accent : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
      ),
    );
  }

  Widget _errorView(AppStrings s) {
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
  }

  /// 3-2-1 atskaita + trumpos taisyklės (kad naujokas suprastų per 3 s).
  Widget _countdownView(AppStrings s) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(s.blitzGetReady,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                  letterSpacing: 1.2)),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Text(
              '$_countdown',
              key: ValueKey(_countdown),
              style: const TextStyle(
                  color: _accent, fontSize: 96, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ruleRow(String emoji, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(text,
            style:
                const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
      ],
    );
  }

  /// Pagrindinis raundo vaizdas.
  Widget _roundView(AppStrings s) {
    final st = _session!.statements;
    final secs = (_remainingMs / 1000).ceil();
    final urgent = _finalPhase || _remainingMs <= 5000;
    final frac = (_remainingMs / _durationMs).clamp(0.0, 1.0).toDouble();
    final current = _idx < st.length ? st[_idx] : null;
    final waiting = _phase != _Phase.playing;
    // Pulsas finale: laikrodžio skaičius „kvėpuoja".
    final pulse = urgent && ((_elapsedMs ~/ 300) % 2 == 0) ? 1.12 : 1.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
      child: Column(
        children: [
          // ── Viršus: laikas · kombo · taškai ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedScale(
                scale: pulse,
                duration: const Duration(milliseconds: 280),
                child: Text('⏱ $secs',
                    style: TextStyle(
                        color:
                            urgent ? AppColors.wrong : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 26)),
              ),
              _comboPill(s),
              Text('${_liveScore < 0 ? 0 : _liveScore}',
                  style: const TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 26)),
            ],
          ),
          const SizedBox(height: 6),
          // ── Tirpstanti laiko juosta ──
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Stack(
              children: [
                Container(height: 12, color: AppColors.shadowDark),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  height: 12,
                  width: MediaQuery.of(context).size.width * frac,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: urgent
                          ? [AppColors.wrong, AppColors.wrong]
                          : [_accent, _accent.withValues(alpha: 0.65)],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 22,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${s.blitzAnswered}: ${_answers.length}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                if (_finalPhase)
                  AnimatedScale(
                    scale: pulse,
                    duration: const Duration(milliseconds: 280),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.wrong.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.wrong),
                      ),
                      child: Text(s.blitzFinalX2,
                          style: const TextStyle(
                              color: AppColors.wrong,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // ── Kortelė + blyksnis + skrendantys taškai ──
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (waiting)
                  const Center(
                      child: CircularProgressIndicator(color: _accent))
                else if (current != null)
                  _statementCard(current),
                _answerFlash(),
                _floatingPoints(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // ── DIDELI nykščio mygtukai ──
          Row(
            children: [
              Expanded(
                  child: _bigButton(
                icon: Icons.close_rounded,
                label: s.blitzNo,
                color: AppColors.wrong,
                pressed: _pressedNo,
                onTap: waiting || current == null
                    ? null
                    : () {
                        setState(() => _pressedNo = true);
                        Timer(const Duration(milliseconds: 130), () {
                          if (mounted) setState(() => _pressedNo = false);
                        });
                        _answer(false);
                      },
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: _bigButton(
                icon: Icons.check_rounded,
                label: s.blitzYes,
                color: AppColors.correct,
                pressed: _pressedYes,
                onTap: waiting || current == null
                    ? null
                    : () {
                        setState(() => _pressedYes = true);
                        Timer(const Duration(milliseconds: 130), () {
                          if (mounted) setState(() => _pressedYes = false);
                        });
                        _answer(true);
                      },
              )),
            ],
          ),
        ],
      ),
    );
  }

  /// 🔥 serijos ženkliukas su daugikliu (×1.4) — auga su serija.
  Widget _comboPill(AppStrings s) {
    final active = _streak >= 2;
    return AnimatedScale(
      scale: active ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.correct.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.correct.withValues(alpha: 0.7)),
        ),
        child: Text(
          '🔥 ×${_multiplier.toStringAsFixed(1)}',
          style: const TextStyle(
              color: AppColors.correct,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
      ),
    );
  }

  /// Temos aprašas kortelės dizainui (emoji + spalva + pavadinimas iš katalogo).
  GameTheme? _themeFor(String cat) {
    for (final t in kThemes) {
      if (t.code == cat) return t;
    }
    return null;
  }

  /// Teiginio kortelė: įskrenda su animacija; braukiama ← NE / TAIP →.
  /// KIEKVIENA TEMA — SAVO VEIDAS (savininko prašymu, kad nebūtų tuščia):
  /// temos ženkliukas su pavadinimu, temos spalvos rėmas/švytėjimas ir
  /// didelis dekoratyvinis emoji kortelės fone — keičiasi su kiekvienu
  /// klausimu (gamta žalia 🌿, geografija 🗺️ ir t. t.).
  Widget _statementCard(BlitzStatement st) {
    final theme = _themeFor(st.cat);
    final tColor = theme?.accent ?? _accent;
    final tEmoji = theme?.emoji ?? '⚡';
    final tTitle = theme?.title(_s) ?? '';

    return GestureDetector(
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v > 250) _answer(true); // brauk dešinėn = TAIP
        if (v < -250) _answer(false); // brauk kairėn = NE
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeOutCubic,
        transitionBuilder: (child, anim) => SlideTransition(
          position: Tween<Offset>(
                  begin: const Offset(0.25, 0), end: Offset.zero)
              .animate(anim),
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: Container(
          key: ValueKey(_idx),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: tColor.withValues(alpha: 0.65), width: 1.6),
            boxShadow: [
              BoxShadow(
                  color: tColor.withValues(alpha: 0.16),
                  blurRadius: 20,
                  spreadRadius: 2),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Didelis dekoratyvinis temos emoji fone — „gyvas" vaizdas.
                Positioned(
                  right: -14,
                  bottom: -18,
                  child: Opacity(
                    opacity: 0.10,
                    child: Text(tEmoji,
                        style: const TextStyle(fontSize: 130)),
                  ),
                ),
                Positioned(
                  left: -20,
                  top: -24,
                  child: Opacity(
                    opacity: 0.06,
                    child: Text(tEmoji,
                        style: const TextStyle(fontSize: 100)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Temos ženkliukas — keičiasi su kiekvienu klausimu.
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: tColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                              color: tColor.withValues(alpha: 0.6)),
                        ),
                        child: Text(
                          '$tEmoji $tTitle',
                          style: TextStyle(
                              color: tColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.4),
                        ),
                      ),
                      const Spacer(),
                      AutoSizeText(
                        st.q,
                        maxLines: 4,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            height: 1.25,
                            fontWeight: FontWeight.w600),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: Container(
                          height: 1.2,
                          width: 90,
                          color: tColor.withValues(alpha: 0.4),
                        ),
                      ),
                      AutoSizeText(
                        st.cand,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: tColor,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Didelis ✓/✕ blyksnis per visą kortelę po kiekvieno atsakymo.
  Widget _answerFlash() {
    if (_lastOk == null) return const SizedBox.shrink();
    final ok = _lastOk!;
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        key: ValueKey('flash_$_flashSeq'),
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 420),
        builder: (context, t, _) => Opacity(
          opacity: ((1 - t) * 0.9).clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.7 + 0.7 * t,
            child: Icon(
              ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
              size: 120,
              color: ok ? AppColors.correct : AppColors.wrong,
            ),
          ),
        ),
      ),
    );
  }

  /// Skrendantys taškai: „+130" žalias už teisingą, „−100" raudonas už klaidą.
  Widget _floatingPoints() {
    if (_lastOk == null || _lastGain == 0) return const SizedBox.shrink();
    final gain = _lastGain > 0;
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        key: ValueKey('gain_$_flashSeq'),
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 650),
        builder: (context, t, _) => Transform.translate(
          offset: Offset(0, gain ? -30 - 70 * t : -30 + 50 * t),
          child: Opacity(
            opacity: (1 - t).clamp(0.0, 1.0),
            child: Text(
              gain ? '+$_lastGain' : '−${-_lastGain}',
              style: TextStyle(
                  color: gain ? AppColors.correct : AppColors.wrong,
                  fontWeight: FontWeight.bold,
                  fontSize: 34),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bigButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool pressed,
    VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: Container(
          height: 88,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: enabled ? color : AppColors.textSecondary, width: 2),
            boxShadow: enabled
                ? [
                    BoxShadow(
                        color: color.withValues(alpha: pressed ? 0.45 : 0.22),
                        blurRadius: 16,
                        spreadRadius: 1),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: enabled ? color : AppColors.textSecondary, size: 34),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: enabled ? color : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Rezultatų panelė: taškai suskaičiuojami animacija, statistikos kortelės.
  Widget _resultView(AppStrings s, BlitzResult r) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text('⚡ ${s.blitzTimeUp}',
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  letterSpacing: 1.4)),
          const SizedBox(height: 6),
          // Taškai skaičiuojasi 0 → rezultatas.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: r.finalScore.toDouble()),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => Text(
              '${v.round()}',
              style: const TextStyle(
                  color: _accent, fontSize: 64, fontWeight: FontWeight.bold),
            ),
          ),
          // Skaidrumas: iš kur toks skaičius (kad 0 neatrodytų klaida).
          if (r.pointsPenalty > 0) ...[
            Text('✅ +${r.pointsEarned}   💥 −${r.pointsPenalty}',
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(s.penaltyExplain,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11)),
            const SizedBox(height: 4),
          ],
          if (r.coinsEarned == 0 && r.correct > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(s.mythRewardsNote,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
            ),
          if (r.isNewRecord)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.6, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, sc, child) =>
                  Transform.scale(scale: sc, child: child),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.correct.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.correct),
                ),
                child: Text(s.blitzNewRecord,
                    style: const TextStyle(
                        color: AppColors.correct,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
            ),
          const SizedBox(height: 18),
          Row(
            children: [
              _statCard('✅', s.blitzCorrectLabel,
                  '${r.correct} / ${r.answered}'),
              const SizedBox(width: 10),
              _statCard('🔥', s.blitzBestCombo, '${r.bestCombo}'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _statCard('🪙', s.blitzCoins, '+${r.coinsEarned}'),
              const SizedBox(width: 10),
              _statCard('🔤', s.blitzLetters, '+${r.earnedLetters}'),
            ],
          ),
          const Spacer(),
          // Pagrindinis veiksmas — ŽAISTI DAR (didelis), šalia Uždaryti.
          GestureDetector(
            onTap: _load,
            child: Container(
              width: double.infinity,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.correct, width: 2),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.correct.withValues(alpha: 0.25),
                      blurRadius: 14),
                ],
              ),
              child: Text('▶ ${s.blitzPlayAgain}',
                  style: const TextStyle(
                      color: AppColors.correct,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 1.2)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => setState(() => _phase = _Phase.pick),
                child: Text('⏱ ${s.blitzChangeDuration}',
                    style: const TextStyle(color: AppColors.textSecondary)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(s.blitzClose,
                    style: const TextStyle(color: AppColors.textSecondary)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String emoji, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _accent.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
