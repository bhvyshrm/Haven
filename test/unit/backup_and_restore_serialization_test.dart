import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:haven/core/database/database_service.dart';
import 'package:haven/core/models/note_model.dart';
import 'package:haven/core/models/journal_entry_model.dart';
import 'package:haven/core/models/person_model.dart';

void main() {
  const dbName = 'test_backup.db';

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

  group('Backup and Restore Serialization Tests', () {
    test('Export snapshot and restore into a fresh database', () async {
      final db = DatabaseService.instance;
      final now = DateTime.now();

      // Seed sample data
      await db.saveNote(
        Note(
          id: 'n_bk_1',
          title: 'Essential Architecture Invariants',
          body: '1. Local first.\n2. Monochromatic.\n3. Zero tracking.',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await db.saveJournalEntry(
        JournalEntry(
          id: 'j_bk_1',
          date: '2026-10-26',
          title: 'Haven Launch Day',
          body: 'All systems verified and working flawlessly.',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await db.savePerson(
        Person(
          id: 'p_bk_1',
          name: 'Julian Vance',
          relationship: 'Editor',
          notes: 'Typography enthusiast.',
          importantDates: '3 March',
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Export
      final payload = await db.exportBackupPayload();
      expect(payload['app_name'], 'Haven');
      expect(payload['schema_version'], 1);
      expect(payload['data'], isNotNull);

      final data = payload['data'] as Map<String, dynamic>;
      expect((data['notes'] as List).length, 1);
      expect((data['journal_entries'] as List).length, 1);
      expect((data['people'] as List).length, 1);

      // Wipe current DB
      await db.wipeAllUserData();
      expect((await db.getAllNotes()).isEmpty, true);
      expect((await db.getJournalEntries()).isEmpty, true);
      expect((await db.getAllPeople()).isEmpty, true);

      // Restore from payload
      final success = await db.restoreFromPayload(payload);
      expect(success, true);

      // Verify records are faithfully restored
      final restoredNotes = await db.getAllNotes();
      expect(restoredNotes.length, 1);
      expect(restoredNotes.first.id, 'n_bk_1');
      expect(restoredNotes.first.title, 'Essential Architecture Invariants');

      final restoredJournals = await db.getJournalEntries();
      expect(restoredJournals.length, 1);
      expect(restoredJournals.first.title, 'Haven Launch Day');

      final restoredPeople = await db.getAllPeople();
      expect(restoredPeople.length, 1);
      expect(restoredPeople.first.name, 'Julian Vance');
    });

    test('Rejects invalid or corrupted backup payloads', () async {
      final db = DatabaseService.instance;

      final invalidPayload1 = {
        'app_name': 'UnknownApp',
        'schema_version': 1,
        'data': {},
      };
      expect(await db.restoreFromPayload(invalidPayload1), false);

      final invalidPayload2 = {
        'app_name': 'Haven',
        // missing schema_version
        'data': {},
      };
      expect(await db.restoreFromPayload(invalidPayload2), false);
    });
  });
}
