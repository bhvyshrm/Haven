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
import 'package:haven/core/widgets/haven_header.dart';

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

  testWidgets(
    'HavenHeader renders without any divider line beneath haven title',
    (WidgetTester tester) async {
      final havenState = HavenState();
      await tester.runAsync(() async {
        await havenState.init();
      });

      await tester.pumpWidget(createHavenAppWidget(havenState));
      await tester.pumpAndSettle();

      // Find HavenHeader on Home
      final headerFinder = find.byType(HavenHeader);
      expect(headerFinder, findsOneWidget);
      final HavenHeader headerWidget = tester.widget(headerFinder);
      expect(headerWidget.showBottomDivider, isFalse);

      // Verify no bottom border exists in HavenHeader
      final containerFinder = find.descendant(
        of: headerFinder,
        matching: find.byType(Container),
      );
      bool hasBottomBorder = false;
      for (final element in containerFinder.evaluate()) {
        final container = element.widget as Container;
        final decoration = container.decoration;
        if (decoration is BoxDecoration && decoration.border != null) {
          if (decoration.border!.bottom != BorderSide.none) {
            hasBottomBorder = true;
          }
        }
      }
      expect(hasBottomBorder, isFalse);
    },
  );

  testWidgets(
    'Smooth tab transitions preserve search text and navigation state across tabs',
    (WidgetTester tester) async {
      final havenState = HavenState();
      await tester.runAsync(() async {
        await havenState.init();
      });

      await tester.pumpWidget(createHavenAppWidget(havenState));
      await tester.pumpAndSettle();

      // 1. Switch to Notes
      await tester.tap(find.bySemanticsLabel('Notes'));
      await tester.pumpAndSettle();
      expect(havenState.currentTabIndex, 2);

      // 2. Enter search text into Notes search field
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'serenity');
      await tester.pumpAndSettle();
      expect(havenState.searchQuery, 'serenity');

      // 3. Switch to Journal
      await tester.tap(find.bySemanticsLabel('Journal'));
      await tester.pumpAndSettle();
      expect(havenState.currentTabIndex, 1);
      expect(find.text("TODAY'S ENTRY"), findsOneWidget);

      // 4. Switch back to Notes -> search query preserved!
      await tester.tap(find.bySemanticsLabel('Notes'));
      await tester.pumpAndSettle();
      expect(havenState.currentTabIndex, 2);
      expect(havenState.searchQuery, 'serenity');
      expect(find.text('serenity'), findsOneWidget);

      // 5. Switch to Discover
      await tester.tap(find.bySemanticsLabel('Discover'));
      await tester.pumpAndSettle();
      expect(havenState.currentTabIndex, 3);
      expect(find.text('DAILY REFLECTION'), findsOneWidget);

      // 6. Return to Home
      await tester.tap(find.bySemanticsLabel('Home'));
      await tester.pumpAndSettle();
      expect(havenState.currentTabIndex, 0);
      expect(find.text('Recently saved'), findsOneWidget);
    },
  );

  testWidgets(
    'Android PopScope navigation manages tab history and back popping',
    (WidgetTester tester) async {
      final havenState = HavenState();
      await tester.runAsync(() async {
        await havenState.init();
      });

      await tester.pumpWidget(createHavenAppWidget(havenState));
      await tester.pumpAndSettle();

      // Start on Home
      expect(havenState.currentTabIndex, 0);

      // Navigate Home (0) -> Journal (1) -> Notes (2)
      await tester.tap(find.bySemanticsLabel('Journal'));
      await tester.pumpAndSettle();
      expect(havenState.currentTabIndex, 1);

      await tester.tap(find.bySemanticsLabel('Notes'));
      await tester.pumpAndSettle();
      expect(havenState.currentTabIndex, 2);

      // Pop tab history
      final didPop1 = havenState.popTab();
      expect(didPop1, isTrue);
      expect(havenState.currentTabIndex, 1);
      await tester.pumpAndSettle();

      // Pop tab history back to Home
      final didPop2 = havenState.popTab();
      expect(didPop2, isTrue);
      expect(havenState.currentTabIndex, 0);
      await tester.pumpAndSettle();

      // Popping from Home returns false (allowing app exit / root pop)
      final didPop3 = havenState.popTab();
      expect(didPop3, isFalse);
      expect(havenState.currentTabIndex, 0);
    },
  );

  testWidgets('Bottom nav bar hides when keyboard is visible', (
    WidgetTester tester,
  ) async {
    final havenState = HavenState();
    await tester.runAsync(() async {
      await havenState.init();
    });

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(() => tester.view.resetViewInsets());

    await tester.pumpWidget(createHavenAppWidget(havenState));
    await tester.pumpAndSettle();

    // With keyboard open, HavenBottomNav content should be empty / hidden
    expect(find.bySemanticsLabel('Journal'), findsNothing);
  });
}
