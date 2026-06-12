import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../l10n/app_strings.dart';
import '../models/detective_models.dart';
import '../services/detective_api.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/neumorphic_button.dart';

/// 🕵️ DETEKTYVAS v2 — slaptas žodis + perkamų klausimų turgus + laikrodis.
///
/// SAVININKO SPEC: laikas tiksi NUOLAT (laimėjimas = bankas − pirkimai −
/// laikas×koef, bet niekada < minAward); atsakymai TAIP / NE / „TAIP, BET…"
/// su paaiškinimu; 3 gyvybės 🔍; likus 1 — SOS mįslė; spėjimas ✍️ tekstu
/// (premija ×1,25) arba 🎯 „įtariamųjų lentoje" (30 kortelių, braukai
/// netinkamus, ilgu paspaudimu KALTINI).
///
/// VISA TIESA SERVERYJE: žodis, atsakymai, bankas, gyvybės ir laikas — tik ten.
class DetectiveScreen extends StatefulWidget {
  /// DU ATSKIRI ŽAIDIMAI (savininko sprendimas): 2 — 🕵️ įtariamųjų lenta
  /// (be rašymo), 1 — ✍️ PRO: žodį rašai pats, be pasiūlymų (+25 %).
  final int variant;
  const DetectiveScreen({super.key, this.variant = 2});

  @override
  State<DetectiveScreen> createState() => _DetectiveScreenState();
}

enum _Phase { levelSelect, loading, playing }

class _DetectiveScreenState extends State<DetectiveScreen> {
  static const _accent = AppColors.correct; // 🕵️ žalia „bylos" tema

  _Phase _phase = _Phase.levelSelect;
  DetectiveView? _view;
  bool _busy = false;
  int? _buyingI; // kurios užuominos pirkimas keliauja į serverį (suktukui)
  bool _finished = false;

  /// Žaidėjo įrašytos raidės pagal kaukės indeksą (✍️ variantas).
  final Map<int, String> _typed = {};
  int? _cursor;

  /// 🎯 lentos būsena: žaidėjo išbrauktos kortelės (TIK kosmetika, kliente).
  final Set<int> _eliminated = {};

  /// Ar tai ✍️ PRO žaidimas (rašymas be pasiūlymų) — pagal serverio būseną.
  bool get _typingMode => (_view?.variant ?? widget.variant) == 1;

  String? _sosText; // nupirkta SOS mįslė
  bool _sosAvailable = false;

  Timer? _ticker; // gyvas taksometras (1 s)
  int _serverOffsetMs = 0;

  /// SPĖJIMO LANGO veidrodis (tiesa serveryje): SPĖTI sustabdo laiką
  /// 1 minutei raidėms suvesti.
  int _lockedAt = 0; // 0 — langas neatidarytas
  int _lockMsUsed = 0;

