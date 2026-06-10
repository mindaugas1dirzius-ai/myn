import 'dart:math' as math;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../models/trivia_models.dart';
import '../providers/nature_game_provider.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/exit_dialog.dart';
import '../widgets/live_points.dart';
import '../widgets/neon_timer_ring.dart';
import '../widgets/neumorphic_button.dart';
import '../widgets/sound_toggle_button.dart';
import 'result_screen.dart';

/// ~20 neutralių gamtos „vaizdų" klausimo kortelei. SVARBU: nė vienas NEturi
/// atskleisti atsakymo (jokio konkretaus gyvūno, kuris būtų teisingas variantas)
/// — tik bendros gamtos temos. Vėliau pakeisim vektorinėmis iliustracijomis.
const List<String> _kNatureScenes = [
  '🌍', '🌿', '🌳', '🍃', '🏞️', '⛰️', '🌊', '🌅', '🌄', '🌲',
  '🍂', '🌷', '🌻', '🌴', '🏜️', '🏝️', '🌋', '☀️', '🐾', '🧭',
];

/// Gamtos trivijos žaidimo ekranas.
///
/// SKIRTUMAS nuo matematikos (game_screen.dart):
///  - klausimas yra ILGAS tekstas (ne „6 × 7") → rodom plačioje kortelėje;
///  - atsakymai yra ŽODŽIAI → 2 stulpelių platūs mygtukai (ne 3 siauri);
///  - NĖRA offline atsargos → klaidos ekranas su „bandyti dar".
/// Bendrus elementus (žiedą, gyvus taškus, rezultatų ekraną) naudojam pakartotinai.
class NatureGameScreen extends StatefulWidget {
  final String modeId; // "nature_lengvas"
  final Color accent; // lygio spalva

  const NatureGameScreen({
    super.key,
    required this.modeId,
    required this.accent,
  });

  @override
  State<NatureGameScreen> createState() => _NatureGameScreenState();
}

