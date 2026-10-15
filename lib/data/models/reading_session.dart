import 'quran_explanation.dart';

class ReadingSession {
  final String id;
  final String profileId;
  final DateTime readAt;
  final int surahNumber;
  final String surahName;
  final int startVerse;
  final int endVerse;
  final String? imagePath;
  final String? extractedText;
  final String? explanationJson;
  final String? notes;
  final bool isBookmarked;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReadingSession({
    required this.id,
    required this.profileId,
    required this.readAt,
    required this.surahNumber,
    required this.surahName,
    required this.startVerse,
    required this.endVerse,
    this.imagePath,
    this.extractedText,
    this.explanationJson,
    this.notes,
    this.isBookmarked = false,
    required this.createdAt,
    required this.updatedAt,
  });

  String get passageReference => '$surahName ($surahNumber:$startVerse${endVerse > startVerse ? '-$endVerse' : ''})';

  int get verseCount => (endVerse >= startVerse) ? (endVerse - startVerse + 1) : 1;

  QuranExplanation? get parsedExplanation {
    if (explanationJson == null || explanationJson!.trim().isEmpty) return null;
    try {
      return QuranExplanation.fromRawString(explanationJson!);
    } catch (_) {
      return null;
    }
  }

  ReadingSession copyWith({
    String? profileId,
    DateTime? readAt,
    int? surahNumber,
    String? surahName,
    int? startVerse,
    int? endVerse,
    String? imagePath,
    String? extractedText,
    String? explanationJson,
    String? notes,
    bool? isBookmarked,
    DateTime? updatedAt,
  }) {
    return ReadingSession(
      id: id,
      profileId: profileId ?? this.profileId,
      readAt: readAt ?? this.readAt,
      surahNumber: surahNumber ?? this.surahNumber,
      surahName: surahName ?? this.surahName,
      startVerse: startVerse ?? this.startVerse,
      endVerse: endVerse ?? this.endVerse,
      imagePath: imagePath ?? this.imagePath,
      extractedText: extractedText ?? this.extractedText,
      explanationJson: explanationJson ?? this.explanationJson,
      notes: notes ?? this.notes,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'read_at': readAt.toIso8601String(),
      'surah_number': surahNumber,
      'surah_name': surahName,
      'start_verse': startVerse,
      'end_verse': endVerse,
      'image_path': imagePath,
      'extracted_text': extractedText,
      'explanation_json': explanationJson,
      'notes': notes,
      'is_bookmarked': isBookmarked ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ReadingSession.fromMap(Map<String, dynamic> map) {
    return ReadingSession(
      id: map['id'] as String,
      profileId: map['profile_id'] as String,
      readAt: DateTime.tryParse(map['read_at'] as String? ?? '') ?? DateTime.now(),
      surahNumber: map['surah_number'] as int? ?? 1,
      surahName: map['surah_name'] as String? ?? 'Surah',
      startVerse: map['start_verse'] as int? ?? 1,
      endVerse: map['end_verse'] as int? ?? 1,
      imagePath: map['image_path'] as String?,
      extractedText: map['extracted_text'] as String?,
      explanationJson: map['explanation_json'] as String?,
      notes: map['notes'] as String?,
      isBookmarked: (map['is_bookmarked'] as int? ?? 0) == 1,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
