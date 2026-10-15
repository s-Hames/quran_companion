import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/profile.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  AppDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    // Enable FFI for desktop and testing environments
    if (!kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String dbPath;
    if (kIsWeb) {
      dbPath = 'quran_companion.db';
    } else if (Platform.environment.containsKey('FLUTTER_TEST')) {
      dbPath = inMemoryDatabasePath;
    } else {
      final documentsDir = await getApplicationDocumentsDirectory();
      dbPath = p.join(documentsDir.path, 'quran_companion.db');
    }
    if (!kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
      return await databaseFactoryFfi.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _onCreate,
        ),
      );
    }

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Profiles table
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

    // 2. Reading Sessions table
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

    // 3. Bookmarks table
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

    // 4. Cached Explanations table
    await db.execute('''
      CREATE TABLE cached_explanations (
        cache_key TEXT PRIMARY KEY,
        explanation_json TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Seed default profiles: Me, Father, Mother
    final batch = db.batch();
    for (final profile in Profile.defaultProfiles) {
      batch.insert('profiles', profile.toMap());
    }
    await batch.commit(noResult: true);
  }

  // Method for tests to inject in-memory database
  @visibleForTesting
  void setDatabaseForTesting(Database db) {
    _db = db;
  }
}