class _NatureGameScreenState extends State<NatureGameScreen>
    with SingleTickerProviderStateMixin {
  late final NatureGameProvider _game;
  late final AnimationController _shake;
  final Stopwatch _stopwatch = Stopwatch();
  int _ringKey = 0;

  /// VIENA bendra dydžio grupė šio klausimo atsakymams. SVARBU: laikoma
  /// būsenoje (NE kuriama build() viduje) — kitaip ji būtų atkuriama per kiekvieną
  /// perpiešimą ir auto_size_text sinchronizacija NEVEIKTŲ (kaip tik dėl to
  /// vienas ilgesnis atsakymas susitraukdavo, o trumpi likdavo dideli → nevienodi
  /// šriftai). Atnaujinama tik PEREINANT prie kito klausimo.
  AutoSizeGroup _answerGroup = AutoSizeGroup();

  /// Neutralūs gamtos „vaizdai" klausimui (NEatskleidžia atsakymo).
  /// Sumaišomi kartą per partiją → per 10 klausimų nesikartoja (pool > 10).
  late final List<String> _scenes;

  /// Ar provideris jau sukurtas (didChangeDependencies kviečiamas kelis kartus).
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scenes = List.of(_kNatureScenes)..shuffle();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // SVARBU: kalbą imam per AppStrings.of(context) (tikroji/resolved kalba —
    // kaip visur kitur), o NE iš languageController.lang tiesiogiai. Kitaip,
    // jei kalba nepasirinkta rankiniu būdu (lang == null), telefonui esant
    // lietuviškam UI būtų LT, o klausimai serveris grąžintų EN (nesutapimas).
    final lang = AppStrings.of(context).lang == AppLang.lt ? 'lt' : 'en';
    _game = NatureGameProvider(modeId: widget.modeId, lang: lang);
  }

  /// Vaizdas šiam klausimui pagal jo eilės numerį (stabilus per perpiešimus).
  String _sceneFor(int index) => _scenes[index % _scenes.length];

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

  void _onAnswer(String value) {
    if (_game.isBusy) return;
    _stopwatch.stop();
    SoundService.instance.tap(); // paspaudimo garsas iškart
    _game.answer(value, _stopwatch.elapsedMilliseconds);
    // Grįžtamasis ryšys: teisinga „ding" ↑ / klaidinga žemas „buzz" ↓.
    if (_game.state == NatureCellState.correct) {
      SoundService.instance.correct();
    } else {
      SoundService.instance.wrong();
    }
    _afterResolve();
  }

  void _onTimeout() {
    if (_game.isBusy) return;
    _stopwatch.stop();
    SoundService.instance.wrong(); // laikas baigėsi = klaida
    _game.timeout();
    _afterResolve();
  }

  Future<void> _onQuitPressed() async {
    final quit = await showQuitDialog(context);
    if (quit && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _afterResolve() async {
    if (_game.state == NatureCellState.wrong) {
      await _shake.forward(from: 0);
    }
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    _game.next();
    if (_game.finished) {
      SoundService.instance.win(); // partijos pabaigos akordas
      final result = await _game.submitToServer();
      if (!mounted) return;
      final review = _buildReview();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            accent: widget.accent,
            onPlayAgain: (ctx) => Navigator.of(ctx).pushReplacement(
              MaterialPageRoute(
                builder: (_) => NatureGameScreen(
                    modeId: widget.modeId, accent: widget.accent),
              ),
            ),
            modeId: widget.modeId,
            correct: _game.correctCount,
            total: _game.total,
            score: result?.finalScore ?? _game.score,
            online: true, // gamta visada serveryje (be offline)
            coinsEarned: result?.coinsEarned ?? 0,
            promptName: result?.promptName ?? false,
            earnedLetters: result?.earnedLetters ?? 0,
            pendingMysteryLetters: result?.pendingMysteryLetters ?? 0,
            review: review,
          ),
        ),
      );
    } else {
      SoundService.instance.swoosh(); // naujo klausimo atsiradimas
      // Naujam klausimui — NAUJA dydžio grupė: atsakymai sinchronizuojami tik
      // tarpusavyje (šio klausimo), o ne su praeitų klausimų tekstais.
      setState(() {
        _ringKey++;
        _answerGroup = AutoSizeGroup();
      });
      _startQuestion();
    }
  }

  /// Sudaro klausimų apžvalgą rezultatų ekranui: kiekvienam klausimui — ką
  /// pasirinko žaidėjas, koks teisingas atsakymas ir kodėl (paaiškinimas).
  List<AnswerReview> _buildReview() {
    final questions = _game.questions;
    final answers = _game.clientAnswers;
    final reviews = <AnswerReview>[];
    for (var i = 0; i < questions.length; i++) {
      final q = questions[i];
      final picked = i < answers.length ? answers[i] : '';
      reviews.add(AnswerReview(
        question: q.action,
        emoji: q.emoji,
        correctAnswer: q.answer,
        pickedAnswer: picked,
        explanation: q.explanation,
        wasCorrect: picked == q.answer,
      ));
    }
    return reviews;
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    return Scaffold(
      body: AppBackground(
        accent: accent,
        child: SafeArea(
        child: ListenableBuilder(
          listenable: _game,
          builder: (context, _) {
            if (_game.loadState == NatureLoadState.loading) {
              return Center(child: CircularProgressIndicator(color: accent));
            }
            if (_game.loadState == NatureLoadState.error) {
              return _errorView(accent);
            }
            if (!_stopwatch.isRunning && _game.state == NatureCellState.idle) {
              _startQuestion();
            }
            final q = _game.current;
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LivePoints(
                        running: _game.state == NatureCellState.idle,
                        resetKey: _ringKey,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SoundToggleButton(),
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: AppColors.textSecondary, size: 28),
                            onPressed: _onQuitPressed,
                          ),
                        ],
                      ),
                    ],
                  ),
                  _ProgressBar(index: _game.index, total: _game.total),
                  const SizedBox(height: 8),
                  // Kompaktiškas laikmačio žiedas (varo onTimeout).
                  NeonTimerRing(
                    key: ValueKey(_ringKey),
                    durationMs: _game.maxTimeMs,
                    size: 64,
                    running: !_game.isBusy,
                    onTimeout: _onTimeout,
                  ),
                  const SizedBox(height: 16),
                  // Ar yra ILGŲ atsakymų (sakinių)? Nuo to priklauso išdėstymas.
                  ..._questionAndAnswers(q, accent),
                ],
              ),
            );
          },
        ),
        ),
      ),
    );
  }

  /// Klausimo kortelė + atsakymai — VISKAS viename ekrane, BE slankiojimo.
  /// Du atvejai:
  ///  - TRUMPI atsakymai (žodžiai): kortelė užima viršų (Expanded → tekstas
  ///    automatiškai sumažinamas, kad TILPTŲ), atsakymai apačioje 2 stulpeliais.
  ///  - ILGI atsakymai (sakiniai, ekstremalus lygis): kortelė ir atsakymai
  ///    pasidalija ekraną; 6 platūs mygtukai dalijasi vietą PO LYGIAI (kiekvienas
  ///    Expanded), todėl visi 6 visada matosi, o tekstas telpa viduje.
  List<Widget> _questionAndAnswers(TriviaQuestion q, Color accent) {
    final longest =
        q.options.fold<int>(0, (m, o) => o.length > m ? o.length : m);
    final longAnswers = longest > 22;
    final card = _questionCard(q.action, _sceneFor(_game.index), accent);

    // Bendra dydžio grupė (laikoma būsenoje) — auto_size_text sinchronizuoja
    // VISUS grupės tekstus į tą patį šriftą → langeliai atrodo vienodai, o
    // žodžiai (wrapWords:false) niekada nelaužomi per vidurį.
    final group = _answerGroup;

    if (!longAnswers) {
      return [
        Expanded(child: card),
        const SizedBox(height: 16),
        _buildAnswers(q.options, accent, group),
        const SizedBox(height: 12),
      ];
    }

    // Ilgi atsakymai: klausimo kortelė susitraukia PAGAL TURINĮ (be tuščios
    // vietos, klausimo šriftas NEmažinamas — nebent klausimas labai ilgas, tada
    // FittedBox jį sumažina, kad neviršytų ~34% ekrano). Visa likusi vieta —
    // atsakymams: 6 platūs mygtukai dalijasi ją po lygiai. Šriftą parenka
    // AutoSizeText (grupė) — vienodas visiems, su apatine riba (minFontSize).
    final maxCardH = MediaQuery.of(context).size.height * 0.34;
    const gap = 8.0;
    final n = q.options.length;
    return [
      ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxCardH),
        child: card,
      ),
      const SizedBox(height: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < n; i++) ...[
              Expanded(
                  child: _answerButton(q.options[i], accent,
                      group: group, maxLines: 3)),
              if (i < n - 1) const SizedBox(height: gap),
            ],
          ],
        ),
      ),
      const SizedBox(height: 12),
    ];
  }

  /// Klausimo kortelė — emoji „paveikslėlis" viršuje + platus daugiaeilis
  /// tekstas (faktai būna ilgi).
  Widget _questionCard(String text, String emoji, Color accent) {
    Color border = accent;
    if (_game.state == NatureCellState.correct) border = AppColors.correct;
    if (_game.state == NatureCellState.wrong) border = AppColors.wrong;

    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        final dx =
            math.sin(_shake.value * math.pi * 8) * 10 * (1 - _shake.value);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: Container(
        // SVARBU: be `alignment` — kitaip Container „išsipučia" iki viso
        // leidžiamo aukščio (maxHeight). Be jo kortelė susitraukia PAGAL turinį.
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: border.withValues(alpha: 0.6), width: 2),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadowDark,
                offset: Offset(8, 8),
                blurRadius: 18),
            BoxShadow(
                color: AppColors.shadowLight,
                offset: Offset(-8, -8),
                blurRadius: 18),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, c) => FittedBox(
            fit: BoxFit.scaleDown,
            child: ConstrainedBox(
              // Tekstas laužomas pagal VISĄ kortelės vidinį plotį (jokio šoninio
              // tuščio tarpo, mažiau eilučių). FittedBox tik SUMAŽINA, jei
              // klausimas labai ilgas ir netelpa į jam skirtą aukštį.
              constraints: BoxConstraints(maxWidth: c.maxWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Emoji „paveikslėlis" — virš teksto (kuklus, kad liktų
                  // daugiau vietos atsakymams).
                  if (emoji.isNotEmpty) ...[
                    Text(emoji, style: const TextStyle(fontSize: 42)),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// TRUMPŲ atsakymų tinklelis (2 stulpeliai). Ilgi sakiniai tvarkomi atskirai
  /// (žr. _questionAndAnswers — 1 platus stulpelis su lygiai pasidalintais
  /// mygtukais), todėl čia visada 2 stulpeliai.
  Widget _buildAnswers(List<String> options, Color accent, AutoSizeGroup group) {
    const crossSpacing = 12.0;
    const aspect = 1.8; // platūs mygtukai; vietos kelioms eilutėms
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: crossSpacing,
      childAspectRatio: aspect,
      children: options
          .map((v) => _answerButton(v, accent, group: group, maxLines: 2))
          .toList(),
    );
  }

  Widget _answerButton(String value, Color accent,
      {AutoSizeGroup? group, int maxLines = 2}) {
    Color c = accent;
    if (_game.state != NatureCellState.idle) {
      if (value == _game.current.answer) {
        c = AppColors.correct;
      } else if (value == _game.pickedOption) {
        c = AppColors.wrong;
      }
    }
    final textColor = c == accent ? AppColors.textPrimary : c;

    // Susijęs emoji iš serverio („viskas arba nieko“). Jei nėra – VIENODAS
    // lapelis 🍃 visiems variantams (net skaičiams), kad KIEKVIENAS atsakymas
    // turėtų paveikslėlį ir atrodytų nuosekliai. Nė vienas neišsiskiria, tad
    // atsakymas neišduodamas.
    final serverEmoji = _game.current.emojiForOption(value);
    final emoji = serverEmoji.isNotEmpty ? serverEmoji : '🍃';
    return NeumorphicButton(
      accent: c,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      onTap: () => _onAnswer(value),
      // Emoji – FIKSUOTAS plotis (30px), kad visuose 6 mygtukuose stovėtų
      // idealiai vienodoje pozicijoje (ilgi žodžiai NEstumdo emoji). Tekstas
      // užima likusią vietą; vienodas šriftas + perkėlimas į 2 eilutes.
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              emoji,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            // VIENODAS šriftas visiems grupės atsakymams: AutoSizeText su bendra
            // `group` parenka VIENĄ dydį (didžiausią, prie kurio telpa visi).
            //  - wrapWords:false → žodis NIEKADA nelaužomas per vidurį (jokios
            //    vienišų raidžių, pvz. „Bušmeisteris" liks sveikas, šriftas tik
            //    truputį sumažės);
            //  - minFontSize:13 → apatinė riba, kad raidės niekada nebūtų per
            //    mažos;
            //  - maxLines → kiek eilučių leidžiama prieš mažinant.
            child: AutoSizeText(
              value,
              textAlign: TextAlign.center,
              group: group,
              maxLines: maxLines,
              wrapWords: false,
              minFontSize: 13,
              stepGranularity: 0.5,
              style: TextStyle(
                color: textColor,
                // Pradinis dydis 16 (ne 18): pakankamai didelis, kad gerai
                // skaitytųsi, bet ir toks, kad į 2 eilutes besilaužiantis ilgas
                // atsakymas TILPTŲ NESUSITRAUKDAMAS → visi atsakymai lieka to
                // paties dydžio (vienodi). Grupė + minFontSize garantuoja, kad
                // jei kuris vis tiek netelpa, susitraukia VISI kartu, ne vienas.
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Klaidos ekranas (serveris nepasiekiamas — gamta neturi offline atsargos).
  Widget _errorView(Color accent) {
    final s = AppStrings.of(context);
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, color: AppColors.textSecondary, size: 56),
          const SizedBox(height: 18),
          Text(
            s.natureLoadError,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 220,
            child: NeumorphicButton(
              accent: accent,
              onTap: () => _game.retry(),
              child: Text(s.retry,
                  style: TextStyle(
                      color: accent,
                      fontSize: 17,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            child: Text(s.toMenu,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
        ],
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
