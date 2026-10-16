import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nightout_core/nightout_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads the stored mode and saves a new one under nightout-theme', () async {
    SharedPreferences.setMockInitialValues({nightOutThemeStorageKey: 'LIGHT'});
    final stored = await loadNightOutThemeMode();
    expect(stored, NightOutThemeMode.light);

    final container = ProviderContainer(
      overrides: [nightOutInitialThemeModeProvider.overrideWithValue(stored)],
    );
    addTearDown(container.dispose);
    expect(container.read(nightOutThemeModeProvider), NightOutThemeMode.light);

    await container.read(nightOutThemeModeProvider.notifier).set(NightOutThemeMode.system);
    expect(container.read(nightOutThemeModeProvider), NightOutThemeMode.system);
    expect(await loadNightOutThemeMode(), NightOutThemeMode.system);
  });

  test('nothing stored means dark', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await loadNightOutThemeMode(), NightOutThemeMode.dark);
  });
}
