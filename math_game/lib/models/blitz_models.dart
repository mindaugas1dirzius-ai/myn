/// ⚡ TAIP/NE BLITZ serverio kontrakto modeliai.
///
/// Teiginys = „patikrinimo šablonas": klausimas PAŽODŽIUI + kandidatas.
/// TAIP — jei kandidatas yra teisingas atsakymas, NE — jei distraktorius.
/// `isTrue` ateina iš serverio (variantas C — momentinė žalia/raudona
/// reakcija be round-tripo; vertinimą vis tiek daro TIK serveris).
library;

/// Vienas teiginys raundui.
class BlitzStatement {
  final String q; // klausimas (žaidėjo kalba)
  final String cand; // kandidatas (atsakymo variantas)
  final bool isTrue; // ar kandidatas teisingas (UX reakcijai)
  final String cat; // temos kodas (nature/geo/...) — kortelės dizainui

  const BlitzStatement({
    required this.q,
    required this.cand,
    required this.isTrue,
    this.cat = '',
  });

  factory BlitzStatement.fromJson(Map<String, dynamic> j) => BlitzStatement(
        q: j['q'] as String? ?? '',
        cand: j['cand'] as String? ?? '',
        isTrue: j['isTrue'] as bool? ?? false,
        cat: j['cat'] as String? ?? '',
      );
}

/// startBlitz atsakymas — visas raundo paketas.
class BlitzSession {
  final String gameId;
  final int durationMs;
  final List<BlitzStatement> statements;

  const BlitzSession({
    required this.gameId,
    required this.durationMs,
    required this.statements,
  });

  factory BlitzSession.fromJson(Map<String, dynamic> j) => BlitzSession(
        gameId: j['gameId'] as String? ?? '',
        durationMs: (j['durationMs'] as num?)?.toInt() ?? 30000,
        statements: ((j['statements'] as List<dynamic>?) ?? const [])
            .map((e) => BlitzStatement.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Žaidėjo atsakymas (siunčiamas serveriui pabaigoje).
class BlitzAnswer {
  final int i; // teiginio indeksas pakete
  final bool val; // TAIP (true) / NE (false)
  final int tMs; // ms nuo raundo pradžios (finalo ×2 skaičiavimui)

  const BlitzAnswer({required this.i, required this.val, required this.tMs});

  Map<String, dynamic> toJson() => {'i': i, 'val': val, 'tMs': tMs};
}

/// submitBlitzScore atsakymas.
class BlitzResult {
  final bool success;
  final int finalScore;
  final int correct;
  final int answered;
  final int bestCombo;
  final bool isNewRecord;
  final int coinsEarned;
  final int totalCoins;
  final int earnedLetters;
  final int pendingMysteryLetters;
  final bool promptName;

  const BlitzResult({
    required this.success,
    required this.finalScore,
    required this.correct,
    required this.answered,
    required this.bestCombo,
    required this.isNewRecord,
    required this.coinsEarned,
    required this.totalCoins,
    required this.earnedLetters,
    required this.pendingMysteryLetters,
    required this.promptName,
  });

  factory BlitzResult.fromJson(Map<String, dynamic> j) => BlitzResult(
        success: j['success'] as bool? ?? false,
        finalScore: (j['finalScore'] as num?)?.toInt() ?? 0,
        correct: (j['correct'] as num?)?.toInt() ?? 0,
        answered: (j['answered'] as num?)?.toInt() ?? 0,
        bestCombo: (j['bestCombo'] as num?)?.toInt() ?? 0,
        isNewRecord: j['isNewRecord'] as bool? ?? false,
        coinsEarned: (j['coinsEarned'] as num?)?.toInt() ?? 0,
        totalCoins: (j['totalCoins'] as num?)?.toInt() ?? 0,
        earnedLetters: (j['earnedLetters'] as num?)?.toInt() ?? 0,
        pendingMysteryLetters:
            (j['pendingMysteryLetters'] as num?)?.toInt() ?? 0,
        promptName: j['promptName'] as bool? ?? false,
      );
}
