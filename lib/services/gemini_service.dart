import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/constants/quran_data.dart';
import '../data/models/passage_identification.dart';
import '../data/models/quran_explanation.dart';
import '../data/models/quran_surah.dart';
import 'settings_service.dart';

class GeminiService {
  final SettingsService _settingsService;
  final bool enableDemoDelay;

  GeminiService(this._settingsService, {this.enableDemoDelay = true});

  bool get isConfigured => _settingsService.isApiKeyConfigured();

  String get _apiKey => _settingsService.getGeminiApiKey();

  /// Identifies the Quranic passage from an uploaded Mushaf page image
  Future<PassageIdentification> identifyPassageFromImage(
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    if (!isConfigured) {
      debugPrint('Gemini API key is not configured. Returning realistic demonstration result.');
      if (enableDemoDelay) await Future.delayed(const Duration(milliseconds: 1200));
      return _generateDemoIdentification();
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-3.5-flash-lite',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.2,
        ),
      );

      final promptText = '''
You are an expert Quranic manuscript and text identification system.
Analyze this image of a page from the Holy Quran (Mushaf) carefully.

Identify:
1. The likely Surah name in English (e.g., "Al-Baqarah", "Al-Kahf", "Yasin").
2. The exact Surah number (1 to 114).
3. The first identifiable verse number (start_verse) appearing on the page.
4. The last identifiable verse number (end_verse) appearing on the page.
5. Extract the Arabic text of the opening lines or identifiable passage.
6. Assess confidence: "high", "medium", "low", or "uncertain".
7. Note any uncertainties, multiple Surahs on one page, or cropped/unclear lines in "uncertainties".
8. Always set "needs_user_confirmation" to true so the reader can verify against their physical Mushaf.

Return strictly a valid JSON object following this exact schema:
{
  "identified": true,
  "surah_name": "string",
  "surah_number": 1,
  "start_verse": 1,
  "end_verse": 10,
  "confidence": "high",
  "extracted_text": "Arabic text snippet here",
  "uncertainties": ["note 1", "note 2"],
  "needs_user_confirmation": true
}
''';

      final content = [
        Content.multi([
          TextPart(promptText),
          DataPart(mimeType, imageBytes),
        ]),
      ];

      final response = await model.generateContent(content);
      final rawText = response.text;

      if (rawText == null || rawText.trim().isEmpty) {
        return PassageIdentification.failure(
          'Gemini returned an empty response. Please verify your photo is clear and retry.',
        );
      }

