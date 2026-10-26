class Note {
  final String id;
  final String title;
  final String body;
  final String category;
  final String? colorId;
  final String? fontSize;
  final String? templateId;
  final bool isPinned;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    this.title = '',
    this.body = '',
    this.category = 'Personal',
    this.colorId,
    this.fontSize = 'md',
    this.templateId,
    this.isPinned = false,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Note copyWith({
    String? id,
    String? title,
    String? body,
    String? category,
    String? colorId,
    String? fontSize,
    String? templateId,
    bool? isPinned,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      colorId: colorId ?? this.colorId,
      fontSize: fontSize ?? this.fontSize,
      templateId: templateId ?? this.templateId,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'category': category,
      'color_id': colorId,
      'font_size': fontSize,
      'template_id': templateId,
      'is_pinned': isPinned ? 1 : 0,
      'is_archived': isArchived ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      title: (map['title'] as String?) ?? '',
      body: (map['body'] as String?) ?? '',
      category: (map['category'] as String?) ?? 'Personal',
      colorId: map['color_id'] as String?,
      fontSize: (map['font_size'] as String?) ?? 'md',
      templateId: map['template_id'] as String?,
      isPinned: (map['is_pinned'] as int? ?? 0) == 1,
      isArchived: (map['is_archived'] as int? ?? 0) == 1,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
