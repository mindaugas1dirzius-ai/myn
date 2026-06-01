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
  /// Vengia pasikartojimo sesijoje (kaip serveryje). Saugiklis nuo begalinio
  /// ciklo: po 200 bandymų atsileidžia (lengvi režimai turi mažai variantų).
  List<LocalQuestion> generateGame(MathOp op, GameLevel level) {
    final questions = <LocalQuestion>[];
    final usedActions = <String>{};
    var guard = 0;
    while (questions.length < 10 && guard < 500) {
      guard++;
      final q = _generateOne(op, level);
      if (usedActions.contains(q.text) && guard < 200) continue;
      usedActions.add(q.text);
      questions.add(q);
    }
    return questions;
  }

  LocalQuestion _generateOne(MathOp op, GameLevel level) {
    // Pažengę režimai turi specialų display — atskiri generatoriai.
    if (op == MathOp.mix) return _generateMix(level);
    if (op == MathOp.brackets) return _generateBrackets(level);
    if (op == MathOp.algebra) return _generateAlgebra(level);
    final (a, b, answer) = _operands(op, level);
    final symbol = op.symbol;
    final options = _options(answer, null);
    return LocalQuestion(
      text: '$a $symbol $b',
      options: options,
      answer: answer,
    );
  }

  /// Skliaustai (atitinka serverio genBrackets).
  LocalQuestion _generateBrackets(GameLevel level) {
    final String text;
    final int answer;
    int? trap;
    switch (level) {
      case GameLevel.lengvas:
        final a = _rnd(2, 9), b = _rnd(1, 5), c = _rnd(2, 5);
        if (_rng.nextBool()) {
          text = '($a+$b)×$c';
          answer = (a + b) * c;
          trap = a + b * c;
        } else {
          final big = a + b;
          text = '($big−$b)×$c';
          answer = a * c;
          trap = big - b * c;
        }
      case GameLevel.vidutinis:
        if (_rng.nextBool()) {
          final a = _rnd(3, 9), c = _rnd(2, 9), b = c + _rnd(1, 9);
          text = '$a×($b−$c)';
          answer = a * (b - c);
          trap = a * b - c;
        } else {
          final a = _rnd(5, 30), c = _rnd(2, 6), q = _rnd(2, 9);
          final b = c * q;
          text = '$a+($b÷$c)';
          answer = a + q;
          trap = (a + b) ~/ c;
        }
      case GameLevel.sunkus:
        final a = _rnd(5, 20), b = _rnd(2, 15), d = _rnd(2, 10);
        final c = d + _rnd(1, 10);
        text = '($a+$b)×($c−$d)';
        answer = (a + b) * (c - d);
      case GameLevel.ekstremalus:
        final c = _rnd(2, 10), d = _rnd(2, 10), inner = c + d;
        final b = inner + _rnd(2, 15), a = _rnd(2, 9);
        text = '$a×($b−($c+$d))';
        answer = a * (b - inner);
        trap = a * (b - c + d);
    }
    return LocalQuestion(text: text, options: _options(answer, trap), answer: answer);
  }

  /// Algebra (atitinka serverio genAlgebra).
  LocalQuestion _generateAlgebra(GameLevel level) {
    final String text;
    final int answer;
    int? trap;
    switch (level) {
      case GameLevel.lengvas:
        final x = _rnd(1, 9);
        if (_rng.nextBool()) {
          final b = _rnd(1, 9);
          text = 'x+$b=${x + b}';
          answer = x;
          trap = x + b;
        } else {
          final b = x + _rnd(1, 9);
          text = '$b−x=${b - x}';
          answer = x;
          trap = b;
        }
      case GameLevel.vidutinis:
        final x = _rnd(2, 12);
        if (_rng.nextBool()) {
          final a = _rnd(2, 9);
          text = '$a×x=${a * x}';
          answer = x;
          trap = a * x;
        } else {
          final a = _rnd(2, 9);
          text = 'x÷$a=$x';
          answer = x * a;
          trap = x;
        }
      case GameLevel.sunkus:
        final a = _rnd(2, 6), x = _rnd(2, 12), b = _rnd(2, 15);
        text = '${a}x+$b=${a * x + b}';
        answer = x;
        trap = a * x + b + b;
      case GameLevel.ekstremalus:
        if (_rng.nextBool()) {
          final x = _rnd(2, 12), a = _rnd(1, 20);
          text = 'x²+$a=${x * x + a}';
          answer = x;
          trap = x * x;
        } else {
          final a = _rnd(2, 5), b = _rnd(2, 9), q = _rnd(2, 12);
          final x = b + q;
          text = '$a×(x−$b)=${a * q}';
          answer = x;
          trap = a * q;
        }
    }
    return LocalQuestion(text: text, options: _options(answer, trap), answer: answer);
  }

  /// Mix Blitz (atitinka serverio questionRegistry.genMix).
  LocalQuestion _generateMix(GameLevel level) {
    String text;
    int answer;
    int? trap;
    switch (level) {
      case GameLevel.lengvas:
      case GameLevel.vidutinis:
        // vieno veiksmo miksas (atsitiktinis veiksmas)
        final ops = [MathOp.add, MathOp.sub, MathOp.mul, MathOp.div];
        return _generateOne(ops[_rnd(0, 3)], level);
      case GameLevel.sunkus:
        if (_rng.nextBool()) {
          final a = _rnd(10, 50), b = _rnd(2, 9), c = _rnd(2, 9);
          text = '$a + $b × $c';
          answer = a + b * c;
          trap = (a + b) * c;
        } else {
          final a = _rnd(2, 12), b = _rnd(2, 9), c = _rnd(2, 30);
          text = '$a × $b − $c';
          answer = a * b - c;
        }
        break;
      case GameLevel.ekstremalus:
        final a = _rnd(3, 12), b = _rnd(2, 9), d = _rnd(2, 9), q = _rnd(2, 12);
        final c = d * q;
        text = '$a × $b + $c ÷ $d';
        answer = a * b + q;
        trap = a * b + c;
        break;
    }
    return LocalQuestion(text: text, options: _options(answer, trap), answer: answer);
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
      case MathOp.mix:
      case MathOp.brackets:
      case MathOp.algebra:
        // Šie gaudomi atskirais generatoriais anksčiau — čia neturėtų patekti.
        final (x, y) = _addRange(level);
        return (x, y, x + y);
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
        return (_rnd(12, 50), _rnd(6, 19)); // V3: praplėstas (atitinka serverį)
    }
  }

  /// 6 variantai: 1 teisingas + spąstas (jei yra) + panašūs (Fisher-Yates).
  /// Atitinka serverio generateOptions (universalus — pagal answer + trap).
  List<int> _options(int answer, int? trap) {
    final set = <int>{answer};
    final candidates = <int>[];

    if (trap != null) candidates.add(trap); // spąstas pirmas (garantuotai tarp 6)
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
