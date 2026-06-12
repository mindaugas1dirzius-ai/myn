import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/melt_models.dart';

/// „Raidžių tirpimas" serverio kvietimai.
///
/// Visa logika serveryje: laikas, raidžių atsivėrimas ir taškai skaičiuojami
/// tik ten. Klientas tik rodo lentą ir siunčia spėjimus. App Check + Auth
/// tokenai pridedami automatiškai (firebase_service.dart).
class MeltApi {
  MeltApi._();

  static final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west1');

  static Map<String, dynamic> _decode(dynamic data) =>
      jsonDecode(jsonEncode(data)) as Map<String, dynamic>;

  /// Pradeda naują partiją (arba grąžina aktyvią — tada nustatymai ignoruojami).
  static Future<MeltView> start(
      String lang, int limitSec, int intervalSec, int level) async {
    final r = await _functions.httpsCallable('startMelt').call(<String, dynamic>{
      'lang': lang,
      'limitSec': limitSec,
      'intervalSec': intervalSec,
      'level': level,
    });
    return MeltView.fromJson(_decode(r.data));
  }

  /// Atnaujina lentą (kviesti ties raidės atsivėrimo riba ir grįžus į programą).
  static Future<MeltSync> sync() async {
    final r = await _functions.httpsCallable('syncMelt').call();
    return MeltSync.fromJson(_decode(r.data));
  }

  /// Spėja visą tekstą.
  static Future<MeltGuessOutcome> guess(String guess) async {
    final r = await _functions
        .httpsCallable('guessMelt')
        .call(<String, dynamic>{'guess': guess});
    return MeltGuessOutcome.fromJson(_decode(r.data));
  }

  /// Pasiduoda (pralaimėjimas be taškų). Grąžina atsakymą parodymui.
  static Future<String?> abandon() async {
    final r = await _functions.httpsCallable('abandonMelt').call();
    final m = _decode(r.data);
    return m['answer'] as String?;
  }
}
