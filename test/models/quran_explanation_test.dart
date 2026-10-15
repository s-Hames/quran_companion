import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/data/models/quran_explanation.dart';

void main() {
  group('QuranExplanation Parsing Tests', () {
    test('parses full structured Gemini explanation response', () {
      const fullResponseJson = '''
      {
        "passage": {
          "surah_name": "Al-Ikhlas",
          "surah_number": 112,
          "start_verse": 1,
          "end_verse": 4
        },
        "arabic_text": "قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ",
        "translation": "Say, He is Allah, [who is] One, Allah, the Eternal Refuge. He neither begets nor is born, Nor is there to Him any equivalent.",
        "translation_source": "Sahih International",
        "simple_explanation": "This short chapter defines the pure monotheistic concept of God in Islam.",
        "historical_context": {
          "content": "Revealed in Makkah when polytheists asked about the lineage of God.",
          "classification": "Makki",
          "occasions_of_revelation": "Documented in authentic hadith compilations.",
          "certainty": "established"
        },
        "related_stories": [
          {
            "title": "Inquiry of the Quraysh",
            "narrative": "The leaders of Quraysh approached the Prophet asking about the lineage of Allah.",
            "story_type": "Quranic Narrative"
          }
        ],
        "lessons": [
          "Complete devotion to the One Creator",
          "Rejection of all forms of idolatry"
        ],
        "scholarly_interpretations": [
          {
            "scholar_or_work": "Tafsir Ibn Kathir",
            "perspective": "Explains Al-Samad as the Master who is relied upon in all needs.",
            "notes": "Linguistic definition from early authorities.",
            "is_verified": true
          }
        ],
        "spiritual_reflections": [
          {
            "attributed_to": "Imam al-Ghazali",
            "reflection": "True sincerity (Ikhlas) is purifying the heart from seeking anyone other than God.",
            "kind": "Spiritual Contemplation",
            "certainty": "Traditional Saying"
          }
        ],
        "limitations": [
          "AI study summary"
        ],
        "caution_disclaimer": "This is a study reflection."
      }
      ''';

      final explanation = QuranExplanation.fromRawString(fullResponseJson);
      expect(explanation.surahName, equals('Al-Ikhlas'));
      expect(explanation.surahNumber, equals(112));
      expect(explanation.startVerse, equals(1));
      expect(explanation.endVerse, equals(4));
      expect(explanation.arabicText.contains('قُلْ هُوَ اللَّهُ'), isTrue);
      expect(explanation.translation.contains('He is Allah'), isTrue);
      expect(explanation.historicalContext.classification, equals('Makki'));
      expect(explanation.relatedStories.length, equals(1));
      expect(explanation.relatedStories.first.title, equals('Inquiry of the Quraysh'));
      expect(explanation.lessons.length, equals(2));
      expect(explanation.scholarlyInterpretations.length, equals(1));
      expect(explanation.scholarlyInterpretations.first.scholarOrWork, equals('Tafsir Ibn Kathir'));
      expect(explanation.spiritualReflections.length, equals(1));
      expect(explanation.spiritualReflections.first.attributedTo, equals('Imam al-Ghazali'));
    });

    test('recovers gracefully from non-JSON or partial response', () {
      const plainText = 'This is a general paragraph explanation without JSON formatting.';
      final explanation = QuranExplanation.fromRawString(plainText);

      expect(explanation.simpleExplanation, equals(plainText));
      expect(explanation.historicalContext.content.isNotEmpty, isTrue);
    });
  });
}
