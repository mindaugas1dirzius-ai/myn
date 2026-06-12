/// 🕵️ DETEKTYVO v2 serverio kontrakto modeliai.
///
/// SAUGUMAS: žodis, atsakymai, bankas, gyvybės ir LAIKAS gyvena TIK serveryje.
/// Klientas gauna žodžio KAUKĘ, klausimų TEKSTUS (turgaus esmė), atsakymus
/// TIK nupirktiems ir laikrodžio sinchroną (startedAt/serverNow/timeCoef).
///
/// Atsakymų tipai: 'y' = TAIP · 'n' = NE · 'b' = „TAIP, BET…" (+ note).
library;

import 'mystery_models.dart' show MysteryCell;

/// Atsakymo kodavimas iš serverio (bool arba "both").
String? _ansFrom(dynamic raw) {
  if (raw == null) return null;
  if (raw is bool) return raw ? 'y' : 'n';
  if (raw == 'both') return 'b';
  return null;
}

/// Vienas turgaus klausimas: tekstas matomas, atsakymas — tik nupirkus.
class DetectiveClue {
  final int i; // indeksas (pirkimui)
  final int t; // kainos lygis 1/2/3
  final String q; // klausimo tekstas
  final String? ans; // 'y'/'n'/'b' — tik jei nupirktas
  final String? note; // paaiškinimas („TAIP, BET…")

  const DetectiveClue({
    required this.i,
    required this.t,
    required this.q,
    this.ans,
    this.note,
  });

  bool get bought => ans != null;

  factory DetectiveClue.fromJson(Map<String, dynamic> j) => DetectiveClue(
        i: (j['i'] as num?)?.toInt() ?? 0,
        t: (j['t'] as num?)?.toInt() ?? 1,
        q: j['q'] as String? ?? '',
        ans: _ansFrom(j['a']),
        note: j['note'] as String?,
      );

  DetectiveClue withAnswer(String? answer, String? answerNote) =>
      DetectiveClue(i: i, t: t, q: q, ans: answer, note: answerNote);
}

/// Vienas analizės įrašas (visi atsakymai po bylos).
class DetectiveAnswer {
  final int t;
  final String q;
  final String ans; // 'y'/'n'/'b'
  final String? note;

  const DetectiveAnswer(
      {required this.t, required this.q, required this.ans, this.note});

  factory DetectiveAnswer.fromJson(Map<String, dynamic> j) => DetectiveAnswer(
        t: (j['t'] as num?)?.toInt() ?? 1,
        q: j['q'] as String? ?? '',
        ans: _ansFrom(j['a']) ?? 'n',
        note: j['note'] as String?,
      );
}

/// Aktyvios bylos vaizdas (startDetective).
class DetectiveView {
  final String caseId;
  final int level;
  final String categoryLabel;
  final String intro; // 1 sakinio intriga ('' jei nėra)
  final List<MysteryCell> mask;
  final List<String> pool;
  final int totalLetters;
  final int bank;
  final int floor;
  final int lives;
  final int maxLives;
  final Map<int, int> prices; // kainos lygis → 🔑
  final List<DetectiveClue> questions;
  final int keys;
  final int freeLeft; // -1 = be ribos (premium)
  final bool resumed;
  // v2: laikrodis (viskas serverio ms) + variantai + SOS.
  final int startedAt;
  final int serverNow;
  final int timeCoef; // 🔑/sek. bauda
  final int minAward; // grindys — spėti apsimoka visada
  // SPĖJIMO LANGAS: SPĖTI sustabdo laiką raidėms suvesti.
  final int guessWindowMs;
  final int lockedAt; // 0 — langas neatidarytas; kitaip serverio ms
  final int lockMsUsed; // ankstesnių langų užšaldytas laikas ms
  final int freezesLeft;
  final int variant; // 1 ✍️ · 2 🎯 lenta
  final bool hasBoard;
  final List<String> board; // „įtariamųjų" kortelės (sumaišyta tvarka)
  final List<String> boardEmoji;
  final bool sosExists;
  final int sosPrice;
  final bool sosAvailable;
  final String? sosText; // jau nupirkta SOS mįslė

