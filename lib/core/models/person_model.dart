class Person {
  final String id;
  final String name;
  final String relationship; // e.g. 'Friend', 'Family', 'Mentor', 'Partner', 'Colleague'
  final String notes;
  final String importantDates;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Person({
    required this.id,
    required this.name,
    this.relationship = 'Friend',
    this.notes = '',
    this.importantDates = '',
    required this.createdAt,
    required this.updatedAt,
  });

  Person copyWith({
    String? id,
    String? name,
    String? relationship,
    String? notes,
    String? importantDates,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      notes: notes ?? this.notes,
      importantDates: importantDates ?? this.importantDates,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'relationship': relationship,
      'notes': notes,
      'important_dates': importantDates,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      id: map['id'] as String,
      name: (map['name'] as String?) ?? '',
      relationship: (map['relationship'] as String?) ?? 'Friend',
      notes: (map['notes'] as String?) ?? '',
      importantDates: (map['important_dates'] as String?) ?? '',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
