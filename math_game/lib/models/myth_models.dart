/// 🧐 „Tiesa ar mitas?" serverio kontrakto modeliai.
///
/// `isTrue` ir paaiškinimas ateina su teiginiu (variantas C — momentinė
/// reakcija + mokomasis paaiškinimas be round-tripo; taškus skaičiuoja
/// serveris pagal LAIKĄ per esamą submitScore).
library;

/// Vienas teiginys.
class MythStatementView {
  final String st; // teiginys
  final String ex; // paaiškinimas (rodomas PO atsakymo)
  final bool isTrue; // ✅ tiesa ar ❌ mitas
  final String emoji; // subjekto paveikslėlis (🐝/🌙/⚡) — kortelės vaizdui

  const MythStatementView(
      {required this.st,
      required this.ex,
      required this.isTrue,
      this.emoji = ''});

  factory MythStatementView.fromJson(Map<String, dynamic> j) =>
      MythStatementView(
        st: j['st'] as String? ?? '',
        ex: j['ex'] as String? ?? '',
        isTrue: j['isTrue'] as bool? ?? false,
        emoji: j['emoji'] as String? ?? '',
      );
}

/// startMythGame atsakymas.
class MythSession {
  final String gameId;
  final int maxTimeMs;
  final List<MythStatementView> statements;

  const MythSession(
      {required this.gameId,
      required this.maxTimeMs,
      required this.statements});

  factory MythSession.fromJson(Map<String, dynamic> j) => MythSession(
        gameId: j['gameId'] as String? ?? '',
        maxTimeMs: (j['maxTimeMs'] as num?)?.toInt() ?? 30000,
        statements: ((j['statements'] as List<dynamic>?) ?? const [])
            .map((e) => MythStatementView.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