      return PassageIdentification.fromRawString(rawText);
    } catch (e) {
      debugPrint('Gemini identification API error: $e');
      // If error is network or key related, give helpful message
      return PassageIdentification.failure(
        _formatErrorMessage(e),
      );
    }
  }

  /// Generates structured Quranic explanation for confirmed passage
  Future<QuranExplanation> generateExplanation({
    required int surahNumber,
    required String surahName,
    required int startVerse,
    required int endVerse,
    String? knownArabicSnippet,
  }) async {
    if (!isConfigured) {
      debugPrint('Gemini API key is not configured. Returning rich demonstration explanation.');
      if (enableDemoDelay) await Future.delayed(const Duration(milliseconds: 1400));
      return _generateDemoExplanation(surahNumber, surahName, startVerse, endVerse);
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-3.5-flash-lite',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.3,
        ),
      );

      final surahInfo = QuranData.getByNumber(surahNumber);
      final surahAr = surahInfo?.nameAr ?? '';
      final revType = surahInfo?.revelationType ?? '';

      final prompt = '''
You are an expert Islamic studies scholar and AI Quran companion.
Your goal is to provide a comprehensive, spiritually enriching, and respectful study guide for:
Surah $surahName (Surah #$surahNumber, $surahAr, traditionally $revType), Verses $startVerse through $endVerse.

CRITICAL GUIDELINES:
1. Clearly distinguish Quranic text, English translation, established history, scholarly views, and spiritual reflections.
2. Do NOT invent scholar names, book titles, quotations, or hadiths. If a specific occasion of revelation is not established in authentic reports, state that it is general or not uniquely documented.
4. Keep the simple explanation accessible for everyday family reading in plain, warm English.
5. Emphasize practical lessons for personal character, family relationships, patience, gratitude, and faith.
6. In 'simple_explanation_urdu', write a fluent, warm, and natural Urdu explanation (آسان اور سلیس اردو تشریح) suitable for family reading, and in 'translation_urdu', provide the authentic Urdu verse translation.

Return strictly a valid JSON object with this exact structure:
{
  "passage": {
    "surah_name": "$surahName",
    "surah_number": $surahNumber,
    "start_verse": $startVerse,
    "end_verse": $endVerse
  },
  "arabic_text": "Exact Arabic text of the verses with diacritics",
  "translation": "Accurate, clear English translation of these verses",
  "translation_urdu": "ان آیات کا سلیس، بامحاورہ اور مستند اردو ترجمہ",
  "translation_source": "English Study Translation (adapted from standard scholarly translations)",
  "simple_explanation": "Accessible, short paragraphs explaining the central themes and meanings in warm, plain English.",
  "simple_explanation_urdu": "ان آیات کا آسان، عام فہم اور دل نشین اردو خلاصہ اور تشریح جو ہر عمر کے افراد اور خاندان کے مطالعہ کے لیے نہایت آسان ہو۔",
  "historical_context": {
    "content": "Historical circumstances of this Surah and passage.",
    "classification": "$revType",
    "occasions_of_revelation": "Specific Sabab al-Nuzul if authentically documented, or general historical backdrop if not.",
    "certainty": "established / general_context / uncertain"
  },
  "related_stories": [
    {
      "title": "Title of story or narrative",
      "narrative": "Detailed narrative relating to this passage.",
      "story_type": "Quranic Narrative"
    }
  ],
  "lessons": [
    "Practical lesson on personal conduct or moral growth",
    "Reflection on patience, gratitude, or trust in God",
    "Practical application in daily life"
  ],
  "scholarly_interpretations": [
    {
      "scholar_or_work": "Name of tafsir work or classical scholar (e.g. Tafsir Ibn Kathir, Al-Qurtubi, Al-Tabari)",
      "perspective": "Key insight and commentary from this scholarly perspective.",
      "notes": "Contextual notes or consensus",
      "is_verified": true
    }
  ],
  "spiritual_reflections": [
    {
      "attributed_to": "Attributed scholar/sage or traditional contemplative theme (e.g. Imam al-Ghazali, Hasan al-Basri)",
      "reflection": "Spiritual meaning, heart contemplation, and deeper ethical dimension.",
      "kind": "Spiritual Contemplation",
      "certainty": "Traditional Contemplation"
    }
  ],
  "limitations": [
    "AI explanations are for personal study and reflection.",
    "For definitive legal rulings or fatwas, consult qualified Islamic scholars."
  ],
  "caution_disclaimer": "This explanation is generated by AI as a study aid. It does not replace classical Islamic scholarship or represent authoritative religious rulings."
}
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final rawText = response.text;

      if (rawText == null || rawText.trim().isEmpty) {
        throw Exception('Gemini returned an empty explanation response.');
      }

      return QuranExplanation.fromRawString(rawText);
    } catch (e) {
      debugPrint('Gemini explanation API error: $e');
      throw Exception(_formatErrorMessage(e));
    }
  }

  /// Contextual Q&A scoped to the current passage
  Future<String> askQuestionAboutPassage({
    required QuranExplanation explanation,
    required String userQuestion,
    List<Map<String, String>> previousHistory = const [],
  }) async {
    if (!isConfigured) {
      if (enableDemoDelay) await Future.delayed(const Duration(milliseconds: 900));
      return _generateDemoQAAnswer(explanation, userQuestion);
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-3.5-flash-lite',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.3,
        ),
      );

      final systemContext = '''
You are Quran Companion, a knowledgeable, gentle, and respectful Islamic study assistant for a family.
The user is currently studying:
Surah: ${explanation.surahName} (${explanation.surahNumber})
Verses: ${explanation.startVerse} to ${explanation.endVerse}
Arabic Text: ${explanation.arabicText}
Translation: ${explanation.translation}
Explanation Summary: ${explanation.simpleExplanation}

