import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_strings.dart';
import '../models/game_models.dart';
import '../models/myth_models.dart';
import '../services/game_api.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/banner_ad_widget.dart';

/// 🧐 „TIESA AR MITAS?" — mūsų paruošti teiginiai su paaiškinimais.
///
/// Žaidėjas skaito teiginį ir sprendžia: ✅ TIESA ar ❌ MITAS. Po atsakymo —
/// trumpas paaiškinimas KODĖL (mokomasis „oho" efektas), tada „Toliau".
/// SAVO TEMPU (be laikmačio ekrane), bet greitesnis atsakymas = daugiau
/// taškų (serveris skaičiuoja pagal laiką per esamą submitScore).
class MythGameScreen extends StatefulWidget {
  const MythGameScreen({super.key});

  @override
  State<MythGameScreen> createState() => _MythGameScreenState();
}

enum _Phase { pick, loading, error, playing, submitting }

class _MythGameScreenState extends State<MythGameScreen> {
  static const _accent = AppColors.neonBlue; // 🧐 mėlyna „tyrimo" tema

  _Phase _phase = _Phase.pick;
  String _level = 'lengvas';
  MythSession? _session;

  int _idx = 0;
  bool? _picked; // žaidėjo pasirinkimas šiam teiginiui (null — dar nespausta)
  final List<bool> _answers = [];
  final List<bool> _results = []; // ar i-tas atsakymas teisingas (taškučiams)
  final List<int> _times = [];
  int _correctSoFar = 0;
  int _streak = 0; // teisingų iš eilės — 🔥 serijai
  DateTime _qStart = DateTime.now();

