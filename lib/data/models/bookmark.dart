class Bookmark {
  final String id;
  final String profileId;
  final String? sessionId;
  final String type; // 'session', 'passage', 'reflection'
  final String title;
  final String subtitle;
  final String content;
  final int surahNumber;
  final String surahName;
  final int startVerse;
  final int endVerse;
  final DateTime createdAt;

  const Bookmark({
    required this.id,
    required this.profileId,
    this.sessionId,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.surahNumber,
    required this.surahName,
    required this.startVerse,
    required this.endVerse,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'session_id': sessionId,
      'type': type,
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'surah_number': surahNumber,
      'surah_name': surahName,
      'start_verse': startVerse,
      'end_verse': endVerse,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'] as String,
      profileId: map['profile_id'] as String,
      sessionId: map['session_id'] as String?,
      type: map['type'] as String? ?? 'session',
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String? ?? '',
      content: map['content'] as String? ?? '',
      surahNumber: map['surah_number'] as int? ?? 1,
      surahName: map['surah_name'] as String? ?? '',
      startVerse: map['start_verse'] as int? ?? 1,
      endVerse: map['end_verse'] as int? ?? 1,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
