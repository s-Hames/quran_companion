import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/data/models/passage_identification.dart';

void main() {
  group('PassageIdentification JSON Parsing Tests', () {
    test('parses a clean, valid Gemini JSON response', () {
      const validJson = '''
      {
        "identified": true,
        "surah_name": "Al-Baqarah",
        "surah_number": 2,
        "start_verse": 1,
        "end_verse": 5,
        "confidence": "high",
        "extracted_text": "الم ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ",
        "uncertainties": [],
        "needs_user_confirmation": true
      }
      ''';

      final result = PassageIdentification.fromRawString(validJson);
      expect(result.identified, isTrue);
      expect(result.surahName, equals('Al-Baqarah'));
      expect(result.surahNumber, equals(2));
      expect(result.startVerse, equals(1));
      expect(result.endVerse, equals(5));
      expect(result.confidence, equals('high'));
      expect(result.extractedText.isNotEmpty, isTrue);
      expect(result.uncertainties, isEmpty);
      expect(result.needsUserConfirmation, isTrue);
      expect(result.errorMessage, isNull);
    });

    test('parses response wrapped in markdown json fences', () {
      const fencedJson = '''
      ```json
      {
        "identified": true,
        "surah_name": "Al-Kahf",
        "surah_number": 18,
        "start_verse": 1,
        "end_verse": 10,
        "confidence": "high",
        "extracted_text": "الْحَمْدُ لِلَّهِ",
        "uncertainties": ["Lower margin slightly cropped"]
      }
      ```
      ''';

      final result = PassageIdentification.fromRawString(fencedJson);
      expect(result.identified, isTrue);
      expect(result.surahName, equals('Al-Kahf'));
      expect(result.surahNumber, equals(18));
      expect(result.startVerse, equals(1));
      expect(result.endVerse, equals(10));
      expect(result.uncertainties.length, equals(1));
      expect(result.uncertainties.first, contains('cropped'));
    });

    test('gracefully handles malformed JSON without crashing', () {
      const brokenJson = 'NOT_JSON { "identified": true, invalid syntax';

      final result = PassageIdentification.fromRawString(brokenJson);
      expect(result.identified, isFalse);
      expect(result.confidence, equals('uncertain'));
      expect(result.errorMessage, isNotNull);
    });

    test('resolves surah number when given string digits or resolves from name', () {
      const stringNumberJson = '''
      {
        "identified": true,
        "surah_name": "Maryam",
        "surah_number": "19",
        "start_verse": "1",
        "end_verse": "5",
        "confidence": "medium"
      }
      ''';

      final result = PassageIdentification.fromRawString(stringNumberJson);
      expect(result.identified, isTrue);
      expect(result.surahNumber, equals(19));
      expect(result.startVerse, equals(1));
      expect(result.endVerse, equals(5));
    });

    test('constrains out-of-bounds verse numbers to known surah totals', () {
      // Surah Al-Fatihah only has 7 verses.
      const outOfBoundsJson = '''
      {
        "identified": true,
        "surah_name": "Al-Fatihah",
        "surah_number": 1,
        "start_verse": 1,
        "end_verse": 20,
        "confidence": "medium"
      }
      ''';

      final result = PassageIdentification.fromRawString(outOfBoundsJson);
      expect(result.surahNumber, equals(1));
      expect(result.endVerse, equals(7)); // Clamped to 7
    });
  });
}