  const DetectiveView({
    required this.caseId,
    required this.level,
    required this.categoryLabel,
    required this.intro,
    required this.mask,
    required this.pool,
    required this.totalLetters,
    required this.bank,
    required this.floor,
    required this.lives,
    required this.maxLives,
    required this.prices,
    required this.questions,
    required this.keys,
    required this.freeLeft,
    required this.resumed,
    required this.startedAt,
    required this.serverNow,
    required this.timeCoef,
    required this.minAward,
    this.guessWindowMs = 60000,
    this.lockedAt = 0,
    this.lockMsUsed = 0,
    this.freezesLeft = 0,
    required this.variant,
    required this.hasBoard,
    required this.board,
    required this.boardEmoji,
    required this.sosExists,
    required this.sosPrice,
    required this.sosAvailable,
    this.sosText,
  });

  DetectiveView copyWith({
    int? bank,
    int? lives,
    List<DetectiveClue>? questions,
    String? sosText,
  }) =>
      DetectiveView(
        caseId: caseId,
        level: level,
        categoryLabel: categoryLabel,
        intro: intro,
        mask: mask,
        pool: pool,
        totalLetters: totalLetters,
        bank: bank ?? this.bank,
        floor: floor,
        lives: lives ?? this.lives,
        maxLives: maxLives,
        prices: prices,
        questions: questions ?? this.questions,
        keys: keys,
        freeLeft: freeLeft,
        resumed: resumed,
        startedAt: startedAt,
        serverNow: serverNow,
        timeCoef: timeCoef,
        minAward: minAward,
        guessWindowMs: guessWindowMs,
        lockedAt: lockedAt,
        lockMsUsed: lockMsUsed,
        freezesLeft: freezesLeft,
        variant: variant,
        hasBoard: hasBoard,
        board: board,
        boardEmoji: boardEmoji,
        sosExists: sosExists,
        sosPrice: sosPrice,
        sosAvailable: sosAvailable,
        sosText: sosText ?? this.sosText,
      );

  factory DetectiveView.fromJson(Map<String, dynamic> j) {
    final rawMask = (j['mask'] as List<dynamic>?) ?? const [];
    final rawPool = (j['pool'] as List<dynamic>?) ?? const [];
    final rawQ = (j['questions'] as List<dynamic>?) ?? const [];
    final rawPrices = (j['prices'] as Map<String, dynamic>?) ?? const {};
    final rawBoard = (j['board'] as List<dynamic>?) ?? const [];
    final rawBoardEmoji = (j['boardEmoji'] as List<dynamic>?) ?? const [];
    return DetectiveView(
      caseId: j['caseId'] as String? ?? '',
      level: (j['level'] as num?)?.toInt() ?? 1,
      categoryLabel: j['categoryLabel'] as String? ?? '',
      intro: j['intro'] as String? ?? '',
      mask: rawMask
          .map((e) => MysteryCell.fromJson(e as Map<String, dynamic>))
          .toList(),
      pool: rawPool.map((e) => e.toString()).toList(),
      totalLetters: (j['totalLetters'] as num?)?.toInt() ?? 0,
      bank: (j['bank'] as num?)?.toInt() ?? 0,
      floor: (j['floor'] as num?)?.toInt() ?? 0,
      lives: (j['lives'] as num?)?.toInt() ?? 3,
      maxLives: (j['maxLives'] as num?)?.toInt() ?? 3,
      prices: rawPrices.map(
          (k, v) => MapEntry(int.tryParse(k) ?? 0, (v as num).toInt())),
      questions: rawQ
          .map((e) => DetectiveClue.fromJson(e as Map<String, dynamic>))
          .toList(),
      keys: (j['keys'] as num?)?.toInt() ?? 0,
      freeLeft: (j['freeLeft'] as num?)?.toInt() ?? 0,
      resumed: j['resumed'] as bool? ?? false,
      startedAt: (j['startedAt'] as num?)?.toInt() ?? 0,
      serverNow: (j['serverNow'] as num?)?.toInt() ?? 0,
      timeCoef: (j['timeCoef'] as num?)?.toInt() ?? 1,
      minAward: (j['minAward'] as num?)?.toInt() ?? 20,
      guessWindowMs: (j['guessWindowMs'] as num?)?.toInt() ?? 60000,
      lockedAt: (j['lockedAt'] as num?)?.toInt() ?? 0,
      lockMsUsed: (j['lockMsUsed'] as num?)?.toInt() ?? 0,
      freezesLeft: (j['freezesLeft'] as num?)?.toInt() ?? 0,
      variant: (j['variant'] as num?)?.toInt() ?? 1,
      hasBoard: j['hasBoard'] as bool? ?? false,
      board: rawBoard.map((e) => e.toString()).toList(),
      boardEmoji: rawBoardEmoji.map((e) => e.toString()).toList(),
      sosExists: j['sosExists'] as bool? ?? false,
      sosPrice: (j['sosPrice'] as num?)?.toInt() ?? 120,
      sosAvailable: j['sosAvailable'] as bool? ?? false,
      sosText: j['sosText'] as String?,
    );
  }
}