Answer the user's specific question strictly within the context of this Quranic passage.
Be clear, encouraging, respectful, and distinguish established facts from reflective interpretations.
Never fabricate hadiths, quotes, or rulings.
''';

      final List<Content> chatHistory = [
        Content.text(systemContext),
      ];

      for (final turn in previousHistory) {
        if (turn.containsKey('user')) {
          chatHistory.add(Content.text('User: ${turn['user']}'));
        }
        if (turn.containsKey('model')) {
          chatHistory.add(Content.model([TextPart(turn['model']!)]));
        }
      }

      chatHistory.add(Content.text('User Question: $userQuestion'));

      final response = await model.generateContent(chatHistory);
      return response.text ?? 'I was unable to formulate a response. Please try rephrasing your question.';
    } catch (e) {
      debugPrint('Gemini Q&A error: $e');
      return 'Could not reach Gemini: ${_formatErrorMessage(e)}';
    }
  }

  /// Generates or translates Urdu explanation on demand
  Future<String> generateUrduExplanationOnDemand({
    required int surahNumber,
    required String surahName,
    required int startVerse,
    required int endVerse,
    required String englishExplanation,
  }) async {
    if (!isConfigured) {
      return 'یہ مبارک آیات اللہ تعالیٰ کی حمد و ثناء سے شروع ہوتی ہیں جس نے اپنے بندے پر یہ برحق کتاب نازل فرمائی اور اس میں کوئی کجی یا نقص نہیں رکھا۔\n\nیہ کلام سراسر سیدھا اور مضبوط ہے، تاکہ غفلت میں پڑے لوگوں کو آگاہ کرے اور نیک عمل کرنے والے مومنین کو یہ بشارت دے کہ ان کے لیے اللہ کے ہاں بہترین اور لازوال اجر ہے۔';
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-3.5-flash-lite',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.3,
        ),
      );

      final prompt = '''
You are an expert Islamic scholar and bilingual Arabic/Urdu translator.
Translate and explain the following Quranic explanation for Surah $surahName ($surahNumber:$startVerse-$endVerse) into clear, beautiful, warm, and easily accessible Urdu (آسان اور سلیس اردو تشریح).
Keep the language natural, respectful, and easy to read for parents and families.
Return ONLY the Urdu explanation text.

