import 'package:flutter/foundation.dart';
import '../models/game_mode.dart';
import '../models/local_question.dart';
import '../services/firebase_service.dart';
import '../services/game_api.dart';
import '../services/local_question_generator.dart';
import '../theme/app_theme.dart';

/// Langelio būsena (vizualui).
enum CellState { idle, correct, wrong }

/// Pakrovimo būsena (J žingsnis): kol serveris generuoja klausimus.
enum LoadState { loading, ready, error }

/// Iš kur gauti klausimai.
enum Source { server, offline }

/// Aktyvios žaidimo sesijos būsena. ChangeNotifier — be papildomų paketų.
///
/// J žingsnis: klausimai imami iš SERVERIO (startGame). Jei serveris
/// nepasiekiamas (nėra interneto, App Check, klaida) — krentam į OFFLINE
/// (LocalQuestionGenerator). Offline rezultatas NEįrašomas į Top 10.
///
/// ⚠️ Taškai ČIA — kosmetika. Oficialius skaičiuoja serveris (submitScore).
class GameProvider extends ChangeNotifier {
  final MathOp op;
  final GameLevel level;
  final String modeId;

  GameProvider({
    required this.op,
    required this.level,
    required this.modeId,
  }) {
    _load();
  }

  // Sesijos duomenys
  List<LocalQuestion> _questions = const [];
  String? _gameId; // serverio žaidimo ID (null offline režime)
  Source _source = Source.offline;
  LoadState _loadState = LoadState.loading;
  int _maxTimeMs = 30000; // langelio riba (V2: 30s); iš serverio arba default

  // Eiga
  int _index = 0;
  int _score = 0; // kosmetinis
  int _correctCount = 0;
  CellState _state = CellState.idle;
  int? _pickedOption;
  bool _finished = false;
  final List<int> _clientAnswers = []; // ką žaidėjas atsakė (serveriui)
  final List<int> _clientTimesMs = []; // kiek truko kiekvienas langelis (taškams)

  // --- Getter'iai UI ---
  LoadState get loadState => _loadState;
  Source get source => _source;
  int get index => _index;
  int get total => _questions.length;
  int get score => _score;
  int get correctCount => _correctCount;
  CellState get state => _state;
  int? get pickedOption => _pickedOption;
  bool get finished => _finished;
  int get maxTimeMs => _maxTimeMs; // langelio laikmačio riba (žiedui)
  LocalQuestion get current => _questions[_index];
  bool get isBusy => _state != CellState.idle;

  /// Pakrauna klausimus: bando serverį, krenta į offline.
  Future<void> _load() async {
    _loadState = LoadState.loading;
    notifyListeners();

    if (FirebaseService.ready) {
      try {
        final session = await GameApi.startGame(modeId);
        _gameId = session.gameId;
        _maxTimeMs = session.maxTimeMs; // 30s riba iš serverio
        _questions = session.questions
            .map((q) => LocalQuestion(
                  text: q.action,
                  options: q.options,
                  answer: q.answer,
                ))
            .toList();
        _source = Source.server;
        _loadState = LoadState.ready;
        notifyListeners();
        return;
      } catch (_) {
        // Serveris nepavyko — tęsiam offline (fallback).
      }
    }

    // Offline fallback
    _questions = LocalQuestionGenerator().generateGame(op, level);
    _gameId = null;
    _source = Source.offline;
    _loadState = LoadState.ready;
    notifyListeners();
  }

  /// Žaidėjas paspaudė atsakymą. [elapsedMs] — laikas (kosmetiniam bonusui).
  void answer(int selected, int elapsedMs) {
    if (isBusy || _finished) return;
    _pickedOption = selected;
    _clientAnswers.add(selected);
    _clientTimesMs.add(elapsedMs);

    if (selected == current.answer) {
      _state = CellState.correct;
      _correctCount++;
      _score += _cosmeticPoints(elapsedMs);
    } else {
      _state = CellState.wrong;
    }
    notifyListeners();
  }

  /// Laikas pasiekė 30s ribą — praleista (0 taškų). -1 = neatsakyta serveriui.
  void timeout() {
    if (isBusy || _finished) return;
    _state = CellState.wrong;
    _pickedOption = null;
    _clientAnswers.add(-1);
    _clientTimesMs.add(maxTimeMs); // pilnas laikas (30s)
    notifyListeners();
  }

  /// Pereiti prie kito klausimo.
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

  /// Pabaigus žaidimą — siunčia rezultatą serveriui (jei server režimas).
  /// Grąžina oficialų serverio rezultatą arba null (offline / klaida).
  Future<int?> submitToServer() async {
    if (_source != Source.server || _gameId == null) return null;
    try {
      final result =
          await GameApi.submitScore(_gameId!, _clientAnswers, _clientTimesMs);
      return result.finalScore;
    } catch (_) {
      return null; // tinklo klaida — paliekam kosmetinį
    }
  }

  /// Kosmetiniai taškai (vizualui) — atitinka serverio V2 formulę:
  /// max(10, maxPoints − sekundės × 4). Oficialius sprendžia serveris.
  int _cosmeticPoints(int elapsedMs) {
    final capped = elapsedMs.clamp(0, 30000);
    final seconds = capped / 1000.0;
    final score = _maxPoints() - seconds * 4;
    return score < 10 ? 10 : score.floor();
  }

  int _maxPoints() {
    switch (level) {
      case GameLevel.lengvas:
        return 100;
      case GameLevel.vidutinis:
        return 150;
      case GameLevel.sunkus:
        return 200;
      case GameLevel.ekstremalus:
        return 300;
    }
  }
}