/// Pirkimo rezultatas (buyDetectiveClue). i == -1 → SOS mįslė (sos laukas).
class DetectiveClueOutcome {
  final int i;
  final String? ans; // 'y'/'n'/'b'
  final String? note;
  final String? sos;
  final int bank;
  final int lives;

  const DetectiveClueOutcome({
    required this.i,
    this.ans,
    this.note,
    this.sos,
    required this.bank,
    required this.lives,
  });

  factory DetectiveClueOutcome.fromJson(Map<String, dynamic> j) =>
      DetectiveClueOutcome(
        i: (j['i'] as num?)?.toInt() ?? 0,
        ans: _ansFrom(j['a']),
        note: j['note'] as String?,
        sos: j['sos'] as String?,
        bank: (j['bank'] as num?)?.toInt() ?? 0,
        lives: (j['lives'] as num?)?.toInt() ?? 3,
      );
}

/// Spėjimo rezultatas (guessDetective) su analize.
class DetectiveGuessOutcome {
  final bool correct;
  final bool dead; // gyvybės baigėsi — byla žlugo
  final String? word; // rodomas laimėjus/žlugus
  final int awarded;
  final int totalKeys;
  final int lives;
  final bool sosAvailable;
  final int rank; // 1 🥇 Šerlokas · 2 🥈 Inspektorius · 3 🥉 Naujokas
  final int boughtCount;
  final int lockMsUsed; // po klaidos — uždaryto lango laikas (sinchronui)
  // Išskaidymas (sąžiningumui).
  final int bankLeft;
  final int elapsedSec;
  final int timePenalty;
  final bool typedBonus;
  final List<DetectiveAnswer> answers; // analizė po bylos

  const DetectiveGuessOutcome({
    required this.correct,
    required this.dead,
    this.word,
    this.awarded = 0,
    this.totalKeys = 0,
    this.lives = 0,
    this.sosAvailable = false,
    this.rank = 3,
    this.boughtCount = 0,
    this.lockMsUsed = 0,
    this.bankLeft = 0,
    this.elapsedSec = 0,
    this.timePenalty = 0,
    this.typedBonus = false,
    this.answers = const [],
  });

  factory DetectiveGuessOutcome.fromJson(Map<String, dynamic> j) {
    final b = (j['breakdown'] as Map<String, dynamic>?) ?? const {};
    final rawA = (j['answers'] as List<dynamic>?) ?? const [];
    return DetectiveGuessOutcome(
      correct: j['correct'] as bool? ?? false,
      dead: j['dead'] as bool? ?? false,
      word: j['word'] as String?,
      awarded: (j['awarded'] as num?)?.toInt() ?? 0,
      totalKeys: (j['totalKeys'] as num?)?.toInt() ?? 0,
      lives: (j['lives'] as num?)?.toInt() ?? 0,
      sosAvailable: j['sosAvailable'] as bool? ?? false,
      rank: (j['rank'] as num?)?.toInt() ?? 3,
      boughtCount: (j['boughtCount'] as num?)?.toInt() ?? 0,
      lockMsUsed: (j['lockMsUsed'] as num?)?.toInt() ?? 0,
      bankLeft: (b['bankLeft'] as num?)?.toInt() ?? 0,
      elapsedSec: (b['elapsedSec'] as num?)?.toInt() ?? 0,
      timePenalty: (b['timePenalty'] as num?)?.toInt() ?? 0,
      typedBonus: b['typedBonus'] as bool? ?? false,
      answers: rawA
          .map((e) => DetectiveAnswer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
