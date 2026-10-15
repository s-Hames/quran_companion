import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/constants/quran_data.dart';

void main() {
  group('QuranData Catalog and Validation Tests', () {
    test('contains exactly 114 Surahs with continuous numbering', () {
      expect(QuranData.surahs.length, equals(114));
      for (int i = 0; i < 114; i++) {
        expect(QuranData.surahs[i].number, equals(i + 1));
        expect(QuranData.surahs[i].nameEn.isNotEmpty, isTrue);
        expect(QuranData.surahs[i].nameAr.isNotEmpty, isTrue);
        expect(QuranData.surahs[i].totalVerses > 0, isTrue);
      }
    });

    test('validates Surah 1 (Al-Fatihah) has 7 verses', () {
      final fatihah = QuranData.getByNumber(1);
      expect(fatihah, isNotNull);
      expect(fatihah!.nameEn, equals('Al-Fatihah'));
      expect(fatihah.totalVerses, equals(7));

      expect(QuranData.isValidVerseRange(1, 1, 7), isTrue);
      expect(QuranData.isValidVerseRange(1, 1, 8), isFalse); // exceeds total
      expect(QuranData.isValidVerseRange(1, 0, 5), isFalse); // start < 1
      expect(QuranData.isValidVerseRange(1, 5, 3), isFalse); // end < start
    });

    test('validates Surah 2 (Al-Baqarah) has 286 verses', () {
      final baqarah = QuranData.getByNumber(2);
      expect(baqarah, isNotNull);
      expect(baqarah!.totalVerses, equals(286));
      expect(QuranData.isValidVerseRange(2, 255, 257), isTrue);
      expect(QuranData.isValidVerseRange(2, 280, 287), isFalse);
    });

    test('finds Surahs by flexible name search', () {
      expect(QuranData.findByName('Baqarah')?.number, equals(2));
      expect(QuranData.findByName('al-kahf')?.number, equals(18));
      expect(QuranData.findByName('yasin')?.number, equals(36));
      expect(QuranData.findByName('NonExistentSurah'), isNull);
    });
  });
}
