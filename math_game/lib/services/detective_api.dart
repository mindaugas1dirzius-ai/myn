import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/detective_models.dart';

/// 🕵️ Detektyvo serverio kvietimai.
///
/// Visa logika serveryje: žodis, atsakymai, bankas, gyvybės ir dienos
/// limitas skaičiuojami tik ten. App Check + Auth pridedami automatiškai.
class DetectiveApi {
  DetectiveApi._();

  static final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west1');

  static Map<String, dynamic> _decode(dynamic data) =>
      jsonDecode(jsonEncode(data)) as Map<String, dynamic>;

  /// Pradeda naują bylą (arba grąžina aktyvią — resume).
  static Future<DetectiveView> start(String lang, int level) async {
    final r = await _functions
        .httpsCallable('startDetective')
        .call(<String, dynamic>{'lang': lang, 'level': level});
    return DetectiveView.fromJson(_decode(r.data));
  }

  /// Perka klausimo atsakymą iš bylos banko.
  static Future<DetectiveClueOutcome> buyClue(int i) async {
    final r = await _functions
        .httpsCallable('buyDetectiveClue')
        .call(<String, dynamic>{'i': i});
    return DetectiveClueOutcome.fromJson(_decode(r.data));
  }

  /// Spėja slaptą žodį TEKSTU (✍️ — premija, kai byla turi lentą).
  static Future<DetectiveGuessOutcome> guess(String guess) async {
    final r = await _functions
        .httpsCallable('guessDetective')
        .call(<String, dynamic>{'guess': guess});
    return DetectiveGuessOutcome.fromJson(_decode(r.data));
  }

  /// Spėja LENTOS kortele (🎯 pick — indeksas serverio atsiųstoje tvarkoje).
  static Future<DetectiveGuessOutcome> pick(int index) async {
    final r = await _functions
        .httpsCallable('guessDetective')
        .call(<String, dynamic>{'pick': index});
    return DetectiveGuessOutcome.fromJson(_decode(r.data));
  }

  /// Perka SOS mįslę (atrakinama likus 1 gyvybei; i = -1 serveryje).
  static Future<DetectiveClueOutcome> buySos() => buyClue(-1);

  /// SPĖJIMO LANGAS: SPĖTI sustabdo laiką 1 min raidėms suvesti (i = -2).
  /// Grąžina atnaujintą bylos vaizdą su lockedAt/freezesLeft.
  static Future<DetectiveView> openGuessWindow() async {
    final r = await _functions
        .httpsCallable('buyDetectiveClue')
        .call(<String, dynamic>{'i': -2});
    return DetectiveView.fromJson(_decode(r.data));
  }

  /// Pasiduoda (žodis parodomas, byla perdega).
  static Future<String?> abandon() async {
    final r = await _functions.httpsCallable('abandonDetective').call();
    final m = _decode(r.data);
    return m['word'] as String?;
  }
}
