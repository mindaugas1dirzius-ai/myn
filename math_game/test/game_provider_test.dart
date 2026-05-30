import 'package:flutter_test/flutter_test.dart';
import 'package:math_game/models/game_mode.dart';
import 'package:math_game/providers/game_provider.dart';
import 'package:math_game/theme/app_theme.dart';

void main() {
  test('10 klausimų sesija: teisingi kaupia taškus, klaida = 0, žaidimas tęsiasi',
      () {
    final game = GameProvider(op: MathOp.add, level: GameLevel.lengvas);

    expect(game.total, 10);
    expect(game.finished, isFalse);

    var correctAnswered = 0;
    for (var i = 0; i < 10; i++) {
      expect(game.index, i);
      final q = game.current;

      // pirmus 7 atsakom teisingai, likusius klaidingai
      if (i < 7) {
        game.answer(q.answer, 500); // greitas teisingas
        correctAnswered++;
        expect(game.state, CellState.correct);
      } else {
        // randam klaidingą variantą
        final wrong = q.options.firstWhere((o) => o != q.answer);
        game.answer(wrong, 500);
        expect(game.state, CellState.wrong);
      }
      game.next();
    }

    expect(game.finished, isTrue);
    expect(game.correctCount, correctAnswered); // 7
    expect(game.score, greaterThan(0)); // kosmetiniai taškai už teisingus
  });

  test('isBusy blokuoja dvigubą atsakymą tame pačiame langelyje', () {
    final game = GameProvider(op: MathOp.mul, level: GameLevel.vidutinis);
    final q = game.current;
    game.answer(q.answer, 300);
    final scoreAfterFirst = game.score;
    // antras paspaudimas neturi nieko keisti (kol nepereita next())
    game.answer(q.options.first, 300);
    expect(game.score, scoreAfterFirst);
  });

  test('timeout = klaida (švelnus modelis, 0 taškų)', () {
    final game = GameProvider(op: MathOp.sub, level: GameLevel.sunkus);
    game.timeout();
    expect(game.state, CellState.wrong);
    expect(game.correctCount, 0);
  });
}
