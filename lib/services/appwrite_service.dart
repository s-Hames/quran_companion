import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';
import '../core/constants/appwrite_constants.dart';
import '../data/models/bookmark.dart';
import '../data/models/profile.dart';
import '../data/models/reading_session.dart';
import '../data/repositories/bookmark_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/reading_repository.dart';

enum SyncState { idle, syncing, success, error }

class AppwriteService {
  late final Client client;
  late final Account account;
  late final TablesDB tables;

  models.User? _currentUser;
  models.User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  final ValueNotifier<models.User?> userNotifier = ValueNotifier(null);
  final ValueNotifier<SyncState> syncStateNotifier = ValueNotifier(SyncState.idle);
  final ValueNotifier<String?> syncMessageNotifier = ValueNotifier(null);

  AppwriteService() {
    client = Client()
        .setEndpoint(AppwriteConstants.endpoint)
        .setProject(AppwriteConstants.projectId);

    account = Account(client);
    tables = TablesDB(client);
  }

  Future<void> init() async {
    try {
      _currentUser = await account.get();
      userNotifier.value = _currentUser;
      debugPrint('Appwrite: Authenticated as ${_currentUser?.name ?? _currentUser?.email}');
    } catch (_) {
      _currentUser = null;
      userNotifier.value = null;
      debugPrint('Appwrite: No active session. Running in local-first mode.');
    }
  }

  // --- Authentication ---

  /// Sign in using Google OAuth2
  Future<void> signInWithGoogle() async {
    try {
      syncMessageNotifier.value = 'Signing in with Google...';
      await account.createOAuth2Session(provider: OAuthProvider.google);
      _currentUser = await account.get();
      userNotifier.value = _currentUser;
      syncStateNotifier.value = SyncState.success;
      syncMessageNotifier.value = 'Signed in as ${_currentUser?.name ?? _currentUser?.email}';
    } catch (e) {
      debugPrint('Appwrite Google Sign-In Error: $e');
      syncStateNotifier.value = SyncState.error;
      syncMessageNotifier.value = 'Sign-in failed: $e';
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await account.deleteSession(sessionId: 'current');
      _currentUser = null;
      userNotifier.value = null;
      syncStateNotifier.value = SyncState.idle;
      syncMessageNotifier.value = 'Signed out';
    } catch (e) {
      debugPrint('Appwrite Sign-Out Error: $e');
    }
  }

  // --- Row Upsert Helper ---

