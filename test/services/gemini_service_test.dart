import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/services/gemini_service.dart';
import 'package:quran_companion/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('GeminiService Configuration and Fallback Tests', () {
    late SettingsService settingsService;
    late GeminiService geminiService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      settingsService = SettingsService(prefs);
      geminiService = GeminiService(settingsService, enableDemoDelay: false);
    });

    test('correctly identifies when API key is missing or placeholder', () {
      expect(geminiService.isConfigured, isFalse);

      settingsService.setCustomApiKey('your_gemini_api_key_here');
      expect(geminiService.isConfigured, isFalse);

      settingsService.setCustomApiKey('AIzaSyValidDummyKey123');
      expect(geminiService.isConfigured, isTrue);
    });

    test('returns demonstration passage identification when API key is not configured', () async {
      // API key is not configured
      expect(geminiService.isConfigured, isFalse);

      final dummyBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final result = await geminiService.identifyPassageFromImage(dummyBytes);

      expect(result.identified, isTrue);
      expect(result.surahName, equals('Al-Kahf'));
      expect(result.surahNumber, equals(18));
      expect(result.startVerse, equals(1));
      expect(result.endVerse, equals(10));
      expect(result.needsUserConfirmation, isTrue);
      expect(result.uncertainties.first, contains('Demonstration mode'));
    });

    test('returns demonstration explanation when API key is not configured', () async {
      expect(geminiService.isConfigured, isFalse);

      final explanation = await geminiService.generateExplanation(
        surahNumber: 18,
        surahName: 'Al-Kahf',
        startVerse: 1,
        endVerse: 10,
      );

      expect(explanation.surahNumber, equals(18));
      expect(explanation.surahName, equals('Al-Kahf'));
      expect(explanation.startVerse, equals(1));
      expect(explanation.endVerse, equals(10));
      expect(explanation.simpleExplanation.isNotEmpty, isTrue);
      expect(explanation.historicalContext.classification, equals('Makki'));
      expect(explanation.relatedStories.isNotEmpty, isTrue);
      expect(explanation.lessons.isNotEmpty, isTrue);
      expect(explanation.scholarlyInterpretations.isNotEmpty, isTrue);
      expect(explanation.spiritualReflections.isNotEmpty, isTrue);
    });

    test('returns contextual answers in Q&A demo mode', () async {
      final explanation = await geminiService.generateExplanation(
        surahNumber: 18,
        surahName: 'Al-Kahf',
        startVerse: 1,
        endVerse: 10,
      );

      final simpleAnswer = await geminiService.askQuestionAboutPassage(
        explanation: explanation,
        userQuestion: 'Explain this in simpler words please',
      );
      expect(simpleAnswer.toLowerCase(), contains('simple'));

      final lessonAnswer = await geminiService.askQuestionAboutPassage(
        explanation: explanation,
        userQuestion: 'What practical lesson can I apply today?',
      );
      expect(lessonAnswer.toLowerCase(), contains('lesson'));
    });
  });
}
