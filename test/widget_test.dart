import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drag_pdf/main.dart';

void main() {
  testWidgets('App starts and renders PdfCombinerScreen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that the AppBar is rendered.
    expect(find.byType(AppBar), findsOneWidget);

    // Verify that the float/action button is rendered.
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
