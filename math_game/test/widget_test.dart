import 'package:flutter_test/flutter_test.dart';

import 'package:math_game/main.dart';

void main() {
  testWidgets('App paleidžiamas, rodo pavadinimą ir 4 veiksmų simbolius',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MathGameApp());

    // Pavadinimas ir veiksmų simboliai nepriklauso nuo kalbos.
    expect(find.text('MATH GAME'), findsOneWidget);
    expect(find.text('+'), findsOneWidget);
    expect(find.text('×'), findsOneWidget);
    expect(find.text('÷'), findsOneWidget);
  });
}
