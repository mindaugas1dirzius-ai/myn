/// 🕵️ DETEKTYVO serverio kontrakto modeliai.
///
/// SAUGUMAS: žodis, atsakymai, bankas ir gyvybės gyvena TIK serveryje.
/// Klientas gauna žodžio KAUKĘ (ilgis matomas — nemokama užuomina),
/// klausimų TEKSTUS (turgaus esmė) ir atsakymus TIK nupirktiems.
library;

import 'mystery_models.dart' show MysteryCell;

/// Vienas turgaus klausimas: tekstas matomas, atsakymas — tik nupirkus.
class DetectiveClue {
  final int i; // indeksas (pirkimui)
  final int t; // kainos lygis 1/2/3
  final String q; // klausimo tekstas
  final bool? a; // TAIP/NE — tik jei nupirktas

  const DetectiveClue({
    required this.i,
    required this.t,
    required this.q,
    this.a,
  });

  factory DetectiveClue.fromJson(Map<String, dynamic> j) => DetectiveClue(
        i: (j['i'] as num?)?.toInt() ?? 0,
        t: (j['t'] as num?)?.toInt() ?? 1,
        q: j['q'] as String? ?? '',
        a: j['a'] as bool?,
      );

  DetectiveClue withAnswer(bool answer) =>
      DetectiveClue(i: i, t: t, q: q, a: answer);
}

/// Aktyvios bylos vaizdas (startDetective).
class DetectiveView {
  final String caseId;
  final int level;
  final String categoryLabel;
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

  const DetectiveView({
    required this.caseId,
    required this.level,
    required this.categoryLabel,
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
  });

  factory DetectiveView.fromJson(Map<String, dynamic> j) {
    final rawMask = (j['mask'] as List<dynamic>?) ?? const [];
    final rawPool = (j['pool'] as List<dynamic>?) ?? const [];
    final rawQ = (j['questions'] as List<dynamic>?) ?? const [];
    final rawPrices = (j['prices'] as Map<String, dynamic>?) ?? const {};
    return DetectiveView(
      caseId: j['caseId'] as String? ?? '',
      level: (j['level'] as num?)?.toInt() ?? 1,
      categoryLabel: j['categoryLabel'] as String? ?? '',
      mask: rawMask
          .map((e) => MysteryCell.fromJson(e as Map<String, dynamic>))
          .toList(),
      pool: rawPool.map((e) => e.toString()).toList(),
      totalLetters: (j['totalLetters'] as num?)?.toInt() ?? 0,
      bank: (j['bank'] as num?)?.toInt() ?? 0,
      floor: (j['floor'] as num?)?.toInt() ?? 50,
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
    );
  }
}

/// Pirkimo rezultatas (buyDetectiveClue).
class DetectiveClueOutcome {
  final int i;
  final bool a;
  final int bank;

  const DetectiveClueOutcome(
      {required this.i, required this.a, required this.bank});

  factory DetectiveClueOutcome.fromJson(Map<String, dynamic> j) =>
      DetectiveClueOutcome(
        i: (j['i'] as num?)?.toInt() ?? 0,
        a: j['a'] as bool? ?? false,
        bank: (j['bank'] as num?)?.toInt() ?? 0,
      );
}

/// Spėjimo rezultatas (guessDetective).
class DetectiveGuessOutcome {
  final bool correct;
  final bool dead; // gyvybės baigėsi — byla žlugo
  final String? word; // rodomas laimėjus/žlugus
  final int awarded;
  final int totalKeys;
  final int lives;

  const DetectiveGuessOutcome({
    required this.correct,
    required this.dead,
    this.word,
    this.awarded = 0,
    this.totalKeys = 0,
    this.lives = 0,
  });

  factory DetectiveGuessOutcome.fromJson(Map<String, dynamic> j) =>
      DetectiveGuessOutcome(
        correct: j['correct'] as bool? ?? false,
        dead: j['dead'] as bool? ?? false,
        word: j['word'] as String?,
        awarded: (j['awarded'] as num?)?.toInt() ?? 0,
        totalKeys: (j['totalKeys'] as num?)?.toInt() ?? 0,
        lives: (j['lives'] as num?)?.toInt() ?? 0,
      );
}
