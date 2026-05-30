import 'package:flutter_test/flutter_test.dart';

import 'package:math_game/main.dart';

void main() {
  testWidgets('App paleidžiamas ir rodo pavadinimą', (WidgetTester tester) async {
    await tester.pumpWidget(const MathGameApp());
    expect(find.text('MATH GAME'), findsOneWidget);
  });
}
