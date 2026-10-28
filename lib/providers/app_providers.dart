import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/app_database.dart';
import '../data/models/bookmark.dart';
import '../data/models/profile.dart';
import '../data/models/reading_session.dart';
import '../data/repositories/bookmark_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/reading_repository.dart';
import '../services/appwrite_service.dart';
import '../services/gemini_service.dart';
import '../services/image_service.dart';
import '../services/settings_service.dart';
import '../services/tts_service.dart';

// --- Base Services & Repositories Providers ---

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  throw UnimplementedError('settingsServiceProvider must be overridden in ProviderScope');
});

final appwriteServiceProvider = Provider<AppwriteService>((ref) {
  return AppwriteService();
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final appwrite = ref.watch(appwriteServiceProvider);
  return ProfileRepository(dbHelper: db, appwriteService: appwrite);
});

final readingRepositoryProvider = Provider<ReadingRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final appwrite = ref.watch(appwriteServiceProvider);
  return ReadingRepository(dbHelper: db, appwriteService: appwrite);
});

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final appwrite = ref.watch(appwriteServiceProvider);
  return BookmarkRepository(dbHelper: db, appwriteService: appwrite);
});

final geminiServiceProvider = Provider<GeminiService>((ref) {
  final settings = ref.watch(settingsServiceProvider);
  return GeminiService(settings);
});

final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageService();
});

final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  ref.onDispose(() => service.dispose());
  return service;
});

// --- State Notifiers ---

class ProfilesNotifier extends StateNotifier<AsyncValue<List<Profile>>> {
  final ProfileRepository _repo;

  ProfilesNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadProfiles();
  }

  Future<void> loadProfiles() async {
    try {
      final list = await _repo.getAllProfiles();
      if (!mounted) return;
      state = AsyncValue.data(list);
    } catch (e, st) {
      if (!mounted) return;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateName(String id, String newName) async {
    await _repo.updateProfileName(id, newName);
    await loadProfiles();
  }
}

final profilesListProvider = StateNotifierProvider<ProfilesNotifier, AsyncValue<List<Profile>>>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return ProfilesNotifier(repo);
});

class ActiveProfileNotifier extends StateNotifier<String> {
  final SettingsService _settings;

  ActiveProfileNotifier(this._settings) : super(_settings.getActiveProfileId());

  Future<void> setProfile(String profileId) async {
    state = profileId;
    await _settings.setActiveProfileId(profileId);
  }
}

final activeProfileIdProvider = StateNotifierProvider<ActiveProfileNotifier, String>((ref) {
  final settings = ref.watch(settingsServiceProvider);
  return ActiveProfileNotifier(settings);
});

final activeProfileProvider = Provider<Profile>((ref) {
  final activeId = ref.watch(activeProfileIdProvider);
  final profilesAsync = ref.watch(profilesListProvider);

  return profilesAsync.when(
    data: (profiles) => profiles.firstWhere(
      (p) => p.id == activeId,
      orElse: () => profiles.isNotEmpty ? profiles.first : Profile.defaultProfiles.first,
    ),
    loading: () => Profile.defaultProfiles.firstWhere((p) => p.id == activeId, orElse: () => Profile.defaultProfiles.first),
    error: (error, stack) => Profile.defaultProfiles.first,
  );
});

class TextScaleNotifier extends StateNotifier<double> {
  final SettingsService _settings;

  TextScaleNotifier(this._settings) : super(_settings.getTextScaleFactor());

  Future<void> setScale(double scale) async {
    state = scale;
    await _settings.setTextScaleFactor(scale);
  }
}

final textScaleProvider = StateNotifierProvider<TextScaleNotifier, double>((ref) {
  final settings = ref.watch(settingsServiceProvider);
  return TextScaleNotifier(settings);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SettingsService _settings;

  ThemeModeNotifier(this._settings) : super(_settings.getThemeMode());

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _settings.setThemeMode(mode);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final settings = ref.watch(settingsServiceProvider);
  return ThemeModeNotifier(settings);
});

// --- Reading Journey & Stats Providers ---

// Counter to trigger refreshes across sessions
class RefreshTriggerNotifier extends StateNotifier<int> {
  RefreshTriggerNotifier() : super(0);
  void trigger() => state++;
}

final sessionRefreshProvider = StateNotifierProvider<RefreshTriggerNotifier, int>((ref) {
  return RefreshTriggerNotifier();
});

final recentSessionsProvider = FutureProvider.family<List<ReadingSession>, String>((ref, profileId) async {
  ref.watch(sessionRefreshProvider);
  final repo = ref.watch(readingRepositoryProvider);
  return await repo.getRecentSessions(profileId, limit: 10);
});

final profileStatsProvider = FutureProvider.family<Map<String, int>, String>((ref, profileId) async {
  ref.watch(sessionRefreshProvider);
  final repo = ref.watch(readingRepositoryProvider);
  final totalSessions = await repo.getTotalSessionsCount(profileId);
  final thisMonthSessions = await repo.getThisMonthSessionsCount(profileId);
  final distinctSurahs = await repo.getDistinctSurahsCount(profileId);
  final versesCovered = await repo.calculateVersesCovered(profileId);

  return {
    'totalSessions': totalSessions,
    'thisMonthSessions': thisMonthSessions,
    'distinctSurahs': distinctSurahs,
    'versesCovered': versesCovered,
  };
});

final calendarDatesProvider = FutureProvider.family<Set<DateTime>, String>((ref, profileId) async {
  ref.watch(sessionRefreshProvider);
  final repo = ref.watch(readingRepositoryProvider);
  return await repo.getAllReadingDates(profileId);
});

final dateSessionsProvider = FutureProvider.family<List<ReadingSession>, ({String profileId, DateTime date})>((ref, arg) async {
  ref.watch(sessionRefreshProvider);
  final repo = ref.watch(readingRepositoryProvider);
  return await repo.getSessionsForDate(arg.profileId, arg.date);
});

// --- Bookmarks Providers ---

final bookmarksListProvider = FutureProvider.family<List<Bookmark>, ({String profileId, String? filter})>((ref, arg) async {
  ref.watch(sessionRefreshProvider);
  final repo = ref.watch(bookmarkRepositoryProvider);
  return await repo.getBookmarksForProfile(arg.profileId, typeFilter: arg.filter);
});
