import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../database/database_service.dart';
import '../models/note_model.dart';
import '../models/journal_entry_model.dart';
import '../models/planner_model.dart';
import '../models/question_model.dart';
import '../models/person_model.dart';
import '../models/template_model.dart';
import '../models/settings_model.dart';
import '../services/seed_service.dart';
import '../services/auth_lock_service.dart';
import '../services/notification_service.dart';

class HavenState extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  final _uuid = const Uuid();

  // Navigation
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  // App Lock
  bool _isLocked = false;
  bool get isLocked => _isLocked;

  // Settings
  HavenSettings _settings = const HavenSettings();
  HavenSettings get settings => _settings;

  // Notes
  List<Note> _notes = [];
  List<Note> get notes => _notes;
  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Journal
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;
  List<JournalEntry> _journalEntries = [];
  List<JournalEntry> get journalEntries => _journalEntries;

  // Planner & Goals
  String _currentWeekId = '';
  String get currentWeekId => _currentWeekId;
  List<PlannerTask> _tasks = [];
  List<PlannerTask> get tasks => _tasks;
  SundayReview? _sundayReview;
  SundayReview? get sundayReview => _sundayReview;
  List<HavenGoal> _monthlyGoals = [];
  List<HavenGoal> get monthlyGoals => _monthlyGoals;
  List<HavenGoal> get yearlyGoals => _yearlyGoals;
  List<HavenGoal> _yearlyGoals = [];

  // Discover & Questions
  Question? _dailyQuestion;
  Question? get dailyQuestion => _dailyQuestion;
  QuestionResponse? _todayDailyResponse;
  QuestionResponse? get todayDailyResponse => _todayDailyResponse;
  Question? _randomQuestion;
  Question? get randomQuestion => _randomQuestion;
  final Set<String> _seenRandomQuestionIds = {};
  int _todayRandomResponseCount = 0;
  int get todayRandomResponseCount => _todayRandomResponseCount;
  static const int maxDailyRandomResponses = 10;
  int get remainingRandomAllowance =>
      (maxDailyRandomResponses - _todayRandomResponseCount).clamp(
        0,
        maxDailyRandomResponses,
      );

  // People
  List<Person> _people = [];
  List<Person> get people => _people;

  // Templates
  List<HavenTemplate> _templates = [];
  List<HavenTemplate> get templates => _templates;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await _db.init();
    await SeedService.seedIfNeeded();

    _settings = await _db.getSettings();

    // Check App Lock
    if (_settings.isAppLockEnabled) {
      _isLocked = true;
    }

    await reloadAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> unlockApp() async {
    final success = await AuthLockService.instance.authenticate();
    if (success) {
      _isLocked = false;
      notifyListeners();
    }
  }

  void setTabIndex(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      notifyListeners();
    }
  }

  Future<void> toggleTheme(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nextMode = isDark ? ThemeMode.light : ThemeMode.dark;
    _settings = _settings.copyWith(themeMode: nextMode);
    await _db.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setSpecificThemeMode(ThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    await _db.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> reloadAll() async {
    await loadNotes();
    await loadJournal();
    await loadPlanner();
    await loadGoals();
    await loadDiscover();
    await loadPeople();
    await loadTemplates();
  }

  // =========================================================================
  // NOTES LOGIC
  // =========================================================================

  Future<void> loadNotes() async {
    _notes = await _db.getAllNotes();
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Note> get filteredNotes {
    return _notes.where((note) {
      final matchesCategory =
          _selectedCategory == 'All' ||
          note.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch =
          _searchQuery.isEmpty ||
          note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.body.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<Note> createNewNote({
    String title = '',
    String body = '',
    String category = 'Personal',
    String? templateId,
  }) async {
    final newNote = Note(
      id: _uuid.v4(),
      title: title,
      body: body,
      category: category,
      templateId: templateId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _db.saveNote(newNote);
    await loadNotes();
    return newNote;
  }

  Future<void> saveNote(Note note) async {
    final updated = note.copyWith(updatedAt: DateTime.now());
    await _db.saveNote(updated);
    await loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await _db.deleteNote(id);
    await loadNotes();
  }

  Future<Note> duplicateNote(Note original) async {
    final copy = Note(
      id: _uuid.v4(),
      title: original.title.isNotEmpty
          ? '${original.title} (Copy)'
          : 'Untitled Copy',
      body: original.body,
      category: original.category,
      colorId: original.colorId,
      fontSize: original.fontSize,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _db.saveNote(copy);
    await loadNotes();
    return copy;
  }

  // =========================================================================
  // JOURNAL LOGIC
  // =========================================================================

  Future<void> loadJournal() async {
    _journalEntries = await _db.getJournalEntries();
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  String get selectedDateFormatted =>
      DateFormat('yyyy-MM-dd').format(_selectedDate);

  JournalEntry? get entryForSelectedDate {
    final dateStr = selectedDateFormatted;
    final match = _journalEntries.where((e) => e.date == dateStr);
    return match.isNotEmpty ? match.first : null;
  }

  Future<JournalEntry> getOrCreateEntryForDate(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    var entry = await _db.getJournalEntryByDate(dateStr);
    if (entry == null) {
      entry = JournalEntry(
        id: _uuid.v4(),
        date: dateStr,
        title: '',
        body: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _db.saveJournalEntry(entry);
      await loadJournal();
    }
    return entry;
  }

  Future<void> saveJournalEntry(JournalEntry entry) async {
    final updated = entry.copyWith(updatedAt: DateTime.now());
    await _db.saveJournalEntry(updated);
    await loadJournal();
  }

  Future<void> deleteJournalEntry(String id) async {
    await _db.deleteJournalEntry(id);
    await loadJournal();
  }

  // =========================================================================
  // PLANNER & GOALS LOGIC
  // =========================================================================

  Future<void> loadPlanner() async {
    final now = DateTime.now();
    final weekNumber = _getWeekNumber(now);
    _currentWeekId = '${now.year}-W${weekNumber.toString().padLeft(2, '0')}';

    await _db.getOrCreateWeeklyPlan(_currentWeekId, now.year, weekNumber);
    _tasks = await _db.getTasksForWeek(_currentWeekId);
    _sundayReview = await _db.getSundayReview(_currentWeekId);
    notifyListeners();
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysOffset = firstDayOfYear.weekday - DateTime.monday;
    final firstMonday = firstDayOfYear.subtract(Duration(days: daysOffset));
    return (date.difference(firstMonday).inDays / 7).floor() + 1;
  }

  Future<void> addPlannerTask(
    String title, {
    String notes = '',
    String? dueDate,
  }) async {
    if (title.trim().isEmpty) return;
    final newTask = PlannerTask(
      id: _uuid.v4(),
      weekId: _currentWeekId,
      title: title.trim(),
      notes: notes,
      dueDate: dueDate,
      sortOrder: _tasks.length,
      createdAt: DateTime.now(),
    );
    await _db.savePlannerTask(newTask);
    _tasks = await _db.getTasksForWeek(_currentWeekId);
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(PlannerTask task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await _db.savePlannerTask(updated);
    _tasks = await _db.getTasksForWeek(_currentWeekId);
    notifyListeners();
  }

  Future<void> deletePlannerTask(String id) async {
    await _db.deletePlannerTask(id);
    _tasks = await _db.getTasksForWeek(_currentWeekId);
    notifyListeners();
  }

  Future<void> reorderPlannerTasks(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = _tasks.removeAt(oldIndex);
    _tasks.insert(newIndex, item);

    for (int i = 0; i < _tasks.length; i++) {
      final updated = _tasks[i].copyWith(sortOrder: i);
      _tasks[i] = updated;
      await _db.savePlannerTask(updated);
    }
    notifyListeners();
  }

  Future<void> saveSundayReview(SundayReview review) async {
    _sundayReview = review;
    await _db.saveSundayReview(review);
    notifyListeners();
  }

  Future<void> carryForwardUnfinishedTasks() async {
    // Carries unfinished tasks to the current week
    final unfinished = _tasks.where((t) => !t.isCompleted).toList();
    for (final task in unfinished) {
      final carried = PlannerTask(
        id: _uuid.v4(),
        weekId: _currentWeekId,
        title: task.title,
        notes: task.notes,
        sortOrder: _tasks.length,
        createdAt: DateTime.now(),
      );
      await _db.savePlannerTask(carried);
    }
    _tasks = await _db.getTasksForWeek(_currentWeekId);
    notifyListeners();
  }

  Future<void> loadGoals() async {
    _monthlyGoals = await _db.getGoals(periodType: 'monthly');
    _yearlyGoals = await _db.getGoals(periodType: 'yearly');
    notifyListeners();
  }

  Future<void> addGoal(
    String title,
    String periodType, {
    String description = '',
    String? targetDate,
  }) async {
    if (title.trim().isEmpty) return;
    final newGoal = HavenGoal(
      id: _uuid.v4(),
      title: title.trim(),
      description: description,
      periodType: periodType,
      targetDate: targetDate,
      createdAt: DateTime.now(),
    );
    await _db.saveGoal(newGoal);
    await loadGoals();
  }

  Future<void> toggleGoal(HavenGoal goal) async {
    final updated = goal.copyWith(isCompleted: !goal.isCompleted);
    await _db.saveGoal(updated);
    await loadGoals();
  }

  Future<void> deleteGoal(String id) async {
    await _db.deleteGoal(id);
    await loadGoals();
  }

  // =========================================================================
  // DISCOVER & QUESTIONS LOGIC
  // =========================================================================

  Future<void> loadDiscover() async {
    final allQuestions = await _db.getQuestions();
    if (allQuestions.isEmpty) return;

    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Deterministic question for today
    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year, 1, 1))
        .inDays;
    final dailyIndex = dayOfYear % allQuestions.length;
    _dailyQuestion = allQuestions[dailyIndex];

    // Check if daily question already answered today
    final responses = await _db.getResponsesForQuestion(_dailyQuestion!.id);
    final todayMatch = responses.where((r) => r.responseDate == todayStr);
    _todayDailyResponse = todayMatch.isNotEmpty ? todayMatch.first : null;

    // Daily limit check for random/optional questions
    _todayRandomResponseCount = await _db.getResponseCountForDate(
      todayStr,
      source: 'random',
    );

    if (_randomQuestion == null) {
      await nextRandomQuestion();
    }

    notifyListeners();
  }

  Future<List<Question>> getQuestions({String? category}) async {
    return _db.getQuestions(category: category);
  }

  Future<void> nextRandomQuestion() async {
    final all = await _db.getQuestions();
    if (all.isEmpty) return;

    final pool = all
        .where(
          (q) =>
              !_seenRandomQuestionIds.contains(q.id) &&
              q.id != _dailyQuestion?.id,
        )
        .toList();
    if (pool.isEmpty) {
      _seenRandomQuestionIds.clear();
      _randomQuestion = all.first;
    } else {
      pool.shuffle();
      _randomQuestion = pool.first;
      _seenRandomQuestionIds.add(_randomQuestion!.id);
    }
    notifyListeners();
  }

  Future<bool> answerQuestion(
    Question question,
    String answer, {
    String source = 'daily',
  }) async {
    if (answer.trim().isEmpty) return false;

    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Check allowance for random questions
    if (source == 'random' &&
        _todayRandomResponseCount >= maxDailyRandomResponses) {
      return false; // Daily limit reached
    }

    final newResponse = QuestionResponse(
      id: _uuid.v4(),
      questionId: question.id,
      answerText: answer.trim(),
      responseDate: todayStr,
      source: source,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _db.saveQuestionResponse(newResponse);

    if (source == 'daily' && question.id == _dailyQuestion?.id) {
      _todayDailyResponse = newResponse;
    }

    if (source == 'random') {
      _todayRandomResponseCount++;
      await nextRandomQuestion();
    }

    notifyListeners();
    return true;
  }

  Future<List<QuestionResponse>> getResponsesForQuestion(
    String questionId,
  ) async {
    return _db.getResponsesForQuestion(questionId);
  }

  Future<List<QuestionResponse>> getAllResponses() async {
    return _db.getAllResponses();
  }

  // =========================================================================
  // PEOPLE LOGIC
  // =========================================================================

  Future<void> loadPeople() async {
    _people = await _db.getAllPeople();
    notifyListeners();
  }

  Future<void> savePerson(Person person) async {
    await _db.savePerson(person.copyWith(updatedAt: DateTime.now()));
    await loadPeople();
  }

  Future<void> deletePerson(String id) async {
    await _db.deletePerson(id);
    await loadPeople();
  }

  // =========================================================================
  // TEMPLATES LOGIC
  // =========================================================================

  Future<void> loadTemplates() async {
    _templates = await _db.getAllTemplates();
    notifyListeners();
  }

  Future<Note> useTemplate(HavenTemplate template) async {
    return createNewNote(
      title: template.title,
      body: template.content,
      category: template.category,
      templateId: template.id,
    );
  }

  // =========================================================================
  // SETTINGS & BACKUP ACTIONS
  // =========================================================================

  Future<void> updateSettings(HavenSettings newSettings) async {
    _settings = newSettings;
    await _db.saveSettings(newSettings);

    // Apply notification schedules
    if (newSettings.isDailyReminderEnabled) {
      final parts = newSettings.dailyReminderTime.split(':');
      final hour = int.tryParse(parts.first) ?? 20;
      final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
      await NotificationService.instance.scheduleDailyJournalReminder(
        hour,
        minute,
      );
    }

    if (newSettings.isWeeklyPlanReminderEnabled) {
      await NotificationService.instance.scheduleMondayPlanReminder();
    }

    if (newSettings.isSundayReviewReminderEnabled) {
      await NotificationService.instance.scheduleSundayReviewReminder();
    }

    notifyListeners();
  }

  Future<void> wipeAllData() async {
    await _db.wipeAllUserData();
    await reloadAll();
  }
}
