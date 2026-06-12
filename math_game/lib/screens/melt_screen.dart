import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/melt_models.dart';
import '../models/mystery_models.dart' show MysteryCell;
import '../services/melt_api.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/neumorphic_button.dart';

/// „Raidžių tirpimas" — paslapties režimas prieš laikrodį.
///
/// Raidės atsiveria SAVAIME kas pasirinktą intervalą, o laimimi taškai tirpsta
/// su laiku ir atsivėrusiomis raidėmis. Jokio banko, mokamų pagalbų ar gyvybių —
/// vienintelis priešas yra laikas. Spėjimų kiekis neribotas (su pauze po klaidos).
///
/// VISA TIESA SERVERYJE: laikas, raidžių atsivėrimas ir taškai skaičiuojami tik
/// ten; čia tik gyvas laikrodis (pagal serverio laiko poslinkį) ir lentos rodymas.
///
/// SPĖJIMO LANGAS — momentinė nuotrauka: atidarius spėjimo lapą, kaukė ir raidės
/// užfiksuojamos, todėl fone tirpstančios raidės NETRINA žaidėjo surinkto teksto.
/// Surinkta frazė vis tiek pilna, tad serveriui nesvarbu, kad lenta jau pasikeitė.
class MeltScreen extends StatefulWidget {
  final MeltView initial;
  const MeltScreen({super.key, required this.initial});

  @override
  State<MeltScreen> createState() => _MeltScreenState();
}

class _MeltScreenState extends State<MeltScreen> with WidgetsBindingObserver {
  static const _accent = AppColors.levelMedium; // geltona — laikrodžio tema

  late MeltView _view;
  Timer? _ticker;
  bool _syncing = false;
  bool _finished = false; // laimėta/pralaimėta — laikrodis stabdomas
  int _serverOffsetMs = 0; // serverNow − vietinis laikas (kosmetikai)
  DateTime? _guessLockUntil; // cooldown po klaidingo spėjimo

