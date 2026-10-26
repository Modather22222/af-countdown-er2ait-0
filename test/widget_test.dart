import 'package:countdown/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the countdown dashboard', (tester) async {
    await tester.pumpWidget(const CountdownApp());

    expect(find.text('Countdown'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('New countdown'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
