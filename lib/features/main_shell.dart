import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/auth_lock_service.dart';
import '../core/state/haven_state.dart';
import '../core/theme/haven_colors.dart';
import '../core/widgets/haven_bottom_nav.dart';
import '../core/widgets/haven_passcode_pad.dart';
import '../core/widgets/haven_responsive_container.dart';
import '../core/widgets/haven_tab_switcher.dart';
import 'home/home_screen.dart';
import 'notes/notes_screen.dart';
import 'journal/journal_screen.dart';
import 'discover/discover_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  String? _lockErrorMessage;
  bool _attemptedAutoBiometrics = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAutoBiometrics();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    final state = context.read<HavenState>();
    if (lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.inactive) {
      state.handleAppPaused();
      _attemptedAutoBiometrics = false;
    } else if (lifecycleState == AppLifecycleState.resumed) {
      state.handleAppResumed();
      if (state.isLocked) {
        _checkAutoBiometrics();
      }
    }
  }

  Future<void> _checkAutoBiometrics() async {
    final state = context.read<HavenState>();
    if (state.isLocked &&
        state.settings.useBiometrics &&
        !_attemptedAutoBiometrics) {
      _attemptedAutoBiometrics = true;
      final canBio = await AuthLockService.instance.isBiometricsSupported();
      if (canBio) {
        final success = await state.unlockWithBiometrics();
        if (success && mounted) {
          setState(() {
            _lockErrorMessage = null;
          });
        }
      }
    }
  }

  void _onPasscodeEntered(String code) async {
    final state = context.read<HavenState>();
    final success = await state.unlockWithPasscode(code);
    if (success && mounted) {
      setState(() {
        _lockErrorMessage = null;
      });
    } else if (mounted) {
      setState(() {
        _lockErrorMessage = 'Incorrect passcode. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HavenState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? HavenColors.darkTextPrimary
        : HavenColors.lightTextPrimary;
    final canvasColor = isDark
        ? HavenColors.darkCanvas
        : HavenColors.lightCanvas;
    final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;

    // If app lock is active
    if (state.isLocked) {
      return Scaffold(
        backgroundColor: canvasColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: HavenPasscodePad(
                title: 'Haven is Locked',
                subtitle: 'Enter your passcode or authenticate to continue.',
                errorMessage: _lockErrorMessage,
                showBiometrics: state.settings.useBiometrics,
                onBiometricsTap: () async {
                  final ok = await state.unlockWithBiometrics();
                  if (ok && mounted) {
                    setState(() {
                      _lockErrorMessage = null;
                    });
                  }
                },
                onPasscodeComplete: _onPasscodeEntered,
              ),
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

    return PopScope(
      canPop: state.currentTabIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (state.currentTabIndex != 0) {
          state.popTab();
        }
      },
      child: Scaffold(
        backgroundColor: canvasColor,
        body: Stack(
          children: [
            HavenResponsiveContainer(
              child: SafeArea(
                top: true,
                bottom: false,
                child: HavenTabSwitcher(
                  currentIndex: state.currentTabIndex,
                  children: const [
                    HomeScreen(),
                    NotesScreen(),
                    JournalScreen(),
                    DiscoverScreen(),
                  ],
                ),
              ),
            ),
            if (!isKeyboardVisible)
              HavenBottomNav(
                currentIndex: state.currentTabIndex,
                onIndexChanged: (idx) => state.setTabIndex(idx),
              ),
          ],
        ),
      ),
    );
  }
}