  AppLang _appLang = AppLang.en;
  bool get _isLt => _appLang == AppLang.lt;
  String _t(String lt, String en) => _isLt ? lt : en;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _apply(widget.initial);
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appLang = AppStrings.of(context).lang;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_finished) {
      _sync(); // grįžus į programą — perskaitom tikrą būseną iš serverio
    }
  }

  void _apply(MeltView v) {
    _view = v;
    _serverOffsetMs =
        v.serverNow - DateTime.now().millisecondsSinceEpoch;
  }

  // --- Gyvas laikas (kosmetinis; tiesa — serveryje) ---

  int get _nowServerMs =>
      DateTime.now().millisecondsSinceEpoch + _serverOffsetMs;
  int get _elapsedMs =>
      (_nowServerMs - _view.startedAt).clamp(0, _view.limitSec * 1000);
  int get _remainingMs => (_view.limitSec * 1000 - _elapsedMs).clamp(0, 1 << 31);

  /// Kiek raidžių jau TURĖTŲ būti atsivėrę pagal laiką (lokalus veidrodis).
  int get _autoCountNow =>
      math.min(_elapsedMs ~/ (_view.intervalSec * 1000), _view.totalLetters);

  /// Tirpstantys taškai DABAR (lokalus formulės veidrodis — tik rodymui).
  int get _pointsNow {
    final limitMs = _view.limitSec * 1000;
    final timeFrac = (1 - _elapsedMs / limitMs).clamp(0.0, 1.0);
    final freeSafe = math.min(_view.freeRevealed, _view.totalLetters);
    final penalty =
        math.min(_autoCountNow, math.max(0, _view.totalLetters - freeSafe));
    final letterFrac = _view.totalLetters > 0
        ? (1 - penalty / _view.totalLetters).clamp(0.0, 1.0)
        : 0.0;
    return math.max(1, (_view.pMax * timeFrac * letterFrac).round());
  }

  void _tick() {
    if (!mounted || _finished) return;
    setState(() {}); // laikrodis, taškai, juostos
    if (_remainingMs <= 0) {
      _sync(); // serveris užskaitys pralaimėjimą ir grąžins atsakymą
      return;
    }
    // Praėjo raidės riba? Lentoje matomų atvertų raidžių mažiau nei priklauso →
    // metas sinchronizuotis (atsivėrusi raidė ateis iš serverio).
    final visibleAuto = _view.autoRevealed;
    if (_autoCountNow > visibleAuto) _sync();
  }

  Future<void> _sync() async {
    if (_syncing || _finished) return;
    _syncing = true;
    try {
      final s = await MeltApi.sync();
      if (!mounted) return;
      if (s.expired) {
        _finished = true;
        SoundService.instance.wrong();
        await _showLossDialog(s.answer ?? '');
        if (mounted) Navigator.of(context).pop();
        return;
      }
      final old = _view.autoRevealed + _view.freeRevealed;
      setState(() => _apply(s.view!));
      final now = _view.autoRevealed + _view.freeRevealed;
      if (now > old) SoundService.instance.points(); // raidė „ištirpo"
    } catch (_) {
      // Tinklo trukdis — laikrodis sukasi toliau, pabandysim kitą ribą.
    } finally {
      _syncing = false;
    }
  }

  // --- Spėjimas (momentinės nuotraukos lapas) ---

  bool get _guessLocked =>
      _guessLockUntil != null && DateTime.now().isBefore(_guessLockUntil!);

  Future<void> _openGuessSheet() async {
    if (_finished || _guessLocked) return;
    final snapshot = _view; // FIKSUOJAM lentą — fonas nebepakeis lapo
    final guess = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _GuessSheet(
        mask: snapshot.mask,
        pool: snapshot.pool,
        isLt: _isLt,
      ),
    );
    if (guess == null || !mounted) return;
    await _submitGuess(guess);
  }

  Future<void> _submitGuess(String guess) async {
    try {
      final r = await MeltApi.guess(guess);
      if (!mounted) return;
      if (r.expired) {
        _finished = true;
        SoundService.instance.wrong();
        await _showLossDialog(r.answer ?? '');
        if (mounted) Navigator.of(context).pop();
        return;
      }
      if (r.correct) {
        _finished = true;
        SoundService.instance.win();
        await _showWinDialog(r);
        if (mounted) Navigator.of(context).pop();
        return;
      }
      // Klaida: laikas tiksi toliau, tik trumpa pauzė iki kito spėjimo.
      SoundService.instance.wrong();
      setState(() {
        _guessLockUntil = DateTime.now()
            .add(Duration(milliseconds: math.max(r.nextGuessInMs, 1500)));
      });
      _feedback(_t('Ne! Laikrodis tiksi toliau…', 'No! The clock keeps ticking…'),
          good: false);
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      final msg = e.code == 'resource-exhausted'
          ? _t('Palauk akimirką ir bandyk vėl.', 'Wait a moment and try again.')
          : _t('Ryšio klaida. Bandyk vėl.', 'Connection error. Try again.');
      _feedback(msg, good: false);
    } catch (_) {
      if (!mounted) return;
      _feedback(_t('Ryšio klaida. Bandyk vėl.', 'Connection error. Try again.'),
          good: false);
    }
  }

  Future<void> _abandon() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(_t('Pasiduoti?', 'Give up?'),
            style: const TextStyle(color: AppColors.textPrimary)),
        content: Text(
          _t('Taškų negausi, atsakymas bus parodytas.',
              'You will get no points; the answer will be shown.'),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(_t('Likti', 'Stay'))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(_t('Pasiduodu', 'Give up'),
                  style: const TextStyle(color: AppColors.wrong))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    _finished = true;
    final answer = await MeltApi.abandon();
    if (!mounted) return;
    await _showLossDialog(answer ?? '');
    if (mounted) Navigator.of(context).pop();
  }

  // --- Dialogai ---

  Future<void> _showWinDialog(MeltGuessOutcome r) {
    final usedTimePct = r.limitMs > 0 ? (r.elapsedMs * 100 ~/ r.limitMs) : 0;
    final meltedPct = r.totalLetters > 0
        ? (r.autoPenaltyCount * 100 ~/ r.totalLetters)
        : 0;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('🎉 ${_t('Atspėjai!', 'You got it!')}',
            style: const TextStyle(color: AppColors.correct)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((r.answer ?? '').isNotEmpty)
              Text('„${r.answer}”',
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('+${r.awarded} 🔑',
                style: const TextStyle(
                    color: AppColors.levelMedium,
                    fontWeight: FontWeight.bold,
                    fontSize: 22)),
            const SizedBox(height: 8),
            Text(
              _t('Sunaudota laiko: $usedTimePct % · ištirpo raidžių: $meltedPct %',
                  'Time used: $usedTimePct % · letters melted: $meltedPct %'),
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
            ),
            Text(
              _t('Iš viso: ${r.totalKeys} 🔑', 'Total: ${r.totalKeys} 🔑'),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(_t('Toliau', 'Next'))),
        ],
      ),
    );
  }

  Future<void> _showLossDialog(String answer) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('⏰ ${_t('Laikas baigėsi', 'Time is up')}',
            style: const TextStyle(color: AppColors.wrong)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_t('Paslaptis buvo:', 'The mystery was:'),
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            if (answer.isNotEmpty)
              Text('„$answer”',
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(_t('Gerai', 'OK'))),
        ],
      ),
    );
  }

  void _feedback(String msg, {required bool good}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(good ? Icons.check_circle : Icons.error_outline,
                color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
                child: Text(msg,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
          ],
        ),
        backgroundColor: good ? AppColors.correct : AppColors.wrong,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1800),
      ),
    );
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    final v = _view;
    final remaining = _remainingMs;
    final secs = (remaining / 1000).ceil();
    final timeFrac =
        (remaining / (v.limitSec * 1000)).clamp(0.0, 1.0).toDouble();
    final urgent = remaining <= 10000;
    final nextIn = _finished
        ? 0
        : ((_autoCountNow + 1) * v.intervalSec * 1000 - _elapsedMs)
            .clamp(0, 1 << 31);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        title: Text(_t('Raidžių tirpimas', 'Letter Melt'),
            style: const TextStyle(color: AppColors.textPrimary)),
        actions: [
          IconButton(
            tooltip: _t('Pasiduoti', 'Give up'),
            icon: const Icon(Icons.flag_outlined, color: AppColors.wrong),
            onPressed: _finished ? null : _abandon,
          ),
        ],
      ),
      body: AppBackground(
        accent: _accent,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                  child: Column(
                    children: [
                      _statusRow(secs, urgent, nextIn),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: timeFrac,
                          minHeight: 8,
                          backgroundColor: AppColors.shadowDark,
                          valueColor: AlwaysStoppedAnimation(
                              urgent ? AppColors.wrong : _accent),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _hintChip(v),
                      const SizedBox(height: 14),
                      _maskArea(v),
                      const SizedBox(height: 18),
                      NeumorphicButton(
                        accent:
                            _guessLocked ? AppColors.textSecondary : AppColors.correct,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        onTap: _finished || _guessLocked ? null : _openGuessSheet,
                        child: Text(
                          _guessLocked
                              ? _t('PALAUK…', 'WAIT…')
                              : _t('ŽINAU ATSAKYMĄ', 'I KNOW THE ANSWER'),
                          style: TextStyle(
                            color: _guessLocked
                                ? AppColors.textSecondary
                                : AppColors.correct,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
              const BannerAdWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusRow(int secs, bool urgent, int nextInMs) {
    final mm = (secs ~/ 60).toString();
    final ss = (secs % 60).toString().padLeft(2, '0');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_t('LAIKAS', 'TIME'),
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 1.5)),
            Text('$mm:$ss',
                style: TextStyle(
                    color: urgent ? AppColors.wrong : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 26)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(_t('LAIMĖSI', 'PRIZE'),
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 1.5)),
            Text('$_pointsNow 🔑',
                style: const TextStyle(
                    color: AppColors.correct,
                    fontWeight: FontWeight.bold,
                    fontSize: 26)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(_t('KITA RAIDĖ', 'NEXT LETTER'),
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 1.5)),
            Text(
              nextInMs > 0 ? '${(nextInMs / 1000).ceil()} s' : '—',
              style: const TextStyle(
                  color: AppColors.levelMedium,
                  fontWeight: FontWeight.bold,
                  fontSize: 26),
            ),
          ],
        ),
      ],
    );
  }

  Widget _hintChip(MeltView v) {
    final (emoji, label) = _categoryLabel(v.category);
    final prefix =
        v.category == 'klausimas' ? _t('Klausimas', 'Question') : label;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _accent.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$emoji  $prefix: ${v.hint}',
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600),
      ),
    );
  }

  (String, String) _categoryLabel(String c) {
    switch (c) {
      case 'patarle':
        return ('📜', _t('Patarlė', 'Proverb'));
      case 'citata':
        return ('💬', _t('Citata', 'Quote'));
      case 'istorija':
        return ('🏛️', _t('Istorija', 'History'));
      case 'klausimas':
        return ('❓', _t('Klausimas', 'Question'));
      case 'faktas':
        return ('💡', _t('Įdomus faktas', 'Fun fact'));
      default:
        return ('⏳', _t('Paslaptis', 'Mystery'));
    }
  }

  /// Lenta TIK skaitymui: atvertos raidės + brūkšneliai, žodžiai nelaužomi.
  Widget _maskArea(MeltView v) {
    final words = <List<MysteryCell>>[];
    var current = <MysteryCell>[];
    for (final c in v.mask) {
      final isSpace = !c.slot && (c.ch == null || c.ch == ' ');
      if (isSpace) {
        if (current.isNotEmpty) words.add(current);
        current = [];
      } else {
        current.add(c);
      }
    }
    if (current.isNotEmpty) words.add(current);

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final w in words)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final c in w)
                if (c.slot && c.ch != null)
                  _cellBox(
                    child: Text(c.ch!,
                        style: const TextStyle(
                            color: AppColors.correct,
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                    border: AppColors.correct.withValues(alpha: 0.5),
                  )
                else if (c.slot)
                  _cellBox(
                    child: const Text(''),
                    border: _accent.withValues(alpha: 0.6),
                    underline: true,
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Text(c.ch ?? '',
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                  ),
            ],
          ),
      ],
    );
  }

  Widget _cellBox(
      {required Widget child, required Color border, bool underline = false}) {
    return Container(
      width: 22,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: underline
            ? Border(bottom: BorderSide(color: border, width: 2))
            : Border.all(color: border, width: 1.5),
        borderRadius:
            underline ? BorderRadius.circular(4) : BorderRadius.circular(6),
      ),
      child: child,
    );
  }
}

