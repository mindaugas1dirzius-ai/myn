/// Lokalus klausimas — TIK offline žaidimui (G4).
///
/// SKIRIASI nuo serverio `MathQuestion` (game_models.dart): šis turi `answer`,
/// nes telefonas pats tikrina. Serverio versija atsakymo NETURI (slepiamas).
///
/// ⚠️ LAIKINA: J žingsnyje klausimus duos serveris (startGame), tada šis
/// modelis ir lokalus generatorius bus pakeisti serverio duomenimis.
class LocalQuestion {
  final String text; // pvz. "6 × 7"
  final List<int> options; // 6 sumaišytų variantų
  final int answer; // teisingas (lokaliai žinomas)

  const LocalQuestion({
    required this.text,
    required this.options,
    required this.answer,
  });
}
