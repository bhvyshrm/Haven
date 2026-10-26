import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:haven/core/database/database_service.dart';
import 'package:haven/core/models/planner_model.dart';
import 'package:haven/core/state/haven_state.dart';

void main() {
  const dbName = 'test_planner.db';

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDownAll(() async {
    try {
      final f = File(dbName);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.instance.init(customPath: dbName);
    await DatabaseService.instance.wipeAllUserData();
  });

  group('Weekly Planner & Rollover Tests', () {
    test('Create weekly plan and manage tasks', () async {
      final db = DatabaseService.instance;
      const weekId = '2026-W43';

      final plan = await db.getOrCreateWeeklyPlan(weekId, 2026, 43);
      expect(plan.id, weekId);

      final task1 = PlannerTask(
        id: 'task_1',
        weekId: weekId,
        title: 'Draft architecture overview',
        sortOrder: 0,
        createdAt: DateTime.now(),
      );
      final task2 = PlannerTask(
        id: 'task_2',
        weekId: weekId,
        title: 'Run database backup verification',
        sortOrder: 1,
        createdAt: DateTime.now(),
      );

      await db.savePlannerTask(task1);
      await db.savePlannerTask(task2);

      var tasks = await db.getTasksForWeek(weekId);
      expect(tasks.length, 2);
      expect(tasks.first.title, 'Draft architecture overview');
      expect(tasks.first.isCompleted, false);

      // Toggle completion
      final completed = task1.copyWith(isCompleted: true);
      await db.savePlannerTask(completed);

      tasks = await db.getTasksForWeek(weekId);
      expect(tasks.first.isCompleted, true);
      expect(tasks.last.isCompleted, false);
    });

    test('Carry forward unfinished tasks preserves unfinished items', () async {
      final state = HavenState();
      await state.init();

      await state.addPlannerTask('Finished task');
      await state.addPlannerTask('Unfinished task');

      expect(state.tasks.length, 2);

      // Mark first task completed
      await state.toggleTaskCompletion(state.tasks.first);
      expect(state.tasks.first.isCompleted, true);
      expect(state.tasks.last.isCompleted, false);

      // Carry forward unfinished tasks
      await state.carryForwardUnfinishedTasks();

      // Only the unfinished task was copied forward
      final activeTasks = state.tasks;
      final unfinishedCarried = activeTasks.where(
        (t) => t.title == 'Unfinished task',
      );
      expect(unfinishedCarried.length, 2);

      final finishedCount = activeTasks.where(
        (t) => t.title == 'Finished task',
      );
      expect(finishedCount.length, 1); // Not duplicated
    });

    test('Sunday Review is saved and associated to the week', () async {
      final db = DatabaseService.instance;
      const weekId = '2026-W43';

      final review = SundayReview(
        id: 'rev_1',
        weekId: weekId,
        achievedNotes: 'Shipped production design system',
        wentWell: 'Deep uninterrupted focus blocks in the mornings',
        unfinishedNotes: 'Postponed non-essential refactor',
        lessonsLearned: 'Small daily steps compound rapidly',
        changesNextWeek: 'Earlier evening wind-down',
        createdAt: DateTime.now(),
      );

      await db.saveSundayReview(review);

      final retrieved = await db.getSundayReview(weekId);
      expect(retrieved, isNotNull);
      expect(retrieved!.achievedNotes, 'Shipped production design system');
      expect(
        retrieved.wentWell,
        'Deep uninterrupted focus blocks in the mornings',
      );
    });

    test('Monthly and Yearly Goals toggle and delete', () async {
      final db = DatabaseService.instance;

      final goal = HavenGoal(
        id: 'g_1',
        title: 'Read 2 deep books on systems architecture',
        periodType: 'monthly',
        createdAt: DateTime.now(),
      );

      await db.saveGoal(goal);

      var monthlyGoals = await db.getGoals(periodType: 'monthly');
      expect(monthlyGoals.length, 1);
      expect(monthlyGoals.first.isCompleted, false);

      await db.saveGoal(goal.copyWith(isCompleted: true));
      monthlyGoals = await db.getGoals(periodType: 'monthly');
      expect(monthlyGoals.first.isCompleted, true);

      await db.deleteGoal('g_1');
      monthlyGoals = await db.getGoals(periodType: 'monthly');
      expect(monthlyGoals.isEmpty, true);
    });
  });
}