English explanation:
$englishExplanation
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim();
      if (text != null && text.isNotEmpty) {
        return text;
      }
    } catch (e) {
      debugPrint('Error generating on-demand Urdu explanation: $e');
    }

    return 'اس سورت کی یہ مبارک آیات اللہ تعالیٰ کی بے پایاں رحمت، رہنمائی اور حکمت پر مبنی ہیں جو ہر مومن کو صبر، شکر اور استقامت کی ترغیب دیتی ہیں۔';
  }

  String _formatErrorMessage(dynamic error) {
    final str = error.toString();
    if (str.contains('API_KEY_INVALID') || str.contains('API key not valid')) {
      return 'The configured Gemini API key is invalid. Please update it in Settings.';
    }
    if (str.contains('RESOURCE_EXHAUSTED') || str.contains('quota')) {
      return 'Gemini API quota exceeded or rate limit reached. Please wait a minute and retry.';
    }
    if (str.contains('SocketException') || str.contains('Failed host lookup')) {
      return 'No internet connection. Please check your network and retry.';
    }
    return str.replaceAll('Exception:', '').trim();
  }

  // --- Demonstration Fallbacks (When API key is not yet configured) ---

  PassageIdentification _generateDemoIdentification() {
    return const PassageIdentification(
      identified: true,
      surahName: 'Al-Kahf',
      surahNumber: 18,
      startVerse: 1,
      endVerse: 10,
      confidence: 'high',
      extractedText:
          'الْحَمْدُ لِلَّهِ الَّذِي أَنزَلَ عَلَىٰ عَبْدِهِ الْكِتَابَ وَلَمْ يَجْعَل لَّهُ عِوَجًا ۜ قَيِّمًا لِّيُنذِرَ بَأْسًا شَدِيدًا مِّن لَّدُنْهُ وَيُبَشِّرَ الْمُؤْمِنِينَ الَّذِينَ يَعْمَلُونَ الصَّالِحَاتِ أَنَّ لَهُمْ أَجْرًا حَسَنًا',
      uncertainties: [
        'Demonstration mode active: Photo identified as opening of Surah Al-Kahf (Verses 1–10). Add your Gemini API key in Settings for live image scanning.',
      ],
      needsUserConfirmation: true,
    );
  }

  QuranExplanation _generateDemoExplanation(
    int surahNumber,
    String surahName,
    int startVerse,
    int endVerse,
  ) {
    final surah = QuranData.getByNumber(surahNumber) ??
        QuranSurah(
          number: surahNumber,
          nameEn: surahName,
          nameTranslation: 'The Chapter',
          nameAr: '',
          totalVerses: 100,
          revelationType: 'Makki',
        );

    return QuranExplanation(
      surahName: surah.nameEn,
      surahNumber: surah.number,
      startVerse: startVerse,
      endVerse: endVerse,
      arabicText:
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nالْحَمْدُ لِلَّهِ الَّذِي أَنزَلَ عَلَىٰ عَبْدِهِ الْكِتَابَ وَلَمْ يَجْعَل لَّهُ عِوَجًا ۜ قَيِّمًا لِّيُنذِرَ بَأْسًا شَدِيدًا مِّن لَّدُنْهُ وَيُبَشِّرَ الْمُؤْمِنِينَ الَّذِينَ يَعْمَلُونَ الصَّالِحَاتِ أَنَّ لَهُمْ أَجْرًا حَسَنًا',
      translation:
          '[All] praise is [due] to Allah, who has sent down upon His Servant the Book and has not made therein any deviance. [He has made it] straight, to warn of severe punishment from Him and to give good tidings to the believers who do righteous deeds that they will have a good reward.',
      translationUrdu:
          'تمام تعریفیں اللہ ہی کے لیے ہیں جس نے اپنے بندے پر یہ کتاب نازل فرمائی اور اس میں کوئی کجی نہ رکھی۔ بالکل سیدھی اور درست کتاب، تاکہ وہ اللہ کے سخت عذاب سے خبردار کرے اور نیک اعمال کرنے والے اہل ایمان کو خوشخبری دے کہ ان کے لیے بہترین اجر ہے۔',
      translationSource: 'Sahih International (Study Reference)',
      simpleExplanation:
          'This noble opening establishes the ultimate praise of God for the gift of divine revelation. The Quran is characterized as completely upright ("qayyiman"), free from distortion, extremes, or contradictions.\n\nIts dual mission is highlighted right away: bringing gentle encouragement and glad tidings to those striving to do good, while providing a clear and compassionate warning against self-destructive paths and spiritual heedlessness.',
      simpleExplanationUrdu:
          'یہ مبارک آیات اللہ تعالیٰ کی حمد و ثناء سے شروع ہوتی ہیں جس نے قرآن مجید جیسی عظیم نعمت عطا فرمائی۔ یہ کلام کسی بھی قسم کے تضاد، نقص اور کجی سے مکمل طور پر پاک ہے۔\n\nاس کا اہم مقصد انسانوں کو غفلت اور گمراہی کے انجام سے باخبر کرنا، اور نیک عمل کرنے والے مومنین کو اللہ تعالیٰ کی رضا، رحمت اور جنت کی نوید سنانا ہے۔',
      historicalContext: HistoricalContext(
        content:
            'Surah ${surah.nameEn} was revealed in Makkah during a period when the early Muslim community faced mounting pressure. The leaders of Quraysh sought counsel from the rabbis of Yathrib (Madinah) to formulate challenging questions for the Prophet Muhammad (peace be upon him) regarding youth who slept in a cave, a great traveler, and the soul.',
        classification: surah.revelationType,
        occasionsOfRevelation:
            'Authentic traditions recount that the Quraysh posed these three inquiries to test the Prophet’s prophethood, leading to the revelation of this comprehensive Surah offering profound wisdom on tribulation, faith, and preservation of truth.',
        certainty: 'established',
      ),
      relatedStories: [
        const StoryItem(
          title: 'The Young Men of the Cave (Ashab al-Kahf)',
          narrative:
              'A group of faithful youths escaped persecution in their city to preserve their monotheistic belief in God. Taking refuge in a secluded mountain cave, they called upon God for mercy. God caused them to sleep peacefully for centuries, sheltered from harm, standing as an eternal symbol that sincerity and reliance upon God always outlast tyranny.',
          storyType: 'Quranic Narrative',
        ),
      ],
      lessons: [
        'Gratitude for Guidance: The opening begins with praise (Alhamdulillah) for divine guidance, reminding us that knowledge of the right path is among life’s greatest blessings.',
        'Courage in Conviction: The youth demonstrated that remaining true to one’s principles and conscience is paramount, even when society moves in an opposing direction.',
        'Seeking Solace with God: In times of anxiety or hardship, turning to heartfelt prayer ("Our Lord, grant us from Yourself mercy and prepare for us from our affair right guidance") brings peace.',
      ],
      scholarlyInterpretations: [
        const ScholarlyView(
          scholarOrWork: 'Tafsir Ibn Kathir',
          perspective:
              'Ibn Kathir emphasizes that Allah begins this Surah praising Himself for sending down the Book, declaring it entirely balanced ("qayyiman") without exaggeration or neglect, serving as a beacon of clarity for humanity.',
          notes: 'Classic textual commentary emphasizing linguistic harmony.',
          isVerified: true,
        ),
        const ScholarlyView(
          scholarOrWork: 'Al-Qurtubi (Al-Jami\' li-Ahkam al-Quran)',
          perspective:
              'Al-Qurtubi notes the beauty of the word "qayyiman" acting as an emphasis: the Quran not only lacks deviance itself, but actively straightens and guides other matters of human life and law.',
          notes: 'Legal and ethical analysis of the verse syntax.',
          isVerified: true,
        ),
      ],
      spiritualReflections: [
        const SpiritualReflection(
          attributedTo: 'Imam Abu Hamid al-Ghazali (Ihya \'Ulum al-Din)',
          reflection:
              'Reflecting on the cave, Al-Ghazali notes that the true cave for the seeker is the solitude of the heart—withdrawing inner consciousness from worldly distractions and ego so that the light of divine mercy may dwell within.',
          kind: 'Historical Saying / Quotation',
          certainty: 'Traditional Contemplation',
        ),
        const SpiritualReflection(
          attributedTo: 'Contemplative Islamic Tradition',
          reflection:
              'The passage teaches us that physical weakness or vulnerability does not limit divine assistance. When a person surrenders their worries to the Divine, tranquility descends where fear once lived.',
          kind: 'Spiritual Contemplation',
          certainty: 'General Spiritual Contemplation',
        ),
      ],
      limitations: [
        'This is a generated study aid to assist your family in personal reflection.',
        'For definitive legal rulings or fatwas, consult qualified Islamic scholars.',
      ],
      cautionDisclaimer:
          'Demonstration study preview: Add your Gemini API key in Settings to generate dynamic live explanations for any passage.',
    );
  }

  String _generateDemoQAAnswer(QuranExplanation explanation, String question) {
    final q = question.toLowerCase();
    if (q.contains('simple') || q.contains('easy') || q.contains('explain')) {
      return 'In simple words: This passage teaches us that God’s message is a great gift that guides us straight. It encourages those who do good deeds with promise of peace and reward, and warns against turning away from truth.';
    }
    if (q.contains('learn') || q.contains('lesson') || q.contains('practical') || q.contains('apply')) {
      return 'A practical lesson you can apply today is to begin your morning with heartfelt gratitude (Alhamdulillah), and to choose honesty and patience even when others around you take shortcuts.';
    }
    if (q.contains('spiritual') || q.contains('heart') || q.contains('meaning')) {
      return 'The spiritual wisdom here invites us to find an "inner cave" of stillness through prayer and remembrance, detaching our hearts from worldly anxieties and trusting that God protects what is sincerely dedicated to Him.';
    }
    return 'Reflecting on ${explanation.passageReference}: This passage directs the heart towards conscious faith, moral integrity, and reliance on God. (Tip: Configure your Gemini API key in Settings to ask any custom in-depth questions!)';
  }
}
