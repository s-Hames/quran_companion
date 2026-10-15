import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/data/database/app_database.dart';
import 'package:quran_companion/data/models/profile.dart';
import 'package:quran_companion/data/models/quran_explanation.dart';
import 'package:quran_companion/data/models/reading_session.dart';
import 'package:quran_companion/data/repositories/bookmark_repository.dart';
import 'package:quran_companion/data/repositories/profile_repository.dart';
import 'package:quran_companion/data/repositories/reading_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;
  late AppDatabase appDb;
  late ProfileRepository profileRepo;
  late ReadingRepository readingRepo;
  late BookmarkRepository bookmarkRepo;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE profiles (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              relation TEXT NOT NULL,
              avatar_color_index INTEGER NOT NULL DEFAULT 0,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE reading_sessions (
              id TEXT PRIMARY KEY,
              profile_id TEXT NOT NULL,
              read_at TEXT NOT NULL,
              surah_number INTEGER NOT NULL,
              surah_name TEXT NOT NULL,
              start_verse INTEGER NOT NULL,
              end_verse INTEGER NOT NULL,
              image_path TEXT,
              extracted_text TEXT,
              explanation_json TEXT,
              notes TEXT,
              is_bookmarked INTEGER NOT NULL DEFAULT 0,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE bookmarks (
              id TEXT PRIMARY KEY,
              profile_id TEXT NOT NULL,
              session_id TEXT,
              type TEXT NOT NULL,
              title TEXT NOT NULL,
              subtitle TEXT,
              content TEXT,
              surah_number INTEGER NOT NULL,
              surah_name TEXT NOT NULL,
              start_verse INTEGER NOT NULL,
              end_verse INTEGER NOT NULL,
              created_at TEXT NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE cached_explanations (
              cache_key TEXT PRIMARY KEY,
              explanation_json TEXT NOT NULL,
              created_at TEXT NOT NULL
            )
          ''');

          // Seed 3 family profiles
          for (final p in Profile.defaultProfiles) {
            await db.insert('profiles', p.toMap());
          }
        },
      ),
    );

    appDb = AppDatabase.instance;
    appDb.setDatabaseForTesting(db);

    profileRepo = ProfileRepository(dbHelper: appDb);
    readingRepo = ReadingRepository(dbHelper: appDb);
    bookmarkRepo = BookmarkRepository(dbHelper: appDb);
  });

  tearDown(() async {
    await db.close();
  });

  group('SQLite Repositories Integration Tests', () {
    test('loads default family profiles and allows updating names', () async {
      final profiles = await profileRepo.getAllProfiles();
      expect(profiles.length, equals(3));
      expect(profiles.map((p) => p.relation).toList(), containsAll(['me', 'father', 'mother']));

      // Rename Father to Baba
      await profileRepo.updateProfileName('father', 'Baba');
      final updatedFather = await profileRepo.getProfileById('father');
      expect(updatedFather?.name, equals('Baba'));
    });

    test('saves and retrieves reading sessions filtered by profile', () async {
      final now = DateTime.now();

      final sessionMe = ReadingSession(
        id: 's_me_1',
        profileId: 'me',
        readAt: now,
        surahNumber: 18,
        surahName: 'Al-Kahf',
        startVerse: 1,
        endVerse: 10,
        notes: 'Read on Friday morning',
        createdAt: now,
        updatedAt: now,
      );

      final sessionFather = ReadingSession(
        id: 's_father_1',
        profileId: 'father',
        readAt: now,
        surahNumber: 36,
        surahName: 'Ya-Sin',
        startVerse: 1,
        endVerse: 12,
        notes: 'Read with Father after Maghrib',
        createdAt: now,
        updatedAt: now,
      );

      await readingRepo.saveSession(sessionMe);
      await readingRepo.saveSession(sessionFather);

      final meSessions = await readingRepo.getAllSessionsForProfile('me');
      expect(meSessions.length, equals(1));
      expect(meSessions.first.surahName, equals('Al-Kahf'));
      expect(meSessions.first.notes, equals('Read on Friday morning'));

      final fatherSessions = await readingRepo.getAllSessionsForProfile('father');
      expect(fatherSessions.length, equals(1));
      expect(fatherSessions.first.surahName, equals('Ya-Sin'));
    });

    test('retrieves calendar dates with reading sessions', () async {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      await readingRepo.saveSession(
        ReadingSession(
          id: 's_cal_1',
          profileId: 'me',
          readAt: today,
          surahNumber: 1,
          surahName: 'Al-Fatihah',
          startVerse: 1,
          endVerse: 7,
          createdAt: today,
          updatedAt: today,
        ),
      );

      await readingRepo.saveSession(
        ReadingSession(
          id: 's_cal_2',
          profileId: 'me',
          readAt: yesterday,
          surahNumber: 2,
          surahName: 'Al-Baqarah',
          startVerse: 1,
          endVerse: 5,
          createdAt: yesterday,
          updatedAt: yesterday,
        ),
      );

      final dates = await readingRepo.getAllReadingDates('me');
      expect(dates.length, equals(2));

      // Sessions for specific date
      final todaySessions = await readingRepo.getSessionsForDate('me', today);
      expect(todaySessions.length, equals(1));
      expect(todaySessions.first.surahName, equals('Al-Fatihah'));
    });

    test('merges overlapping intervals correctly when calculating verses covered', () async {
      final now = DateTime.now();

      // Session 1: Surah 2, Verses 1 to 10 (10 verses)
      await readingRepo.saveSession(
        ReadingSession(
          id: 'cov_1',
          profileId: 'me',
          readAt: now,
          surahNumber: 2,
          surahName: 'Al-Baqarah',
          startVerse: 1,
          endVerse: 10,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Session 2: Surah 2, Verses 5 to 15 (overlapping, expands coverage to 1..15 = 15 verses)
      await readingRepo.saveSession(
        ReadingSession(
          id: 'cov_2',
          profileId: 'me',
          readAt: now,
          surahNumber: 2,
          surahName: 'Al-Baqarah',
          startVerse: 5,
          endVerse: 15,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Session 3: Surah 2, Verses 20 to 25 (disjoint, +6 verses => 15 + 6 = 21 verses)
      await readingRepo.saveSession(
        ReadingSession(
          id: 'cov_3',
          profileId: 'me',
          readAt: now,
          surahNumber: 2,
          surahName: 'Al-Baqarah',
          startVerse: 20,
          endVerse: 25,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Session 4: Surah 1, Verses 1 to 7 (+7 verses => 28 verses)
      await readingRepo.saveSession(
        ReadingSession(
          id: 'cov_4',
          profileId: 'me',
          readAt: now,
          surahNumber: 1,
          surahName: 'Al-Fatihah',
          startVerse: 1,
          endVerse: 7,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final totalCovered = await readingRepo.calculateVersesCovered('me');
      expect(totalCovered, equals(28));
    });

    test('persists, retrieves, and toggles bookmarks', () async {
      final now = DateTime.now();

      final session = ReadingSession(
        id: 'bm_sess_1',
        profileId: 'me',
        readAt: now,
        surahNumber: 18,
        surahName: 'Al-Kahf',
        startVerse: 1,
        endVerse: 10,
        createdAt: now,
        updatedAt: now,
      );
      await readingRepo.saveSession(session);

      // Toggle bookmark ON
      final bookmarked = await bookmarkRepo.toggleSessionBookmark(session);
      expect(bookmarked, isTrue);

      final bookmarks = await bookmarkRepo.getBookmarksForProfile('me');
      expect(bookmarks.length, equals(1));
      expect(bookmarks.first.title, contains('Al-Kahf'));

      // Toggle bookmark OFF
      final unbookmarked = await bookmarkRepo.toggleSessionBookmark(session);
      expect(unbookmarked, isFalse);

      final afterToggle = await bookmarkRepo.getBookmarksForProfile('me');
      expect(afterToggle, isEmpty);
    });

    test('persists and retrieves cached explanations', () async {
      await readingRepo.saveCachedExplanation(18, 1, 10, '{"test":"cached"}');
      final cached = await readingRepo.getCachedExplanation(18, 1, 10);
      expect(cached, equals('{"test":"cached"}'));

      // Non-existent cache key returns null
      final missing = await readingRepo.getCachedExplanation(18, 11, 20);
      expect(missing, isNull);
    });

    test('preserves previously cached Urdu explanation when saving new explanation without Urdu', () async {
      const initialJson = '{"simple_explanation": "English initial", "simple_explanation_urdu": "ابتدائی اردو خلاصہ"}';
      await readingRepo.saveCachedExplanation(18, 1, 10, initialJson);

      // Overwrite with an explanation that has no Urdu
      const updatedWithoutUrdu = '{"simple_explanation": "English updated", "simple_explanation_urdu": ""}';
      await readingRepo.saveCachedExplanation(18, 1, 10, updatedWithoutUrdu);

      final cached = await readingRepo.getCachedExplanation(18, 1, 10);
      expect(cached, isNotNull);
      final parsed = QuranExplanation.fromRawString(cached!);
      expect(parsed.simpleExplanation, equals('English updated'));
      expect(parsed.simpleExplanationUrdu, equals('ابتدائی اردو خلاصہ'));
    });

    test('updateExplanation updates session record and syncs to cached_explanations', () async {
      final session = ReadingSession(
        id: 'session_urdu_update',
        profileId: 'me',
        readAt: DateTime.now(),
        surahNumber: 1,
        surahName: 'Al-Fatihah',
        startVerse: 1,
        endVerse: 7,
        explanationJson: '{"simple_explanation": "Initial English"}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await readingRepo.saveSession(session);

      const updatedWithUrdu = '{"simple_explanation": "Updated English", "simple_explanation_urdu": "مکمل اردو تشریح"}';
      await readingRepo.updateExplanation(session.id, updatedWithUrdu);

      // Verify session row updated
      final updatedSession = await readingRepo.getSessionById(session.id);
      expect(updatedSession, isNotNull);
      final sessionParsed = QuranExplanation.fromRawString(updatedSession!.explanationJson!);
      expect(sessionParsed.simpleExplanationUrdu, equals('مکمل اردو تشریح'));

      // Verify cached_explanations row synced
      final cached = await readingRepo.getCachedExplanation(1, 1, 7);
      expect(cached, isNotNull);
      final cacheParsed = QuranExplanation.fromRawString(cached!);
      expect(cacheParsed.simpleExplanationUrdu, equals('مکمل اردو تشریح'));
    });

    test('getSessionsForPassage retrieves session for given surah and verse range', () async {
      final session = ReadingSession(
        id: 'session_passage_lookup',
        profileId: 'me',
        readAt: DateTime.now(),
        surahNumber: 18,
        surahName: 'Al-Kahf',
        startVerse: 1,
        endVerse: 10,
        explanationJson: '{"simple_explanation": "Al-Kahf"}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await readingRepo.saveSession(session);

      final found = await readingRepo.getSessionsForPassage('me', 18, 1, 10);
      expect(found, isNotEmpty);
      expect(found.first.id, equals('session_passage_lookup'));

      final notFound = await readingRepo.getSessionsForPassage('me', 18, 11, 20);
      expect(notFound, isEmpty);
    });
  });
}
