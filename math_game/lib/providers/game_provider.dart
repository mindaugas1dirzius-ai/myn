import 'package:flutter/foundation.dart';
import '../models/game_mode.dart';
import '../models/local_question.dart';
import '../services/local_question_generator.dart';
import '../theme/app_theme.dart';

/// Langelio būsena (vizualui).
enum CellState { idle, correct, wrong }

/// Aktyvios žaidimo sesijos būsena (G4). ChangeNotifier — be papildomų paketų.
///
/// ⚠️ Taškai ČIA — TIK kosmetika (rodymui). Oficialius taškus skaičiuoja
/// SERVERIS (DIZAINAS.md 5 sprendimas). J žingsnyje submitScore grąžins
/// tikrą rezultatą; lokalus `score` lieka tik gražiam „+280" rodymui.
class GameProvider extends ChangeNotifier {
  final MathOp op;
  final GameLevel level;
  final List<LocalQuestion> _questions;

  GameProvider({required this.op, required this.level})
      : _questions = LocalQuestionGenerator().generateGame(op, level);

  int _index = 0;
  int _score = 0; // kosmetinis
  int _correctCount = 0;
  CellState _state = CellState.idle;
  int? _pickedOption; // ką paspaudė (klaidos paryškinimui)
  bool _finished = false;

  // --- Getter'iai UI ---
  int get index => _index;
  int get total => _questions.length;
  int get score => _score;
  int get correctCount => _correctCount;
  CellState get state => _state;
  int? get pickedOption => _pickedOption;
  bool get finished => _finished;
  LocalQuestion get current => _questions[_index];
  bool get isBusy => _state != CellState.idle; // blokuoja dvigubą paspaudimą

  /// Žaidėjas paspaudė atsakymą. [elapsedMs] — kiek užtruko (kosmetiniam bonusui).
  void answer(int selected, int elapsedMs) {
    if (isBusy || _finished) return;
    _pickedOption = selected;

    if (selected == current.answer) {
      _state = CellState.correct;
      _correctCount++;
      _score += _cosmeticPoints(elapsedMs);
    } else {
      _state = CellState.wrong;
      // švelnus modelis: 0 taškų, bet žaidimas tęsiasi
    }
    notifyListeners();
  }

  /// Laikas baigėsi nepaspaudus — klaida (švelnus modelis).
  void timeout() {
    if (isBusy || _finished) return;
    _state = CellState.wrong;
    _pickedOption = null;
    notifyListeners();
  }

  /// Pereiti prie kito klausimo (kviečiama po animacijos pauzės).
  void next() {
    if (_index + 1 >= _questions.length) {
      _finished = true;
    } else {
      _index++;
      _state = CellState.idle;
      _pickedOption = null;
    }
    notifyListeners();
  }

  /// Kosmetinis taškų skaičiavimas (vizualui) — atitinka serverio formulę,
  /// bet oficialus rezultatas vis tiek ateina iš serverio.
  int _cosmeticPoints(int elapsedMs) {
    final maxMs = level.maxTimeMs;
    final base = _basePoints();
    final clamped = elapsedMs.clamp(0, maxMs);
    final bonus = ((maxMs - clamped) / 10).floor();
    return base + bonus;
  }

  int _basePoints() {
    switch (level) {
      case GameLevel.lengvas:
        return 50;
      case GameLevel.vidutinis:
        return 100;
      case GameLevel.sunkus:
        return 150;
      case GameLevel.ekstremalus:
        return 200;
    }
  }
}
