import 'package:flutter_test/flutter_test.dart';
import 'package:math_game/models/game_mode.dart';
import 'package:math_game/providers/game_provider.dart';
import 'package:math_game/theme/app_theme.dart';

/// Teste Firebase neinicializuotas → FirebaseService.ready == false →
/// GameProvider visada krenta į OFFLINE režimą (LocalQuestionGenerator).
/// Taip testuojam žaidimo logiką be tinklo.

/// Sukuria provider ir palaukia, kol pakraus klausimus (offline — akimirksniu).
Future<GameProvider> _readyGame(MathOp op, GameLevel level) async {
  final game =
      GameProvider(op: op, level: level, modeId: '${op.id}_${level.name}');
  while (game.loadState == LoadState.loading) {
    await Future.delayed(const Duration(milliseconds: 1));
  }
  return game;
}

void main() {
  test('offline fallback: pakrauna 10 klausimų, source = offline', () async {
    final game = await _readyGame(MathOp.add, GameLevel.lengvas);
    expect(game.loadState, LoadState.ready);
    expect(game.source, Source.offline); // teste nėra Firebase
    expect(game.total, 10);
  });

  test('10 klausimų sesija: teisingi kaupia taškus, klaida = 0, tęsiasi',
      () async {
    final game = await _readyGame(MathOp.add, GameLevel.lengvas);

    var correctAnswered = 0;
    for (var i = 0; i < 10; i++) {
      expect(game.index, i);
      final q = game.current;
      if (i < 7) {
        game.answer(q.answer, 500);
        correctAnswered++;
        expect(game.state, CellState.correct);
      } else {
        final wrong = q.options.firstWhere((o) => o != q.answer);
        game.answer(wrong, 500);
        expect(game.state, CellState.wrong);
      }
      game.next();
    }

    expect(game.finished, isTrue);
    expect(game.correctCount, correctAnswered); // 7
    expect(game.score, greaterThan(0));
  });

  test('isBusy blokuoja dvigubą atsakymą', () async {
    final game = await _readyGame(MathOp.mul, GameLevel.vidutinis);
    final q = game.current;
    game.answer(q.answer, 300);
    final scoreAfterFirst = game.score;
    game.answer(q.options.first, 300);
    expect(game.score, scoreAfterFirst);
  });

  test('timeout = klaida (švelnus modelis, 0 taškų)', () async {
    final game = await _readyGame(MathOp.sub, GameLevel.sunkus);
    game.timeout();
    expect(game.state, CellState.wrong);
    expect(game.correctCount, 0);
  });

  test('offline submitToServer grąžina null (nėra serverio)', () async {
    final game = await _readyGame(MathOp.div, GameLevel.lengvas);
    final result = await game.submitToServer();
    expect(result, isNull);
  });
}
