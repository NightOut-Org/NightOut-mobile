import 'package:flutter_test/flutter_test.dart';
import 'package:nightout_core/nightout_core.dart';

void main() {
  test('initNightOutSupabase without dart-defines names the env file to pass', () {
    expect(
      initNightOutSupabase(),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('--dart-define-from-file=../../.env.dev'),
        ),
      ),
    );
  });
}
