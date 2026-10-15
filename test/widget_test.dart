import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nightout/app.dart';

void main() {
  testWidgets('splash opens home', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    expect(find.text('Nightout'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump();

    expect(find.text('ไปหน้า Login'), findsOneWidget);
  });
}
