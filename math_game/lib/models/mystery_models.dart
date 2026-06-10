/// „Cyber-Ratelis" (Laimės ratas) serverio kontrakto modeliai (klientas).
///
/// SAUGUMAS: klientas NIEKADA negauna pilno teksto, kol paslaptis neišspręsta.
/// Gauna tik kaukę (brūkšneliai + atvertos raidės) ir raidžių „pool".
///
/// EKONOMIKA (B būdas / banko modelis): kiekviena paslaptis turi banką
/// (bankMax pagal lygį). Mokamos pagalbos „tirpdo" banką (didina `spent`),
/// o teisingai atspėjus dabartinis bankas (`potentialWin`) pridedamas prie
/// raktų (🔑). Bankas negali nukristi žemiau `floor` (50). Klaida banko
/// netirpdo — kainuoja tik vieną širdelę.
library;

/// Viena kaukės pozicija: arba raidės langelis (brūkšnelis / atverta raidė),
/// arba skyriklis (tarpas, kablelis — rodomas atvirai).
class MysteryCell {
  final bool slot; // true = raidės langelis; false = skyriklis
  final String? ch; // atverta raidė (slot) / skyriklio simbolis / null (paslėpta)

  const MysteryCell({required this.slot, required this.ch});

  factory MysteryCell.fromJson(Map<String, dynamic> j) => MysteryCell(
        slot: j['slot'] as bool? ?? false,
        ch: j['ch'] as String?,
      );
}

/// Visa aktyvios paslapties būsena (startMystery / revealLetters / resetMystery /
/// mysteryPowerup).
class MysteryView {
  final String mysteryId;
  final String hint; // nemokama užuomina/klausimas virš brūkšnelių
  final String category; // "patarle" / "citata" / "istorija" / "klausimas"
  final int level; // 1..4 (lemia banko dydį)
  final List<MysteryCell> mask;
  final List<String> pool; // sumaišytos raidės dėliojimui (didžiosios)
  final int totalLetters;
  final int revealedLetters;

  // --- Banko modelis ---
  final int bankMax; // didžiausias galimas laimėjimas šiam lygiui
  final int potentialWin; // DABARTINIS bankas = kiek 🔑 laimėtum atspėjęs DABAR
  final int spent; // kiek banko jau „ištirpdyta" mokamomis pagalbomis
  final int floor; // žemiausia banko riba (50)

  // --- Papildomos (mokamos) užuominos ---
  final bool hasHint1; // ar šiai paslapčiai egzistuoja 1-a papildoma užuomina
  final bool hasHint2;
  final bool hint1Unlocked; // ar jau nupirkta/atrakinta
  final bool hint2Unlocked;
  final String? hint1Text; // tekstas TIK kai atrakinta (kitaip null)
  final String? hint2Text;

  // --- Pagalbų kainos (serveris vis tiek pertikrina) ---
  final int costHint; // papildomos užuominos kaina
  final int costReveal; // raidės atvėrimo kaina
  final int costGuess; // +1 spėjimo kaina

  final int attemptsLeft; // kiek spėjimų liko
  final int pendingLetters; // dar nepanaudotos „pažadėtos" raidės iš kitų žaidimų
  final int keys; // bendras raktų (🔑) balansas
  final List<int> revealedNow; // ką tik atvertų pozicijų indeksai (animacijai)

  const MysteryView({
    required this.mysteryId,
    required this.hint,
    required this.category,
    this.level = 1,
    required this.mask,
    required this.pool,
    required this.totalLetters,
    required this.revealedLetters,
    required this.bankMax,
    required this.potentialWin,
    this.spent = 0,
    this.floor = 50,
    this.hasHint1 = false,
    this.hasHint2 = false,
    this.hint1Unlocked = false,
    this.hint2Unlocked = false,
    this.hint1Text,
    this.hint2Text,
    this.costHint = 50,
    this.costReveal = 50,
    this.costGuess = 30,
    required this.attemptsLeft,
    this.pendingLetters = 0,
    this.keys = 0,
    this.revealedNow = const [],
  });

  /// Ar užtenka banko šiai kainai (banko taisyklė: bankas − kaina ≥ floor).
  bool canAfford(int cost) => (potentialWin - cost) >= floor;

  /// Kopija su pakeistais laukais (pvz. atnaujinti likę spėjimai po klaidos,
  /// neperkraunant viso ekrano iš serverio).
  MysteryView copyWith({
    int? attemptsLeft,
    int? potentialWin,
    int? spent,
    int? keys,
  }) {
    return MysteryView(
      mysteryId: mysteryId,
      hint: hint,
      category: category,
      level: level,
      mask: mask,
      pool: pool,
      totalLetters: totalLetters,
      revealedLetters: revealedLetters,
      bankMax: bankMax,
      potentialWin: potentialWin ?? this.potentialWin,
      spent: spent ?? this.spent,
      floor: floor,
      hasHint1: hasHint1,
      hasHint2: hasHint2,
      hint1Unlocked: hint1Unlocked,
      hint2Unlocked: hint2Unlocked,
      hint1Text: hint1Text,
      hint2Text: hint2Text,
      costHint: costHint,
      costReveal: costReveal,
      costGuess: costGuess,
      attemptsLeft: attemptsLeft ?? this.attemptsLeft,
      pendingLetters: pendingLetters,
      keys: keys ?? this.keys,
      revealedNow: revealedNow,
    );
  }

