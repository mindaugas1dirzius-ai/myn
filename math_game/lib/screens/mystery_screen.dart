import 'dart:math' as math;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/mystery_models.dart';
import '../services/mystery_api.dart';
import '../services/player_profile_api.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/neumorphic_button.dart';

/// „Cyber-Ratelis" (Laimės ratas) ekranas — savarankiškas žaidimas.
///
/// Žaidėjas dėlioja paslėpto teksto raides iš „pool" į brūkšnelius ir spėja.
/// EKONOMIKA (banko modelis): kiekviena paslaptis turi banką (pagal lygį).
/// Mokamos pagalbos (užuominos, raidės atvėrimas, +spėjimas) „tirpdo" banką,
/// bet niekada žemiau ribos (50). Teisingai atspėjus dabartinis bankas
/// pridedamas prie raktų (🔑). Klaida banko netirpdo — kainuoja tik širdelę.
///
/// Visa tiesa serveryje: čia tik rodom kaukę/banką ir siunčiam spėjimą.
class MysteryScreen extends StatefulWidget {
  const MysteryScreen({super.key});

  @override
  State<MysteryScreen> createState() => _MysteryScreenState();
}

class _MysteryScreenState extends State<MysteryScreen>
    with SingleTickerProviderStateMixin {
  static const _accent = AppColors.neonBlue;

  /// „Papurtymo" animacija neteisingam spėjimui (matomas grįžtamasis ryšys).
  late final AnimationController _shake;

  MysteryView? _view;
  bool _loading = true;
  bool _busy = false; // spėjimas/atstatymas vyksta
  String? _error;

  /// Į brūkšnelius sudėtų raidžių pool indeksai (tvarka = brūkšnelių tvarka).
  final List<int> _placed = [];

  // Tikroji (resolved) kalba — nustatoma didChangeDependencies. SVARBU: imam ją
  // per AppStrings.of(context) (kaip visa programa), o NE iš languageController
  // tiesiogiai — kitaip nepasirinkus kalbos rankiniu būdu (lang == null) UI būtų
  // lietuviškas, o turinys angliškas (nesutapimas, kurį pastebėjo žaidėjas).
  AppLang _appLang = AppLang.en;
  bool _started = false;

  String get _lang => _appLang == AppLang.lt ? 'lt' : 'en';
  bool get _isLt => _appLang == AppLang.lt;
  String _t(String lt, String en) => _isLt ? lt : en;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appLang = AppStrings.of(context).lang; // ta pati kalba kaip visur kitur
    if (!_started) {
      _started = true;
      _init();
    }
  }

  /// Užkrauna paslaptį ir iškart atveria sukauptas „pažadėtas" raides.
  Future<void> _init() async {
    setState(() {
      _loading = true;
      _error = null;
      _placed.clear();
    });
    try {
      var v = await MysteryApi.start(_lang);
      // Jei žaidžiant sukaupta atveriamų raidžių — atveriam jas dabar.
      if (v.pendingLetters > 0) {
        v = await MysteryApi.reveal(_lang);
      }
      if (!mounted) return;
      setState(() {
        _view = v;
        _loading = false;
      });
      if (v.revealedNow.isNotEmpty) {
        SoundService.instance.points(); // naujų raidžių „atsivėrimo" garsas
        _toast(_t('Atvertos ${v.revealedNow.length} naujos raidės!',
            '${v.revealedNow.length} new letters revealed!'));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = _t('Nepavyko pasiekti serverio. Bandyk vėliau.',
            'Could not reach the server. Try again later.');
        _loading = false;
      });
    }
  }

  // --- Brūkšnelių (blank) pozicijos ir užpildymas ---

  /// Kiek raidžių langelių dar paslėpta (jas reikia užpildyti iš pool).
  int get _blankCount {
    final v = _view;
    if (v == null) return 0;
    return v.mask.where((c) => c.slot && c.ch == null).length;
  }

  Set<int> get _usedPool => _placed.toSet();
  bool get _canGuess =>
      _view != null && _blankCount > 0 && _placed.length == _blankCount;

  void _tapPool(int i) {
    if (_placed.contains(i)) return; // ta pati raidė jau padėta
    if (_placed.length >= _blankCount) return; // visi brūkšneliai užpildyti
    SoundService.instance.tap(); // raidės „klavišo" spragtelėjimas
    setState(() => _placed.add(i));
  }

  void _backspace() {
    if (_placed.isEmpty) return;
    SoundService.instance.tap(); // ištrynimo spragtelėjimas
    setState(() => _placed.removeLast());
  }

  void _clear() {
    if (_placed.isEmpty) return;
    SoundService.instance.swoosh(); // viską nuvalom — „švyst"
    setState(_placed.clear);
  }

  /// Surenka spėjamą tekstą: atvertos raidės + sudėtos iš pool + skyrikliai.
  String _buildGuess() {
    final v = _view!;
    final sb = StringBuffer();
    var blank = 0;
    for (final c in v.mask) {
      if (!c.slot) {
        sb.write(c.ch ?? ' '); // skyriklis (tarpas, kablelis)
      } else if (c.ch != null) {
        sb.write(c.ch); // jau atverta raidė
      } else {
        // paslėptas langelis — imam padėtą raidę (jei yra)
        if (blank < _placed.length) {
          sb.write(v.pool[_placed[blank]]);
        }
        blank++;
      }
    }
    return sb.toString();
  }

  Future<void> _submitGuess() async {
    if (!_canGuess || _busy) return;
    setState(() => _busy = true);
    try {
      final r = await MysteryApi.guess(_buildGuess());
      if (!mounted) return;
      if (r.correct) {
        SoundService.instance.win(); // pergalės akordas
        await _showWinDialog(r);
        await _init(); // nauja paslaptis
      } else if (r.exhausted) {
        // Bandymai išseko — parodom atsakymą ir kraunam naują paslaptį.
        SoundService.instance.wrong();
        await _shake.forward(from: 0);
        if (!mounted) return;
        await _showFailDialog(r);
        await _init(); // serveris jau parinko naują — užkraunam
      } else {
        SoundService.instance.wrong(); // neteisingo spėjimo „buzz"
        await _shake.forward(from: 0); // MATOMAS papurtymas — aišku, kad ne
        if (!mounted) return;
        _feedback(
          _t('Neteisingai! Liko bandymų: ${r.attemptsLeft}.',
              'Wrong! Attempts left: ${r.attemptsLeft}.'),
          good: false,
        );
        // Atnaujinam likusius bandymus IŠ KART (kad širdelė dingtų po klaidos,
        // o ne tik iš naujo užkrovus ekraną).
        setState(() => _view = _view?.copyWith(attemptsLeft: r.attemptsLeft));
      }
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      // Atskiriam „palauk sekundę" (anti-spam pauzė) nuo tikros ryšio klaidos —
      // kitaip žaidėjas nesupranta, kodėl niekas „nevyksta".
      final msg = e.code == 'resource-exhausted'
          ? _t('Palauk sekundę ir bandyk vėl.', 'Wait a second and try again.')
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

  Future<void> _resetMystery() async {
    final ok = await _confirmReset();
    if (ok != true || _busy) return;
    setState(() => _busy = true);
    try {
      final v = await MysteryApi.reset(_lang);
      if (!mounted) return;
      setState(() {
        _view = v;
        _placed.clear();
      });
    } catch (_) {
      if (mounted) {
        _toast(_t('Nepavyko. Bandyk vėl.', 'Failed. Try again.'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // --- Galios priemonės (banko modelis: „ištirpdo" dalį banko) ---
  //
  // Kainos ateina iš serverio (v.costHint / v.costReveal / v.costGuess) — čia
  // konstantų NĖRA, kad niekada nesusiskirtų su serverio tiesa.

  /// Naudoja galios priemonę. Serveris sumažina banką (`spent`) ir grąžina
  /// naują būseną. Bankas niekada nenukrenta žemiau ribos (floor 50).
  Future<void> _powerup(String action) async {
    if (_busy || _view == null) return;
    setState(() => _busy = true);
    try {
      final r = await MysteryApi.powerup(action);
      if (!mounted) return;
      setState(() {
        _view = r.view;
        // Atvėrus raidę pool gali pasikeisti — nuvalom padėtas raides, kad
        // indeksai nesusimaišytų su naujuoju pool.
        _placed.clear();
      });
      if (action == 'revealLetter' && r.revealedNow.isNotEmpty) {
        SoundService.instance.points();
        _feedback(_t('Atversta raidė!', 'Letter revealed!'), good: true);
      } else if (action == 'extraGuess') {
        SoundService.instance.tap();
        _feedback(_t('+1 spėjimas!', '+1 guess!'), good: true);
      } else if (action == 'hint1' || action == 'hint2') {
        SoundService.instance.points();
        _feedback(_t('Užuomina atrakinta!', 'Hint unlocked!'), good: true);
      }
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      // failed-precondition: per mažai raktų / visos raidės atvertos / nėra
      // paslapties — serveris atsiunčia aiškią žinutę (e.message).
      final msg = e.code == 'failed-precondition'
          ? (e.message ?? _t('Negalima.', 'Not allowed.'))
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

  // --- Pagalbinukai UI ---

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.surface),
    );
  }

  /// Ryškus, NEPRALEIDŽIAMAS grįžtamasis ryšys (spalvotas, su ikona, plaukiantis).
  /// Naudojam spėjimo rezultatui — kad žaidėjas visada matytų, kas įvyko.
  void _feedback(String msg, {required bool good}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars(); // kad seni pranešimai nesikauptų
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
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        backgroundColor: good ? AppColors.correct : AppColors.wrong,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 2200),
      ),
    );
  }

  Future<bool?> _confirmReset() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(_t('Nusinulinti?', 'Reset?'),
            style: const TextStyle(color: AppColors.textPrimary)),
        content: Text(
          _t('Gausi NAUJĄ paslaptį. Šios atvertos raidės dings.',
              'You will get a NEW mystery. Revealed letters here will be lost.'),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(_t('Atšaukti', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(_t('Taip', 'Yes'),
                style: const TextStyle(color: AppColors.wrong)),
          ),
        ],
      ),
    );
  }

  Future<void> _showWinDialog(GuessOutcome r) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('🎉 ${_t('Teisingai!', 'Correct!')}',
            style: const TextStyle(color: AppColors.correct)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (r.answer != null)
              Text('„${r.answer}"',
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              _t('+${r.awarded} raktų 🔑', '+${r.awarded} keys 🔑'),
              style: const TextStyle(
                  color: AppColors.levelMedium,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              _t('Iš viso: ${r.totalKeys} 🔑', 'Total: ${r.totalKeys} 🔑'),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_t('Toliau', 'Next')),
          ),
        ],
      ),
    );
  }

  /// Bandymai išseko — parodom, kokia buvo paslaptis, ir kad ateina nauja.
  Future<void> _showFailDialog(GuessOutcome r) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('😔 ${_t('Bandymai baigėsi', 'Out of attempts')}',
            style: const TextStyle(color: AppColors.wrong)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_t('Paslaptis buvo:', 'The mystery was:'),
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            if (r.answer != null)
              Text('„${r.answer}"',
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(_t('Ateina nauja paslaptis.', 'A new mystery is coming.'),
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_t('Toliau', 'Next')),
          ),
        ],
      ),
    );
  }

  /// Gyvas RAKTŲ (🔑) skaitliukas viršuje (StreamBuilder iš users/{uid}).
  /// Raktai — atskira paslapties valiuta: laimi spėdamas, leidi galios priemonėms.
  Widget _keysChip() {
    return StreamBuilder<PlayerProfile>(
      stream: PlayerProfileApi.stream(),
      builder: (context, snap) {
        final keys = snap.data?.mysteryKeys ?? 0;
        return Center(
          child: Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _accent.withValues(alpha: 0.4)),
            ),
            child: Text(
              '$keys 🔑',
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        title: Text(_t('Atspėk paslaptį', 'Guess the Mystery'),
            style: const TextStyle(color: AppColors.textPrimary)),
        actions: [
          // Gyvas raktų (🔑) skaitliukas (tiesiai iš users/{uid} srauto) — kad
          // iškart matytum, kaip balansas keičiasi atspėjus (+) ar suklydus (−).
          _keysChip(),
          // Aiškus grįžimas TIESIAI į meniu (pradinį ekraną) — nesvarbu, ar
          // atėjom iš meniu, ar iš rezultatų ekrano „Eiti spėti".
          IconButton(
            tooltip: _t('Į meniu', 'To menu'),
            icon: const Icon(Icons.home_rounded),
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: AppBackground(
        accent: _accent,
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _errorView()
                  : _content(),
        ),
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          NeumorphicButton(
            accent: _accent,
            onTap: _init,
            child: Text(_t('Bandyti dar', 'Retry'),
                style: const TextStyle(
                    color: _accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    final v = _view!;
    return Padding(
      padding: EdgeInsets.zero,
      // VISAS turinys vienoje slenkančioje srityje — kad ilgos frazės, užuominos
      // ir klaviatūra niekada nebūtų „nukirpti". Reklama lieka fiksuota apačioje.
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              child: Column(
                children: [
                  _hintChip(v),
                  const SizedBox(height: 8),
                  _bankRow(v),
                  const SizedBox(height: 8),
                  _powerupRow(v),
                  _hintTexts(v),
                  const SizedBox(height: 14),
                  // Paslaptis (brūkšneliai + atvertos raidės).
                  _shakeWrap(_maskArea(v)),
                  const SizedBox(height: 16),
                  _poolArea(v),
                  const SizedBox(height: 12),
                  _buttonsRow(),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }

  /// Apgaubia paslaptį „papurtymo" efektu (horizontalus virpesys gęstant).
  Widget _shakeWrap(Widget child) {
    return AnimatedBuilder(
      animation: _shake,
      builder: (context, c) {
        final dx =
            math.sin(_shake.value * math.pi * 8) * 10 * (1 - _shake.value);
        return Transform.translate(offset: Offset(dx, 0), child: c);
      },
      child: child,
    );
  }

  Widget _hintChip(MysteryView v) {
    final label = _categoryLabel(v.category);
    // „klausimas" kategorijoje užuomina YRA klausimas (atsakymas — paslėptas
    // tekstas), todėl etiketė kitokia.
    final prefix =
        v.category == 'klausimas' ? _t('Klausimas', 'Question') : label.$2;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _accent.withValues(alpha: 0.4)),
      ),
      child: Text(
        '${label.$1}  $prefix: ${v.hint}',
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600),
      ),
    );
  }

  /// (emoji, pavadinimas) pagal kategoriją.
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
        return ('🎡', _t('Ratelis', 'Wheel'));
    }
  }

  /// Banko juosta: didelis DABARTINIS bankas (= laimėjimas atspėjus dabar),
  /// banko „tirpimo" progresas (nuo bankMax iki floor) ir likę spėjimai.
  Widget _bankRow(MysteryView v) {
    // Kiek banko liko (1.0 = pilnas bankMax, 0.0 = nukritęs iki floor).
    final span = (v.bankMax - v.floor);
    final bankFrac =
        span > 0 ? ((v.potentialWin - v.floor) / span).clamp(0.0, 1.0) : 1.0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t('BANKAS', 'BANK'),
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      letterSpacing: 1.5),
                ),
                Text(
                  '${v.potentialWin} 🔑',
                  style: const TextStyle(
                      color: AppColors.correct,
                      fontWeight: FontWeight.bold,
                      fontSize: 26),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Likę spėjimai — širdelėmis.
                Text(
                  '${'❤️' * v.attemptsLeft}${'🤍' * (5 - v.attemptsLeft).clamp(0, 5)}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_t('iš', 'of')} ${v.bankMax} 🔑 · ${_t('riba', 'floor')} ${v.floor}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: bankFrac,
            minHeight: 7,
            backgroundColor: AppColors.shadowDark,
            valueColor: const AlwaysStoppedAnimation(AppColors.correct),
          ),
        ),
      ],
    );
  }

  /// Galios priemonių juosta — VIENA kompaktiška eilutė (4 mygtukai), kad
  /// liktų kuo daugiau vietos ilgoms frazėms. Kiekvienas „ištirpdo" dalį banko.
  /// Mygtukas pilkas, jei banko neužtektų (bankas − kaina < riba) arba
  /// priemonė negalima (užuomina jau atrakinta / nėra ko atverti).
  Widget _powerupRow(MysteryView v) {
    final canReveal = v.canAfford(v.costReveal) && _blankCount > 0;
    final canGuess = v.canAfford(v.costGuess);
    // Užuominos: galima TIK jei egzistuoja turinys, dar neatrakinta ir užtenka banko.
    final canHint1 = v.hasHint1 && !v.hint1Unlocked && v.canAfford(v.costHint);
    final canHint2 = v.hasHint2 && !v.hint2Unlocked && v.canAfford(v.costHint);
    return Row(
      children: [
        Expanded(
          child: _powerupButton(
            icon: v.hint1Unlocked ? Icons.check : Icons.lightbulb_outline,
            label: _t('Užuom. 1', 'Hint 1'),
            cost: v.costHint,
            enabled: canHint1 && !_busy,
            onTap: () => _powerup('hint1'),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _powerupButton(
            icon: v.hint2Unlocked ? Icons.check : Icons.lightbulb,
            label: _t('Užuom. 2', 'Hint 2'),
            cost: v.costHint,
            enabled: canHint2 && !_busy,
            onTap: () => _powerup('hint2'),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _powerupButton(
            icon: Icons.search,
            label: _t('Raidė', 'Letter'),
            cost: v.costReveal,
            enabled: canReveal && !_busy,
            onTap: () => _powerup('revealLetter'),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _powerupButton(
            icon: Icons.favorite_border,
            label: _t('+Spėj.', '+Guess'),
            cost: v.costGuess,
            enabled: canGuess && !_busy,
            onTap: () => _powerup('extraGuess'),
          ),
        ),
      ],
    );
  }

  /// Atrakintų papildomų užuominų tekstai (rodom tik kai nupirktos).
  Widget _hintTexts(MysteryView v) {
    final texts = <String>[];
    if (v.hint1Unlocked && (v.hint1Text ?? '').isNotEmpty) texts.add(v.hint1Text!);
    if (v.hint2Unlocked && (v.hint2Text ?? '').isNotEmpty) texts.add(v.hint2Text!);
    if (texts.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          for (final t in texts)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.levelMedium.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.levelMedium.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Text('💡 ', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Text(t,
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 13)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _powerupButton({
    required IconData icon,
    required String label,
    required int cost,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final color = enabled ? _accent : AppColors.textSecondary;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.45,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 11),
              ),
              Text('$cost 🔑',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  /// Paslaptis suskaidoma į „žodžius" (skiriant tarpais), kad žodžiai
  /// nesilaužytų per eilutės kraštą. Skyryba lieka prie žodžio.
  Widget _maskArea(MysteryView v) {
    // Žodžiai laiko (absoliutus mask indeksas, langelis) poras — kad žinotume,
    // kurie langeliai ką tik atsivėrė (revealedNow) ir įjungtume „įkritimo" efektą.
    final words = <List<(int, MysteryCell)>>[];
    var current = <(int, MysteryCell)>[];
    for (var mi = 0; mi < v.mask.length; mi++) {
      final c = v.mask[mi];
      final isSpace = !c.slot && (c.ch == null || c.ch == ' ');
      if (isSpace) {
        if (current.isNotEmpty) words.add(current);
        current = [];
      } else {
        current.add((mi, c));
      }
    }
    if (current.isNotEmpty) words.add(current);

    final revealedNow = v.revealedNow.toSet();

    // Bendras brūkšnelio indeksas (per visą paslaptį), kad žinotume užpildymą.
    var blank = 0;
    final wordWidgets = <Widget>[];
    for (final w in words) {
      final cells = <Widget>[];
      for (final pair in w) {
        final mi = pair.$1;
        final c = pair.$2;
        if (c.slot && c.ch == null) {
          final filled = blank < _placed.length ? v.pool[_placed[blank]] : null;
          cells.add(_blankCell(filled));
          blank++;
        } else if (c.slot) {
          cells.add(_revealedCell(c.ch!, mi, isNew: revealedNow.contains(mi)));
        } else {
          cells.add(_punctCell(c.ch ?? ''));
        }
      }
      wordWidgets.add(Row(mainAxisSize: MainAxisSize.min, children: cells));
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12, // tarpas tarp žodžių
      runSpacing: 12,
      children: wordWidgets,
    );
  }

  /// Atverta raidė. Jei [isNew] — „įkrenta" į vietą (fade + slinktis žemyn +
  /// padidėjimas) — vizualus „atsidarančios spynos" efektas serverio raidėms.
  Widget _revealedCell(String ch, int maskIndex, {bool isNew = false}) {
    final cell = _cellBox(
      child: Text(ch,
          style: const TextStyle(
              color: AppColors.correct,
              fontSize: 17,
              fontWeight: FontWeight.bold)),
      border: AppColors.correct.withValues(alpha: 0.5),
    );
    if (!isNew) return cell;
    // Vienkartinė animacija (TweenAnimationBuilder paleidžia sukūrus): 0 → 1.
    // STABILUS raktas (pagal mask indeksą) — kad neperleistų animacijos per
    // kiekvieną setState (pvz. spaudžiant pool raides).
    return TweenAnimationBuilder<double>(
      key: ValueKey('reveal_$maskIndex'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: Curves.elasticOut,
      builder: (context, t, child) {
        final clamped = t.clamp(0.0, 1.0);
        return Opacity(
          opacity: clamped,
          child: Transform.translate(
            offset: Offset(0, -16 * (1 - clamped)),
            child: Transform.scale(scale: 0.5 + 0.5 * t, child: child),
          ),
        );
      },
      child: cell,
    );
  }

  Widget _blankCell(String? filled) => _cellBox(
        child: Text(filled ?? '',
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.bold)),
        border: _accent.withValues(alpha: 0.6),
        underline: true,
      );

  Widget _punctCell(String ch) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: Text(ch,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 17,
                fontWeight: FontWeight.bold)),
      );

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
        borderRadius: underline ? null : BorderRadius.circular(6),
      ),
      child: child,
    );
  }

  Widget _poolArea(MysteryView v) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var i = 0; i < v.pool.length; i++)
          _poolButton(v.pool[i], i, used: _usedPool.contains(i)),
      ],
    );
  }

  Widget _poolButton(String letter, int i, {required bool used}) {
    return GestureDetector(
      onTap: used ? null : () => _tapPool(i),
      child: AnimatedOpacity(
        opacity: used ? 0.25 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 34,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _accent.withValues(alpha: 0.6)),
          ),
          child: Text(letter,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buttonsRow() {
    return Row(
      children: [
        _iconBtn(Icons.backspace_outlined, _backspace),
        const SizedBox(width: 8),
        _iconBtn(Icons.clear, _clear),
        const SizedBox(width: 8),
        Expanded(
          child: NeumorphicButton(
            accent: _canGuess ? AppColors.correct : AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            onTap: _canGuess && !_busy ? _submitGuess : null,
            child: Text(
              _t('SPĖTI', 'GUESS'),
              style: TextStyle(
                color: _canGuess ? AppColors.correct : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _iconBtn(Icons.refresh, _busy ? null : _resetMystery,
            color: AppColors.wrong),
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
