import '../database/app_database.dart';
import '../models/bookmark.dart';
import '../models/reading_session.dart';

class BookmarkRepository {
  final AppDatabase _dbHelper;

  BookmarkRepository({AppDatabase? dbHelper})
      : _dbHelper = dbHelper ?? AppDatabase.instance;

  Future<void> addBookmark(Bookmark bookmark) async {
    final db = await _dbHelper.database;
    await db.insert('bookmarks', bookmark.toMap());
  }

  Future<void> removeBookmark(String bookmarkId) async {
    final db = await _dbHelper.database;
    await db.delete('bookmarks', where: 'id = ?', whereArgs: [bookmarkId]);
  }

  Future<void> removeBookmarkBySessionId(String sessionId) async {
    final db = await _dbHelper.database;
    await db.delete('bookmarks', where: 'session_id = ?', whereArgs: [sessionId]);
  }

  Future<List<Bookmark>> getBookmarksForProfile(String profileId, {String? typeFilter}) async {
    final db = await _dbHelper.database;
    List<Map<String, dynamic>> maps;
    if (typeFilter != null && typeFilter.isNotEmpty && typeFilter != 'all') {
      maps = await db.query(
        'bookmarks',
        where: 'profile_id = ? AND type = ?',
        whereArgs: [profileId, typeFilter],
        orderBy: 'created_at DESC',
      );
    } else {
      maps = await db.query(
        'bookmarks',
        where: 'profile_id = ?',
        whereArgs: [profileId],
        orderBy: 'created_at DESC',
      );
    }
    return maps.map((m) => Bookmark.fromMap(m)).toList();
  }

  Future<bool> isSessionBookmarked(String sessionId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'bookmarks',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  Future<bool> toggleSessionBookmark(ReadingSession session, {String? snippet}) async {
    final db = await _dbHelper.database;
    final existing = await db.query(
      'bookmarks',
      where: 'session_id = ?',
      whereArgs: [session.id],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      await db.delete('bookmarks', where: 'session_id = ?', whereArgs: [session.id]);
      await db.update(
        'reading_sessions',
        {'is_bookmarked': 0, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [session.id],
      );
      return false;
    } else {
      final bookmarkId = '${DateTime.now().millisecondsSinceEpoch}_${session.id}';
      final bookmark = Bookmark(
        id: bookmarkId,
        profileId: session.profileId,
        sessionId: session.id,
        type: 'session',
        title: session.passageReference,
        subtitle: 'Read on ${session.readAt.day}/${session.readAt.month}/${session.readAt.year}',
        content: snippet ?? session.notes ?? 'Bookmarked reading session',
        surahNumber: session.surahNumber,
        surahName: session.surahName,
        startVerse: session.startVerse,
        endVerse: session.endVerse,
        createdAt: DateTime.now(),
      );
      await db.insert('bookmarks', bookmark.toMap());
      await db.update(
        'reading_sessions',
        {'is_bookmarked': 1, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [session.id],
      );
      return true;
    }
  }
}
