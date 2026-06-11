/// Trivijos (Gamta/Geografija) serverio kontrakto modeliai.
///
/// SKIRTUMAS nuo matematikos (game_models.dart): atsakymai yra ŽODŽIAI
/// (String), ne skaičiai (int). Pvz. „Mėlynasis banginis", ne „42".
/// Visa kita logika ta pati — serveris generuoja klausimus, tikrina
/// atsakymus pagal laiką (submitScore), rašo Top 10.
///
/// startNatureGame grąžina:
///   `{ gameId, level, maxTimeMs, questions: [ { action, options:[6], answer } ] }`
library;

/// Vienas trivijos klausimas: tekstas + 6 atsakymų variantai (žodžiai).
class TriviaQuestion {
  final String action; // klausimo tekstas, pvz. "Koks aukščiausias gyvūnas?"
  final List<String> options; // 6 variantai (žodžiai), sumaišyti serveryje
  final String answer; // teisingas (sutaps su vienu iš options)
  final String explanation; // KODĖL teisinga — rodoma žaidimo pabaigoje
  final String emoji; // iliustracinis „paveikslėlis" (gali būti tuščias)
  /// KLAUSIMO KORTELĖS paveikslėlis: klausimo SUBJEKTAS (pvz. 🕷️ prie „kiek kojų
  /// turi voras?"), kurį serveris davė TIK kai jis neišduoda atsakymo. Tuščias =
  /// rodom bendrą temos „sceną" (kaip seniau). NIEKADA neišduoda teisingo.
  final String cardEmoji;
  /// Po vieną emoji KIEKVIENAM variantui (ta pati tvarka kaip [options]).
  /// Serveris atsiunčia ARBA savus, unikalius emoji (kai visi variantai turi
  /// neišduodantį paveikslėlį), ARBA VIENODĄ temos ženkliuką ant visų (🍃/🗺️/⚙️…)
  /// — taip atsakymai NIEKADA nelieka tušti ir niekada nebūna mišrūs.
  final List<String> optionEmojis;

  const TriviaQuestion({
    required this.action,
    required this.options,
    required this.answer,
    this.explanation = '',
    this.emoji = '',
    this.cardEmoji = '',
    this.optionEmojis = const [],
  });

  /// Emoji konkrečiam variantui pagal jo tekstą (arba '' jei nerodom).
  String emojiForOption(String option) {
    if (optionEmojis.length != options.length) return '';
    final i = options.indexOf(option);
    return i >= 0 ? optionEmojis[i] : '';
  }

  factory TriviaQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = (json['options'] as List<dynamic>?) ?? const [];
    final rawEmojis = (json['optionEmojis'] as List<dynamic>?) ?? const [];
    return TriviaQuestion(
      action: json['action'] as String? ?? '',
      options: rawOptions.map((e) => e.toString()).toList(),
      answer: json['answer'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '',
      cardEmoji: json['cardEmoji'] as String? ?? '',
      optionEmojis: rawEmojis.map((e) => e.toString()).toList(),
    );
  }
}

/// Visa trivijos sesija, grąžinta iš startNatureGame.
class TriviaSession {
  final String gameId;
  final String level; // "lengvas" / "vidutinis"
  final int maxTimeMs; // langelio laikas pagal lygį
  final List<TriviaQuestion> questions;

  const TriviaSession({
    required this.gameId,
    required this.level,
    required this.maxTimeMs,
    required this.questions,
  });

  factory TriviaSession.fromJson(Map<String, dynamic> json) {
    final rawQuestions = (json['questions'] as List<dynamic>?) ?? const [];
    return TriviaSession(
      gameId: json['gameId'] as String? ?? '',
      level: json['level'] as String? ?? 'lengvas',
      maxTimeMs: (json['maxTimeMs'] as num?)?.toInt() ?? 4000,
      questions: rawQuestions
          .map((e) => TriviaQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
