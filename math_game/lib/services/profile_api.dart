import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Profilio duomenys (Etapas 1): Personal Best + getMyRank.
class ProfileApi {
  ProfileApi._();

  static final _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west1');

  /// Žaidėjo geriausias rezultatas konkrečiam režimui (pigus skaitymas).
  /// Grąžina null, jei dar nežaista.
  static Future<int?> personalBest(String mode) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final doc = await FirebaseFirestore.instance
        .collection('leaderboard')
        .doc('${uid}_$mode')
        .get();
    if (!doc.exists) return null;
    return (doc.data()?['score'] as num?)?.toInt();
  }

  /// Žaidėjo vardas iš users/{uid} (arba null).
  static Future<String?> username() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data()?['username'] as String?;
  }

  /// Išsaugo žaidėjo pasirinktą vardą (serveris sanitizuos kitą submitScore).
  static Future<void> saveUsername(String name) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({'username': name}, SetOptions(merge: true));
  }

  /// Pozicija pasaulyje (getMyRank Cloud Function) — TIK paspaudus režimą.
  /// Grąžina {hasScore, rank, total, score} arba {hasScore:false}.
  static Future<RankResult> myRank(String mode) async {
    final res = await _functions
        .httpsCallable('getMyRank')
        .call<Map<String, dynamic>>({'mode': mode});
    final data = Map<String, dynamic>.from(res.data);
    if (data['hasScore'] != true) return const RankResult.none();
    return RankResult(
      rank: (data['rank'] as num).toInt(),
      total: (data['total'] as num).toInt(),
      score: (data['score'] as num).toInt(),
    );
  }
}

/// getMyRank rezultatas.
class RankResult {
  final bool hasScore;
  final int rank;
  final int total;
  final int score;

  const RankResult({
    required this.rank,
    required this.total,
    required this.score,
  }) : hasScore = true;

  const RankResult.none()
      : hasScore = false,
        rank = 0,
        total = 0,
        score = 0;
}