/// Spėjimo lapas — MOMENTINĖ lentos kopija su raidžių dėliojimu.
/// Grąžina surinktą tekstą (Navigator.pop) arba null (atšaukta).
class _GuessSheet extends StatefulWidget {
  final List<MysteryCell> mask;
  final List<String> pool;
  final bool isLt;
  const _GuessSheet(
      {required this.mask, required this.pool, required this.isLt});

  @override
  State<_GuessSheet> createState() => _GuessSheetState();
}

class _GuessSheetState extends State<_GuessSheet> {
  static const _accent = AppColors.levelMedium;
  late List<int?> _slots;
  int _cursor = 0;

  String _t(String lt, String en) => widget.isLt ? lt : en;

  int get _blankCount =>
      widget.mask.where((c) => c.slot && c.ch == null).length;
  Set<int> get _usedPool => _slots.whereType<int>().toSet();
  bool get _canGuess => _blankCount > 0 && !_slots.contains(null);

  @override
  void initState() {
    super.initState();
    _slots = List<int?>.filled(_blankCount, null);
  }

  int? _firstEmptyFrom(int start) {
    for (var i = start; i < _slots.length; i++) {
      if (_slots[i] == null) return i;
    }
    for (var i = 0; i < start && i < _slots.length; i++) {
      if (_slots[i] == null) return i;
    }
    return null;
  }

