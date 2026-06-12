import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/melt_models.dart';
import '../services/melt_api.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/neumorphic_button.dart';

/// „Raidžių tirpimas" — paslapties režimas prieš laikrodį.
///
/// VIENA DIDELĖ LENTA (be jokių iššokančių langų): žaidėjas raides iš apačios
/// dėlioja TIESIAI į lentą, kol laikrodis tiksi ir raidės tirpsta savaime.
/// Savaime atsivėrusi raidė NETRINA žaidėjo surinktų: jo įrašai saugomi pagal
/// POZICIJĄ ir RAIDĘ, o po kiekvieno atnaujinimo permetami į naują lentą.
///
/// VISA TIESA SERVERYJE: laikas, raidžių atsivėrimas ir taškai skaičiuojami
/// tik ten; čia tik gyvas laikrodis (serverio laiko poslinkis) ir lenta.
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
  bool _busy = false; // spėjimas siunčiamas
  bool _finished = false;
  int _serverOffsetMs = 0;
  DateTime? _guessLockUntil;

  /// Žaidėjo įrašytos raidės pagal KAUKĖS indeksą (pozicija tekste).
  /// Saugome RAIDĘ (ne pool indeksą) — todėl lentai atsinaujinus įrašai
  /// išlieka, net jei pool pasikeitė.
  final Map<int, String> _typed = {};

  /// Aktyvus langelis (kaukės indeksas), į kurį kris kita paspausta raidė.
  int? _cursor;

  /// Ką tik savaime atsivėrusios pozicijos — „įkritimo" animacijai.
  Set<int> _revealedNow = {};

  AppLang _appLang = AppLang.en;
  bool get _isLt => _appLang == AppLang.lt;
  String _t(String lt, String en) => _isLt ? lt : en;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _view = widget.initial;
    _serverOffsetMs =
        _view.serverNow - DateTime.now().millisecondsSinceEpoch;
    _cursor = _firstHiddenEmpty();
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
    if (state == AppLifecycleState.resumed && !_finished) _sync();
  }

  // --- Lentos pozicijos ---

  /// Visi PASLĖPTI (dar neatverti) kaukės indeksai, iš eilės.
  List<int> get _hiddenIdx => [
        for (var i = 0; i < _view.mask.length; i++)
          if (_view.mask[i].slot && _view.mask[i].ch == null) i
      ];

  int? _firstHiddenEmpty() {
    for (final i in _hiddenIdx) {
      if (!_typed.containsKey(i)) return i;
    }
    return null;
  }

  int? _nextHiddenEmptyAfter(int after) {
    final hid = _hiddenIdx;
    for (final i in hid) {
      if (i > after && !_typed.containsKey(i)) return i;
    }
    return _firstHiddenEmpty();
  }

  bool get _canGuess =>
      _hiddenIdx.isNotEmpty && _hiddenIdx.every((i) => _typed.containsKey(i));

  /// Pool naudojimo žemėlapis: kiekvienam pool indeksui — ar jis „panaudotas".
  /// Skaičiuojame pagal RAIDES: kiek kartų raidė įrašyta, tiek pool kopijų dimsta.
  List<bool> get _poolUsed {
    final need = <String, int>{};
    for (final ch in _typed.values) {
      need[ch] = (need[ch] ?? 0) + 1;
    }
    final used = List<bool>.filled(_view.pool.length, false);
    for (var i = 0; i < _view.pool.length; i++) {
      final ch = _view.pool[i];
      if ((need[ch] ?? 0) > 0) {
        used[i] = true;
        need[ch] = need[ch]! - 1;
      }
    }
    return used;
  }

  // --- Gyvas laikas (su laiko stabdymo veidrodžiu) ---

  static const _freezeMs = 30000;

  int get _nowServerMs =>
      DateTime.now().millisecondsSinceEpoch + _serverOffsetMs;

  /// Užšaldyto laiko tarpas (iki 30 s) — atimamas iš praėjusio laiko.
  int get _lockExtra => _view.lockedAt > 0
      ? (_nowServerMs - _view.lockedAt).clamp(0, _freezeMs)
      : 0;

  /// Ar laikas ŠIUO METU užšaldytas.
  bool get _frozenNow =>
      _view.lockedAt > 0 && (_nowServerMs - _view.lockedAt) < _freezeMs;

  int get _frozenLeftMs => _frozenNow
      ? _freezeMs - (_nowServerMs - _view.lockedAt)
      : 0;

  int get _elapsedMs =>
      (_nowServerMs - _view.startedAt - _lockExtra)
          .clamp(0, _view.limitSec * 1000);
  int get _remainingMs => (_view.limitSec * 1000 - _elapsedMs).clamp(0, 1 << 31);
  int get _autoCountNow =>
      math.min(_elapsedMs ~/ (_view.intervalSec * 1000), _view.totalLetters);

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
    setState(() {});
    if (_remainingMs <= 0) {
      _sync();
      return;
    }
    if (_autoCountNow > _view.autoRevealed) _sync();
  }

  /// Po lentos atnaujinimo: išvalom įrašus ant JAU ATVERTŲ pozicijų ir
  /// patikrinam, ar įrašytoms raidėms dar užtenka pool kopijų (jei raidė
  /// „ištirpo" ir jos pool'e nebėra — tą įrašą paleidžiam).
  void _applyView(MeltView v) {
    final oldMask = _view.mask;
    _view = v;
    _serverOffsetMs = v.serverNow - DateTime.now().millisecondsSinceEpoch;

    // Naujai atsivėrusios pozicijos (buvo paslėptos, dabar atvertos).
    final newly = <int>{};
    for (var i = 0; i < v.mask.length && i < oldMask.length; i++) {
      final was = oldMask[i].slot && oldMask[i].ch == null;
      final now = v.mask[i].slot && v.mask[i].ch != null;
      if (was && now) newly.add(i);
    }
    _revealedNow = newly;

    // 1) Atvertos pozicijos nebereikalingos įrašuose.
    _typed.removeWhere((i, _) => newly.contains(i) ||
        i >= v.mask.length ||
        !(v.mask[i].slot && v.mask[i].ch == null));

    // 2) Raidžių atsarga: įrašytų raidžių negali būti daugiau nei pool turi.
    final have = <String, int>{};
    for (final ch in v.pool) {
      have[ch] = (have[ch] ?? 0) + 1;
    }
    final keepOrder = _typed.keys.toList()..sort();
    for (final i in keepOrder) {
      final ch = _typed[i]!;
      if ((have[ch] ?? 0) > 0) {
        have[ch] = have[ch]! - 1;
      } else {
        _typed.remove(i); // šios raidės pool'e nebėra — paleidžiam
      }
    }

    _cursor = (_cursor != null &&
            _cursor! < v.mask.length &&
            v.mask[_cursor!].slot &&
            v.mask[_cursor!].ch == null &&
            !_typed.containsKey(_cursor!))
        ? _cursor
        : _firstHiddenEmpty();
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
      final oldOpen = _view.autoRevealed + _view.freeRevealed;
      setState(() => _applyView(s.view!));
      final nowOpen = _view.autoRevealed + _view.freeRevealed;
      if (nowOpen > oldOpen) SoundService.instance.points();
    } catch (_) {
      // tinklo trukdis — bandysime kitą ribą
    } finally {
      _syncing = false;
    }
  }

  // --- Raidžių dėliojimas (tiesiai lentoje) ---

  void _tapPool(int poolIdx) {
    if (_finished) return;
    final used = _poolUsed;
    if (poolIdx < 0 || poolIdx >= used.length || used[poolIdx]) return;
    final target = (_cursor != null && !_typed.containsKey(_cursor))
        ? _cursor!
        : _firstHiddenEmpty();
    if (target == null) return;
    SoundService.instance.tap();
    setState(() {
      _typed[target] = _view.pool[poolIdx];
      _cursor = _nextHiddenEmptyAfter(target);
    });
  }

  void _tapBlank(int maskIdx) {
    SoundService.instance.tap();
    setState(() => _cursor = maskIdx);
  }

  void _backspace() {
    if (_cursor != null && _typed.containsKey(_cursor)) {
      SoundService.instance.tap();
      setState(() => _typed.remove(_cursor));
      return;
    }
    // Trinam paskutinį (didžiausio indekso) įrašą.
    if (_typed.isEmpty) return;
    final last = (_typed.keys.toList()..sort()).last;
    SoundService.instance.tap();
    setState(() {
      _typed.remove(last);
      _cursor = last;
    });
  }

  void _clear() {
    if (_typed.isEmpty) return;
    SoundService.instance.swoosh();
    setState(() {
      _typed.clear();
      _cursor = _firstHiddenEmpty();
    });
  }

  String _buildGuess() {
    final sb = StringBuffer();
    for (var i = 0; i < _view.mask.length; i++) {
      final c = _view.mask[i];
      if (!c.slot) {
        sb.write(c.ch ?? ' ');
      } else if (c.ch != null) {
        sb.write(c.ch);
      } else {
        sb.write(_typed[i] ?? '');
      }
    }
    return sb.toString();
  }

  bool get _guessLocked =>
      _guessLockUntil != null && DateTime.now().isBefore(_guessLockUntil!);

  Future<void> _submitGuess() async {
    if (!_canGuess || _busy || _finished || _guessLocked) return;
    setState(() => _busy = true);
    try {
      final r = await MeltApi.guess(_buildGuess());
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
      SoundService.instance.wrong();
      setState(() {
        _guessLockUntil = DateTime.now()
            .add(Duration(milliseconds: math.max(r.nextGuessInMs, 1500)));
      });
      _feedback(
          _t('Ne! Laikrodis tiksi toliau…', 'No! The clock keeps ticking…'),
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
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _freeze() async {
    if (_finished || _view.freezeUsed || _busy) return;
    try {
      final s = await MeltApi.freeze();
      if (!mounted) return;
      if (s.expired) {
        _finished = true;
        SoundService.instance.wrong();
        await _showLossDialog(s.answer ?? '');
        if (mounted) Navigator.of(context).pop();
        return;
      }
      SoundService.instance.points();
      setState(() => _applyView(s.view!));
      _feedback(
          _t('❄️ Laikas sustabdytas 30 sek. — vesk ramiai!',
              '❄️ Time frozen for 30 s — type calmly!'),
          good: true);
    } catch (_) {
      if (!mounted) return;
      _feedback(_t('Nepavyko. Bandyk vėl.', 'Failed. Try again.'),
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

  // --- Dialogai / pranešimai ---

  Future<void> _showWinDialog(MeltGuessOutcome r) {
    final usedTimePct = r.limitMs > 0 ? (r.elapsedMs * 100 ~/ r.limitMs) : 0;
    final meltedPct =
        r.totalLetters > 0 ? (r.autoPenaltyCount * 100 ~/ r.totalLetters) : 0;
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
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              _t('Tavo raktų banke dabar: ${r.totalKeys} 🔑',
                  'Your key bank now holds: ${r.totalKeys} 🔑'),
              style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            ),
            Text(
              _t('(visi raktai, sukaupti per visas partijas)',
                  '(all keys earned across all games)'),
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11),
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
                      const SizedBox(height: 16),
                      _maskArea(v),
                      const SizedBox(height: 18),
                      _poolArea(v),
                      const SizedBox(height: 14),
                      _buttonsRow(),
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
    final frozen = _frozenNow;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(frozen ? _t('SUSTABDYTA', 'FROZEN') : _t('LAIKAS', 'TIME'),
                style: TextStyle(
                    color: frozen
                        ? AppColors.neonBlue
                        : AppColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 1.5)),
            Text(frozen ? '❄ $mm:$ss' : '$mm:$ss',
                style: TextStyle(
                    color: frozen
                        ? AppColors.neonBlue
                        : (urgent ? AppColors.wrong : AppColors.textPrimary),
                    fontWeight: FontWeight.bold,
                    fontSize: 26)),
          ],
        ),
        Column(
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
            Text(
                frozen
                    ? _t('ŠALDYMAS', 'FREEZE')
                    : _t('KITA RAIDĖ', 'NEXT LETTER'),
                style: TextStyle(
                    color: frozen
                        ? AppColors.neonBlue
                        : AppColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 1.5)),
            Text(
              frozen
                  ? '${(_frozenLeftMs / 1000).ceil()} s'
                  : (nextInMs > 0 ? '${(nextInMs / 1000).ceil()} s' : '—'),
              style: TextStyle(
                  color:
                      frozen ? AppColors.neonBlue : AppColors.levelMedium,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
            fontSize: 16,
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

  /// DIDELĖ interaktyvi lenta: atvertos raidės žalios, žaidėjo įrašytos —
  /// baltos ant pažymėto langelio, aktyvus langelis paryškintas.
  Widget _maskArea(MeltView v) {
    final words = <List<int>>[]; // kaukės indeksų grupės (žodžiai)
    var current = <int>[];
    for (var i = 0; i < v.mask.length; i++) {
      final c = v.mask[i];
      final isSpace = !c.slot && (c.ch == null || c.ch == ' ');
      if (isSpace) {
        if (current.isNotEmpty) words.add(current);
        current = [];
      } else {
        current.add(i);
      }
    }
    if (current.isNotEmpty) words.add(current);

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 14,
      children: [
        for (final w in words)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final i in w) _boardCell(v, i),
            ],
          ),
      ],
    );
  }

  Widget _boardCell(MeltView v, int i) {
    final c = v.mask[i];
    if (!c.slot) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: Text(c.ch ?? '',
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 21,
                fontWeight: FontWeight.bold)),
      );
    }
    if (c.ch != null) {
      // Serverio atverta raidė (žalia). Naujai atsivėrusi — „įkrenta".
      final cell = _cellBox(
        child: Text(c.ch!,
            style: const TextStyle(
                color: AppColors.correct,
                fontSize: 21,
                fontWeight: FontWeight.bold)),
        border: AppColors.correct.withValues(alpha: 0.55),
      );
      if (!_revealedNow.contains(i)) return cell;
      return TweenAnimationBuilder<double>(
        key: ValueKey('melt_reveal_$i'),
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 520),
        curve: Curves.elasticOut,
        builder: (context, t, child) {
          final clamped = t.clamp(0.0, 1.0);
          return Opacity(
            opacity: clamped,
            child: Transform.translate(
              offset: Offset(0, -18 * (1 - clamped)),
              child: Transform.scale(scale: 0.5 + 0.5 * t, child: child),
            ),
          );
        },
        child: cell,
      );
    }
    // Paslėptas langelis — žaidėjo pildomas.
    final typed = _typed[i];
    final active = _cursor == i;
    return GestureDetector(
      onTap: () => _tapBlank(i),
      child: _cellBox(
        child: Text(typed ?? '',
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 21,
                fontWeight: FontWeight.bold)),
        border: active ? _accent : _accent.withValues(alpha: 0.55),
        underline: true,
        active: active,
      ),
    );
  }

  Widget _cellBox(
      {required Widget child,
      required Color border,
      bool underline = false,
      bool active = false}) {
    return Container(
      width: 28,
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? _accent.withValues(alpha: 0.18) : null,
        border: underline
            ? Border(bottom: BorderSide(color: border, width: active ? 3 : 2))
            : Border.all(color: border, width: 1.5),
        borderRadius:
            underline ? BorderRadius.circular(5) : BorderRadius.circular(8),
      ),
      child: child,
    );
  }

  Widget _poolArea(MeltView v) {
    final used = _poolUsed;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 7,
      runSpacing: 7,
      children: [
        for (var i = 0; i < v.pool.length; i++)
          GestureDetector(
            onTap: used[i] || _finished ? null : () => _tapPool(i),
            child: AnimatedOpacity(
              opacity: used[i] ? 0.22 : 1.0,
              duration: const Duration(milliseconds: 120),
              child: Container(
                width: 40,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _accent.withValues(alpha: 0.6)),
                ),
                child: Text(v.pool[i],
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 21,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buttonsRow() {
    final ready = _canGuess && !_busy && !_finished && !_guessLocked;
    final canFreeze = !_view.freezeUsed && !_finished;
    return Row(
      children: [
        _iconBtn(Icons.backspace_outlined, _backspace),
        const SizedBox(width: 8),
        _iconBtn(Icons.clear, _clear),
        const SizedBox(width: 8),
        // ❄ VIENKARTINIS laiko stabdymas (30 s) — vesk raides be streso.
        _iconBtn(Icons.ac_unit, canFreeze ? _freeze : null,
            color: canFreeze ? AppColors.neonBlue : AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: NeumorphicButton(
            accent: ready ? AppColors.correct : AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            onTap: ready ? _submitGuess : null,
            child: Text(
              _guessLocked
                  ? _t('PALAUK…', 'WAIT…')
                  : _t('SPĖTI', 'GUESS'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ready ? AppColors.correct : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback? onTap,
      {Color color = AppColors.textSecondary}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}
