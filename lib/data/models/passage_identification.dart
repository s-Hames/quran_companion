import 'dart:convert';
import '../../core/constants/quran_data.dart';

class PassageIdentification {
  final bool identified;
  final String surahName;
  final int surahNumber;
  final int startVerse;
  final int endVerse;
  final String confidence; // 'high', 'medium', 'low', 'uncertain'
  final String extractedText;
  final List<String> uncertainties;
  final bool needsUserConfirmation;
  final String? errorMessage;

  const PassageIdentification({
    required this.identified,
    required this.surahName,
    required this.surahNumber,
    required this.startVerse,
    required this.endVerse,
    this.confidence = 'medium',
    this.extractedText = '',
    this.uncertainties = const [],
    this.needsUserConfirmation = true,
    this.errorMessage,
  });

  PassageIdentification copyWith({
    bool? identified,
    String? surahName,
    int? surahNumber,
    int? startVerse,
    int? endVerse,
    String? confidence,
    String? extractedText,
    List<String>? uncertainties,
    bool? needsUserConfirmation,
    String? errorMessage,
  }) {
    return PassageIdentification(
      identified: identified ?? this.identified,
      surahName: surahName ?? this.surahName,
      surahNumber: surahNumber ?? this.surahNumber,
      startVerse: startVerse ?? this.startVerse,
      endVerse: endVerse ?? this.endVerse,
      confidence: confidence ?? this.confidence,
      extractedText: extractedText ?? this.extractedText,
      uncertainties: uncertainties ?? this.uncertainties,
      needsUserConfirmation: needsUserConfirmation ?? this.needsUserConfirmation,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identified': identified,
      'surah_name': surahName,
      'surah_number': surahNumber,
      'start_verse': startVerse,
      'end_verse': endVerse,
      'confidence': confidence,
      'extracted_text': extractedText,
      'uncertainties': uncertainties,
      'needs_user_confirmation': needsUserConfirmation,
      'error_message': errorMessage,
    };
  }

  factory PassageIdentification.fromJson(Map<String, dynamic> json) {
    int parsedSurahNumber = 0;
    if (json['surah_number'] is int) {
      parsedSurahNumber = json['surah_number'] as int;
    } else if (json['surah_number'] != null) {
      parsedSurahNumber = int.tryParse(json['surah_number'].toString()) ?? 0;
    }

    String parsedSurahName = json['surah_name']?.toString() ?? '';

    // If surah number is 0 or out of bounds, try to resolve from name
    if (parsedSurahNumber < 1 || parsedSurahNumber > 114) {
      final matched = QuranData.findByName(parsedSurahName);
      if (matched != null) {
        parsedSurahNumber = matched.number;
        parsedSurahName = matched.nameEn;
      }
    } else {
      // Validate or standardize surah name from number
      final known = QuranData.getByNumber(parsedSurahNumber);
      if (known != null && parsedSurahName.isEmpty) {
        parsedSurahName = known.nameEn;
      }
    }

    int start = 1;
    if (json['start_verse'] is int) {
      start = json['start_verse'] as int;
    } else if (json['start_verse'] != null) {
      start = int.tryParse(json['start_verse'].toString()) ?? 1;
    }

    int end = start;
    if (json['end_verse'] is int) {
      end = json['end_verse'] as int;
    } else if (json['end_verse'] != null) {
      end = int.tryParse(json['end_verse'].toString()) ?? start;
    }

    // Ensure start >= 1 and end >= start
    if (start < 1) start = 1;
    if (end < start) end = start;

    // Check bounds against known total verses if surah is valid
    if (parsedSurahNumber >= 1 && parsedSurahNumber <= 114) {
      final known = QuranData.getByNumber(parsedSurahNumber);
      if (known != null && end > known.totalVerses) {
        end = known.totalVerses;
        if (start > end) start = 1;
      }
    }

    List<String> parsedUncertainties = [];
    if (json['uncertainties'] is List) {
      parsedUncertainties = (json['uncertainties'] as List)
          .map((e) => e.toString())
          .toList();
    }

    final identified = json['identified'] == true ||
        (json['identified'] is String && json['identified'].toString().toLowerCase() == 'true') ||
        (parsedSurahNumber > 0);

    return PassageIdentification(
      identified: identified,
      surahName: parsedSurahName.isNotEmpty ? parsedSurahName : 'Unknown Surah',
      surahNumber: parsedSurahNumber,
      startVerse: start,
      endVerse: end,
      confidence: json['confidence']?.toString() ?? (identified ? 'medium' : 'uncertain'),
      extractedText: json['extracted_text']?.toString() ?? '',
      uncertainties: parsedUncertainties,
      needsUserConfirmation: json['needs_user_confirmation'] != false,
      errorMessage: json['error_message']?.toString(),
    );
  }

  factory PassageIdentification.fromRawString(String raw) {
    try {
      String clean = raw.trim();
      if (clean.startsWith('```json')) {
        clean = clean.substring(7);
      } else if (clean.startsWith('```')) {
        clean = clean.substring(3);
      }
      if (clean.endsWith('```')) {
        clean = clean.substring(0, clean.length - 3);
      }
      clean = clean.trim();

      // Find first '{' and last '}'
      final startIdx = clean.indexOf('{');
      final endIdx = clean.lastIndexOf('}');
      if (startIdx != -1 && endIdx != -1 && endIdx > startIdx) {
        clean = clean.substring(startIdx, endIdx + 1);
      }

      final dynamic decoded = jsonDecode(clean);
      if (decoded is Map<String, dynamic>) {
        return PassageIdentification.fromJson(decoded);
      }
      return const PassageIdentification(
        identified: false,
        surahName: '',
        surahNumber: 0,
        startVerse: 1,
        endVerse: 1,
        confidence: 'uncertain',
        errorMessage: 'Response format was not a JSON object.',
      );
    } catch (e) {
      return PassageIdentification(
        identified: false,
        surahName: '',
        surahNumber: 0,
        startVerse: 1,
        endVerse: 1,
        confidence: 'uncertain',
        errorMessage: 'Failed to parse identification result: $e',
      );
    }
  }

  factory PassageIdentification.failure(String message) {
    return PassageIdentification(
      identified: false,
      surahName: '',
      surahNumber: 0,
      startVerse: 1,
      endVerse: 1,
      confidence: 'uncertain',
      errorMessage: message,
    );
  }
}