  void _tapPool(int i) {
    if (_usedPool.contains(i)) return;
    final target = (_cursor < _slots.length && _slots[_cursor] == null)
        ? _cursor
        : _firstEmptyFrom(_cursor);
    if (target == null) return;
    SoundService.instance.tap();
    setState(() {
      _slots[target] = i;
      _cursor = _firstEmptyFrom(target + 1) ?? target;
    });
  }

  void _tapBlank(int b) {
    if (b < 0 || b >= _slots.length) return;
    SoundService.instance.tap();
    setState(() => _cursor = b);
  }

  void _backspace() {
    if (_cursor < _slots.length && _slots[_cursor] != null) {
      SoundService.instance.tap();
      setState(() => _slots[_cursor] = null);
      return;
    }
    for (var b = _cursor - 1; b >= 0; b--) {
      if (_slots[b] != null) {
        SoundService.instance.tap();
        setState(() {
          _slots[b] = null;
          _cursor = b;
        });
        return;
      }
    }
  }

  void _clear() {
    if (_usedPool.isEmpty) return;
    SoundService.instance.swoosh();
    setState(() {
      for (var i = 0; i < _slots.length; i++) {
        _slots[i] = null;
      }
      _cursor = 0;
    });
  }

  String _buildGuess() {
    final sb = StringBuffer();
    var blank = 0;
    for (final c in widget.mask) {
      if (!c.slot) {
        sb.write(c.ch ?? ' ');
      } else if (c.ch != null) {
        sb.write(c.ch);
      } else {
        final pi = blank < _slots.length ? _slots[blank] : null;
        if (pi != null) sb.write(widget.pool[pi]);
        blank++;
      }
    }
    return sb.toString();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom + 16;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 14, 16, bottomPad),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _t('Sudėk trūkstamas raides ir spėk!',
                  'Place the missing letters and guess!'),
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              _t('Laikrodis tiksi toliau ⏳', 'The clock keeps ticking ⏳'),
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 14),
            _sheetMask(),
            const SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var i = 0; i < widget.pool.length; i++)
                  GestureDetector(
                    onTap: _usedPool.contains(i) ? null : () => _tapPool(i),
                    child: AnimatedOpacity(
                      opacity: _usedPool.contains(i) ? 0.25 : 1.0,
                      duration: const Duration(milliseconds: 120),
                      child: Container(
                        width: 34,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: _accent.withValues(alpha: 0.6)),
                        ),
                        child: Text(widget.pool[i],
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _iconBtn(Icons.backspace_outlined, _backspace),
                const SizedBox(width: 8),
                _iconBtn(Icons.clear, _clear),
                const SizedBox(width: 8),
                Expanded(
                  child: NeumorphicButton(
                    accent:
                        _canGuess ? AppColors.correct : AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    onTap: _canGuess
                        ? () => Navigator.pop(context, _buildGuess())
                        : null,
                    child: Text(
                      _t('SPĖTI', 'GUESS'),
                      style: TextStyle(
                        color: _canGuess
                            ? AppColors.correct
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetMask() {
    final words = <List<MysteryCell>>[];
    var current = <MysteryCell>[];
    for (final c in widget.mask) {
      final isSpace = !c.slot && (c.ch == null || c.ch == ' ');
      if (isSpace) {
        if (current.isNotEmpty) words.add(current);
        current = [];
      } else {
        current.add(c);
      }
    }
    if (current.isNotEmpty) words.add(current);

    var blank = 0;
    final wordWidgets = <Widget>[];
    for (final w in words) {
      final cells = <Widget>[];
      for (final c in w) {
        if (c.slot && c.ch == null) {
          final pi = blank < _slots.length ? _slots[blank] : null;
          final filled = pi != null ? widget.pool[pi] : null;
          final b = blank;
          final active = b == _cursor;
          cells.add(GestureDetector(
            onTap: () => _tapBlank(b),
            child: Container(
              width: 22,
              height: 30,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? _accent.withValues(alpha: 0.18) : null,
                border: Border(
                    bottom: BorderSide(
                        color: active ? _accent : _accent.withValues(alpha: 0.6),
                        width: active ? 3 : 2)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(filled ?? '',
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.bold)),
            ),
          ));
          blank++;
        } else if (c.slot) {
          cells.add(Container(
            width: 22,
            height: 30,
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                  color: AppColors.correct.withValues(alpha: 0.5), width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(c.ch!,
                style: const TextStyle(
                    color: AppColors.correct,
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
          ));
        } else {
          cells.add(Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Text(c.ch ?? '',
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
          ));
        }
      }
      wordWidgets.add(Row(mainAxisSize: MainAxisSize.min, children: cells));
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: wordWidgets,
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.textSecondary.withValues(alpha: 0.5)),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 22),
      ),
    );
  }
}
