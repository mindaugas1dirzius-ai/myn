import 'package:cloud_functions/cloud_functions.dart';
import '../models/game_models.dart';

/// Serverio kvietimai (J žingsnis): startGame / submitScore.
///
/// Naudoja Cloud Functions (2nd Gen, onCall). App Check + Auth tokenai
/// pridedami automatiškai (firebase_service.dart sukonfigūruoja).
/// Regionas turi sutapti su serverio funkcijomis (europe-west1).
class GameApi {
  GameApi._();

  static final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west1');

  /// Pradeda žaidimą: serveris generuoja 10 klausimų + variantus.
  /// [mode] — pvz. "mul_sunkus" (buildModeId rezultatas).
  static Future<GameSession> startGame(String mode) async {
    final result = await _functions
        .httpsCallable('startGame')
        .call<Map<String, dynamic>>({'mode': mode});
    return GameSession.fromJson(Map<String, dynamic>.from(result.data));
  }

  /// Pateikia atsakymus: serveris tikrina, skaičiuoja taškus, rašo rekordą.
  static Future<GameResult> submitScore(
    String gameId,
    List<int> clientAnswers,
  ) async {
    final result = await _functions
        .httpsCallable('submitScore')
        .call<Map<String, dynamic>>({
      'gameId': gameId,
      'clientAnswers': clientAnswers,
    });
    return GameResult.fromJson(Map<String, dynamic>.from(result.data));
  }
}
