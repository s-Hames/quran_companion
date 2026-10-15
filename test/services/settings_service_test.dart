import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsService Theme & Profile Tests', () {
    test('defaults to ThemeMode.system and allows changing theme mode', () async {
      SharedPreferences.setMockInitialValues({});
      final service = await SettingsService.init();

      expect(service.getThemeMode(), equals(ThemeMode.system));

      await service.setThemeMode(ThemeMode.dark);
      expect(service.getThemeMode(), equals(ThemeMode.dark));

      await service.setThemeMode(ThemeMode.light);
      expect(service.getThemeMode(), equals(ThemeMode.light));

      await service.setThemeMode(ThemeMode.system);
      expect(service.getThemeMode(), equals(ThemeMode.system));
    });

    test('retains active personal profile id', () async {
      SharedPreferences.setMockInitialValues({'active_profile_id': 'me'});
      final service = await SettingsService.init();

      expect(service.getActiveProfileId(), equals('me'));
    });
  });
}