  AppLang _appLang = AppLang.en;
  bool get _isLt => _appLang == AppLang.lt;
  String _t(String lt, String en) => _isLt ? lt : en;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appLang = AppStrings.of(context).lang;
  }

  Future<void> _start() async {
    setState(() {
      _phase = _Phase.loading;
      _idx = 0;
      _picked = null;
      _answers.clear();
      _results.clear();
      _times.clear();
      _correctSoFar = 0;
      _streak = 0;
    });
    try {
      final lang = _isLt ? 'lt' : 'en';
      final s = await GameApi.startMythGame('myth_$_level', lang);
      if (!mounted) return;
      if (s.statements.isEmpty) {
        setState(() => _phase = _Phase.error);
        return;
      }
      SoundService.instance.swoosh();
      setState(() {
        _session = s;
        _phase = _Phase.playing;
        _qStart = DateTime.now();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _phase = _Phase.error);
    }
  }

  void _answer(bool val) {
    if (_phase != _Phase.playing || _picked != null) return;
    final st = _session!.statements[_idx];
    final ok = st.isTrue == val;
    _answers.add(val);
    _results.add(ok);
    _times.add(DateTime.now().difference(_qStart).inMilliseconds);
    if (ok) {
      _correctSoFar++;
      _streak++;
      HapticFeedback.lightImpact();
      SoundService.instance.correct();
    } else {
      _streak = 0;
      HapticFeedback.heavyImpact();
      SoundService.instance.wrong();
    }
    setState(() => _picked = val);
  }

  /// Detektyvinis titulas pagal rezultatą — smagi staigmena pabaigoje.
  (String, String) _rankFor(int correct, int total) {
    final frac = total > 0 ? correct / total : 0.0;
    if (frac >= 1.0) {
      return ('🏆', _t('Mitų griovėjas!', 'Mythbuster!'));
    } else if (frac >= 0.8) {
      return ('🥇', _t('Faktų medžiotojas', 'Fact hunter'));
    } else if (frac >= 0.6) {
      return ('🥈', _t('Tiesos sekėjas', 'Truth seeker'));
    } else if (frac >= 0.4) {
      return ('🥉', _t('Smalsuolis', 'Curious mind'));
    }
    return ('🔎', _t('Pradedantis tyrėjas', 'Rookie investigator'));
  }

  Future<void> _next() async {
    if (_picked == null) return;
    if (_idx + 1 < _session!.statements.length) {
      SoundService.instance.tap();
      setState(() {
        _idx++;
        _picked = null;
        _qStart = DateTime.now();
      });
      return;
    }
    // Partija baigta — atsiskaitymas serveryje.
    setState(() => _phase = _Phase.submitting);
    try {
      final r =
          await GameApi.submitMythScore(_session!.gameId, _answers, _times);
      if (!mounted) return;
      if (r.isNewRecord) SoundService.instance.win();
      await _showResultDialog(r);
    } catch (_) {
      if (!mounted) return;
      _feedbackError();
    }
    if (mounted) setState(() => _phase = _Phase.pick);
  }

  void _feedbackError() {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
            _t('Ryšio klaida — taškai neįskaityti.',
                'Connection error — score not counted.'),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.wrong,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showResultDialog(GameResult r) async {
    final total = _session!.statements.length;
    final (rankEmoji, rankTitle) = _rankFor(r.correct, total);
    final again = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Column(
            children: [
              // Titulas „iššoka" — smagi pabaigos staigmena.
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.3, end: 1),
                duration: const Duration(milliseconds: 550),
                curve: Curves.elasticOut,
                builder: (context, sc, child) =>
                    Transform.scale(scale: sc, child: child),
                child:
                    Text(rankEmoji, style: const TextStyle(fontSize: 46)),
              ),
              const SizedBox(height: 4),
              Text(rankTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${r.finalScore}',
                  style: const TextStyle(
                      color: _accent,
                      fontSize: 42,
                      fontWeight: FontWeight.bold)),
              // Skaidrumas: iš kur toks skaičius (kad 0 neatrodytų klaida).
              if (r.pointsPenalty > 0) ...[
                const SizedBox(height: 4),
                Text('✅ +${r.pointsEarned}   💥 −${r.pointsPenalty}',
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                Text(
                  _t('Kiekviena klaida nubraukia 60 taškų',
                      'Each mistake deducts 60 points'),
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
              if (r.coinsEarned == 0 && r.correct > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _t('🪙 Monetos — kai teisingų daugiau nei klaidų',
                        '🪙 Coins — when correct outnumber mistakes'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11),
                  ),
                ),
              if (r.isNewRecord)
                Text(_t('🏆 Naujas rekordas!', '🏆 New record!'),
                    style: const TextStyle(
                        color: AppColors.correct,
                        fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // Atsakymų „egzamino lapas" — žali/raudoni taškučiai.
              Wrap(
                spacing: 5,
                children: [
                  for (final ok in _results)
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (ok ? AppColors.correct : AppColors.wrong)
                            .withValues(alpha: 0.85),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text('${_t('Teisingi', 'Correct')}: ${r.correct} / $total',
                  style: const TextStyle(color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text('+${r.coinsEarned} 🪙   +${r.earnedLetters} 🔤',
                  style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(_t('Uždaryti', 'Close'))),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(_t('Žaisti dar', 'Play again'),
                    style: const TextStyle(
                        color: AppColors.correct,
                        fontWeight: FontWeight.bold))),
          ],
        );
      },
    );
    if (!mounted) return;
    if (again == true) _start();
  }

  // ── UI ──

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        title: Text('🧐 ${s.categoryMyth}',
            style: const TextStyle(color: AppColors.textPrimary)),
      ),
      body: AppBackground(
        accent: _accent,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(child: _body()),
              const BannerAdWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    switch (_phase) {
      case _Phase.pick:
        return _pickView();
      case _Phase.loading:
      case _Phase.submitting:
        return const Center(child: CircularProgressIndicator(color: _accent));
      case _Phase.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppStrings.of(context).natureLoadError,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                TextButton(
                    onPressed: _start,
                    child: Text(AppStrings.of(context).retry)),
              ],
            ),
          ),
        );
      case _Phase.playing:
        return _gameView();
    }
  }

  Widget _pickView() {
    final levels = [
      ('lengvas', '🟢', _t('Lengvas', 'Easy')),
      ('vidutinis', '🟡', _t('Vidutinis', 'Medium')),
      ('sunkus', '🟠', _t('Sunkus', 'Hard')),
      ('ekstremalus', '🔴', _t('Ekstremalus', 'Extreme')),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Column(
        children: [
          const Text('🧐', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 6),
          Text(
            _t('Tiesa ar mitas? Spręsk pats!', 'Fact or myth? You decide!'),
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                letterSpacing: 1.1),
          ),
          const SizedBox(height: 4),
          Text(
            _t('10 teiginių · po atsakymo sužinosi KODĖL · greitas atsakymas = daugiau taškų · klaida = −60',
                '10 statements · learn WHY after each answer · fast answer = more points · mistake = −60'),
            textAlign: TextAlign.center,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final (code, emoji, name) in levels)
                GestureDetector(
                  onTap: () {
                    SoundService.instance.tap();
                    setState(() => _level = code);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _level == code
                          ? _accent.withValues(alpha: 0.18)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: _level == code
                              ? _accent
                              : AppColors.textSecondary
                                  .withValues(alpha: 0.5),
                          width: _level == code ? 2 : 1.2),
                    ),
                    child: Text('$emoji $name',
                        style: TextStyle(
                            color: _level == code
                                ? _accent
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () {
              SoundService.instance.tap();
              _start();
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
              child: Text('▶ ${_t('PRADĖTI', 'START')}',
                  style: const TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      letterSpacing: 1.4)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gameView() {
    final st = _session!.statements[_idx];
    final total = _session!.statements.length;
    final answered = _picked != null;
    final ok = answered && _picked == st.isTrue;
    final verdictColor = st.isTrue ? AppColors.correct : AppColors.wrong;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Column(
        children: [
          // Viršus: progresas · 🔥 serija · teisingi.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_idx + 1} / $total',
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              AnimatedScale(
                scale: _streak >= 2 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.correct.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.correct.withValues(alpha: 0.7)),
                  ),
                  child: Text('🔥 $_streak ${_t('iš eilės', 'in a row')}',
                      style: const TextStyle(
                          color: AppColors.correct,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ),
              ),
              Text('✅ $_correctSoFar',
                  style: const TextStyle(
                      color: AppColors.correct,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          // „Egzamino lapas" — 10 taškučių (žalias/raudonas/aktyvus/būsimi).
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < total; i++)
                Container(
                  width: i == _idx && !answered ? 16 : 12,
                  height: i == _idx && !answered ? 16 : 12,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _results.length
                        ? (_results[i] ? AppColors.correct : AppColors.wrong)
                        : (i == _idx
                            ? _accent.withValues(alpha: 0.9)
                            : AppColors.shadowDark),
                    border: i == _idx && !answered
                        ? Border.all(color: _accent, width: 2)
                        : null,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Teiginio kortelė: didelis subjekto emoji + tekstas + antspaudas.
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: answered
                      ? verdictColor.withValues(alpha: 0.85)
                      : _accent.withValues(alpha: 0.5),
                  width: answered ? 2.2 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                      color: (answered ? verdictColor : _accent)
                          .withValues(alpha: 0.14),
                      blurRadius: 18,
                      spreadRadius: 2),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Subjekto emoji fone — didelis, vos matomas.
                    Positioned(
                      right: -18,
                      bottom: -22,
                      child: Opacity(
                        opacity: 0.08,
                        child: Text(st.emoji.isNotEmpty ? st.emoji : '🧐',
                            style: const TextStyle(fontSize: 150)),
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          // Didelis subjekto paveikslėlis — kortelė gyva.
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(
                                    scale: anim,
                                    child: FadeTransition(
                                        opacity: anim, child: child)),
                            child: Text(
                              st.emoji.isNotEmpty ? st.emoji : '🧐',
                              key: ValueKey(_idx),
                              style: const TextStyle(fontSize: 64),
                            ),
                          ),
                          const SizedBox(height: 12),
                          AutoSizeText(
                            st.st,
                            maxLines: 5,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 23,
                                height: 1.3,
                                fontWeight: FontWeight.w600),
                          ),
                          // VERDIKTO ANTSPAUDAS + paaiškinimo kortelė.
                          if (answered) ...[
                            const SizedBox(height: 14),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 360),
                              curve: Curves.elasticOut,
                              builder: (context, t, child) =>
                                  Transform.rotate(
                                angle: -0.10 * t,
                                child: Transform.scale(
                                    scale: 0.4 + 1.2 * t - 0.6 * t * t,
                                    child: child),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 8),
                                decoration: BoxDecoration(
                                  color:
                                      verdictColor.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: verdictColor, width: 2.5),
                                ),
                                child: Text(
                                  st.isTrue
                                      ? '✅ ${_t('TIESA', 'FACT')}'
                                      : '❌ ${_t('MITAS', 'MYTH')}',
                                  style: TextStyle(
                                      color: verdictColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      letterSpacing: 1.5),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              ok
                                  ? _t('Atspėjai! 🎯', 'You got it! 🎯')
                                  : _t('Nepavyko 😅  −60 taškų',
                                      'Not this time 😅  −60 points'),
                              style: TextStyle(
                                  color: ok
                                      ? AppColors.correct
                                      : AppColors.wrong,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _accent.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color:
                                        _accent.withValues(alpha: 0.35)),
                              ),
                              child: Text(
                                '💡 ${st.ex}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14.5,
                                    height: 1.35),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Mygtukai: prieš atsakymą — MITAS/TIESA; po — TOLIAU.
          if (!answered)
            Row(
              children: [
                Expanded(
                    child: _bigBtn('❌ ${_t('MITAS', 'MYTH')}',
                        AppColors.wrong, () => _answer(false))),
                const SizedBox(width: 12),
                Expanded(
                    child: _bigBtn('✅ ${_t('TIESA', 'FACT')}',
                        AppColors.correct, () => _answer(true))),
              ],
            )
          else
            _bigBtn(
                _idx + 1 < total
                    ? '${_t('TOLIAU', 'NEXT')} ▶'
                    : '🏁 ${_t('BAIGTI', 'FINISH')}',
                _accent,
                _next),
        ],
      ),
    );
  }

  Widget _bigBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 76,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.22), blurRadius: 14),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 1.2),
        ),
      ),
    );
  }
}
