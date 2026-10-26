import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;
import 'package:path/path.dart' as p;

import '../models/note_model.dart';
import '../models/journal_entry_model.dart';
import '../models/planner_model.dart';
import '../models/question_model.dart';
import '../models/person_model.dart';
import '../models/template_model.dart';
import '../models/settings_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  sqflite.Database? _sqliteDb;
  SharedPreferences? _webPrefs;
  bool _initialized = false;

  Future<void> init({String? customPath, bool inMemory = false}) async {
    if (_initialized && customPath == null && !inMemory) return;

    if (kIsWeb) {
      _webPrefs = await SharedPreferences.getInstance();
      _initialized = true;
      return;
    }

    try {
      // Use ffi databaseFactory on desktop (macOS/Linux/Windows) or in tests
      if (!kIsWeb &&
          (io.Platform.environment.containsKey('FLUTTER_TEST') ||
              defaultTargetPlatform == TargetPlatform.macOS ||
              defaultTargetPlatform == TargetPlatform.linux ||
              defaultTargetPlatform == TargetPlatform.windows)) {
        ffi.sqfliteFfiInit();
        sqflite.databaseFactory = ffi.databaseFactoryFfi;
      }

      final String dbPath;
      if (inMemory) {
        dbPath = ffi.inMemoryDatabasePath;
      } else if (customPath != null) {
        dbPath = customPath;
      } else {
        final databasesPath = await sqflite.getDatabasesPath();
        dbPath = p.join(databasesPath, 'haven_local.db');
      }

      _sqliteDb = await sqflite.openDatabase(
        dbPath,
        version: 1,
        onCreate: _onCreate,
      );
      _initialized = true;
    } catch (e) {
      // Fallback to SharedPreferences if SQLite initialization encounters platform limits
      debugPrint(
        'SQLite init failed ($e), falling back to persistent preferences.',
      );
      _webPrefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  Future<void> _onCreate(sqflite.Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        title TEXT,
        body TEXT,
        category TEXT,
        color_id TEXT,
        font_size TEXT,
        template_id TEXT,
        is_pinned INTEGER DEFAULT 0,
        is_archived INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE journal_entries (
        id TEXT PRIMARY KEY,
        date TEXT UNIQUE,
        title TEXT,
        body TEXT,
        color_id TEXT,
        font_size TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE planner_weeks (
        id TEXT PRIMARY KEY,
        year INTEGER,
        week_number INTEGER,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE planner_tasks (
        id TEXT PRIMARY KEY,
        week_id TEXT,
        title TEXT,
        notes TEXT,
        is_completed INTEGER DEFAULT 0,
        due_date TEXT,
        sort_order INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sunday_reviews (
        id TEXT PRIMARY KEY,
        week_id TEXT UNIQUE,
        achieved_notes TEXT,
        went_well TEXT,
        unfinished_notes TEXT,
        lessons_learned TEXT,
        changes_next_week TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        period_type TEXT,
        target_date TEXT,
        is_completed INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE questions (
        id TEXT PRIMARY KEY,
        text TEXT,
        category TEXT,
        tags TEXT,
        is_active INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE question_responses (
        id TEXT PRIMARY KEY,
        question_id TEXT,
        answer_text TEXT,
        response_date TEXT,
        source TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE people (
        id TEXT PRIMARY KEY,
        name TEXT,
        relationship TEXT,
        notes TEXT,
        important_dates TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE templates (
        id TEXT PRIMARY KEY,
        title TEXT,
        category TEXT,
        description TEXT,
        content TEXT,
        version INTEGER DEFAULT 1,
        is_active INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  // =========================================================================
  // NOTES
  // =========================================================================

  Future<List<Note>> getAllNotes() async {
    await init();
    if (_sqliteDb != null) {
      final maps = await _sqliteDb!.query(
        'notes',
        where: 'is_archived = 0',
        orderBy: 'updated_at DESC',
      );
      return maps.map(Note.fromMap).toList();
    } else {
      final list = _getWebList('notes');
      return list
          .map((m) => Note.fromMap(m))
          .where((n) => !n.isArchived)
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
  }

  Future<Note?> getNoteById(String id) async {
    await init();
    if (_sqliteDb != null) {
      final maps = await _sqliteDb!.query(
        'notes',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isNotEmpty) return Note.fromMap(maps.first);
      return null;
    } else {
      final list = _getWebList('notes');
      final match = list.where((m) => m['id'] == id);
      if (match.isNotEmpty) return Note.fromMap(match.first);
      return null;
    }
  }

  Future<void> saveNote(Note note) async {
    await init();
    if (_sqliteDb != null) {
      await _sqliteDb!.insert(
        'notes',
        note.toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    } else {
      final list = _getWebList('notes');
      final idx = list.indexWhere((m) => m['id'] == note.id);
      if (idx >= 0) {
        list[idx] = note.toMap();
      } else {
        list.add(note.toMap());
      }
      await _saveWebList('notes', list);
    }
  }

  Future<void> deleteNote(String id) async {
    await init();
    if (_sqliteDb != null) {
      await _sqliteDb!.delete('notes', where: 'id = ?', whereArgs: [id]);
    } else {
      final list = _getWebList('notes');
      list.removeWhere((m) => m['id'] == id);
      await _saveWebList('notes', list);
    }
  }

  // =========================================================================
  // JOURNAL ENTRIES
  // =========================================================================

  Future<List<JournalEntry>> getJournalEntries() async {
    await init();
    if (_sqliteDb != null) {
      final maps = await _sqliteDb!.query(
        'journal_entries',
        orderBy: 'date DESC',
      );
      return maps.map(JournalEntry.fromMap).toList();
    } else {
      final list = _getWebList('journal_entries');
      return list.map((m) => JournalEntry.fromMap(m)).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }
  }

  Future<JournalEntry?> getJournalEntryByDate(String date) async {
    await init();
    if (_sqliteDb != null) {
      final maps = await _sqliteDb!.query(
        'journal_entries',
        where: 'date = ?',
        whereArgs: [date],
        limit: 1,
      );
      if (maps.isNotEmpty) return JournalEntry.fromMap(maps.first);
      return null;
    } else {
      final list = _getWebList('journal_entries');
      final match = list.where((m) => m['date'] == date);
      if (match.isNotEmpty) return JournalEntry.fromMap(match.first);
      return null;
    }
  }

  Future<void> saveJournalEntry(JournalEntry entry) async {
    await init();
    if (_sqliteDb != null) {
      await _sqliteDb!.insert(
        'journal_entries',
        entry.toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    } else {
      final list = _getWebList('journal_entries');
      final idx = list.indexWhere((m) => m['date'] == entry.date);
      if (idx >= 0) {
        list[idx] = entry.toMap();
      } else {
        list.add(entry.toMap());
      }
      await _saveWebList('journal_entries', list);
    }
  }

  Future<void> deleteJournalEntry(String id) async {
    await init();
    if (_sqliteDb != null) {
      await _sqliteDb!.delete(
        'journal_entries',
        where: 'id = ?',
        whereArgs: [id],
      );
    } else {
      final list = _getWebList('journal_entries');
      list.removeWhere((m) => m['id'] == id);
      await _saveWebList('journal_entries', list);
    }
  }

  // =========================================================================
  // PLANNER & GOALS
  // =========================================================================

  Future<WeeklyPlan> getOrCreateWeeklyPlan(
    String weekId,
    int year,
    int weekNumber,
  ) async {
    await init();
    if (_sqliteDb != null) {
      final maps = await _sqliteDb!.query(
        'planner_weeks',
        where: 'id = ?',
        whereArgs: [weekId],
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return WeeklyPlan.fromMap(maps.first);
      }
      final newPlan = WeeklyPlan(
        id: weekId,
        year: year,
        weekNumber: weekNumber,
        createdAt: DateTime.now(),
      );
      await _sqliteDb!.insert('planner_weeks', newPlan.toMap());
      return newPlan;
    } else {
      final list = _getWebList('planner_weeks');
      final match = list.where((m) => m['id'] == weekId);
      if (match.isNotEmpty) {
        return WeeklyPlan.fromMap(match.first);
      }
      final newPlan = WeeklyPlan(
        id: weekId,
        year: year,
        weekNumber: weekNumber,
        createdAt: DateTime.now(),
      );
      list.add(newPlan.toMap());
      await _saveWebList('planner_weeks', list);
      return newPlan;
    }
  }

  Future<List<PlannerTask>> getTasksForWeek(String weekId) async {
    await init();
    if (_sqliteDb != null) {
      final maps = await _sqliteDb!.query(
        'planner_tasks',
        where: 'week_id = ?',
        whereArgs: [weekId],
        orderBy: 'sort_order ASC, created_at ASC',
      );
      return maps.map(PlannerTask.fromMap).toList();
    } else {
      final list = _getWebList('planner_tasks');
      final filtered = list
          .where((m) => m['week_id'] == weekId)
          .map((m) => PlannerTask.fromMap(m))
          .toList();
      filtered.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return filtered;
    }
  }

  Future<void> savePlannerTask(PlannerTask task) async {
    await init();
    if (_sqliteDb != null) {
      await _sqliteDb!.insert(
        'planner_tasks',
        task.toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    } else {
      final list = _getWebList('planner_tasks');
      final idx = list.indexWhere((m) => m['id'] == task.id);
      if (idx >= 0) {
        list[idx] = task.toMap();
      } else {
        list.add(task.toMap());
      }
      await _saveWebList('planner_tasks', list);
    }
  }

  Future<void> deletePlannerTask(String id) async {
    await init();
    if (_sqliteDb != null) {
      await _sqliteDb!.delete(
        'planner_tasks',
        where: 'id = ?',
        whereArgs: [id],
      );
    } else {
      final list = _getWebList('planner_tasks');
      list.removeWhere((m) => m['id'] == id);
      await _saveWebList('planner_tasks', list);
    }
  }

  Future<SundayReview?> getSundayReview(String weekId) async {
    await init();
    if (_sqliteDb != null) {
      final maps = await _sqliteDb!.query(
        'sunday_reviews',
        where: 'week_id = ?',
        whereArgs: [weekId],
        limit: 1,
      );
      if (maps.isNotEmpty) return SundayReview.fromMap(maps.first);
      return null;
    } else {
      final list = _getWebList('sunday_reviews');
      final match = list.where((m) => m['week_id'] == weekId);
      if (match.isNotEmpty) return SundayReview.fromMap(match.first);
      return null;
    }
  }

  Future<void> saveSundayReview(SundayReview review) async {
    await init();
    if (_sqliteDb != null) {
      await _sqliteDb!.insert(
        'sunday_reviews',
        review.toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    } else {
      final list = _getWebList('sunday_reviews');
      final idx = list.indexWhere((m) => m['week_id'] == review.weekId);
      if (idx >= 0) {
        list[idx] = review.toMap();
      } else {
        list.add(review.toMap());
      }
      await _saveWebList('sunday_reviews', list);
    }
  }

  Future<List<HavenGoal>> getGoals({String? periodType}) async {
    await init();
    if (_sqliteDb != null) {
      final whereClause = periodType != null ? 'period_type = ?' : null;
      final whereArgs = periodType != null ? [periodType] : null;
      final maps = await _sqliteDb!.query(
        'goals',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'created_at DESC',
      );
      return maps.map(HavenGoal.fromMap).toList();
    } else {
      final list = _getWebList('goals');
      var filtered = list.map((m) => HavenGoal.fromMap(m));
      if (periodType != null) {
        filtered = filtered.where((g) => g.periodType == periodType);
      }
      final result = filtered.toList();
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return result;
    }
  }

  Future<void> saveGoal(HavenGoal goal) async {
    await init();
    if (_sqliteDb != null) {
      await _sqliteDb!.insert(
        'goals',
        goal.toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    } else {
      final list = _getWebList('goals');
      final idx = list.indexWhere((m) => m['id'] == goal.id);
      if (idx >= 0) {
        list[idx] = goal.toMap();
      } else {
        list.add(goal.toMap());
      }
      await _saveWebList('goals', list);
    }
  }

  Future<void> deleteGoal(String id) async {
    await init();
    if (_sqliteDb != null) {
      await _sqliteDb!.delete('goals', where: 'id = ?', whereArgs: [id]);
    } else {
      final list = _getWebList('goals');
      list.removeWhere((m) => m['id'] == id);
      await _saveWebList('goals', list);
    }
  }

  // =========================================================================
  // QUESTIONS & RESPONSES
  // =========================================================================

  Future<List<Question>> getQuestions({String? category}) async {
    await init();
    if (_sqliteDb != null) {
      final whereClause = category != null
          ? 'category = ? AND is_active = 1'
          : 'is_active = 1';
      final whereArgs = category != null ? [category] : null;
      final maps = await _sqliteDb!.query(
        'questions',
        where: whereClause,
        whereArgs: whereArgs,
      );
      return maps.map(Question.fromMap).toList();
    } else {
      final list = _getWebList('questions');
      var filtered = list
          .map((m) => Question.fromMap(m))
          .where((q) => q.isActive);
      if (category != null) {
        filtered = filtered.where((q) => q.category == category);
      }
      return filtered.toList();
    }
  }

  Future<void> insertQuestions(List<Question> questions) async {
    await init();
    if (_sqliteDb != null) {
      final batch = _sqliteDb!.batch();
      for (final q in questions) {
        batch.insert(
          'questions',
          q.toMap(),
          conflictAlgorithm: sqflite.ConflictAlgorithm.ignore,
        );
      }
      await batch.commit(noResult: true);
    } else {
      final list = _getWebList('questions');
      final existingIds = list.map((m) => m['id']).toSet();
      for (final q in questions) {
        if (!existingIds.contains(q.id)) {
          list.add(q.toMap());
        }
      }
      await _saveWebList('questions', list);
    }
  }

  Future<int> getQuestionCount() async {
    await init();
    if (_sqliteDb != null) {
      final result = await _sqliteDb!.rawQuery(
        'SELECT COUNT(*) as count FROM questions',
      );
      return (result.first['count'] as int?) ?? 0;
    } else {
      return _getWebList('questions').length;
    }
  }

  Future<List<QuestionResponse>> getResponsesForQuestion(
    String questionId,
  ) async {
    await init();
    if (_sqliteDb != null) {
      final maps = await _sqliteDb!.query(
        'question_responses',
        where: 'question_id = ?',
        whereArgs: [questionId],
        orderBy: 'created_at DESC',
      );
      return maps.map(QuestionResponse.fromMap).toList();
    } else {
      final list = _getWebList('question_responses');
      return list
          .where((m) => m['question_id'] == questionId)
          .map((m) => QuestionResponse.fromMap(m))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  Future<List<QuestionResponse>> getAllResponses() async {
    await init();
    if (_sqliteDb != null) {
      final maps = await _sqliteDb!.query(
        'question_responses',
        orderBy: 'created_at DESC',
      );
      return maps.map(QuestionResponse.fromMap).toList();
    } else {
      final list = _getWebList('question_responses');
      return list.map((m) => QuestionResponse.fromMap(m)).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  Future<int> getResponseCountForDate(String date, {String? source}) async {
    await init();
    if (_sqliteDb != null) {
      String where = 'response_date = ?';
      List<dynamic> args = [date];
      if (source != null) {
        where += ' AND source = ?';
        args.add(source);
      }
      final result = await _sqliteDb!.rawQuery(
        'SELECT COUNT(*) as count FROM question_responses WHERE $where',
        args,
      );
      return (result.first['count'] as int?) ?? 0;
    } else {
      final list = _getWebList('question_responses');
      var filtered = list.where((m) => m['response_date'] == date);
      if (source != null) {
        filtered = filtered.where((m) => m['source'] == source);
      }
      return filtered.length;
    }
  }

  Future<void> saveQuestionResponse(QuestionResponse response) async {
    await init();
    if (_sqliteDb != null) {
      await _sqliteDb!.insert(
        'question_responses',
        response.toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    } else {
      final list = _getWebList('question_responses');
      final idx = list.indexWhere((m) => m['id'] == response.id);
      if (idx >= 0) {
        list[idx] = response.toMap();
      } else {
        list.add(response.toMap());
      }
      await _saveWebList('question_responses', list);
    }
  }

  // =========================================================================
  // PEOPLE
  // =========================================================================

  Future<List<Person>> getAllPeople() async {
    await init();
    if (_sqliteDb != null) {
      final maps = await _sqliteDb!.query('people', orderBy: 'name ASC');
      return maps.map(Person.fromMap).toList();
    } else {
      final list = _getWebList('people');
      return list.map((m) => Person.fromMap(m)).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    }
  }

  Future<void> savePerson(Person person) async {
    await init();
    if (_sqliteDb != null) {
      await _sqliteDb!.insert(
        'people',
        person.toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    } else {
      final list = _getWebList('people');
      final idx = list.indexWhere((m) => m['id'] == person.id);
      if (idx >= 0) {
        list[idx] = person.toMap();
      } else {
        list.add(person.toMap());
      }
      await _saveWebList('people', list);
    }
  }

  Future<void> deletePerson(String id) async {
    await init();
    if (_sqliteDb != null) {
      await _sqliteDb!.delete('people', where: 'id = ?', whereArgs: [id]);
    } else {
      final list = _getWebList('people');
      list.removeWhere((m) => m['id'] == id);
      await _saveWebList('people', list);
    }
  }

  // =========================================================================
  // TEMPLATES
  // =========================================================================

  Future<List<HavenTemplate>> getAllTemplates({String? category}) async {
    await init();
    if (_sqliteDb != null) {
      final where = category != null
          ? 'category = ? AND is_active = 1'
          : 'is_active = 1';
      final args = category != null ? [category] : null;
      final maps = await _sqliteDb!.query(
        'templates',
        where: where,
        whereArgs: args,
      );
      return maps.map(HavenTemplate.fromMap).toList();
    } else {
      final list = _getWebList('templates');
      var filtered = list
          .map((m) => HavenTemplate.fromMap(m))
          .where((t) => t.isActive);
      if (category != null) {
        filtered = filtered.where((t) => t.category == category);
      }
      return filtered.toList();
    }
  }

  Future<void> insertTemplates(List<HavenTemplate> templates) async {
    await init();
    if (_sqliteDb != null) {
      final batch = _sqliteDb!.batch();
      for (final t in templates) {
        batch.insert(
          'templates',
          t.toMap(),
          conflictAlgorithm: sqflite.ConflictAlgorithm.ignore,
        );
      }
      await batch.commit(noResult: true);
    } else {
      final list = _getWebList('templates');
      final existingIds = list.map((m) => m['id']).toSet();
      for (final t in templates) {
        if (!existingIds.contains(t.id)) {
          list.add(t.toMap());
        }
      }
      await _saveWebList('templates', list);
    }
  }

  // =========================================================================
  // SETTINGS
  // =========================================================================

  Future<HavenSettings> getSettings() async {
    await init();
    if (_sqliteDb != null) {
      final maps = await _sqliteDb!.query(
        'settings',
        where: 'key = ?',
        whereArgs: ['app_settings'],
      );
      if (maps.isNotEmpty) {
        final jsonStr = maps.first['value'] as String?;
        if (jsonStr != null && jsonStr.isNotEmpty) {
          final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
          return HavenSettings.fromMap(decoded);
        }
      }
      return const HavenSettings();
    } else {
      final jsonStr = _webPrefs?.getString('app_settings');
      if (jsonStr != null) {
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        return HavenSettings.fromMap(decoded);
      }
      return const HavenSettings();
    }
  }

  Future<void> saveSettings(HavenSettings settings) async {
    await init();
    final jsonStr = jsonEncode(settings.toMap());
    if (_sqliteDb != null) {
      await _sqliteDb!.insert('settings', {
        'key': 'app_settings',
        'value': jsonStr,
      }, conflictAlgorithm: sqflite.ConflictAlgorithm.replace);
    } else {
      await _webPrefs?.setString('app_settings', jsonStr);
    }
  }

  // =========================================================================
  // BACKUP & RESTORE SERIALIZATION
  // =========================================================================

  Future<Map<String, dynamic>> exportBackupPayload() async {
    await init();
    final notes = await getAllNotes();
    final journals = await getJournalEntries();
    final goals = await getGoals();
    final people = await getAllPeople();
    final responses = await getAllResponses();
    final settings = await getSettings();

    List<Map<String, dynamic>> weeksList = [];
    List<Map<String, dynamic>> tasksList = [];
    List<Map<String, dynamic>> reviewsList = [];

    if (_sqliteDb != null) {
      weeksList = await _sqliteDb!.query('planner_weeks');
      tasksList = await _sqliteDb!.query('planner_tasks');
      reviewsList = await _sqliteDb!.query('sunday_reviews');
    } else {
      weeksList = _getWebList('planner_weeks');
      tasksList = _getWebList('planner_tasks');
      reviewsList = _getWebList('sunday_reviews');
    }

    return {
      'schema_version': 1,
      'app_version': '1.0.0',
      'app_name': 'Haven',
      'backup_timestamp': DateTime.now().toIso8601String(),
      'data': {
        'notes': notes.map((n) => n.toMap()).toList(),
        'journal_entries': journals.map((j) => j.toMap()).toList(),
        'planner_weeks': weeksList,
        'planner_tasks': tasksList,
        'sunday_reviews': reviewsList,
        'goals': goals.map((g) => g.toMap()).toList(),
        'people': people.map((p) => p.toMap()).toList(),
        'question_responses': responses.map((r) => r.toMap()).toList(),
        'settings': settings.toMap(),
      },
    };
  }

  Future<bool> restoreFromPayload(
    Map<String, dynamic> payload, {
    bool merge = false,
  }) async {
    await init();
    try {
      if (payload['app_name'] != 'Haven' || payload['schema_version'] == null) {
        return false;
      }

      final data = payload['data'] as Map<String, dynamic>?;
      if (data == null) return false;

      if (!merge) {
        await wipeAllUserData();
      }

      // Restore Notes
      if (data['notes'] != null) {
        final list = data['notes'] as List;
        for (final item in list) {
          await saveNote(Note.fromMap(Map<String, dynamic>.from(item as Map)));
        }
      }

      // Restore Journal Entries
      if (data['journal_entries'] != null) {
        final list = data['journal_entries'] as List;
        for (final item in list) {
          await saveJournalEntry(
            JournalEntry.fromMap(Map<String, dynamic>.from(item as Map)),
          );
        }
      }

      // Restore Planner
      if (data['planner_tasks'] != null) {
        final list = data['planner_tasks'] as List;
        for (final item in list) {
          await savePlannerTask(
            PlannerTask.fromMap(Map<String, dynamic>.from(item as Map)),
          );
        }
      }

      if (data['sunday_reviews'] != null) {
        final list = data['sunday_reviews'] as List;
        for (final item in list) {
          await saveSundayReview(
            SundayReview.fromMap(Map<String, dynamic>.from(item as Map)),
          );
        }
      }

      // Restore Goals
      if (data['goals'] != null) {
        final list = data['goals'] as List;
        for (final item in list) {
          await saveGoal(
            HavenGoal.fromMap(Map<String, dynamic>.from(item as Map)),
          );
        }
      }

      // Restore People
      if (data['people'] != null) {
        final list = data['people'] as List;
        for (final item in list) {
          await savePerson(
            Person.fromMap(Map<String, dynamic>.from(item as Map)),
          );
        }
      }

      // Restore Responses
      if (data['question_responses'] != null) {
        final list = data['question_responses'] as List;
        for (final item in list) {
          await saveQuestionResponse(
            QuestionResponse.fromMap(Map<String, dynamic>.from(item as Map)),
          );
        }
      }

      return true;
    } catch (e) {
      debugPrint('Restore failed: $e');
      return false;
    }
  }

  Future<void> wipeAllUserData() async {
    await init();
    if (_sqliteDb != null) {
      await _sqliteDb!.delete('notes');
      await _sqliteDb!.delete('journal_entries');
      await _sqliteDb!.delete('planner_weeks');
      await _sqliteDb!.delete('planner_tasks');
      await _sqliteDb!.delete('sunday_reviews');
      await _sqliteDb!.delete('goals');
      await _sqliteDb!.delete('people');
      await _sqliteDb!.delete('question_responses');
    } else {
      await _saveWebList('notes', []);
      await _saveWebList('journal_entries', []);
      await _saveWebList('planner_weeks', []);
      await _saveWebList('planner_tasks', []);
      await _saveWebList('sunday_reviews', []);
      await _saveWebList('goals', []);
      await _saveWebList('people', []);
      await _saveWebList('question_responses', []);
    }
  }

  // =========================================================================
  // WEB PREFERENCES HELPERS
  // =========================================================================

  List<Map<String, dynamic>> _getWebList(String key) {
    final str = _webPrefs?.getString('db_$key');
    if (str == null || str.isEmpty) return [];
    try {
      final decoded = jsonDecode(str) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveWebList(String key, List<Map<String, dynamic>> list) async {
    final str = jsonEncode(list);
    await _webPrefs?.setString('db_$key', str);
  }
}
