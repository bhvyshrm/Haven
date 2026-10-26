import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:haven/core/database/database_service.dart';
import 'package:haven/core/models/note_model.dart';
import 'package:haven/core/models/journal_entry_model.dart';
import 'package:haven/core/models/person_model.dart';
import 'package:haven/core/services/seed_service.dart';

void main() {
  const dbName = 'test_models.db';

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

  group('Note Model & Persistence Tests', () {
    test('Create, retrieve, update, and delete note', () async {
      final db = DatabaseService.instance;
      final now = DateTime.now();

      final note = Note(
        id: 'note_1',
        title: 'Morning Reflections',
        body: 'Early morning coffee and stillness.',
        category: 'Personal',
        colorId: 'warm_cream',
        createdAt: now,
        updatedAt: now,
      );

      await db.saveNote(note);

      final retrieved = await db.getNoteById('note_1');
      expect(retrieved, isNotNull);
      expect(retrieved!.title, 'Morning Reflections');
      expect(retrieved.body, 'Early morning coffee and stillness.');
      expect(retrieved.category, 'Personal');
      expect(retrieved.colorId, 'warm_cream');

      // Update
      final updatedNote = retrieved.copyWith(
        title: 'Updated Morning Reflections',
        body: 'Added more thoughts on work.',
      );
      await db.saveNote(updatedNote);

      final updated = await db.getNoteById('note_1');
      expect(updated!.title, 'Updated Morning Reflections');
      expect(updated.body, 'Added more thoughts on work.');

      // Delete
      await db.deleteNote('note_1');
      final deleted = await db.getNoteById('note_1');
      expect(deleted, isNull);
    });

    test('Notes are sorted by updated_at descending', () async {
      final db = DatabaseService.instance;
      final now = DateTime.now();

      final noteOld = Note(
        id: 'note_old',
        title: 'Older Note',
        body: 'Old content',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      );

      final noteNew = Note(
        id: 'note_new',
        title: 'Newer Note',
        body: 'New content',
        createdAt: now,
        updatedAt: now,
      );

      await db.saveNote(noteOld);
      await db.saveNote(noteNew);

      final allNotes = await db.getAllNotes();
      expect(allNotes.length, 2);
      expect(allNotes.first.id, 'note_new');
      expect(allNotes.last.id, 'note_old');
    });
  });

  group('Journal Entry Persistence Tests', () {
    test('Unique entry per local calendar date', () async {
      final db = DatabaseService.instance;
      final now = DateTime.now();

      final entry1 = JournalEntry(
        id: 'j_1',
        date: '2026-10-26',
        title: 'Initial Draft',
        body: 'First notes of the day.',
        createdAt: now,
        updatedAt: now,
      );

      await db.saveJournalEntry(entry1);

      final retrieved = await db.getJournalEntryByDate('2026-10-26');
      expect(retrieved, isNotNull);
      expect(retrieved!.title, 'Initial Draft');

      // Re-saving on the same date replaces/updates without duplicating
      final entry2 = retrieved.copyWith(
        title: 'Evening Synthesis',
        body: 'Expanded reflections on what happened today.',
      );
      await db.saveJournalEntry(entry2);

      final entries = await db.getJournalEntries();
      expect(entries.length, 1);
      expect(entries.first.title, 'Evening Synthesis');
    });
  });

  group('Person Archive Persistence Tests', () {
    test('Add, search, and delete person record', () async {
      final db = DatabaseService.instance;
      final now = DateTime.now();

      final person = Person(
        id: 'p_1',
        name: 'Elena Rostova',
        relationship: 'Mentor',
        notes: 'Advised that clarity follows deliberate action, not before.',
        importantDates: '14 November (Birthday)',
        createdAt: now,
        updatedAt: now,
      );

      await db.savePerson(person);

      final people = await db.getAllPeople();
      expect(people.length, 1);
      expect(people.first.name, 'Elena Rostova');
      expect(people.first.relationship, 'Mentor');

      await db.deletePerson('p_1');
      final remaining = await db.getAllPeople();
      expect(remaining.isEmpty, true);
    });
  });

  group('Seed Service Tests', () {
    test('Seeds 500+ questions and templates', () async {
      final db = DatabaseService.instance;
      await SeedService.seedIfNeeded();

      final questionCount = await db.getQuestionCount();
      expect(questionCount, greaterThanOrEqualTo(500));

      final templates = await db.getAllTemplates();
      expect(templates.length, greaterThanOrEqualTo(10));
    });
  });
}
