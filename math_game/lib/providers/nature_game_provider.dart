import 'package:flutter/foundation.dart';
import '../models/game_models.dart';
import '../models/trivia_models.dart';
import '../services/firebase_service.dart';
import '../services/game_api.dart';

/// Langelio būsena (vizualui) — tokia pati kaip matematikoj.
enum NatureCellState { idle, correct, wrong }

/// Pakrovimo būsena: kraunasi / paruošta / klaida.
enum NatureLoadState { loading, ready, error }

/// Gamtos trivijos žaidimo būsena (ChangeNotifier — be papildomų paketų).
///
/// SKIRTUMAS nuo GameProvider (matematikos):
///  - atsakymai yra ŽODŽIAI (String), ne skaičiai;
///  - NĖRA offline atsargos — gamtos klausimai gyvena serveryje. Jei serveris
///    nepasiekiamas → klaidos būsena (vartotojas mato „bandyk vėliau"),
///    NES be patvirtinto turinio negalim garantuoti teisingų faktų.
///
/// ⚠️ Taškai ČIA — kosmetika. Oficialius skaičiuoja serveris (submitScore).
class NatureGameProvider extends ChangeNotifier {
  final String modeId; // "nature_lengvas" arba "tech_lengvas"
  final String lang; // "en" / "lt"

  /// Kurį serverio startą kviesti:
  ///  - false (numatyta) → startNatureGame (gamta su potemėmis, NEPALIESTA);
  ///  - true             → startTriviaGame (bendros naujos žinių temos).
  /// Atsakymas ir pateikimas (submitNatureScore → submitScore) IDENTIŠKI.
  final bool useTrivia;

  NatureGameProvider({
    required this.modeId,
    required this.lang,
    this.useTrivia = false,
  }) {
    _load();
  }

  // Sesijos duomenys
  List<TriviaQuestion> _questions = const [];
  String? _gameId;
  NatureLoadState _loadState = NatureLoadState.loading;
  int _maxTimeMs = 4000;

  // Eiga
  int _index = 0;
  int _score = 0; // kosmetinis
  int _correctCount = 0;
  NatureCellState _state = NatureCellState.idle;
  String? _pickedOption;
  bool _finished = false;
  final List<String> _clientAnswers = []; // žodžiai (serveriui)
  final List<int> _clientTimesMs = []; // kiek truko kiekvienas langelis

  // --- Getter'iai UI ---
  NatureLoadState get loadState => _loadState;
  int get index => _index;
  int get total => _questions.length;
  int get score => _score;
  int get correctCount => _correctCount;
  NatureCellState get state => _state;
  String? get pickedOption => _pickedOption;
  bool get finished => _finished;
  int get maxTimeMs => _maxTimeMs;
  TriviaQuestion get current => _questions[_index];
  bool get isBusy => _state != NatureCellState.idle;

  /// Klausimai (peržiūrai pabaigoje: tekstas, teisingas, emoji, paaiškinimas).
  List<TriviaQuestion> get questions => _questions;

  /// Žaidėjo pasirinkti atsakymai (peržiūrai). "" = praleista / laikas baigėsi.
  List<String> get clientAnswers => _clientAnswers;

  /// Pakrauna klausimus iš serverio. Klaida → error būsena (be atsargos).
  Future<void> _load() async {
    _loadState = NatureLoadState.loading;
    notifyListeners();

    if (!FirebaseService.ready) {
      _loadState = NatureLoadState.error;
      notifyListeners();
      return;
    }

    try {
      final session = useTrivia
          ? await GameApi.startTriviaGame(modeId, lang)
          : await GameApi.startNatureGame(modeId, lang);
      if (session.questions.isEmpty) {
        _loadState = NatureLoadState.error;
        notifyListeners();
        return;
      }
      _gameId = session.gameId;
      _maxTimeMs = session.maxTimeMs;
      _questions = session.questions;
      _loadState = NatureLoadState.ready;
      notifyListeners();
    } catch (_) {
      _loadState = NatureLoadState.error;
      notifyListeners();
    }
  }

  /// Bandyti pakrauti dar kartą (klaidos ekrano mygtukas).
  Future<void> retry() => _load();

  /// Žaidėjas paspaudė atsakymą. [elapsedMs] — laikas (kosmetiniam bonusui).
  void answer(String selected, int elapsedMs) {
    if (isBusy || _finished) return;
    _pickedOption = selected;
    _clientAnswers.add(selected);
    _clientTimesMs.add(elapsedMs);

    if (selected == current.answer) {
      _state = NatureCellState.correct;
      _correctCount++;
      _score += _cosmeticPoints(elapsedMs);
    } else {
      _state = NatureCellState.wrong;
    }
    notifyListeners();
  }

  /// Laikas pasibaigė — praleista (0 taškų). "" = neatsakyta (serveris: 0).
  void timeout() {
    if (isBusy || _finished) return;
    _state = NatureCellState.wrong;
    _pickedOption = null;
    _clientAnswers.add(''); // tuščias niekada nesutaps su teisingu → 0 taškų
    _clientTimesMs.add(maxTimeMs);
    notifyListeners();
  }

  /// Pereiti prie kito klausimo.
  void next() {
    if (_index + 1 >= _questions.length) {
      _finished = true;
    } else {
      _index++;
      _state = NatureCellState.idle;
      _pickedOption = null;
    }
    notifyListeners();
  }

  /// Pabaigus — siunčia rezultatą serveriui (TAS PATS submitScore).
  /// Grąžina pilną GameResult (su coins, promptName) arba null (klaida).
  Future<GameResult?> submitToServer() async {
    if (_gameId == null) return null;
    try {
      return await GameApi.submitNatureScore(
          _gameId!, _clientAnswers, _clientTimesMs);
    } catch (_) {
      return null;
    }
  }

  /// Kosmetiniai taškai (vizualui) — atitinka serverio V2 formulę:
  /// max(10, 100 − sekundės × 3). Oficialius sprendžia serveris.
  int _cosmeticPoints(int elapsedMs) {
    final capped = elapsedMs.clamp(0, 30000);
    final seconds = capped / 1000.0;
    final score = 100 - seconds * 3;
    return score < 10 ? 10 : score.floor();
  }
}
