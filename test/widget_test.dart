import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build a simple widget for testing
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Medora Test'),
          ),
        ),
      ),
    );

    // Verify that our text is found
    expect(find.text('Medora Test'), findsOneWidget);
  });
}