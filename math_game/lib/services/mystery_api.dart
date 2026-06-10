import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/mystery_models.dart';

/// „Atspėk paslaptį" serverio kvietimai.
///
/// Visa logika serveryje (saugumas): klientas tik prašo būsenos, atveria
/// raides (iš jau uždirbto „pending"), spėja ir nusinulina. App Check + Auth
/// tokenai pridedami automatiškai (firebase_service.dart).
class MysteryApi {
  MysteryApi._();

  static final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west1');

  static Map<String, dynamic> _decode(dynamic data) =>
      jsonDecode(jsonEncode(data)) as Map<String, dynamic>;

  /// Užkrauna (ar sukuria) aktyvią paslaptį.
  static Future<MysteryView> start(String lang) async {
    final r = await _functions
        .httpsCallable('startMystery')
        .call(<String, dynamic>{'lang': lang});
    return MysteryView.fromJson(_decode(r.data));
  }

  /// Atveria raides iš sukauptų (po žaidimų) „pažadėtų" raidžių.
  static Future<MysteryView> reveal(String lang) async {
    final r = await _functions
        .httpsCallable('revealLetters')
        .call(<String, dynamic>{'lang': lang});
    return MysteryView.fromJson(_decode(r.data));
  }

  /// Spėja visą tekstą. Serveris grąžina true/false + monetų pokytį.
  static Future<GuessOutcome> guess(String guess) async {
    final r = await _functions
        .httpsCallable('guessMystery')
        .call(<String, dynamic>{'guess': guess});
    return GuessOutcome.fromJson(_decode(r.data));
  }

  /// Perka galios priemonę už raktus (🔑). action: "revealLetter" | "extraGuess".
  /// Serveris nuima raktus atomiškai ir grąžina atnaujintą būseną.
  static Future<PowerupOutcome> powerup(String action) async {
    final r = await _functions
        .httpsCallable('mysteryPowerup')
        .call(<String, dynamic>{'action': action});
    return PowerupOutcome.fromJson(_decode(r.data));
  }

  /// Atsisako dabartinės paslapties ir gauna naują (nuo nulio).
  static Future<MysteryView> reset(String lang) async {
    final r = await _functions
        .httpsCallable('resetMystery')
        .call(<String, dynamic>{'lang': lang});
    return MysteryView.fromJson(_decode(r.data));
  }

  /// Lengvas statusas (ženkliukui/profiliui). Klaida → null (tyliai praleidžiam).
  static Future<MysteryStatus?> status() async {
    try {
      final r = await _functions.httpsCallable('getMysteryStatus').call();
      return MysteryStatus.fromJson(_decode(r.data));
    } catch (_) {
      return null;
    }
  }
}
