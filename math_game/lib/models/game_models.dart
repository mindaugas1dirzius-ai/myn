/// Serverio kontrakto duomenų modeliai (griežtai tipizuoti, su fromJson).
///
/// KODĖL: vengiam „palaidų" `Map` tipų — kad spausdinimo klaida
/// nevirstų runtime crash. Visi serverio duomenys praeina pro šias klases.
///
/// startGame grąžina:
///   `{ gameId, level, maxTimeMs, questions: [ { action, options:[6] } ] }`
library;

/// Vienas klausimas: tekstas + 6 atsakymų variantai (be pažymėto teisingo).
class MathQuestion {
  final String action; // pvz. "6×7"
  final List<int> options; // 6 variantai, sumaišyti serveryje
  final int answer; // teisingas (variantas C — UX žalia/raudona; taškus tikrina serveris)

  const MathQuestion({
    required this.action,
    required this.options,
    required this.answer,
  });

  factory MathQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = (json['options'] as List<dynamic>?) ?? const [];
    return MathQuestion(
      action: json['action'] as String? ?? '',
      options: rawOptions.map((e) => (e as num).toInt()).toList(),
      answer: (json['answer'] as num?)?.toInt() ?? -1,
    );
  }
}

/// Visa žaidimo sesija, grąžinta iš startGame.
class GameSession {
  final String gameId;
  final String level; // "lengvas" / "vidutinis" / ...
  final int maxTimeMs; // langelio laikas pagal lygį
  final List<MathQuestion> questions;

  const GameSession({
    required this.gameId,
    required this.level,
    required this.maxTimeMs,
    required this.questions,
  });

  factory GameSession.fromJson(Map<String, dynamic> json) {
    final rawQuestions = (json['questions'] as List<dynamic>?) ?? const [];
    return GameSession(
      gameId: json['gameId'] as String? ?? '',
      level: json['level'] as String? ?? 'lengvas',
      maxTimeMs: (json['maxTimeMs'] as num?)?.toInt() ?? 3000,
      questions: rawQuestions
          .map((e) => MathQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// submitScore rezultatas.
class GameResult {
  final bool success;
  final int finalScore;
  final int correct;
  final bool isNewRecord;

  const GameResult({
    required this.success,
    required this.finalScore,
    required this.correct,
    required this.isNewRecord,
  });

  factory GameResult.fromJson(Map<String, dynamic> json) {
    return GameResult(
      success: json['success'] as bool? ?? false,
      finalScore: (json['finalScore'] as num?)?.toInt() ?? 0,
      correct: (json['correct'] as num?)?.toInt() ?? 0,
      isNewRecord: json['isNewRecord'] as bool? ?? false,
    );
  }
}
