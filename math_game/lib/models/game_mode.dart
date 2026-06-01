import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

/// Matematinis veiksmas/režimas. `id` SUTAMPA su serverio parseMode.
/// (Kids — Grupė B, vėliau su ikonomis.)
enum MathOp { add, sub, mul, div, mix, brackets, algebra }

extension MathOpX on MathOp {
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
      case MathOp.brackets:
        return 'brackets';
      case MathOp.algebra:
        return 'algebra';
    }
  }

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
      case MathOp.brackets:
        return s.opBrackets;
      case MathOp.algebra:
        return s.opAlgebra;
    }
  }

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
      case MathOp.brackets:
        return '( )';
      case MathOp.algebra:
        return 'x';
    }
  }
}

/// Pilnas režimo ID serveriui, pvz. "brackets_sunkus".
String buildModeId(MathOp op, GameLevel level) => '${op.id}_${level.name}';
