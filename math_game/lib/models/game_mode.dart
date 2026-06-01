import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

/// Matematinis veiksmas/režimas. `id` SUTAMPA su serverio parseMode
/// (add/sub/mul/div/mix). `label`/`symbol` — tik žaidėjui.
enum MathOp { add, sub, mul, div, mix }

extension MathOpX on MathOp {
  /// Serverio raktas (mode pradžia).
  String get id {
    switch (this) {
      case MathOp.add:
        return 'add';
      case MathOp.sub:
        return 'sub';
      case MathOp.mul:
        return 'mul';
      case MathOp.div:
        return 'div';
      case MathOp.mix:
        return 'mix';
    }
  }

  /// Žaidėjui rodomas pavadinimas — iš AppStrings (LT/EN).
  String label(AppStrings s) {
    switch (this) {
      case MathOp.add:
        return s.opAdd;
      case MathOp.sub:
        return s.opSub;
      case MathOp.mul:
        return s.opMul;
      case MathOp.div:
        return s.opDiv;
      case MathOp.mix:
        return s.opMix2;
    }
  }

  /// Simbolis ant mygtuko.
  String get symbol {
    switch (this) {
      case MathOp.add:
        return '+';
      case MathOp.sub:
        return '−';
      case MathOp.mul:
        return '×';
      case MathOp.div:
        return '÷';
      case MathOp.mix:
        return '🌪️';
    }
  }
}

/// Pilnas režimo ID serveriui, pvz. "mix_sunkus".
String buildModeId(MathOp op, GameLevel level) => '${op.id}_${level.name}';
