import 'dart:async';
import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/game_models.dart';
import '../models/trivia_models.dart';

/// Serverio kvietimai (J žingsnis): startGame / submitScore.
///
/// Naudoja Cloud Functions (2nd Gen, onCall). App Check + Auth tokenai
/// pridedami automatiškai (firebase_service.dart sukonfigūruoja).
/// Regionas turi sutapti su serverio funkcijomis (europe-west1).
///
/// Tinklo atsparumas: kvietimai apgaubti _withRetry (Exponential Backoff).
/// Trumpas WiFi↔mobile blyksnis (JAV: autobusas, metro) nebesudegina partijos
/// — bandom dar 2 kartus su 1s ir 3s pauzėmis prieš pasiduodant.
class GameApi {
  GameApi._();

  static final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west1');

  /// Laikinos klaidos, kurias verta kartoti. Realios klaidos
  /// (unauthenticated, permission-denied, failed-precondition, invalid-argument)
  /// NEkartojamos — pakartojimas jų neištaisytų, tik gaišintų vartotoją.
  static const Set<String> _retryableCodes = {
    'unavailable',
    'deadline-exceeded',
    'internal',
    'unknown',
    'aborted',
    'cancelled',
  };

  /// Pauzės tarp bandymų. 2 įrašai = iš viso 3 bandymai (max ~4s laukimo,
  /// kad rezultatų ekrane nereiktų ilgai spoksoti į suktuką).
  static const List<Duration> _backoff = [
    Duration(seconds: 1),
    Duration(seconds: 3),
  ];

  /// Kvietimas su pakartojimu. Kartoja tik laikinas tinklo klaidas.
  static Future<T> _withRetry<T>(Future<T> Function() op) async {
    for (var attempt = 0;; attempt++) {
      try {
        return await op();
      } on FirebaseFunctionsException catch (e) {
        if (!_retryableCodes.contains(e.code) || attempt >= _backoff.length) {
          rethrow; // reali klaida arba bandymai išseko
        }
      } catch (e) {
        if (attempt >= _backoff.length) rethrow; // tinklo/socket klaida
      }
      await Future.delayed(_backoff[attempt]);
    }
  }

  /// Pradeda žaidimą: serveris generuoja 10 klausimų + variantus.
  /// [mode] — pvz. "mul_sunkus" (buildModeId rezultatas).
  static Future<GameSession> startGame(String mode) {
    return _withRetry(() async {
      final result = await _functions
          .httpsCallable('startGame')
          .call(<String, dynamic>{'mode': mode});
      // Serverio atsakymas ateina kaip Map<Object?,Object?> — JSON „perpakavimas"
      // jį paverčia tvarkingu Map<String,dynamic> (su visais įdėtais laukais).
      final data = jsonDecode(jsonEncode(result.data)) as Map<String, dynamic>;
      return GameSession.fromJson(data);
    });
  }

  /// Pateikia atsakymus: serveris tikrina, skaičiuoja taškus, rašo rekordą.
  static Future<GameResult> submitScore(
    String gameId,
    List<int> clientAnswers,
    List<int> clientTimesMs,
  ) {
    return _withRetry(() async {
      final result = await _functions
          .httpsCallable('submitScore')
          .call(<String, dynamic>{
        'gameId': gameId,
        'clientAnswers': clientAnswers,
        'clientTimesMs': clientTimesMs,
      });
      final data = jsonDecode(jsonEncode(result.data)) as Map<String, dynamic>;
      return GameResult.fromJson(data);
    });
  }

  // ---------------------------------------------------------------------------
  // GAMTOS TRIVIJA (izoliuotas srautas) — atskira funkcija startNatureGame.
  // Atsakymai grąžinami serveriui kaip ŽODŽIAI (List<String>), bet TAŠKUS
  // skaičiuoja TAS PATS submitScore pagal LAIKĄ (type-agnostic palyginimas).
  // ---------------------------------------------------------------------------

  /// Pradeda gamtos žaidimą: serveris parenka 10 klausimų pagal lygį + kalbą.
  /// [mode] — `nature_<lygis>` (pvz. "nature_lengvas").
  /// [lang] — "en" / "lt" (numatyta serveryje → "en", jei nežinoma).
  static Future<TriviaSession> startNatureGame(String mode, String lang) {
    return _withRetry(() async {
      final result = await _functions
          .httpsCallable('startNatureGame')
          .call(<String, dynamic>{'mode': mode, 'lang': lang});
      final data = jsonDecode(jsonEncode(result.data)) as Map<String, dynamic>;
      return TriviaSession.fromJson(data);
    });
  }

  /// Pradeda BENDROS žinių trivijos žaidimą (pop/geo/history/tech/food/sport/
  /// body). Serverio funkcija `startTriviaGame`. [mode] — `<tema>_<lygis>`
  /// (pvz. "tech_lengvas"). Atsakymas TOKS PAT kaip startNatureGame, todėl
  /// naudojam tą patį TriviaSession ir tą patį submitNatureScore pateikimą.
  static Future<TriviaSession> startTriviaGame(String mode, String lang) {
    return _withRetry(() async {
      final result = await _functions
          .httpsCallable('startTriviaGame')
          .call(<String, dynamic>{'mode': mode, 'lang': lang});
      final data = jsonDecode(jsonEncode(result.data)) as Map<String, dynamic>;
      return TriviaSession.fromJson(data);
    });
  }

  /// Pateikia gamtos atsakymus (žodžius). Naudoja TĄ PATĮ submitScore endpoint'ą
  /// kaip matematika — serveris palygina string===string, skaičiuoja pagal laiką.
  static Future<GameResult> submitNatureScore(
    String gameId,
    List<String> clientAnswers,
    List<int> clientTimesMs,
  ) {
    return _withRetry(() async {
      final result = await _functions
          .httpsCallable('submitScore')
          .call(<String, dynamic>{
        'gameId': gameId,
        'clientAnswers': clientAnswers,
        'clientTimesMs': clientTimesMs,
      });
      final data = jsonDecode(jsonEncode(result.data)) as Map<String, dynamic>;
      return GameResult.fromJson(data);
    });
  }
}
