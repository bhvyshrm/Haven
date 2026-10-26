import 'dart:io';

import 'package:flutter/cupertino.dart';
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
      await DatabaseService.instance.close();
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
    'HavenApp renders main shell, header wordmark on Home, and 4 bottom tabs',
    (WidgetTester tester) async {
      final havenState = HavenState();
      await tester.runAsync(() async {
        await havenState.init();
      });

      await tester.pumpWidget(createHavenAppWidget(havenState));
      await tester.pumpAndSettle();

      // Verify wordmark 'haven' is displayed on Home
      expect(find.text('haven'), findsOneWidget);

      // Verify subtle settings button is accessible on Home
      expect(find.byTooltip('Settings'), findsOneWidget);

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
    'Bottom navigation switches tabs smoothly and wordmark is absent on non-Home tabs',
    (WidgetTester tester) async {
      final havenState = HavenState();
      await tester.runAsync(() async {
        await havenState.init();
      });

      await tester.pumpWidget(createHavenAppWidget(havenState));
      await tester.pumpAndSettle();

      // On Home: wordmark present
      expect(find.text('haven'), findsOneWidget);

      // Switch to Journal: wordmark must NOT be present
      await tester.tap(find.bySemanticsLabel('Journal'));
      await tester.pumpAndSettle();
      expect(find.text('haven'), findsNothing);
      expect(find.text("TODAY'S ENTRY"), findsOneWidget);
      expect(havenState.currentTabIndex, 1);

      // Switch to Notes: wordmark must NOT be present
      await tester.tap(find.bySemanticsLabel('Notes'));
      await tester.pumpAndSettle();
      expect(find.text('haven'), findsNothing);
      expect(find.text('Notes'), findsWidgets);
      expect(find.text('Search your notes'), findsOneWidget);
      expect(havenState.currentTabIndex, 2);

      // Switch to Discover: wordmark must NOT be present
      await tester.tap(find.bySemanticsLabel('Discover'));
      await tester.pumpAndSettle();
      expect(find.text('haven'), findsNothing);
      expect(find.text('DAILY REFLECTION'), findsOneWidget);
      expect(find.text('Get to know yourself'), findsOneWidget);
      expect(havenState.currentTabIndex, 3);

      // Return to Home: wordmark restored
      await tester.tap(find.bySemanticsLabel('Home'));
      await tester.pumpAndSettle();
      expect(find.text('haven'), findsOneWidget);
      expect(find.text('Recently saved'), findsOneWidget);
      expect(havenState.currentTabIndex, 0);
    },
  );

  testWidgets(
    'Settings screen opens from Home header, lacks Haven wordmark, and allows segmented theme selection',
    (WidgetTester tester) async {
      final havenState = HavenState();
      await tester.runAsync(() async {
        await havenState.init();
      });

      await tester.pumpWidget(createHavenAppWidget(havenState));
      await tester.pumpAndSettle();

      // Find subtle Settings icon button on Home
      final settingsButton = find.byTooltip('Settings');
      expect(settingsButton, findsOneWidget);

      // Tap settings button
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();

      // Settings screen should be open with its own title
      expect(find.text('Settings & Privacy'), findsOneWidget);
      // Wordmark 'haven' should NOT be on the settings screen
      expect(find.text('haven'), findsNothing);

      // Verify Appearance section and Cupertino segmented control exist
      expect(find.text('APPEARANCE'), findsOneWidget);
      expect(
        find.byType(CupertinoSlidingSegmentedControl<ThemeMode>),
        findsOneWidget,
      );

      // Tap the Dark option
      await tester.tap(find.byKey(const ValueKey('theme_segment_dark')));
      await tester.pumpAndSettle();

      // Verify state was updated to dark mode
      expect(havenState.settings.themeMode, ThemeMode.dark);

      // Verify setting light theme updates state and segmented control
      await tester.runAsync(() async {
        await havenState.setSpecificThemeMode(ThemeMode.light);
      });
      await tester.pumpAndSettle();
      expect(havenState.settings.themeMode, ThemeMode.light);

      // Navigate back
      final backButton = find.byTooltip('Back');
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Back on Home with wordmark
      expect(find.text('haven'), findsOneWidget);
    },
  );
}
