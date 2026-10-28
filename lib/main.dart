import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/database/app_database.dart';
import 'data/repositories/bookmark_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/reading_repository.dart';
import 'providers/app_providers.dart';
import 'services/appwrite_service.dart';
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

  // Initialize Appwrite Cloud Service
  final appwriteService = AppwriteService();
  try {
    await appwriteService.init();
    // Non-blocking background sync on launch
    unawaited(appwriteService.performFullSync(
      readingRepo: ReadingRepository(appwriteService: appwriteService),
      profileRepo: ProfileRepository(appwriteService: appwriteService),
      bookmarkRepo: BookmarkRepository(appwriteService: appwriteService),
      settingsService: settingsService,
    ));
  } catch (e) {
    debugPrint('Appwrite initial sync notice: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        settingsServiceProvider.overrideWithValue(settingsService),
        appwriteServiceProvider.overrideWithValue(appwriteService),
      ],
      child: const QuranCompanionApp(),
    ),
  );
}
