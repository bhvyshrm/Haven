class WeeklyPlan {
  final String id; // Format: 'YYYY-Www' (e.g., '2026-W43')
  final int year;
  final int weekNumber;
  final DateTime createdAt;

  const WeeklyPlan({
    required this.id,
    required this.year,
    required this.weekNumber,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'year': year,
      'week_number': weekNumber,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory WeeklyPlan.fromMap(Map<String, dynamic> map) {
    return WeeklyPlan(
      id: map['id'] as String,
      year: (map['year'] as int?) ?? DateTime.now().year,
      weekNumber: (map['week_number'] as int?) ?? 1,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class PlannerTask {
  final String id;
  final String weekId;
  final String title;
  final String notes;
  final bool isCompleted;
  final String? dueDate;
  final int sortOrder;
  final DateTime createdAt;

  const PlannerTask({
    required this.id,
    required this.weekId,
    required this.title,
    this.notes = '',
    this.isCompleted = false,
    this.dueDate,
    this.sortOrder = 0,
    required this.createdAt,
  });

  PlannerTask copyWith({
    String? id,
    String? weekId,
    String? title,
    String? notes,
    bool? isCompleted,
    String? dueDate,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return PlannerTask(
      id: id ?? this.id,
      weekId: weekId ?? this.weekId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'week_id': weekId,
      'title': title,
      'notes': notes,
      'is_completed': isCompleted ? 1 : 0,
      'due_date': dueDate,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PlannerTask.fromMap(Map<String, dynamic> map) {
    return PlannerTask(
      id: map['id'] as String,
      weekId: map['week_id'] as String,
      title: (map['title'] as String?) ?? '',
      notes: (map['notes'] as String?) ?? '',
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      dueDate: map['due_date'] as String?,
      sortOrder: (map['sort_order'] as int?) ?? 0,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class SundayReview {
  final String id;
  final String weekId;
  final String achievedNotes;
  final String wentWell;
  final String unfinishedNotes;
  final String lessonsLearned;
  final String changesNextWeek;
  final DateTime createdAt;

  const SundayReview({
    required this.id,
    required this.weekId,
    this.achievedNotes = '',
    this.wentWell = '',
    this.unfinishedNotes = '',
    this.lessonsLearned = '',
    this.changesNextWeek = '',
    required this.createdAt,
  });

  SundayReview copyWith({
    String? id,
    String? weekId,
    String? achievedNotes,
    String? wentWell,
    String? unfinishedNotes,
    String? lessonsLearned,
    String? changesNextWeek,
    DateTime? createdAt,
  }) {
    return SundayReview(
      id: id ?? this.id,
      weekId: weekId ?? this.weekId,
      achievedNotes: achievedNotes ?? this.achievedNotes,
      wentWell: wentWell ?? this.wentWell,
      unfinishedNotes: unfinishedNotes ?? this.unfinishedNotes,
      lessonsLearned: lessonsLearned ?? this.lessonsLearned,
      changesNextWeek: changesNextWeek ?? this.changesNextWeek,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'week_id': weekId,
      'achieved_notes': achievedNotes,
      'went_well': wentWell,
      'unfinished_notes': unfinishedNotes,
      'lessons_learned': lessonsLearned,
      'changes_next_week': changesNextWeek,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SundayReview.fromMap(Map<String, dynamic> map) {
    return SundayReview(
      id: map['id'] as String,
      weekId: map['week_id'] as String,
      achievedNotes: (map['achieved_notes'] as String?) ?? '',
      wentWell: (map['went_well'] as String?) ?? '',
      unfinishedNotes: (map['unfinished_notes'] as String?) ?? '',
      lessonsLearned: (map['lessons_learned'] as String?) ?? '',
      changesNextWeek: (map['changes_next_week'] as String?) ?? '',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class HavenGoal {
  final String id;
  final String title;
  final String description;
  final String periodType; // 'monthly' or 'yearly'
  final String? targetDate;
  final bool isCompleted;
  final DateTime createdAt;

  const HavenGoal({
    required this.id,
    required this.title,
    this.description = '',
    required this.periodType,
    this.targetDate,
    this.isCompleted = false,
    required this.createdAt,
  });

  HavenGoal copyWith({
    String? id,
    String? title,
    String? description,
    String? periodType,
    String? targetDate,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return HavenGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      periodType: periodType ?? this.periodType,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'period_type': periodType,
      'target_date': targetDate,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory HavenGoal.fromMap(Map<String, dynamic> map) {
    return HavenGoal(
      id: map['id'] as String,
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      periodType: (map['period_type'] as String?) ?? 'monthly',
      targetDate: map['target_date'] as String?,
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