  Future<void> _upsertRow({
    required String tableId,
    required String rowId,
    required Map<String, dynamic> data,
  }) async {
    // Sanitize rowId to ensure it is alphanumeric/underscore/dash/dot and <= 36 chars
    final safeRowId = rowId.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final truncatedRowId = safeRowId.length > 36 ? safeRowId.substring(0, 36) : safeRowId;

    try {
      await tables.createRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: tableId,
        rowId: truncatedRowId,
        data: data,
      );
    } on AppwriteException catch (e) {
      if (e.code == 409) {
        // Row already exists, update it
        await tables.updateRow(
          databaseId: AppwriteConstants.databaseId,
          tableId: tableId,
          rowId: truncatedRowId,
          data: data,
        );
      } else {
        rethrow;
      }
    }
  }

  // --- Profiles Sync ---

  Future<void> syncProfile(Profile profile) async {
    if (!isAuthenticated) return;
    try {
      await _upsertRow(
        tableId: AppwriteConstants.profilesCollectionId,
        rowId: profile.id,
        data: {
          'name': profile.name,
          'avatar_index': profile.avatarColorIndex,
        },
      );
    } catch (e) {
      debugPrint('Appwrite syncProfile error: $e');
    }
  }

  Future<List<Profile>> fetchCloudProfiles() async {
    if (!isAuthenticated) return [];
    try {
      final res = await tables.listRows(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteConstants.profilesCollectionId,
      );

      return res.rows.map((row) {
        return Profile(
          id: row.$id,
          name: row.data['name'] as String? ?? 'User',
          relation: row.$id,
          avatarColorIndex: row.data['avatar_index'] as int? ?? 0,
          createdAt: DateTime.tryParse(row.$createdAt) ?? DateTime.now(),
          updatedAt: DateTime.tryParse(row.$updatedAt) ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      debugPrint('Appwrite fetchCloudProfiles error: $e');
      return [];
    }
  }

  // --- Reading Sessions Sync ---

  Future<void> syncReadingSession(ReadingSession session) async {
    if (!isAuthenticated) return;
    try {
      await _upsertRow(
        tableId: AppwriteConstants.readingSessionsCollectionId,
        rowId: session.id,
        data: {
          'profile_id': session.profileId,
          'surah_number': session.surahNumber,
          'surah_name': session.surahName,
          'start_verse': session.startVerse,
          'end_verse': session.endVerse,
          'explanation_json': session.explanationJson,
          'notes': session.notes,
          'is_bookmarked': session.isBookmarked,
          'read_at': session.readAt.toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Appwrite syncReadingSession error: $e');
    }
  }

  Future<void> deleteReadingSession(String sessionId) async {
    if (!isAuthenticated) return;
    try {
      final safeRowId = sessionId.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final truncatedRowId = safeRowId.length > 36 ? safeRowId.substring(0, 36) : safeRowId;
      await tables.deleteRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteConstants.readingSessionsCollectionId,
        rowId: truncatedRowId,
      );
    } catch (e) {
      debugPrint('Appwrite deleteReadingSession error: $e');
    }
  }

  Future<List<ReadingSession>> fetchCloudReadingSessions() async {
    if (!isAuthenticated) return [];
    try {
      models.RowList res;
      try {
        res = await tables.listRows(
          databaseId: AppwriteConstants.databaseId,
          tableId: AppwriteConstants.readingSessionsCollectionId,
          queries: [
            Query.limit(100),
          ],
        );
      } catch (_) {
        // Fallback without queries if limit is unindexed or restricted
        res = await tables.listRows(
          databaseId: AppwriteConstants.databaseId,
          tableId: AppwriteConstants.readingSessionsCollectionId,
        );
      }

      final sessions = res.rows.map((row) {
        final d = row.data;
        return ReadingSession(
          id: row.$id,
          profileId: d['profile_id'] as String? ?? 'me',
          readAt: DateTime.tryParse(d['read_at'] as String? ?? '') ??
              DateTime.tryParse(row.$createdAt) ??
              DateTime.now(),
          surahNumber: d['surah_number'] as int? ?? 1,
          surahName: d['surah_name'] as String? ?? 'Surah',
          startVerse: d['start_verse'] as int? ?? 1,
          endVerse: d['end_verse'] as int? ?? 1,
          explanationJson: d['explanation_json'] as String?,
          notes: d['notes'] as String?,
          isBookmarked: d['is_bookmarked'] as bool? ?? false,
          createdAt: DateTime.tryParse(row.$createdAt) ?? DateTime.now(),
          updatedAt: DateTime.tryParse(row.$updatedAt) ?? DateTime.now(),
        );
      }).toList();

      sessions.sort((a, b) => b.readAt.compareTo(a.readAt));
      debugPrint('Appwrite: Successfully fetched ${sessions.length} sessions from cloud.');
      return sessions;
    } catch (e) {
      debugPrint('Appwrite fetchCloudReadingSessions error: $e');
      return [];
    }
  }

  // --- Bookmarks Sync ---

  Future<void> syncBookmark(Bookmark bookmark) async {
    if (!isAuthenticated) return;
    try {
      await _upsertRow(
        tableId: AppwriteConstants.bookmarksCollectionId,
        rowId: bookmark.id,
        data: {
          'session_id': bookmark.sessionId,
          'surah_number': bookmark.surahNumber,
          'surah_name': bookmark.surahName,
          'verse_key': '${bookmark.surahNumber}:${bookmark.startVerse}',
          'note': bookmark.content.isNotEmpty ? bookmark.content : bookmark.title,
        },
      );
    } catch (e) {
      debugPrint('Appwrite syncBookmark error: $e');
    }
  }

  Future<void> deleteBookmark(String bookmarkId) async {
    if (!isAuthenticated) return;
    try {
      final safeRowId = bookmarkId.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final truncatedRowId = safeRowId.length > 36 ? safeRowId.substring(0, 36) : safeRowId;
      await tables.deleteRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteConstants.bookmarksCollectionId,
        rowId: truncatedRowId,
      );
    } catch (e) {
      debugPrint('Appwrite deleteBookmark error: $e');
    }
  }

  Future<List<Bookmark>> fetchCloudBookmarks() async {
    if (!isAuthenticated) return [];
    try {
      models.RowList res;
      try {
        res = await tables.listRows(
          databaseId: AppwriteConstants.databaseId,
          tableId: AppwriteConstants.bookmarksCollectionId,
          queries: [
            Query.limit(100),
          ],
        );
      } catch (_) {
        // Fallback without queries if limit is unindexed or restricted
        res = await tables.listRows(
          databaseId: AppwriteConstants.databaseId,
          tableId: AppwriteConstants.bookmarksCollectionId,
        );
      }

      final bookmarks = res.rows.map((row) {
        final d = row.data;
        return Bookmark(
          id: row.$id,
          profileId: 'me',
          sessionId: d['session_id'] as String?,
          type: 'session',
          title: d['surah_name'] as String? ?? 'Bookmark',
          subtitle: 'Surah ${d['surah_number']}:${d['verse_key']}',
          content: d['note'] as String? ?? '',
          surahNumber: d['surah_number'] as int? ?? 1,
          surahName: d['surah_name'] as String? ?? 'Surah',
          startVerse: 1,
          endVerse: 1,
          createdAt: DateTime.tryParse(row.$createdAt) ?? DateTime.now(),
        );
      }).toList();

      bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      debugPrint('Appwrite: Successfully fetched ${bookmarks.length} bookmarks from cloud.');
      return bookmarks;
    } catch (e) {
      debugPrint('Appwrite fetchCloudBookmarks error: $e');
      return [];
    }
  }

  // --- Cached Explanations Sync ---

  Future<void> syncCachedExplanation(
    int surah,
    int startVerse,
    int endVerse,
    String explanationJson,
  ) async {
    if (!isAuthenticated) return;
    try {
      final passageKey = '${surah}_${startVerse}_$endVerse';
      await _upsertRow(
        tableId: AppwriteConstants.cachedExplanationsCollectionId,
        rowId: passageKey,
        data: {
          'passage_key': passageKey,
          'surah_number': surah,
          'start_verse': startVerse,
          'end_verse': endVerse,
          'explanation_json': explanationJson,
        },
      );
    } catch (e) {
      debugPrint('Appwrite syncCachedExplanation error: $e');
    }
  }

  Future<String?> fetchCachedExplanation(
    int surah,
    int startVerse,
    int endVerse,
  ) async {
    if (!isAuthenticated) return null;
    try {
      final passageKey = '${surah}_${startVerse}_$endVerse';
      final row = await tables.getRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteConstants.cachedExplanationsCollectionId,
        rowId: passageKey,
      );
      return row.data['explanation_json'] as String?;
    } catch (_) {
      return null;
    }
  }

  // --- Two-Way Synchronization Engine ---

  Future<void> performFullSync({
    required ReadingRepository readingRepo,
    required ProfileRepository profileRepo,
    required BookmarkRepository bookmarkRepo,
  }) async {
    if (!isAuthenticated) {
      debugPrint('Appwrite: Skipping sync because user is not authenticated.');
      syncStateNotifier.value = SyncState.idle;
      syncMessageNotifier.value = null;
      return;
    }

    if (syncStateNotifier.value == SyncState.syncing) return;

    syncStateNotifier.value = SyncState.syncing;
    syncMessageNotifier.value = 'Syncing with Appwrite Cloud...';

    try {
      // 1. Sync Profiles
      final localProfiles = await profileRepo.getAllProfiles();
      for (final p in localProfiles) {
        await syncProfile(p);
      }
      final remoteProfiles = await fetchCloudProfiles();
      for (final rp in remoteProfiles) {
        await profileRepo.saveProfile(rp);
      }

      // 2. Sync Reading Sessions
      final localSessions = await readingRepo.getAllSessions();
      for (final s in localSessions) {
        await syncReadingSession(s);
      }
      final remoteSessions = await fetchCloudReadingSessions();
      for (final rs in remoteSessions) {
        final existing = await readingRepo.getSessionById(rs.id);
        if (existing == null) {
          await readingRepo.saveSession(rs, syncToCloud: false);
        } else {
          await readingRepo.updateSession(rs);
        }
      }

      // 3. Sync Bookmarks
      final localBookmarks = await bookmarkRepo.getAllBookmarks();
      for (final b in localBookmarks) {
        await syncBookmark(b);
      }
      final remoteBookmarks = await fetchCloudBookmarks();
      for (final rb in remoteBookmarks) {
        final existing = await bookmarkRepo.getBookmarkById(rb.id);
        if (existing == null) {
          await bookmarkRepo.saveBookmark(rb, syncToCloud: false);
        }
      }

      syncStateNotifier.value = SyncState.success;
      syncMessageNotifier.value = 'All data synced with cloud';
      debugPrint('Appwrite full sync completed successfully.');
    } catch (e) {
      debugPrint('Appwrite full sync error: $e');
      syncStateNotifier.value = SyncState.error;
      syncMessageNotifier.value = 'Sync completed with local storage';
    }
  }
}

