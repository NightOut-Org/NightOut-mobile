import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nightout_core/nightout_core.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget app({required bool reduceMotion}) {
    return MaterialApp(
      theme: nightOutTheme(Brightness.dark),
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
          child: const Center(child: LoadWidget()),
        ),
      ),
    );
  }

  testWidgets('spinner rotates by default', (tester) async {
    await tester.pumpWidget(app(reduceMotion: false));
    expect(find.byType(RotationTransition), findsWidgets);
    expect(tester.binding.hasScheduledFrame, isTrue);
  });

  testWidgets('reduced motion shows a still ring and schedules no frames', (tester) async {
    await tester.pumpWidget(app(reduceMotion: true));
    await tester.pump();
    expect(
      find.descendant(of: find.byType(LoadWidget), matching: find.byType(RotationTransition)),
      findsNothing,
    );
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('turning reduced motion off starts the spin again', (tester) async {
    await tester.pumpWidget(app(reduceMotion: true));
    await tester.pumpWidget(app(reduceMotion: false));
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isTrue);
  });
}
