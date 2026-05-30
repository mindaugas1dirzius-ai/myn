import 'dart:math';
import '../models/game_mode.dart';
import '../models/local_question.dart';
import '../theme/app_theme.dart';

/// Lokalus klausimų generatorius (offline žaidimui, G4).
///
/// ⚠️ LAIKINA: tai supaprastinta serverio `generateQuestion`+`generateOptions`
/// versija Dart kalba. J žingsnyje pakeis serverio kvietimas (startGame),
/// tada šį failą ištrinsim. Logika atitinka DIZAINAS.md (2 ir 4 sprendimai).
class LocalQuestionGenerator {
  final Random _rng = Random();

  int _rnd(int min, int max) => min + _rng.nextInt(max - min + 1);

  /// Sugeneruoja 10 klausimų pasirinktam veiksmui ir lygiui.
  List<LocalQuestion> generateGame(MathOp op, GameLevel level) {
    return List.generate(10, (_) => _generateOne(op, level));
  }

  LocalQuestion _generateOne(MathOp op, GameLevel level) {
    final (a, b, answer) = _operands(op, level);
    final symbol = op.symbol;
    final options = _options(a, b, answer, op);
    return LocalQuestion(
      text: '$a $symbol $b',
      options: options,
      answer: answer,
    );
  }

  /// Operandai pagal veiksmą ir lygį (atitinka serverio ribas).
  (int, int, int) _operands(MathOp op, GameLevel level) {
    switch (op) {
      case MathOp.add:
        final (x, y) = _addRange(level);
        return (x, y, x + y);
      case MathOp.sub:
        final (x, y) = _addRange(level);
        final big = x + y;
        return (big, y, x); // rezultatas >= 0
      case MathOp.mul:
        final (x, y) = _mulRange(level);
        return (x, y, x * y);
      case MathOp.div:
        final (x, y) = _mulRange(level);
        return (x * y, y, x); // sveikas rezultatas
    }
  }

  (int, int) _addRange(GameLevel level) {
    switch (level) {
      case GameLevel.lengvas:
        return (_rnd(1, 9), _rnd(1, 9));
      case GameLevel.vidutinis:
        return (_rnd(10, 99), _rnd(1, 9));
      case GameLevel.sunkus:
        return (_rnd(10, 99), _rnd(10, 99));
      case GameLevel.ekstremalus:
        return (_rnd(100, 999), _rnd(10, 99));
    }
  }

  (int, int) _mulRange(GameLevel level) {
    switch (level) {
      case GameLevel.lengvas:
        return (_rnd(2, 5), _rnd(2, 5));
      case GameLevel.vidutinis:
        return (_rnd(2, 10), _rnd(2, 10));
      case GameLevel.sunkus:
        return (_rnd(2, 12), _rnd(2, 12));
      case GameLevel.ekstremalus:
        return (_rnd(13, 25), _rnd(3, 9));
    }
  }

  /// 6 variantai: 1 teisingas + 5 panašūs klaidingi (Fisher-Yates).
  List<int> _options(int a, int b, int answer, MathOp op) {
    final set = <int>{answer};
    final candidates = <int>[];

    if (op == MathOp.mul) {
      candidates.addAll([(a + 1) * b, (a - 1) * b, a * (b + 1), a * (b - 1)]);
    }
    if (op == MathOp.div) {
      candidates.addAll([b, answer + 2]);
    }
    if (answer >= 10) {
      candidates.add(int.parse(answer.toString().split('').reversed.join()));
    }
    candidates.addAll(
        [answer + 1, answer - 1, answer + 10, answer - 10, answer + 2, answer - 2]);

    for (final c in candidates) {
      if (set.length == 6) break;
      if (c > 0 && c != answer) set.add(c);
    }
    var fallback = 1;
    while (set.length < 6) {
      set.add(answer + fallback);
      if (set.length < 6 && answer - fallback > 0) set.add(answer - fallback);
      fallback++;
    }

    return _shuffle(set.toList());
  }

  List<int> _shuffle(List<int> list) {
    for (var i = list.length - 1; i > 0; i--) {
      final j = _rng.nextInt(i + 1);
      final tmp = list[i];
      list[i] = list[j];
      list[j] = tmp;
    }
    return list;
  }
}
