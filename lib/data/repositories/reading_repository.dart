import 'dart:convert';
import 'dart:math';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/app_database.dart';
import '../models/quran_explanation.dart';
import '../models/reading_session.dart';

class ReadingRepository {
  final AppDatabase _dbHelper;

  ReadingRepository({AppDatabase? dbHelper})
      : _dbHelper = dbHelper ?? AppDatabase.instance;

  Future<void> saveSession(ReadingSession session) async {
    final db = await _dbHelper.database;
    await db.insert(
      'reading_sessions',
      session.toMap(),
    );

    // If session has explanation, cache it for future instant reloads
    if (session.explanationJson != null && session.explanationJson!.isNotEmpty) {
      await saveCachedExplanation(
        session.surahNumber,
        session.startVerse,
        session.endVerse,
        session.explanationJson!,
      );
    }
  }

  Future<void> updateSession(ReadingSession session) async {
    final db = await _dbHelper.database;
    await db.update(
      'reading_sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );

    // Sync explanation to cache if present
    if (session.explanationJson != null && session.explanationJson!.isNotEmpty) {
      await saveCachedExplanation(
        session.surahNumber,
        session.startVerse,
        session.endVerse,
        session.explanationJson!,
      );
    }
  }

  Future<void> updateExplanation(String sessionId, String explanationJson) async {
    final db = await _dbHelper.database;
    await db.update(
      'reading_sessions',
      {
        'explanation_json': explanationJson,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );

    final session = await getSessionById(sessionId);
    if (session != null) {
      await saveCachedExplanation(
        session.surahNumber,
        session.startVerse,
        session.endVerse,
        explanationJson,
      );
    }
  }

  Future<List<ReadingSession>> getSessionsForPassage(
    String profileId,
    int surahNumber,
    int startVerse,
    int endVerse,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'reading_sessions',
      where: 'profile_id = ? AND surah_number = ? AND start_verse = ? AND end_verse = ?',
      whereArgs: [profileId, surahNumber, startVerse, endVerse],
      orderBy: 'updated_at DESC',
      limit: 1,
    );
    return maps.map((m) => ReadingSession.fromMap(m)).toList();
  }

  Future<void> updateNotes(String sessionId, String notes) async {
    final db = await _dbHelper.database;
    await db.update(
      'reading_sessions',
      {
        'notes': notes,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> updatePassageRange(
    String sessionId,
    int surahNumber,
    String surahName,
    int startVerse,
    int endVerse,
  ) async {
    final db = await _dbHelper.database;
    await db.update(
      'reading_sessions',
      {
        'surah_number': surahNumber,
        'surah_name': surahName,
        'start_verse': startVerse,
        'end_verse': endVerse,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> toggleBookmark(String sessionId, bool isBookmarked) async {
    final db = await _dbHelper.database;
    await db.update(
      'reading_sessions',
      {
        'is_bookmarked': isBookmarked ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> deleteSession(String sessionId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'reading_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    // Also remove associated bookmark if exists
    await db.delete(
      'bookmarks',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<ReadingSession?> getSessionById(String sessionId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'reading_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ReadingSession.fromMap(maps.first);
  }

  Future<List<ReadingSession>> getRecentSessions(String profileId, {int limit = 10}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'reading_sessions',
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'read_at DESC',
      limit: limit,
    );
    return maps.map((m) => ReadingSession.fromMap(m)).toList();
  }

  Future<List<ReadingSession>> getAllSessionsForProfile(String profileId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'reading_sessions',
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'read_at DESC',
    );
    return maps.map((m) => ReadingSession.fromMap(m)).toList();
  }

  Future<List<ReadingSession>> getSessionsForDate(String profileId, DateTime date) async {
    final db = await _dbHelper.database;
    final startOfDay = DateTime(date.year, date.month, date.day).toIso8601String();
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999).toIso8601String();

    final maps = await db.query(
      'reading_sessions',
      where: 'profile_id = ? AND read_at >= ? AND read_at <= ?',
      whereArgs: [profileId, startOfDay, endOfDay],
      orderBy: 'read_at DESC',
    );
    return maps.map((m) => ReadingSession.fromMap(m)).toList();
  }

  Future<Set<DateTime>> getAllReadingDates(String profileId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'reading_sessions',
      columns: ['read_at'],
      where: 'profile_id = ?',
      whereArgs: [profileId],
    );

    final Set<DateTime> dates = {};
    for (final m in maps) {
      final readAtStr = m['read_at'] as String?;
      if (readAtStr != null) {
        final dt = DateTime.tryParse(readAtStr);
        if (dt != null) {
          dates.add(DateTime(dt.year, dt.month, dt.day));
        }
      }
    }
    return dates;
  }

  Future<int> getTotalSessionsCount(String profileId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM reading_sessions WHERE profile_id = ?',
      [profileId],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<int> getThisMonthSessionsCount(String profileId) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM reading_sessions WHERE profile_id = ? AND read_at >= ?',
      [profileId, startOfMonth],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<int> getDistinctSurahsCount(String profileId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(DISTINCT surah_number) as count FROM reading_sessions WHERE profile_id = ?',
      [profileId],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  /// Calculates total distinct verses covered by merging overlapping intervals
  Future<int> calculateVersesCovered(String profileId) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'reading_sessions',
      columns: ['surah_number', 'start_verse', 'end_verse'],
      where: 'profile_id = ?',
      whereArgs: [profileId],
    );

    // Group intervals by surah_number
    final Map<int, List<_Interval>> surahIntervals = {};
    for (final row in rows) {
      final sNum = row['surah_number'] as int;
      final start = row['start_verse'] as int;
      final end = row['end_verse'] as int;
      surahIntervals.putIfAbsent(sNum, () => []).add(_Interval(start, end));
    }

    int totalUniqueVerses = 0;
    for (final intervals in surahIntervals.values) {
      if (intervals.isEmpty) continue;
      // Sort intervals by start ascending
      intervals.sort((a, b) => a.start.compareTo(b.start));

      int mergedStart = intervals[0].start;
      int mergedEnd = intervals[0].end;

      for (int i = 1; i < intervals.length; i++) {
        final current = intervals[i];
        if (current.start <= mergedEnd + 1) {
          // Overlapping or contiguous
          mergedEnd = max(mergedEnd, current.end);
        } else {
          // Disjoint interval
          totalUniqueVerses += (mergedEnd - mergedStart + 1);
          mergedStart = current.start;
          mergedEnd = current.end;
        }
      }
      totalUniqueVerses += (mergedEnd - mergedStart + 1);
    }

    return totalUniqueVerses;
  }

  // --- Explanation Caching Methods ---

  String _cacheKey(int surahNumber, int startVerse, int endVerse) =>
      'surah_${surahNumber}_${startVerse}_$endVerse';

  Future<String?> getCachedExplanation(int surahNumber, int startVerse, int endVerse) async {
    final db = await _dbHelper.database;
    final key = _cacheKey(surahNumber, startVerse, endVerse);
    final maps = await db.query(
      'cached_explanations',
      where: 'cache_key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return maps.first['explanation_json'] as String?;
  }

  Future<void> saveCachedExplanation(
    int surahNumber,
    int startVerse,
    int endVerse,
    String explanationJson,
  ) async {
    final db = await _dbHelper.database;
    final key = _cacheKey(surahNumber, startVerse, endVerse);

    // If the new explanation lacks Urdu but the local cache already has Urdu, preserve the Urdu!
    try {
      final existingJson = await getCachedExplanation(surahNumber, startVerse, endVerse);
      if (existingJson != null && existingJson.isNotEmpty) {
        final existingParsed = QuranExplanation.fromRawString(existingJson);
        final newParsed = QuranExplanation.fromRawString(explanationJson);

        final preserveUrduExplanation = newParsed.simpleExplanationUrdu.trim().isEmpty &&
            existingParsed.simpleExplanationUrdu.trim().isNotEmpty;
        final preserveUrduTranslation = newParsed.translationUrdu.trim().isEmpty &&
            existingParsed.translationUrdu.trim().isNotEmpty;

        if (preserveUrduExplanation || preserveUrduTranslation) {
          final merged = newParsed.copyWith(
            simpleExplanationUrdu: preserveUrduExplanation
                ? existingParsed.simpleExplanationUrdu
                : newParsed.simpleExplanationUrdu,
            translationUrdu: preserveUrduTranslation
                ? existingParsed.translationUrdu
                : newParsed.translationUrdu,
          );
          explanationJson = jsonEncode(merged.toJson());
        }
      }
    } catch (_) {}

    await db.insert(
      'cached_explanations',
      {
        'cache_key': key,
        'explanation_json': explanationJson,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearAllCachedExplanations() async {
    final db = await _dbHelper.database;
    await db.delete('cached_explanations');
  }

  Future<Map<String, int>> getStorageStats(String profileId) async {
    final db = await _dbHelper.database;
    final sessionRes = await db.rawQuery(
      'SELECT COUNT(*) as count FROM reading_sessions WHERE profile_id = ?',
      [profileId],
    );
    final cacheRes = await db.rawQuery('SELECT COUNT(*) as count FROM cached_explanations');
    final bookmarkRes = await db.rawQuery(
      'SELECT COUNT(*) as count FROM bookmarks WHERE profile_id = ?',
      [profileId],
    );

    return {
      'sessions': (sessionRes.first['count'] as int?) ?? 0,
      'cached_explanations': (cacheRes.first['count'] as int?) ?? 0,
      'bookmarks': (bookmarkRes.first['count'] as int?) ?? 0,
    };
  }
}

class _Interval {
  final int start;
  final int end;
  _Interval(this.start, this.end);
}
