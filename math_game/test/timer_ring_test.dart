import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_game/widgets/neon_timer_ring.dart';

void main() {
  testWidgets('NeonTimerRing sukasi ir iškviečia onTimeout pabaigoje',
      (WidgetTester tester) async {
    var timedOut = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NeonTimerRing(
          durationMs: 1000,
          onTimeout: () => timedOut = true,
        ),
      ),
    ));

    expect(timedOut, isFalse); // dar nesibaigė
    await tester.pump(const Duration(milliseconds: 1100));
    expect(timedOut, isTrue); // laikas baigėsi -> onTimeout
  });
}
