import '../database/app_database.dart';
import '../models/profile.dart';
import '../../services/appwrite_service.dart';

class ProfileRepository {
  final AppDatabase _dbHelper;
  final AppwriteService? _appwriteService;

  ProfileRepository({AppDatabase? dbHelper, AppwriteService? appwriteService})
      : _dbHelper = dbHelper ?? AppDatabase.instance,
        _appwriteService = appwriteService;

  Future<List<Profile>> getAllProfiles() async {
    final db = await _dbHelper.database;
    final maps = await db.query('profiles', orderBy: 'created_at ASC');
    if (maps.isEmpty) {
      // Re-seed if empty
      for (final p in Profile.defaultProfiles) {
        await db.insert('profiles', p.toMap());
      }
      return Profile.defaultProfiles;
    }
    return maps.map((m) => Profile.fromMap(m)).toList();
  }

  Future<Profile?> getProfileById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'profiles',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Profile.fromMap(maps.first);
  }

  Future<void> updateProfileName(String id, String newName) async {
    final db = await _dbHelper.database;
    await db.update(
      'profiles',
      {
        'name': newName.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    final updated = await getProfileById(id);
    if (updated != null) {
      _appwriteService?.syncProfile(updated);
    }
  }

  Future<void> saveProfile(Profile profile) async {
    final db = await _dbHelper.database;
    final existing = await getProfileById(profile.id);
    if (existing != null) {
      await db.update(
        'profiles',
        profile.toMap(),
        where: 'id = ?',
        whereArgs: [profile.id],
      );
    } else {
      await db.insert('profiles', profile.toMap());
    }
    _appwriteService?.syncProfile(profile);
  }
}
