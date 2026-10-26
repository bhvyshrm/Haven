import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:haven/core/database/database_service.dart';
import 'package:haven/core/models/question_model.dart';
import 'package:haven/core/state/haven_state.dart';

void main() {
  const dbName = 'test_questions.db';

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDownAll(() async {
    try {
      await DatabaseService.instance.close();
      final f = File(dbName);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.instance.init(customPath: dbName);
    await DatabaseService.instance.wipeAllUserData();
  });

  group('Questions & Daily Response Limits Tests', () {
    test('Daily Question answering and update', () async {
      final state = HavenState();
      await state.init();

      expect(state.dailyQuestion, isNotNull);
      final question = state.dailyQuestion!;

      final saved = await state.answerQuestion(
        question,
        'Quiet coffee at 6am before any screens.',
        source: 'daily',
      );
      expect(saved, true);
      expect(state.todayDailyResponse, isNotNull);
      expect(
        state.todayDailyResponse!.answerText,
        'Quiet coffee at 6am before any screens.',
      );

      // Updating the answer
      final updated = await state.answerQuestion(
        question,
        'Quiet coffee at 6am and a ten minute walk outside.',
        source: 'daily',
      );
      expect(updated, true);
      expect(
        state.todayDailyResponse!.answerText,
        'Quiet coffee at 6am and a ten minute walk outside.',
      );
    });

    test(
      'Random question daily limit is strictly 10 responses per day',
      () async {
        final state = HavenState();
        await state.init();

        expect(state.remainingRandomAllowance, 10);

        // Answer 10 random questions
        for (int i = 0; i < 10; i++) {
          final q = Question(
            id: 'test_q_$i',
            text: 'Prompt number $i',
            category: 'General',
          );
          final res = await state.answerQuestion(
            q,
            'Answer $i',
            source: 'random',
          );
          expect(res, true);
        }

        expect(state.todayRandomResponseCount, 10);
        expect(state.remainingRandomAllowance, 0);

        // 11th random response should be rejected by the allowance policy
        final extraQ = const Question(
          id: 'test_q_11',
          text: 'Prompt number 11',
          category: 'General',
        );
        final rejected = await state.answerQuestion(
          extraQ,
          'Should fail',
          source: 'random',
        );
        expect(rejected, false);
      },
    );

    test(
      'Template to note creation does not mutate template catalog',
      () async {
        final state = HavenState();
        await state.init();

        final originalTemplates = state.templates;
        expect(originalTemplates.isNotEmpty, true);

        final template = originalTemplates.first;
        final originalContent = template.content;

        final generatedNote = await state.useTemplate(template);
        expect(generatedNote.title, template.title);
        expect(generatedNote.body, originalContent);
        expect(generatedNote.templateId, template.id);

        // Edit the generated note
        final editedNote = generatedNote.copyWith(
          title: 'My Custom Note based on Template',
          body: 'Completely different personal text.',
        );
        await state.saveNote(editedNote);

        // Verify the template remains 100% pristine and unaltered
        final templatesAfter = state.templates;
        final targetTemplate = templatesAfter.firstWhere(
          (t) => t.id == template.id,
        );
        expect(targetTemplate.content, originalContent);
        expect(targetTemplate.title, template.title);
      },
    );
  });
}
