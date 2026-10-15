class Profile {
  final String id;
  final String name;
  final String relation; // 'me', 'father', 'mother', 'custom'
  final int avatarColorIndex;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.id,
    required this.name,
    required this.relation,
    this.avatarColorIndex = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Profile copyWith({
    String? name,
    int? avatarColorIndex,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id,
      name: name ?? this.name,
      relation: relation,
      avatarColorIndex: avatarColorIndex ?? this.avatarColorIndex,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'relation': relation,
      'avatar_color_index': avatarColorIndex,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      name: map['name'] as String,
      relation: map['relation'] as String? ?? 'custom',
      avatarColorIndex: map['avatar_color_index'] as int? ?? 0,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  static List<Profile> get defaultProfiles {
    final now = DateTime.now();
    return [
      Profile(id: 'me', name: 'Me', relation: 'me', avatarColorIndex: 0, createdAt: now, updatedAt: now),
      Profile(id: 'father', name: 'Father', relation: 'father', avatarColorIndex: 1, createdAt: now, updatedAt: now),
      Profile(id: 'mother', name: 'Mother', relation: 'mother', avatarColorIndex: 2, createdAt: now, updatedAt: now),
    ];
  }
}
