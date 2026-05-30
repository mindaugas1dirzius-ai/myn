import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_game/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen rodo pavadinimą ir bent vieną veiksmą',
      (WidgetTester tester) async {
    // Didelis viewport, kad tilptų visas tinklelis.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump();

    expect(find.text('MATH GAME'), findsOneWidget);
    expect(find.text('+'), findsOneWidget); // Addition simbolis
  });
}
