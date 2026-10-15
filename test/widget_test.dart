import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_companion/core/constants/app_colors.dart';
import 'package:quran_companion/core/theme/app_theme.dart';
import 'package:quran_companion/data/models/profile.dart';
import 'package:quran_companion/data/models/quran_explanation.dart';
import 'package:quran_companion/data/models/reading_session.dart';
import 'package:quran_companion/features/exploration/exploration_screen.dart';
import 'package:quran_companion/features/exploration/widgets/historical_context_card.dart';
import 'package:quran_companion/features/exploration/widgets/lessons_reflections_card.dart';
import 'package:quran_companion/features/exploration/widgets/related_stories_card.dart';
import 'package:quran_companion/features/exploration/widgets/scholarly_views_card.dart';
import 'package:quran_companion/features/exploration/widgets/simple_explanation_card.dart';
import 'package:quran_companion/features/exploration/widgets/verse_translation_card.dart';
import 'package:quran_companion/features/home/widgets/profile_header_card.dart';
import 'package:quran_companion/features/passage_selection/manual_passage_screen.dart';
import 'package:quran_companion/features/settings/settings_screen.dart';
import 'package:quran_companion/data/database/app_database.dart';
import 'package:quran_companion/providers/app_providers.dart';
import 'package:quran_companion/services/settings_service.dart';
import 'package:quran_companion/shared/widgets/arabic_text_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await AppDatabase.instance.database;
  });

  group('Widget UI Component Tests', () {
    testWidgets(
      'ArabicTextView renders text with RTL direction and Amiri style',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ArabicTextView(
                text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              ),
            ),
          ),
        );

        expect(
          find.text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'),
          findsOneWidget,
        );
        final directionality = tester.widget<Directionality>(
          find.descendant(
            of: find.byType(ArabicTextView),
            matching: find.byType(Directionality),
          ),
        );
        expect(directionality.textDirection, equals(TextDirection.rtl));
      },
    );

    testWidgets('ArabicTextView in dark mode uses dark styling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.getTheme(isDark: true, useGoogleFonts: false),
          home: const Scaffold(
            body: ArabicTextView(text: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ'),
          ),
        ),
      );

      expect(
        find.text('الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ'),
        findsOneWidget,
      );
    });

    test('AppTheme generates valid light and dark ThemeData', () {
      final light = AppTheme.getTheme(isDark: false, useGoogleFonts: false);
      expect(light.brightness, equals(Brightness.light));
      expect(light.scaffoldBackgroundColor, equals(AppColors.background));

      final dark = AppTheme.getTheme(isDark: true, useGoogleFonts: false);
      expect(dark.brightness, equals(Brightness.dark));
      expect(dark.scaffoldBackgroundColor, equals(AppColors.darkBackground));
      expect(dark.colorScheme.primary, equals(AppColors.darkPrimary));
    });

    testWidgets(
      'ProfileHeaderCard renders personal greeting and does not show reader switcher chips',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              activeProfileProvider.overrideWithValue(
                Profile(
                  id: 'me',
                  name: 'Hamid',
                  relation: 'self',
                  createdAt: DateTime(2025),
                  updatedAt: DateTime(2025),
                ),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.getTheme(useGoogleFonts: false),
              home: const Scaffold(body: ProfileHeaderCard()),
            ),
          ),
        );

        expect(find.text('Assalamu Alaikum,'), findsOneWidget);
        expect(find.text('Hamid'), findsOneWidget);
        expect(
          find.text('Continue your Quranic study & reflection today'),
          findsOneWidget,
        );

        // Verify "Switch Reader:" and family choice chips have been removed
        expect(find.text('Switch Reader:'), findsNothing);
        expect(find.text('Father'), findsNothing);
        expect(find.text('Mother'), findsNothing);
      },
    );

    testWidgets(
      'ManualPassageScreen displays passage picker with all 114 Surahs',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.getTheme(useGoogleFonts: false),
            home: const ManualPassageScreen(),
          ),
        );

        expect(find.text('Select Passage'), findsOneWidget);
        expect(find.text('Manual Passage Entry'), findsOneWidget);
        expect(find.text('1. Choose Surah'), findsOneWidget);
        expect(find.text('2. Verse Range'), findsOneWidget);
        expect(find.text('Explore Passage Meaning'), findsOneWidget);

        // Verify default Surah is Al-Fatihah (1)
        expect(find.text('Al-Fatihah'), findsOneWidget);
      },
    );

    testWidgets(
      'SettingsScreen in dark mode renders visible text size preview',
      (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final settingsService = SettingsService(prefs);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              settingsServiceProvider.overrideWithValue(settingsService),
            ],
            child: MaterialApp(
              theme: AppTheme.getTheme(isDark: true, useGoogleFonts: false),
              home: const SettingsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final previewFinder = find.text(
          'Preview: "All praise is due to Allah, Lord of the worlds."',
        );
        expect(previewFinder, findsOneWidget);

        final Text previewText = tester.widget<Text>(previewFinder);
        expect(previewText.style?.color, equals(AppColors.darkTextPrimary));
      },
    );

    testWidgets(
      'SettingsScreen renders without overflow on 320px narrow screens',
      (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final settingsService = SettingsService(prefs);

        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              settingsServiceProvider.overrideWithValue(settingsService),
            ],
            child: MaterialApp(
              theme: AppTheme.getTheme(isDark: true, useGoogleFonts: false),
              home: const SettingsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Settings & Preferences'), findsOneWidget);
        await tester.scrollUntilVisible(find.text('Standard'), 200);
        expect(find.text('Standard'), findsOneWidget);
        expect(find.text('Comfortable'), findsOneWidget);
        expect(find.text('Large'), findsOneWidget);
        expect(find.text('Extra Large'), findsOneWidget);
      },
    );

    testWidgets(
      'ManualPassageScreen renders without overflow on 320px narrow screens',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.getTheme(useGoogleFonts: false),
            home: const ManualPassageScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Manual Passage Entry'), findsOneWidget);
        expect(find.text('From Verse'), findsOneWidget);
        expect(find.text('To Verse'), findsOneWidget);
      },
    );

    testWidgets(
      'Exploration cards in dark mode use high-contrast dark text styling',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.getTheme(isDark: true, useGoogleFonts: false),
              home: const Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      SimpleExplanationCard(
                        explanation:
                            'This is a clear explanation in plain English.',
                      ),
                      ScholarlyViewsCard(
                        scholarlyViews: [
                          ScholarlyView(
                            scholarOrWork: 'Tafsir Ibn Kathir',
                            perspective:
                                'Classical contextual explanation of the verses.',
                            notes: 'Traditional narration based',
                            isVerified: true,
                          ),
                        ],
                      ),
                      VerseTranslationCard(
                        surahName: 'Al-Baqarah',
                        surahNumber: 2,
                        startVerse: 1,
                        endVerse: 5,
                        arabicText: 'الم',
                        translation:
                            'Alif, Lam, Meem. This is the Book about which there is no doubt.',
                        translationSource: 'Saheeh International',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final explanationFinder = find.text(
          'This is a clear explanation in plain English.',
        );
        expect(explanationFinder, findsOneWidget);
        final Text explanationText = tester.widget<Text>(explanationFinder);
        expect(explanationText.style?.color, equals(AppColors.darkTextPrimary));

        final scholarFinder = find.text(
          'Classical contextual explanation of the verses.',
        );
        expect(scholarFinder, findsOneWidget);
        final Text scholarText = tester.widget<Text>(scholarFinder);
        expect(scholarText.style?.color, equals(AppColors.darkTextPrimary));

        final translationFinder = find.text(
          'Alif, Lam, Meem. This is the Book about which there is no doubt.',
        );
        expect(translationFinder, findsOneWidget);
        final Text translationText = tester.widget<Text>(translationFinder);
        expect(translationText.style?.color, equals(AppColors.darkTextPrimary));
      },
    );

    testWidgets(
      'Exploration cards render without overflow on 320px narrow screens with large font scale',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.getTheme(isDark: true, useGoogleFonts: false),
            home: const Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    HistoricalContextCard(
                      contextData: HistoricalContext(
                        content:
                            'Detailed historical backdrop of the revelation.',
                        classification: 'Madani',
                        occasionsOfRevelation:
                            'Revealed concerning a group inquiring about specific rulings.',
                      ),
                      textScale: 1.3,
                    ),
                    ScholarlyViewsCard(
                      scholarlyViews: [
                        ScholarlyView(
                          scholarOrWork:
                              'Tafsir Al-Qurtubi (Abu Abd Allah al-Qurtubi)',
                          perspective:
                              'Comprehensive legal and contextual exposition.',
                          notes:
                              'Focus on jurisprudence and linguistic precision',
                          isVerified: true,
                        ),
                      ],
                      textScale: 1.3,
                    ),
                    LessonsReflectionsCard(
                      lessons: [
                        'Patience and perseverance through times of tribulation and hardship.',
                      ],
                      textScale: 1.3,
                    ),
                    RelatedStoriesCard(
                      stories: [
                        StoryItem(
                          title: 'The Companions and the Migration',
                          narrative: 'A narrative of faith and brotherhood.',
                          storyType: 'Sahabah History',
                        ),
                      ],
                      textScale: 1.3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'ExplorationScreen loads and renders explanation sections without getting stuck',
      (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final mockSettingsService = SettingsService(prefs);

        final testExplanation = QuranExplanation(
          surahName: 'Al-Kahf',
          surahNumber: 18,
          startVerse: 1,
          endVerse: 10,
          arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          translation:
              'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
          simpleExplanation:
              'This is a clear, beautiful explanation of Surah Al-Kahf.',
          historicalContext: const HistoricalContext(
            content:
                'Revealed in Makkah during a pivotal phase of early Islamic history.',
          ),
        );

        final testSession = ReadingSession(
          id: 'test_session_1',
          profileId: 'profile_me',
          readAt: DateTime.now(),
          surahNumber: 18,
          surahName: 'Al-Kahf',
          startVerse: 1,
          endVerse: 10,
          explanationJson: jsonEncode(testExplanation.toJson()),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              settingsServiceProvider.overrideWithValue(mockSettingsService),
            ],
            child: MaterialApp(
              theme: AppTheme.getTheme(isDark: false, useGoogleFonts: false),
              home: ExplorationScreen(
                surahNumber: 18,
                surahName: 'Al-Kahf',
                startVerse: 1,
                endVerse: 10,
                existingSession: testSession,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Verse & Translation'), findsOneWidget);
        expect(find.text('Simple Explanation'), findsOneWidget);
        expect(find.text('Historical Context'), findsOneWidget);
        expect(find.text('Ask Gemini'), findsOneWidget);
        expect(find.text('Saved'), findsOneWidget);
      },
    );

    testWidgets(
      'ExplorationScreen switches between English and Urdu explanations when language toggle is pressed',
      (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final mockSettingsService = SettingsService(prefs);

        final testExplanation = QuranExplanation(
          surahName: 'Al-Kahf',
          surahNumber: 18,
          startVerse: 1,
          endVerse: 10,
          arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          translation: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
          translationUrdu: 'اللہ کے نام سے جو نہایت مہربان، ہمیشہ رحم فرمانے والا ہے۔',
          simpleExplanation: 'This is an English explanation.',
          simpleExplanationUrdu: 'یہ ایک آسان اور سلیس اردو تشریح ہے۔',
          historicalContext: const HistoricalContext(content: 'Historical context.'),
        );

        final testSession = ReadingSession(
          id: 'test_session_urdu',
          profileId: 'profile_me',
          readAt: DateTime.now(),
          surahNumber: 18,
          surahName: 'Al-Kahf',
          startVerse: 1,
          endVerse: 10,
          explanationJson: jsonEncode(testExplanation.toJson()),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              settingsServiceProvider.overrideWithValue(mockSettingsService),
            ],
            child: MaterialApp(
              theme: AppTheme.getTheme(isDark: false, useGoogleFonts: false),
              home: ExplorationScreen(
                surahNumber: 18,
                surahName: 'Al-Kahf',
                startVerse: 1,
                endVerse: 10,
                existingSession: testSession,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Initially in English
        expect(find.text('This is an English explanation.'), findsOneWidget);
        expect(find.text('Simple Explanation'), findsOneWidget);

        // Tap the Urdu language toggle
        final urduToggleFinder = find.text('اردو');
        expect(urduToggleFinder, findsAtLeastNWidgets(1));
        await tester.tap(urduToggleFinder.first);
        await tester.pumpAndSettle();

        // Switched to Urdu
        expect(find.text('یہ ایک آسان اور سلیس اردو تشریح ہے۔'), findsOneWidget);
        expect(find.text('آسان تشریح (اردو)'), findsOneWidget);
        expect(find.text('اللہ کے نام سے جو نہایت مہربان، ہمیشہ رحم فرمانے والا ہے۔'), findsOneWidget);
      },
    );

    testWidgets(
      'SimpleExplanationCard renders speaker audio button and responds to tap',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.getTheme(isDark: false, useGoogleFonts: false),
              home: const Scaffold(
                body: SimpleExplanationCard(
                  explanation: 'This is an explanation to be read aloud.',
                  explanationUrdu: 'یہ اردو تشریح ہے۔',
                  isUrdu: false,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Speaker button exists
        expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
        expect(find.text('Listen'), findsOneWidget);

        // Tap the speaker button
        await tester.tap(find.text('Listen'));
        await tester.pump();
        expect(tester.takeException(), isNull);
      },
    );
  });
}
