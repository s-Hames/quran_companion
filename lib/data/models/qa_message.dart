class QAMessage {
  final String id;
  final String question;
  final String answer;
  final DateTime timestamp;

  const QAMessage({
    required this.id,
    required this.question,
    required this.answer,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'answer': answer,
    'timestamp': timestamp.toIso8601String(),
  };

  factory QAMessage.fromJson(Map<String, dynamic> json) => QAMessage(
    id: json['id'] as String? ?? UniqueKey().toString(),
    question: json['question'] as String? ?? '',
    answer: json['answer'] as String? ?? '',
    timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
  );
}

class UniqueKey {
  @override
  String toString() => DateTime.now().microsecondsSinceEpoch.toString();
}