  factory MysteryView.fromJson(Map<String, dynamic> j) {
    final rawMask = (j['mask'] as List<dynamic>?) ?? const [];
    final rawPool = (j['pool'] as List<dynamic>?) ?? const [];
    final rawNow = (j['revealedNow'] as List<dynamic>?) ?? const [];
    return MysteryView(
      mysteryId: j['mysteryId'] as String? ?? '',
      hint: j['hint'] as String? ?? '',
      category: j['category'] as String? ?? '',
      level: (j['level'] as num?)?.toInt() ?? 1,
      mask: rawMask
          .map((e) => MysteryCell.fromJson(e as Map<String, dynamic>))
          .toList(),
      pool: rawPool.map((e) => e.toString()).toList(),
      totalLetters: (j['totalLetters'] as num?)?.toInt() ?? 0,
      revealedLetters: (j['revealedLetters'] as num?)?.toInt() ?? 0,
      bankMax: (j['bankMax'] as num?)?.toInt() ?? 0,
      potentialWin: (j['potentialWin'] as num?)?.toInt() ?? 0,
      spent: (j['spent'] as num?)?.toInt() ?? 0,
      floor: (j['floor'] as num?)?.toInt() ?? 50,
      hasHint1: j['hasHint1'] as bool? ?? false,
      hasHint2: j['hasHint2'] as bool? ?? false,
      hint1Unlocked: j['hint1Unlocked'] as bool? ?? false,
      hint2Unlocked: j['hint2Unlocked'] as bool? ?? false,
      hint1Text: j['hint1Text'] as String?,
      hint2Text: j['hint2Text'] as String?,
      costHint: (j['costHint'] as num?)?.toInt() ?? 50,
      costReveal: (j['costReveal'] as num?)?.toInt() ?? 50,
      costGuess: (j['costGuess'] as num?)?.toInt() ?? 30,
      attemptsLeft: (j['attemptsLeft'] as num?)?.toInt() ?? 5,
      pendingLetters: (j['pendingLetters'] as num?)?.toInt() ?? 0,
      keys: (j['keys'] as num?)?.toInt() ?? 0,
      revealedNow: rawNow.map((e) => (e as num).toInt()).toList(),
    );
  }
}

/// Lengvas statusas meniu ženkliukui + profiliui (getMysteryStatus).
class MysteryStatus {
  final int pendingLetters; // laukia neatvertų raidžių (ženkliukas)
  final int solvedCount; // išspręsta paslapčių (profilio statistika)

  const MysteryStatus({required this.pendingLetters, required this.solvedCount});

  factory MysteryStatus.fromJson(Map<String, dynamic> j) => MysteryStatus(
        pendingLetters: (j['pendingLetters'] as num?)?.toInt() ?? 0,
        solvedCount: (j['solvedCount'] as num?)?.toInt() ?? 0,
      );
}

/// Spėjimo rezultatas (guessMystery).
///
/// Banko modelyje klaida banko netirpdo (kainuoja tik širdelę), todėl
/// `penalty` lauko nebėra.
class GuessOutcome {
  final bool correct;
  final int awarded; // laimėti raktai 🔑 (= bankas, jei teisinga)
  final int totalKeys; // raktų balansas po spėjimo
  final int attemptsLeft; // kiek spėjimų liko po šio (0 = baigėsi)
  final bool exhausted; // true = bandymai išseko, paslaptis pralaimėta
  final String? answer; // pilnas tekstas — kai teisinga ARBA kai bandymai išseko

  const GuessOutcome({
    required this.correct,
    required this.awarded,
    required this.totalKeys,
    this.attemptsLeft = 0,
    this.exhausted = false,
    this.answer,
  });

  factory GuessOutcome.fromJson(Map<String, dynamic> j) => GuessOutcome(
        correct: j['correct'] as bool? ?? false,
        awarded: (j['awarded'] as num?)?.toInt() ?? 0,
        totalKeys: (j['totalKeys'] as num?)?.toInt() ?? 0,
        attemptsLeft: (j['attemptsLeft'] as num?)?.toInt() ?? 0,
        exhausted: j['exhausted'] as bool? ?? false,
        answer: j['answer'] as String?,
      );
}

/// Galios priemonės rezultatas (mysteryPowerup).
///
/// Grąžina pilną atnaujintą paslapties būseną (kaip MysteryView), nes po
/// raidės atvėrimo, užuominos ar +spėjimo keičiasi kaukė, pool, bankas ir spėjimai.
class PowerupOutcome {
  final MysteryView view; // atnaujinta būsena (mask, pool, bankas, attemptsLeft)
  final List<int> revealedNow; // ką tik atverta raidė (animacijai)

  const PowerupOutcome({required this.view, this.revealedNow = const []});

  factory PowerupOutcome.fromJson(Map<String, dynamic> j) => PowerupOutcome(
        view: MysteryView.fromJson(j),
        revealedNow: ((j['revealedNow'] as List<dynamic>?) ?? const [])
            .map((e) => (e as num).toInt())
            .toList(),
      );
}
