import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/app_database.dart';
import '../models/bookmark.dart';
import '../models/reading_session.dart';
import '../../services/appwrite_service.dart';

class BookmarkRepository {
  final AppDatabase _dbHelper;
  final AppwriteService? _appwriteService;

  BookmarkRepository({AppDatabase? dbHelper, AppwriteService? appwriteService})
      : _dbHelper = dbHelper ?? AppDatabase.instance,
        _appwriteService = appwriteService;

  Future<void> addBookmark(Bookmark bookmark) async {
    final db = await _dbHelper.database;
    await db.insert('bookmarks', bookmark.toMap());
    _appwriteService?.syncBookmark(bookmark);
  }

  Future<void> saveBookmark(Bookmark bookmark, {bool syncToCloud = true}) async {
    final db = await _dbHelper.database;
    final existing = await getBookmarkById(bookmark.id);
    if (existing != null) {
      await db.update(
        'bookmarks',
        bookmark.toMap(),
        where: 'id = ?',
        whereArgs: [bookmark.id],
      );
    } else {
      await db.insert(
        'bookmarks',
        bookmark.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    if (syncToCloud) {
      _appwriteService?.syncBookmark(bookmark);
    }
  }

  Future<Bookmark?> getBookmarkById(String bookmarkId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'bookmarks',
      where: 'id = ?',
      whereArgs: [bookmarkId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Bookmark.fromMap(maps.first);
  }

  Future<List<Bookmark>> getAllBookmarks() async {
    final db = await _dbHelper.database;
    final maps = await db.query('bookmarks', orderBy: 'created_at DESC');
    return maps.map((m) => Bookmark.fromMap(m)).toList();
  }

  Future<void> removeBookmark(String bookmarkId) async {
    final db = await _dbHelper.database;
    await db.delete('bookmarks', where: 'id = ?', whereArgs: [bookmarkId]);
    _appwriteService?.deleteBookmark(bookmarkId);
  }

  Future<void> removeBookmarkBySessionId(String sessionId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'bookmarks',
      columns: ['id'],
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
    for (final m in maps) {
      final id = m['id'] as String?;
      if (id != null) {
        _appwriteService?.deleteBookmark(id);
      }
    }
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
