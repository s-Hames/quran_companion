import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/database/app_database.dart';
import 'providers/app_providers.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables gracefully
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Note: .env file not found or could not be loaded: $e');
  }

  // Initialize SQLite database
  try {
    await AppDatabase.instance.database;
  } catch (e) {
    debugPrint('Database initialization notice: $e');
  }

  // Initialize SharedPreferences Settings
  final settingsService = await SettingsService.init();

  runApp(
    ProviderScope(
      overrides: [
        settingsServiceProvider.overrideWithValue(settingsService),
      ],
      child: const QuranCompanionApp(),
    ),
  );
}
