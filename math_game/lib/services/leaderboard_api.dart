import 'package:cloud_firestore/cloud_firestore.dart';

/// Vienas Top 10 lentelės įrašas (atitinka serverio `leaderboard` struktūrą:
/// dokumentas {uid}_{mode} su laukais uid/username/mode/score/timestamp).
class LeaderboardEntry {
  final String username;
  final int score;

  const LeaderboardEntry({required this.username, required this.score});

  factory LeaderboardEntry.fromDoc(Map<String, dynamic> data) {
    return LeaderboardEntry(
      username: data['username'] as String? ?? 'Žaidėjas',
      score: (data['score'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Top 10 skaitymas iš Firestore. Rašo TIK serveris — klientas tik skaito
/// (Security Rules: leaderboard read if auth, write if false).
class LeaderboardApi {
  LeaderboardApi._();

  /// Top 10 įrašų konkrečiam režimui (pvz. "mul_sunkus"), nuo didžiausio.
  static Stream<List<LeaderboardEntry>> top10(String mode) {
    return FirebaseFirestore.instance
        .collection('leaderboard')
        .where('mode', isEqualTo: mode)
        .orderBy('score', descending: true)
        .limit(10)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => LeaderboardEntry.fromDoc(d.data())).toList());
  }
}