  AppLang _appLang = AppLang.en;
  bool get _isLt => _appLang == AppLang.lt;
  String _t(String lt, String en) => _isLt ? lt : en;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _phase == _Phase.playing && !_finished) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appLang = AppStrings.of(context).lang;
  }

  // ── Gyvas laikrodis (serverio laiko veidrodis) ──

  int get _nowServerMs =>
      DateTime.now().millisecondsSinceEpoch + _serverOffsetMs;

  int get _windowMs => _view?.guessWindowMs ?? 60000;
  int get _activeLockMs =>
      _lockedAt > 0 ? (_nowServerMs - _lockedAt).clamp(0, _windowMs) : 0;
  bool get _frozenNow =>
      _lockedAt > 0 && (_nowServerMs - _lockedAt) < _windowMs;
  int get _frozenLeftMs =>
      _frozenNow ? _windowMs - (_nowServerMs - _lockedAt) : 0;

  /// Kiek laimėtų atspėjęs DABAR (savininko formulė su grindimis).
  /// Spėjimo lango laikas NESKAIČIUOJAMAS (laikrodis sustojęs).
  int get _potentialNow {
    final v = _view;
    if (v == null) return 0;
    final elapsedMs =
        (_nowServerMs - v.startedAt - _lockMsUsed - _activeLockMs)
            .clamp(0, 1 << 62);
    final raw = v.bank - (elapsedMs ~/ 1000) * v.timeCoef;
    return raw < v.minAward ? v.minAward : raw;
  }

  // ── Lentos pozicijos (✍️ variantas — kaip tirpime) ──

  List<int> get _hiddenIdx => [
        for (var i = 0; i < (_view?.mask.length ?? 0); i++)
          if (_view!.mask[i].slot && _view!.mask[i].ch == null) i
      ];

  int? _firstEmpty() {
    for (final i in _hiddenIdx) {
      if (!_typed.containsKey(i)) return i;
    }
    return null;
  }

  int? _nextEmptyAfter(int after) {
    for (final i in _hiddenIdx) {
      if (i > after && !_typed.containsKey(i)) return i;
    }
    return _firstEmpty();
  }

  bool get _canGuess =>
      _hiddenIdx.isNotEmpty && _hiddenIdx.every((i) => _typed.containsKey(i));

  List<bool> get _poolUsed {
    final need = <String, int>{};
    for (final ch in _typed.values) {
      need[ch] = (need[ch] ?? 0) + 1;
    }
    final used = List<bool>.filled(_view?.pool.length ?? 0, false);
    for (var i = 0; i < used.length; i++) {
      final ch = _view!.pool[i];
      if ((need[ch] ?? 0) > 0) {
        used[i] = true;
        need[ch] = need[ch]! - 1;
      }
    }
    return used;
  }

  String _buildGuess() {
    final sb = StringBuffer();
    for (var i = 0; i < _view!.mask.length; i++) {
      final c = _view!.mask[i];
      if (!c.slot) {
        sb.write(c.ch ?? ' ');
      } else {
        sb.write(_typed[i] ?? '');
      }
    }
    return sb.toString();
  }

  // ── Veiksmai ──

  Future<void> _start(int level) async {
    setState(() {
      _phase = _Phase.loading;
      _finished = false;
      _typed.clear();
      _cursor = null;
      _eliminated.clear();
      _sosText = null;
      _sosAvailable = false;
    });
    try {
      final lang = _isLt ? 'lt' : 'en';
      final v = await DetectiveApi.start(lang, level, widget.variant);
      if (!mounted) return;
      SoundService.instance.swoosh();
      setState(() {
        _view = v;
        _serverOffsetMs =
            v.serverNow - DateTime.now().millisecondsSinceEpoch;
        _sosAvailable = v.sosAvailable;
        _sosText = v.sosText;
        _lockedAt = v.lockedAt;
        _lockMsUsed = v.lockMsUsed;
        _phase = _Phase.playing;
        _cursor = _firstEmpty();
      });
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      setState(() => _phase = _Phase.levelSelect);
      _feedback(
          e.code == 'resource-exhausted'
              ? _t('Šiandienos nemokamos bylos baigtos — grįžk rytoj!',
                  'Today\'s free cases are done — come back tomorrow!')
              : e.code == 'failed-precondition'
                  ? _t('Šio lygio bylos kol kas išspręstos — netrukus naujų!',
                      'This level\'s cases are solved — new ones soon!')
                  : _t('Ryšio klaida. Bandyk vėl.',
                      'Connection error. Try again.'),
          good: false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _phase = _Phase.levelSelect);
      _feedback(_t('Ryšio klaida. Bandyk vėl.', 'Connection error. Try again.'),
          good: false);
    }
  }

  Future<void> _buy(DetectiveClue c) async {
    if (_busy || c.bought) return;
    final price = _view!.prices[c.t] ?? 0;
    if (_view!.bank - price < _view!.floor) {
      _feedback(
          _t('Banke per mažai — spėk iš to, ką žinai!',
              'Bank too low — guess from what you know!'),
          good: false);
      return;
    }
    // Momentinis atsakas: garsas ir suktukas IŠKART, dar prieš serverį.
    SoundService.instance.tap();
    setState(() {
      _busy = true;
      _buyingI = c.i;
    });
    try {
      final r = await DetectiveApi.buyClue(c.i);
      if (!mounted) return;
      SoundService.instance.points();
      setState(() {
        final qs = _view!.questions
            .map((q) => q.i == r.i ? q.withAnswer(r.ans, r.note) : q)
            .toList();
        _view = _view!.copyWith(bank: r.bank, questions: qs);
        // Pirkimas uždaro spėjimo langą serveryje — atspindime ir čia.
        if (_lockedAt > 0) {
          _lockMsUsed += _activeLockMs;
          _lockedAt = 0;
        }
      });
    } catch (_) {
      if (!mounted) return;
      _feedback(_t('Nepavyko. Bandyk vėl.', 'Failed. Try again.'),
          good: false);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _buyingI = null;
        });
      }
    }
  }

  Future<void> _buySos() async {
    if (_busy || _sosText != null) return;
    SoundService.instance.tap();
    setState(() => _busy = true);
    try {
      final r = await DetectiveApi.buySos();
      if (!mounted) return;
      SoundService.instance.points();
      setState(() {
        _sosText = r.sos;
        _sosAvailable = false;
        _view = _view!.copyWith(bank: r.bank, sosText: r.sos);
        // Pirkimas uždaro spėjimo langą serveryje — atspindime ir čia.
        if (_lockedAt > 0) {
          _lockMsUsed += _activeLockMs;
          _lockedAt = 0;
        }
      });
    } catch (_) {
      if (!mounted) return;
      _feedback(_t('Nepavyko. Bandyk vėl.', 'Failed. Try again.'),
          good: false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _handleOutcome(DetectiveGuessOutcome r,
      {int? pickedIdx}) async {
    if (r.correct) {
      _finished = true;
      SoundService.instance.win();
      await _showWinDialog(r);
      if (mounted) setState(() => _phase = _Phase.levelSelect);
      return;
    }
    if (r.dead) {
      _finished = true;
      SoundService.instance.wrong();
      await _showCaseEndDialog(
          title: '💥 ${_t('Byla žlugo', 'Case failed')}',
          titleColor: AppColors.wrong,
          word: r.word ?? '',
          answers: r.answers);
      if (mounted) setState(() => _phase = _Phase.levelSelect);
      return;
    }
    SoundService.instance.wrong();
    setState(() {
      _view = _view!.copyWith(lives: r.lives);
      _sosAvailable = r.sosAvailable;
      _typed.clear();
      _cursor = _firstEmpty();
      // Klaida uždarė spėjimo langą serveryje — sinchronizuojam veidrodį.
      _lockedAt = 0;
      _lockMsUsed = r.lockMsUsed;
      if (pickedIdx != null) _eliminated.add(pickedIdx); // kortelė „sudegė"
    });
    _feedback(
        _t('Ne! Liko ${r.lives} 🔍', 'No! ${r.lives} 🔍 left'),
        good: false);
  }

  /// SPĖJIMO LANGAS: paspaudus SPĖTI laikas SUSTOJA 1 min raidėms suvesti.
  Future<void> _openGuessWindow() async {
    setState(() => _busy = true);
    try {
      final v = await DetectiveApi.openGuessWindow();
      if (!mounted) return;
      setState(() {
        _view = v;
        _serverOffsetMs =
            v.serverNow - DateTime.now().millisecondsSinceEpoch;
        _lockedAt = v.lockedAt;
        _lockMsUsed = v.lockMsUsed;
        _sosAvailable = v.sosAvailable;
        _sosText = v.sosText ?? _sosText;
        _cursor = _firstEmpty();
      });
      if (_frozenNow) {
        SoundService.instance.points();
        _feedback(
            _t('⏸ Laikas sustojo 1 min — suvesk raides ir spausk SPĖTI!',
                '⏸ Time paused for 1 min — type the letters and press GUESS!'),
            good: true);
      } else {
        _feedback(
            _t('Stabdymai išnaudoti — laikas tiksi! Suvesk ir spausk SPĖTI.',
                'No pauses left — the clock is ticking! Type and press GUESS.'),
            good: false);
      }
    } catch (_) {
      if (!mounted) return;
      _feedback(_t('Nepavyko. Bandyk vėl.', 'Failed. Try again.'),
          good: false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitTyped() async {
    if (_busy || _finished) return;
    // Mygtukas spaudžiamas VISADA: neužpildyta + langas neatidarytas →
    // SUSTABDOM LAIKĄ (1 min suvedimui); langas jau atidarytas → priminimas.
    if (!_canGuess) {
      if (_frozenNow) {
        SoundService.instance.tap();
        setState(() => _cursor = _firstEmpty());
        _feedback(
            _t('Užpildyk visus langelius raidėmis ir spausk dar kartą!',
                'Fill in all the boxes with letters, then press again!'),
            good: false);
        return;
      }
      await _openGuessWindow();
      return;
    }
    setState(() => _busy = true);
    try {
      final r = await DetectiveApi.guess(_buildGuess());
      if (!mounted) return;
      await _handleOutcome(r);
    } catch (_) {
      if (!mounted) return;
      _feedback(_t('Ryšio klaida. Bandyk vėl.', 'Connection error. Try again.'),
          good: false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Paspaudus kortelę — aiškus pasirinkimas: KALTINTI ar išbraukti.
  Future<void> _cardAction(int idx) async {
    final v = _view!;
    final emoji = v.boardEmoji.length > idx ? v.boardEmoji[idx] : '🎯';
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('$emoji ${v.board[idx]}',
            style: const TextStyle(color: AppColors.textPrimary)),
        content: Text(
          _t('Kaltinti šitą įtariamąjį? Klaida kainuos 1 🔍',
              'Accuse this suspect? A mistake costs 1 🔍'),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, 'cancel'),
              child: Text(_t('Atšaukti', 'Cancel'))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, 'eliminate'),
              child: Text('❌ ${_t('Išbraukti', 'Cross out')}',
                  style: const TextStyle(color: AppColors.textSecondary))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, 'accuse'),
              child: Text('🎯 ${_t('KALTINU!', 'ACCUSE!')}',
                  style: const TextStyle(
                      color: AppColors.wrong, fontWeight: FontWeight.bold))),
        ],
      ),
    );
    if (!mounted) return;
    if (action == 'eliminate') {
      SoundService.instance.tap();
      setState(() => _eliminated.add(idx));
      return;
    }
    if (action == 'accuse') await _accuse(idx, confirm: false);
  }

  Future<void> _accuse(int idx, {bool confirm = true}) async {
    if (_busy || _finished) return;
    final v = _view!;
    if (confirm) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
              '${v.boardEmoji.length > idx ? v.boardEmoji[idx] : '🎯'} '
              '${v.board[idx]}',
              style: const TextStyle(color: AppColors.textPrimary)),
          content: Text(
            _t('Kaltinti ŠITĄ? Klaida kainuos 1 🔍',
                'Accuse THIS one? A mistake costs 1 🔍'),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(_t('Dar galvoju', 'Still thinking'))),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(_t('KALTINU!', 'ACCUSE!'),
                    style: const TextStyle(
                        color: AppColors.wrong,
                        fontWeight: FontWeight.bold))),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }
    setState(() => _busy = true);
    try {
      final r = await DetectiveApi.pick(idx);
      if (!mounted) return;
      await _handleOutcome(r, pickedIdx: idx);
    } catch (_) {
      if (!mounted) return;
      _feedback(_t('Ryšio klaida. Bandyk vėl.', 'Connection error. Try again.'),
          good: false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _abandon() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(_t('Uždaryti bylą?', 'Close the case?'),
            style: const TextStyle(color: AppColors.textPrimary)),
        content: Text(
          _t('Žodis bus parodytas, bet 🔑 negausi. Byla perdega.',
              'The word will be revealed, but you get no 🔑. The case burns.'),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(_t('Likti', 'Stay'))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(_t('Uždaryti bylą', 'Close case'),
                  style: const TextStyle(color: AppColors.wrong))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    _finished = true;
    final word = await DetectiveApi.abandon();
    if (!mounted) return;
    await _showCaseEndDialog(
        title: '📁 ${_t('Byla uždaryta', 'Case closed')}',
        titleColor: AppColors.textSecondary,
        word: word ?? '',
        answers: const []);
    if (mounted) setState(() => _phase = _Phase.levelSelect);
  }

  // ── Dialogai ──

  String _rankLabel(int rank) {
    switch (rank) {
      case 1:
        return '🥇 ${_t('Šerlokas', 'Sherlock')}';
      case 2:
        return '🥈 ${_t('Inspektorius', 'Inspector')}';
      default:
        return '🥉 ${_t('Naujokas', 'Rookie')}';
    }
  }

  Widget _answersList(List<DetectiveAnswer> answers) {
    if (answers.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      width: double.maxFinite,
      height: 220,
      child: ListView.builder(
        itemCount: answers.length,
        itemBuilder: (ctx, i) {
          final a = answers[i];
          final (chip, color) = switch (a.ans) {
            'y' => ('✓', AppColors.correct),
            'b' => ('⚠', AppColors.levelMedium),
            _ => ('✗', AppColors.wrong),
          };
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(chip,
                    style: TextStyle(
                        color: color, fontWeight: FontWeight.bold)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    a.note == null ? a.q : '${a.q}\n${a.note}',
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.25),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showWinDialog(DetectiveGuessOutcome r) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('🎉 ${_t('Byla išspręsta!', 'Case solved!')}',
            style: const TextStyle(color: AppColors.correct)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('„${r.word}”',
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('+${r.awarded} 🔑',
                style: const TextStyle(
                    color: AppColors.levelMedium,
                    fontWeight: FontWeight.bold,
                    fontSize: 24)),
            const SizedBox(height: 4),
            Text(_rankLabel(r.rank),
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
            const SizedBox(height: 6),
            Text(
              _t(
                  'Užuominų pirkta: ${r.boughtCount} · laikas: ${r.elapsedSec}s '
                  '(−${r.timePenalty})${r.typedBonus ? ' · ✍️ ×1,25' : ''}',
                  'Clues bought: ${r.boughtCount} · time: ${r.elapsedSec}s '
                  '(−${r.timePenalty})${r.typedBonus ? ' · ✍️ ×1.25' : ''}'),
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
            ),
            Text(
              _t('Raktų banke dabar: ${r.totalKeys} 🔑',
                  'Your key bank now: ${r.totalKeys} 🔑'),
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Text(_t('Visi atsakymai:', 'All answers:'),
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
            const SizedBox(height: 6),
            _answersList(r.answers),
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

  Future<void> _showCaseEndDialog({
    required String title,
    required Color titleColor,
    required String word,
    required List<DetectiveAnswer> answers,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(title, style: TextStyle(color: titleColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_t('Slaptas žodis buvo:', 'The secret word was:'),
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            if (word.isNotEmpty)
              Text('„$word”',
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            if (answers.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(_t('Visi atsakymai:', 'All answers:'),
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
              const SizedBox(height: 6),
              _answersList(answers),
            ],
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
        duration: const Duration(milliseconds: 2200),
      ),
    );
  }

  // ── UI ──

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        title: Text(
            widget.variant == 1
                ? '✍️ ${_t('Detektyvas PRO', 'Detective PRO')}'
                : '🕵️ ${_t('Detektyvas', 'Detective')}',
            style: const TextStyle(color: AppColors.textPrimary)),
        actions: [
          if (_phase == _Phase.playing)
            IconButton(
              tooltip: _t('Uždaryti bylą', 'Close case'),
              icon: const Icon(Icons.folder_off_outlined,
                  color: AppColors.wrong),
              onPressed: _abandon,
            ),
        ],
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
      case _Phase.levelSelect:
        return _levelSelect();
      case _Phase.loading:
        return const Center(child: CircularProgressIndicator(color: _accent));
      case _Phase.playing:
        return _caseView();
    }
  }

  Widget _levelSelect() {
    final levels = [
      (1, '🟢', _t('Naujokas', 'Rookie'),
          _t('Lengvos bylos — atspės ir vaikas', 'Easy cases — even kids can crack them'), 1),
      (2, '🟡', _t('Seklys', 'Sleuth'),
          _t('Reikia šiek tiek nuovokos', 'Takes a bit of wit'), 2),
      (3, '🟠', _t('Inspektorius', 'Inspector'),
          _t('Rimtos bylos patyrusiems', 'Serious cases for the experienced'), 3),
      (4, '🔴', _t('Šerlokas', 'Sherlock'),
          _t('Tik tikriems žinovams', 'For true masterminds only'), 4),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Column(
        children: [
          const Text('🕵️', style: TextStyle(fontSize: 50)),
          const SizedBox(height: 4),
          Text(
            _t('Pasirink bylos sunkumą', 'Pick your case difficulty'),
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                letterSpacing: 1.2),
          ),
          const SizedBox(height: 6),
          Text(
            _t('Bylos bankas 1000 🔑. Perki užuominas, o laikrodis tiksi — '
                'kuo greičiau įminsi, tuo daugiau laimėsi (mažiausiai 20 🔑)',
                'Case bank 1000 🔑. Buy clues while the clock ticks — '
                'solve faster to win more (at least 20 🔑)'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 14),
          for (final (lvl, emoji, name, desc, coef) in levels) ...[
            GestureDetector(
              onTap: () => _start(lvl),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: _accent.withValues(alpha: 0.55), width: 1.4),
                  boxShadow: [
                    BoxShadow(
                        color: _accent.withValues(alpha: 0.10),
                        blurRadius: 12,
                        spreadRadius: 1),
                  ],
                ),
                child: Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 30)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20)),
                          const SizedBox(height: 3),
                          Text(desc,
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.levelMedium.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.levelMedium
                                .withValues(alpha: 0.7)),
                      ),
                      child: Text('⏱ −$coef/s',
                          style: const TextStyle(
                              color: AppColors.levelMedium,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _caseView() {
    final v = _view!;
    final boardMode = v.hasBoard && !_typingMode;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Column(
        children: [
          _statusRow(v),
          if (v.intro.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              v.intro,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                  fontStyle: FontStyle.italic,
                  height: 1.3),
            ),
          ],
          const SizedBox(height: 12),
          // „Bylos segtuvas" su žodžio langeliais — TIK ✍️ PRO režime.
          // Lentos žaidime raidžių skaičius išduotų atsakymą (savininko
          // taisyklė) — ten žodžio kaukės apskritai nėra.
          if (!boardMode) ...[
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(18),
                border:
                    Border.all(color: _accent.withValues(alpha: 0.35)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    right: -6,
                    bottom: -16,
                    child: Opacity(
                      opacity: 0.08,
                      child: const Text('🔍', style: TextStyle(fontSize: 90)),
                    ),
                  ),
                  _wordBoard(v),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_sosText != null) _sosStrip(),
          if (_sosText == null && _sosAvailable) _sosCard(v),
          if (boardMode) ...[
            _suspectBoard(v),
          ] else ...[
            _poolArea(v),
            const SizedBox(height: 10),
            _guessRow(),
          ],
          const SizedBox(height: 16),
          _market(v),
          const SizedBox(height: 14),
          // 🏳️ PASIDUODU — matomas mygtukas (ne tik ikona viršuje).
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _busy || _finished ? null : _abandon,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.wrong.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.wrong.withValues(alpha: 0.55)),
              ),
              child: Text(
                '🏳️ ${_t('PASIDUODU', 'I GIVE UP')}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.wrong,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.2),
              ),
            ),
          ),
          if (v.freeLeft >= 0) ...[
            const SizedBox(height: 10),
            Text(
              _t('Šiandien liko nemokamų bylų: ${v.freeLeft}',
                  'Free cases left today: ${v.freeLeft}'),
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _statusRow(DetectiveView v) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _accent.withValues(alpha: 0.6)),
          ),
          child: Text('📁 ${v.categoryLabel}',
              style: const TextStyle(
                  color: _accent, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        Column(
          children: [
            Text(
                _frozenNow
                    ? '⏸ ${_t('SUSTABDYTA', 'PAUSED')}'
                    : _t('LAIMĖSI', 'PRIZE'),
                style: TextStyle(
                    color: _frozenNow
                        ? AppColors.neonBlue
                        : AppColors.textSecondary,
                    fontSize: 10,
                    letterSpacing: 1.5)),
            Text('$_potentialNow 🔑',
                style: TextStyle(
                    color: _frozenNow
                        ? AppColors.neonBlue
                        : AppColors.levelMedium,
                    fontWeight: FontWeight.bold,
                    fontSize: 22)),
            if (_frozenNow)
              Text(
                  _t('suvesk per ${(_frozenLeftMs / 1000).ceil()} s',
                      'type within ${(_frozenLeftMs / 1000).ceil()} s'),
                  style: const TextStyle(
                      color: AppColors.neonBlue, fontSize: 10)),
          ],
        ),
        Text(
          '${'🔍' * v.lives}${'💥' * (v.maxLives - v.lives)}',
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  // 🆘 SOS mįslė: kortelė pirkimui ir juosta nupirkus.
  Widget _sosCard(DetectiveView v) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _busy ? null : _buySos,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.wrong.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.wrong, width: 1.6),
        ),
        child: Row(
          children: [
            const Text('🆘', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _t('Slaptas informatorius — paskutinė užuomina!',
                    'Secret informant — one last clue!'),
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5),
              ),
            ),
            Text('−${v.sosPrice} 🔑',
                style: const TextStyle(
                    color: AppColors.wrong,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _sosStrip() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.neonBlue.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neonBlue.withValues(alpha: 0.6)),
      ),
      child: Text(
        '🆘 $_sosText',
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: AppColors.textPrimary, fontSize: 14, height: 1.3),
      ),
    );
  }

  // 🎯 ĮTARIAMŲJŲ LENTA: brūkšt — išbraukti, ilgas paspaudimas — KALTINTI.
  Widget _suspectBoard(DetectiveView v) {
    final remaining = v.board.length - _eliminated.length;
    final cellW = (MediaQuery.of(context).size.width - 32 - 16) / 3;
    return Column(
      children: [
        Text(
          _t('Spausk kortelę — KALTINTI arba išbraukti',
              'Tap a card — ACCUSE or cross out'),
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          _t('Įtariamųjų liko: $remaining', 'Suspects left: $remaining'),
          style: TextStyle(
              color: remaining <= 3 ? AppColors.wrong : _accent,
              fontWeight: FontWeight.bold,
              fontSize: 13),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < v.board.length; i++)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _busy || _finished
                    ? null
                    : () {
                        if (_eliminated.contains(i)) {
                          SoundService.instance.tap();
                          setState(() => _eliminated.remove(i));
                        } else {
                          // Paspaudimas atveria aiškų pasirinkimą:
                          // 🎯 KALTINTI arba ❌ išbraukti.
                          _cardAction(i);
                        }
                      },
                onLongPress: _busy || _finished || _eliminated.contains(i)
                    ? null
                    : () => _accuse(i),
                child: AnimatedOpacity(
                  opacity: _eliminated.contains(i) ? 0.25 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    width: cellW,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _eliminated.contains(i)
                              ? AppColors.wrong.withValues(alpha: 0.6)
                              : _accent.withValues(alpha: 0.45)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          v.boardEmoji.length > i ? v.boardEmoji[i] : '❓',
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _eliminated.contains(i)
                              ? '✗ ${v.board[i]}'
                              : v.board[i],
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _eliminated.contains(i)
                                ? AppColors.wrong
                                : AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            decoration: _eliminated.contains(i)
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _wordBoard(DetectiveView v) {
    // Žodžiai (kaukės indeksų grupės) — kaip tirpime.
    final words = <List<int>>[];
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

    // Ilgi žodžiai (pvz. UGNIKALNIS) NETELPA į ekraną — kiekvieną žodį
    // suspaudžiam iki turimo pločio (FittedBox), kad nebūtų „overflow" juostos.
    final maxW = MediaQuery.of(context).size.width - 76;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 14,
      children: [
        for (final w in words)
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [for (final i in w) _boardCell(v, i)],
              ),
            ),
          ),
      ],
    );
  }

  Widget _boardCell(DetectiveView v, int i) {
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
    final typed = _typed[i];
    final active = _cursor == i;
    return GestureDetector(
      onTap: () {
        SoundService.instance.tap();
        setState(() => _cursor = i);
      },
      child: Container(
        width: 30,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? _accent.withValues(alpha: 0.18) : null,
          border: Border(
              bottom: BorderSide(
                  color: active ? _accent : _accent.withValues(alpha: 0.55),
                  width: active ? 3 : 2)),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(typed ?? '',
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _poolArea(DetectiveView v) {
    final used = _poolUsed;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 7,
      runSpacing: 7,
      children: [
        for (var i = 0; i < v.pool.length; i++)
          GestureDetector(
            onTap: used[i]
                ? null
                : () {
                    final target =
                        (_cursor != null && !_typed.containsKey(_cursor))
                            ? _cursor!
                            : _firstEmpty();
                    if (target == null) return;
                    SoundService.instance.tap();
                    setState(() {
                      _typed[target] = v.pool[i];
                      _cursor = _nextEmptyAfter(target);
                    });
                  },
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

  Widget _guessRow() {
    // SPĖTI spaudžiamas VISADA (neužpildžius — paaiškinimas, ne tyla).
    final tappable = !_busy && !_finished;
    final ready = tappable && _canGuess;
    return Row(
      children: [
        _iconBtn(Icons.backspace_outlined, () {
          if (_cursor != null && _typed.containsKey(_cursor)) {
            SoundService.instance.tap();
            setState(() => _typed.remove(_cursor));
            return;
          }
          if (_typed.isEmpty) return;
          final last = (_typed.keys.toList()..sort()).last;
          SoundService.instance.tap();
          setState(() {
            _typed.remove(last);
            _cursor = last;
          });
        }),
        const SizedBox(width: 8),
        _iconBtn(Icons.clear, () {
          if (_typed.isEmpty) return;
          SoundService.instance.swoosh();
          setState(() {
            _typed.clear();
            _cursor = _firstEmpty();
          });
        }),
        const SizedBox(width: 8),
        Expanded(
          child: NeumorphicButton(
            accent: ready
                ? _accent
                : (tappable ? AppColors.levelMedium : AppColors.textSecondary),
            padding: const EdgeInsets.symmetric(vertical: 15),
            onTap: tappable ? _submitTyped : null,
            child: Text(
              _t('SPĖTI ŽODĮ', 'GUESS THE WORD'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ready
                    ? _accent
                    : (tappable
                        ? AppColors.levelMedium
                        : AppColors.textSecondary),
                fontWeight: FontWeight.bold,
                fontSize: 17,
                letterSpacing: 1.6,
              ),
            ),
          ),
        ),
      ],
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.textSecondary.withValues(alpha: 0.5)),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 22),
      ),
    );
  }

  /// KLAUSIMŲ TURGUS: tekstai matomi, atsakymas perkamas. Trys kainų lygiai.
  Widget _market(DetectiveView v) {
    final tiers = [
      (1, '🟢', _t('Pigios užuominos', 'Cheap clues')),
      (2, '🟡', _t('Vidutinės užuominos', 'Medium clues')),
      (3, '🔴', _t('Protingos užuominos', 'Clever clues')),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            '🛒 ${_t('Klausimų turgus', 'Clue market')}',
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.6),
          ),
        ),
        const SizedBox(height: 8),
        for (final (tier, emoji, label) in tiers) ...[
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 6),
            child: Text(
              '$emoji $label  ·  −${v.prices[tier] ?? 0} 🔑',
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4),
            ),
          ),
          for (final c in v.questions.where((q) => q.t == tier))
            _clueCard(v, c),
        ],
      ],
    );
  }

  Widget _clueCard(DetectiveView v, DetectiveClue c) {
    final bought = c.bought;
    final price = v.prices[c.t] ?? 0;
    final affordable = v.bank - price >= v.floor;
    final buying = _buyingI == c.i;
    final ansColor = switch (c.ans) {
      'y' => AppColors.correct,
      'b' => AppColors.levelMedium,
      _ => AppColors.wrong,
    };
    // VISA kortelė — mygtukas (ne tik mažas kainos ženkliukas!).
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: bought || _busy ? null : () => _buy(c),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: bought
                ? ansColor.withValues(alpha: 0.7)
                : _accent.withValues(alpha: buying ? 0.9 : 0.35),
            width: bought || buying ? 1.8 : 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    c.q,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14.5,
                        height: 1.25),
                  ),
                ),
                const SizedBox(width: 10),
                if (bought)
                  // Atsakymo „antspaudas" — chip'as iššoka.
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.4, end: 1),
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.elasticOut,
                    builder: (context, sc, child) =>
                        Transform.scale(scale: sc, child: child),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ansColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: ansColor),
                      ),
                      child: Text(
                        switch (c.ans) {
                          'y' => '✓ ${_t('TAIP', 'YES')}',
                          'b' => '⚠ ${_t('TAIP/NE', 'YES/NO')}',
                          _ => '✗ ${_t('NE', 'NO')}',
                        },
                        style: TextStyle(
                            color: ansColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ),
                  )
                else if (buying)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: AppColors.levelMedium),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.levelMedium
                          .withValues(alpha: affordable ? 0.16 : 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: affordable
                              ? AppColors.levelMedium
                              : AppColors.textSecondary),
                    ),
                    child: Text(
                      '🔓 $price',
                      style: TextStyle(
                          color: affordable
                              ? AppColors.levelMedium
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
              ],
            ),
            // „TAIP, BET…" paaiškinimo juostelė (rodoma iškart nupirkus).
            if (bought && c.note != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.levelMedium.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.levelMedium.withValues(alpha: 0.45)),
                ),
                child: Text(
                  c.note!,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                      height: 1.25),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
