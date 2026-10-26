class JournalEntry {
  final String id;
  final String date; // YYYY-MM-DD
  final String title;
  final String body;
  final String? colorId;
  final String? fontSize;
  final DateTime createdAt;
  final DateTime updatedAt;

  const JournalEntry({
    required this.id,
    required this.date,
    this.title = '',
    this.body = '',
    this.colorId,
    this.fontSize = 'md',
    required this.createdAt,
    required this.updatedAt,
  });

  JournalEntry copyWith({
    String? id,
    String? date,
    String? title,
    String? body,
    String? colorId,
    String? fontSize,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      body: body ?? this.body,
      colorId: colorId ?? this.colorId,
      fontSize: fontSize ?? this.fontSize,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'title': title,
      'body': body,
      'color_id': colorId,
      'font_size': fontSize,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] as String,
      date: (map['date'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      body: (map['body'] as String?) ?? '',
      colorId: map['color_id'] as String?,
      fontSize: (map['font_size'] as String?) ?? 'md',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
