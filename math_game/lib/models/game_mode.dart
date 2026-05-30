import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

/// Matematinis veiksmas. `id` SUTAMPA su serverio parseMode (add/sub/mul/div),
/// o `label`/`symbol` — tik žaidėjui rodyti. Niekada nesumaišom šitų dviejų.
enum MathOp { add, sub, mul, div }

extension MathOpX on MathOp {
  /// Serverio raktas (siunčiamas į startGame kaip mode pradžia).
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
    }
  }
}

/// Pilnas režimo identifikatorius serveriui, pvz. "mul_sunkus".
/// Sujungia veiksmą + lygį taip, kaip laukia backend parseMode.
String buildModeId(MathOp op, GameLevel level) => '${op.id}_${level.name}';
