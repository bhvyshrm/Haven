class HavenTemplate {
  final String id;
  final String title;
  final String category; // 'Personal', 'People', 'College', 'School', 'Interests', 'Routines', 'Books & Movies', 'Ideas', 'Other'
  final String description;
  final String content;
  final int version;
  final bool isActive;

  const HavenTemplate({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.content,
    this.version = 1,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'content': content,
      'version': version,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory HavenTemplate.fromMap(Map<String, dynamic> map) {
    return HavenTemplate(
      id: map['id'] as String,
      title: (map['title'] as String?) ?? '',
      category: (map['category'] as String?) ?? 'Personal',
      description: (map['description'] as String?) ?? '',
      content: (map['content'] as String?) ?? '',
      version: (map['version'] as int?) ?? 1,
      isActive: (map['is_active'] as int? ?? 1) == 1,
    );
  }
}
