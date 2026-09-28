import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocal_lens/main.dart';

void main() {
  testWidgets('VocalLens app smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // Build our app and trigger a frame.
    await tester.pumpWidget(const VocalLensApp());
    await tester.pump();

    // Verify app brand is rendered
    expect(find.text('VocalLens'), findsOneWidget);
  });
}
