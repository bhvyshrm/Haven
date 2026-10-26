import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:haven/main.dart';
import 'package:haven/core/state/haven_state.dart';
import 'package:haven/core/database/database_service.dart';

void main() {
  const testDbName = 'test_widget_haven.db';

  setUpAll(() async {
    sqfliteFfiInit();
    sqflite.databaseFactory = databaseFactoryFfi;
  });

  tearDownAll(() async {
    try {
      final file = File(testDbName);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.instance.init(customPath: testDbName);
    await DatabaseService.instance.wipeAllUserData();
  });

  Widget createHavenAppWidget(HavenState state) {
    return ChangeNotifierProvider<HavenState>.value(
      value: state,
      child: const HavenApp(),
    );
  }

  testWidgets(
    'HavenApp renders main shell, header wordmark, and 4 bottom tabs',
    (WidgetTester tester) async {
      final havenState = HavenState();
      await tester.runAsync(() async {
        await havenState.init();
      });

      await tester.pumpWidget(createHavenAppWidget(havenState));
      await tester.pumpAndSettle();

      // Verify wordmark 'haven'
      expect(find.text('haven'), findsOneWidget);

      // Verify 4 primary destinations via semantic labels
      expect(find.bySemanticsLabel('Home'), findsOneWidget);
      expect(find.bySemanticsLabel('Journal'), findsOneWidget);
      expect(find.bySemanticsLabel('Notes'), findsOneWidget);
      expect(find.bySemanticsLabel('Discover'), findsOneWidget);

      // Verify initial Home tab content
      expect(find.text('Recently saved'), findsOneWidget);
    },
  );

  testWidgets(
    'Bottom navigation switches tabs smoothly between all 4 destinations',
    (WidgetTester tester) async {
      final havenState = HavenState();
      await tester.runAsync(() async {
        await havenState.init();
      });

      await tester.pumpWidget(createHavenAppWidget(havenState));
      await tester.pumpAndSettle();

      // Switch to Journal
      await tester.tap(find.bySemanticsLabel('Journal'));
      await tester.pumpAndSettle();
      expect(find.text("TODAY'S ENTRY"), findsOneWidget);
      expect(havenState.currentTabIndex, 1);

      // Switch to Notes
      await tester.tap(find.bySemanticsLabel('Notes'));
      await tester.pumpAndSettle();
      expect(find.text('Notes'), findsWidgets);
      expect(find.text('Search your notes'), findsOneWidget);
      expect(havenState.currentTabIndex, 2);

      // Switch to Discover
      await tester.tap(find.bySemanticsLabel('Discover'));
      await tester.pumpAndSettle();
      expect(find.text('DAILY REFLECTION'), findsOneWidget);
      expect(find.text('Get to know yourself'), findsOneWidget);
      expect(havenState.currentTabIndex, 3);

      // Return to Home
      await tester.tap(find.bySemanticsLabel('Home'));
      await tester.pumpAndSettle();
      expect(find.text('Recently saved'), findsOneWidget);
      expect(havenState.currentTabIndex, 0);
    },
  );

  testWidgets('Theme toggle button cycles theme modes', (
    WidgetTester tester,
  ) async {
    final havenState = HavenState();
    await tester.runAsync(() async {
      await havenState.init();
    });

    await tester.pumpWidget(createHavenAppWidget(havenState));
    await tester.pumpAndSettle();

    // Find theme toggle button via tooltip
    final themeToggle = find.byWidgetPredicate(
      (widget) =>
          widget is IconButton &&
          (widget.tooltip == 'Switch to AMOLED Dark' ||
              widget.tooltip == 'Switch to Light'),
    );
    expect(themeToggle, findsOneWidget);

    await tester.tap(themeToggle);
    await tester.pumpAndSettle();

    // Theme mode should now be explicitly toggled (either dark or light)
    expect(havenState.settings.themeMode, isNot(ThemeMode.system));
  });
}
