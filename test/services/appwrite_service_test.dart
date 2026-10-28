import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/constants/appwrite_constants.dart';
import 'package:quran_companion/services/appwrite_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppwriteService Configuration & Initialization Tests', () {
    test('Appwrite constants are correctly configured', () {
      expect(AppwriteConstants.endpoint, equals('https://sgp.cloud.appwrite.io/v1'));
      expect(AppwriteConstants.projectId, equals('6ae0d54d0006a54bbe8b'));
      expect(AppwriteConstants.databaseId, equals('6ae0da160025ea7fe23e'));
      expect(AppwriteConstants.profilesCollectionId, equals('6ae0da380023220f3e95'));
      expect(AppwriteConstants.readingSessionsCollectionId, equals('6ae0db1d0012ea854b5c'));
      expect(AppwriteConstants.bookmarksCollectionId, equals('6ae0dbf9001ac2ffec20'));
      expect(AppwriteConstants.cachedExplanationsCollectionId, equals('6ae0dc91003b275ad8a2'));
    });

    test('AppwriteService initializes with local-first defaults', () {
      final service = AppwriteService();
      expect(service.currentUser, isNull);
      expect(service.isAuthenticated, isFalse);
      expect(service.syncStateNotifier.value, equals(SyncState.idle));
    });
  });
}
