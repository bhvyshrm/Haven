import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/state/haven_state.dart';
import '../core/theme/haven_colors.dart';
import '../core/theme/haven_typography.dart';
import '../core/widgets/haven_header.dart';
import '../core/widgets/haven_bottom_nav.dart';
import '../core/widgets/haven_responsive_container.dart';
import 'home/home_screen.dart';
import 'journal/journal_screen.dart';
import 'notes/notes_screen.dart';
import 'discover/discover_screen.dart';
import 'settings/settings_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HavenState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? HavenColors.darkTextPrimary
        : HavenColors.lightTextPrimary;
    final secondaryTextColor = isDark
        ? HavenColors.darkTextSecondary
        : HavenColors.lightTextSecondary;
    final canvasColor = isDark
        ? HavenColors.darkCanvas
        : HavenColors.lightCanvas;

    // If app lock is active
    if (state.isLocked) {
      return Scaffold(
        backgroundColor: canvasColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 48.0,
                  color: primaryTextColor,
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Haven is Locked',
                  style: HavenTypography.headlineSm(primaryTextColor)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6.0),
                Text(
                  'Your private space is protected by device authentication.',
                  textAlign: TextAlign.center,
                  style: HavenTypography.bodySm(secondaryTextColor),
                ),
                const SizedBox(height: 24.0),
                ElevatedButton.icon(
                  onPressed: () => state.unlockApp(),
                  icon: const Icon(Icons.fingerprint_rounded, size: 18.0),
                  label: const Text('Unlock'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTextColor,
                    foregroundColor: canvasColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 12.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state.isLoading) {
      return Scaffold(
        backgroundColor: canvasColor,
        body: Center(child: CircularProgressIndicator(color: primaryTextColor)),
      );
    }

    return Scaffold(
      backgroundColor: canvasColor,
      appBar: HavenHeader(
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Theme toggle button
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                size: 20.0,
                color: secondaryTextColor,
              ),
              onPressed: () => state.toggleTheme(context),
              tooltip: isDark ? 'Switch to Light' : 'Switch to AMOLED Dark',
            ),
            // Settings button
            IconButton(
              icon: Icon(
                Icons.settings_outlined,
                size: 20.0,
                color: secondaryTextColor,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
              tooltip: 'Settings & Privacy',
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          HavenResponsiveContainer(
            child: IndexedStack(
              index: state.currentTabIndex,
              children: const [
                HomeScreen(),
                JournalScreen(),
                NotesScreen(),
                DiscoverScreen(),
              ],
            ),
          ),
          HavenBottomNav(
            currentIndex: state.currentTabIndex,
            onIndexChanged: (idx) => state.setTabIndex(idx),
          ),
        ],
      ),
    );
  }
}
