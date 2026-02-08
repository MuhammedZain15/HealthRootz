import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grad_project/patient/layout/patient_layout.dart';

void main() {
  testWidgets('AppLayout has BottomAppBar and FAB', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AppLayout()));

    // Verify FAB exists
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);

    // Verify BottomAppBar exists
    expect(find.byType(BottomAppBar), findsOneWidget);

    // Verify Bottom Sheet opens on FAB tap
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verify Bottom Sheet content
    expect(find.text('Chat with Doctor'), findsOneWidget);
    expect(find.text('Chat with AI'), findsOneWidget);
    expect(
      find.byIcon(Icons.person),
      findsNWidgets(2),
    ); // One in nav bar, one in bottom sheet
    expect(find.byIcon(Icons.smart_toy), findsOneWidget);
  });
}
