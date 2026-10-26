class Question {
  final String id;
  final String text;
  final String
  category; // 'My Story', 'My People', 'My Interests', 'My Future', 'General'
  final List<String> tags;
  final bool isActive;

  const Question({
    required this.id,
    required this.text,
    required this.category,
    this.tags = const [],
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'category': category,
      'tags': tags.join(','),
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    final tagsStr = map['tags'] as String? ?? '';
    return Question(
      id: map['id'] as String,
      text: (map['text'] as String?) ?? '',
      category: (map['category'] as String?) ?? 'General',
      tags: tagsStr.isNotEmpty ? tagsStr.split(',') : const [],
      isActive: (map['is_active'] as int? ?? 1) == 1,
    );
  }
}

class QuestionResponse {
  final String id;
  final String questionId;
  final String answerText;
  final String responseDate; // YYYY-MM-DD
  final String? source; // 'daily', 'random', 'category'
  final DateTime createdAt;
  final DateTime updatedAt;

  const QuestionResponse({
    required this.id,
    required this.questionId,
    required this.answerText,
    required this.responseDate,
    this.source = 'daily',
    required this.createdAt,
    required this.updatedAt,
  });

  QuestionResponse copyWith({
    String? id,
    String? questionId,
    String? answerText,
    String? responseDate,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuestionResponse(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      answerText: answerText ?? this.answerText,
      responseDate: responseDate ?? this.responseDate,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question_id': questionId,
      'answer_text': answerText,
      'response_date': responseDate,
      'source': source,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory QuestionResponse.fromMap(Map<String, dynamic> map) {
    return QuestionResponse(
      id: map['id'] as String,
      questionId: map['question_id'] as String,
      answerText: (map['answer_text'] as String?) ?? '',
      responseDate: (map['response_date'] as String?) ?? '',
      source: (map['source'] as String?) ?? 'daily',
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
