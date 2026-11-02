import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/state/haven_state.dart';
import '../../core/theme/haven_colors.dart';
import '../../core/theme/haven_typography.dart';
import '../../core/widgets/haven_responsive_container.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/auth_lock_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/widgets/haven_passcode_pad.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HavenState>();
    final settings = state.settings;
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
    final surfaceColor = isDark
        ? HavenColors.darkSurface
        : HavenColors.lightSurface;
    final borderColor = isDark
        ? HavenColors.darkBorder
        : HavenColors.lightBorder;

    return Scaffold(
      backgroundColor: canvasColor,
      body: SafeArea(
        child: HavenResponsiveContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, size: 24.0),
                      color: primaryTextColor,
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Back',
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      'Settings & Privacy',
                      style: HavenTypography.headlineSm(primaryTextColor)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 8.0,
                  ),
                  children: [
                    // APPEARANCE
                    _SectionHeader(
                      title: 'APPEARANCE',
                      color: secondaryTextColor,
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: borderColor, width: 1.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CupertinoSlidingSegmentedControl<ThemeMode>(
                            groupValue: settings.themeMode,
                            backgroundColor: isDark
                                ? const Color(0xFF1E1E1E)
                                : const Color(0xFFEBEBEB),
                            thumbColor: isDark
                                ? const Color(0xFF333333)
                                : Colors.white,
                            children: {
                              ThemeMode.system: Padding(
                                key: const ValueKey('theme_segment_system'),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Text(
                                  'System',
                                  style:
                                      HavenTypography.bodySm(primaryTextColor)
                                          .copyWith(
                                            fontWeight:
                                                settings.themeMode ==
                                                    ThemeMode.system
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                          ),
                                ),
                              ),
                              ThemeMode.light: Padding(
                                key: const ValueKey('theme_segment_light'),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Text(
                                  'Light',
                                  style:
                                      HavenTypography.bodySm(primaryTextColor)
                                          .copyWith(
                                            fontWeight:
                                                settings.themeMode ==
                                                    ThemeMode.light
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                          ),
                                ),
                              ),
                              ThemeMode.dark: Padding(
                                key: const ValueKey('theme_segment_dark'),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Text(
                                  'Dark',
                                  style:
                                      HavenTypography.bodySm(
                                        primaryTextColor,
                                      ).copyWith(
                                        fontWeight:
                                            settings.themeMode == ThemeMode.dark
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                ),
                              ),
                            },
                            onValueChanged: (val) {
                              if (val != null) {
                                HapticFeedback.selectionClick();
                                state.setSpecificThemeMode(val);
                              }
                            },
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            settings.themeMode == ThemeMode.system
                                ? 'System: Automatically adapts to your device theme.'
                                : settings.themeMode == ThemeMode.light
                                ? 'Light: Clean white background for bright environments.'
                                : 'Dark: True AMOLED black (#000000) for battery saving and night reflection.',
                            style: HavenTypography.caption(secondaryTextColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // PRIVACY & APP LOCK
                    _SectionHeader(
                      title: 'SECURITY & PRIVACY',
                      color: secondaryTextColor,
                    ),
                    _AppLockSettingsBlock(
                      settings: settings,
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    const SizedBox(height: 24.0),

                    // NOTIFICATIONS
                    _SectionHeader(
                      title: 'LOCAL REMINDERS',
                      color: secondaryTextColor,
                    ),
                    Material(
                      color: surfaceColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        side: BorderSide(color: borderColor, width: 1.0),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          SwitchListTile(
                            value: settings.isDailyReminderEnabled,
                            onChanged: (val) async {
                              if (val) {
                                final granted = await NotificationService
                                    .instance
                                    .requestPermissions();
                                if (!granted && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please enable notification permissions in system settings',
                                      ),
                                    ),
                                  );
                                }
                              }
                              await state.updateSettings(
                                settings.copyWith(isDailyReminderEnabled: val),
                              );
                            },
                            title: Text(
                              'Daily reflection reminder',
                              style: HavenTypography.bodyMd(primaryTextColor),
                            ),
                            subtitle: Text(
                              'Evening reminder for quiet journaling',
                              style: HavenTypography.caption(
                                secondaryTextColor,
                              ),
                            ),
                            activeThumbColor: primaryTextColor,
                          ),
                          Divider(height: 1.0, color: borderColor),
                          SwitchListTile(
                            value: settings.isWeeklyPlanReminderEnabled,
                            onChanged: (val) async {
                              if (val) {
                                await NotificationService.instance
                                    .requestPermissions();
                              }
                              await state.updateSettings(
                                settings.copyWith(
                                  isWeeklyPlanReminderEnabled: val,
                                ),
                              );
                            },
                            title: Text(
                              'Monday weekly plan reminder',
                              style: HavenTypography.bodyMd(primaryTextColor),
                            ),
                            subtitle: Text(
                              'Set intentions on Monday morning (9:00 AM)',
                              style: HavenTypography.caption(
                                secondaryTextColor,
                              ),
                            ),
                            activeThumbColor: primaryTextColor,
                          ),
                          Divider(height: 1.0, color: borderColor),
                          SwitchListTile(
                            value: settings.isSundayReviewReminderEnabled,
                            onChanged: (val) async {
                              if (val) {
                                await NotificationService.instance
                                    .requestPermissions();
                              }
                              await state.updateSettings(
                                settings.copyWith(
                                  isSundayReviewReminderEnabled: val,
                                ),
                              );
                            },
                            title: Text(
                              'Sunday review reminder',
                              style: HavenTypography.bodyMd(primaryTextColor),
                            ),
                            subtitle: Text(
                              'Review your week on Sunday evening (7:00 PM)',
                              style: HavenTypography.caption(
                                secondaryTextColor,
                              ),
                            ),
                            activeThumbColor: primaryTextColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // BACKUP & RESTORE
                    _SectionHeader(
                      title: 'BACKUP & RESTORE',
                      color: secondaryTextColor,
                    ),
                    Material(
                      color: surfaceColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        side: BorderSide(color: borderColor, width: 1.0),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          // File Export
                          ListTile(
                            leading: Icon(
                              Icons.file_download_outlined,
                              color: primaryTextColor,
                            ),
                            title: Text(
                              'Export backup file (.json)',
                              style: HavenTypography.bodyMd(primaryTextColor),
                            ),
                            subtitle: Text(
                              'Save portable snapshot to your device or drive',
                              style: HavenTypography.caption(
                                secondaryTextColor,
                              ),
                            ),
                            onTap: () async {
                              final res = await BackupService.instance
                                  .exportToFile();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(res.message)),
                                );
                              }
                            },
                          ),
                          Divider(height: 1.0, color: borderColor),

                          // File Import
                          ListTile(
                            leading: Icon(
                              Icons.file_upload_outlined,
                              color: primaryTextColor,
                            ),
                            title: Text(
                              'Restore from backup file',
                              style: HavenTypography.bodyMd(primaryTextColor),
                            ),
                            subtitle: Text(
                              'Load Haven data from a previously exported JSON file',
                              style: HavenTypography.caption(
                                secondaryTextColor,
                              ),
                            ),
                            onTap: () async {
                              _confirmRestore(context, isDrive: false);
                            },
                          ),
                          Divider(height: 1.0, color: borderColor),

                          // Google Drive
                          ListTile(
                            leading: Icon(
                              Icons.cloud_sync_outlined,
                              color: primaryTextColor,
                            ),
                            title: Text(
                              'Google Drive Backup',
                              style: HavenTypography.bodyMd(primaryTextColor),
                            ),
                            subtitle: Text(
                              settings.googleAccountEmail != null
                                  ? 'Connected as ${settings.googleAccountEmail}'
                                  : 'Sync private backup to your Google Drive App Data',
                              style: HavenTypography.caption(
                                secondaryTextColor,
                              ),
                            ),
                            trailing: TextButton(
                              onPressed: () async {
                                final res = await BackupService.instance
                                    .backupToGoogleDrive();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(res.message)),
                                  );
                                }
                              },
                              child: Text(
                                'Back up now',
                                style: HavenTypography.labelSm(
                                  primaryTextColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // DATA INTEGRITY & DANGER ZONE
                    _SectionHeader(
                      title: 'DATA MANAGEMENT',
                      color: secondaryTextColor,
                    ),
                    Material(
                      color: surfaceColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        side: BorderSide(color: borderColor, width: 1.0),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        leading: const Icon(
                          Icons.delete_forever_rounded,
                          color: HavenColors.error,
                        ),
                        title: Text(
                          'Clear all local data',
                          style: HavenTypography.bodyMd(HavenColors.error),
                        ),
                        subtitle: Text(
                          'Permanently erase all notes, entries, and plans',
                          style: HavenTypography.caption(secondaryTextColor),
                        ),
                        onTap: () => _confirmWipeData(context),
                      ),
                    ),
                    const SizedBox(height: 32.0),

                    // App Information
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 64.0,
                            height: 64.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.4 : 0.08,
                                  ),
                                  blurRadius: 12.0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              'assets/icon/app_icon.png',
                              width: 64.0,
                              height: 64.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            'Haven',
                            style: HavenTypography.headlineSm(primaryTextColor),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Version 1.0.0 • Local-First • No Tracking',
                            style: HavenTypography.caption(secondaryTextColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmRestore(BuildContext context, {required bool isDrive}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final havenState = context.read<HavenState>();
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dlgContext) {
        return AlertDialog(
          backgroundColor: isDark
              ? HavenColors.darkSurface
              : HavenColors.lightCanvas,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text(
            'Restore backup?',
            style: HavenTypography.headlineSm(
              isDark ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            'Restoring replaces current local content with the backup snapshot. Would you like to merge or replace?',
            style: HavenTypography.bodySm(
              isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlgContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dlgContext);
                final res = isDrive
                    ? await BackupService.instance.restoreFromGoogleDrive(
                        merge: true,
                      )
                    : await BackupService.instance.importFromFile(merge: true);
                await havenState.reloadAll();
                messenger.showSnackBar(SnackBar(content: Text(res.message)));
              },
              child: const Text('Merge'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dlgContext);
                final res = isDrive
                    ? await BackupService.instance.restoreFromGoogleDrive(
                        merge: false,
                      )
                    : await BackupService.instance.importFromFile(merge: false);
                await havenState.reloadAll();
                messenger.showSnackBar(SnackBar(content: Text(res.message)));
              },
              child: const Text('Replace all'),
            ),
          ],
        );
      },
    );
  }

  void _confirmWipeData(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (dlgContext) {
        return AlertDialog(
          backgroundColor: isDark
              ? HavenColors.darkSurface
              : HavenColors.lightCanvas,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text(
            'Wipe all local data?',
            style: HavenTypography.headlineSm(HavenColors.error),
          ),
          content: Text(
            'This will permanently delete all your journal entries, personal notes, people, and weekly reviews. This action cannot be reversed.',
            style: HavenTypography.bodySm(
              isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlgContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dlgContext);
                await context.read<HavenState>().wipeAllData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All local data wiped cleanly'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: HavenColors.error,
              ),
              child: const Text(
                'Yes, wipe everything',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: HavenTypography.caption(color)
            .copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.8),
      ),
    );
  }
}

class _AppLockSettingsBlock extends StatelessWidget {
  final dynamic settings;
  final Color surfaceColor;
  final Color borderColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;

  const _AppLockSettingsBlock({
    required this.settings,
    required this.surfaceColor,
    required this.borderColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
  });

  void _showPasscodeSetup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? HavenColors.darkCanvas
          : HavenColors.lightCanvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) => const _PasscodeSetupModal(),
    );
  }

  void _showPasscodeDisable(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? HavenColors.darkCanvas
          : HavenColors.lightCanvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) => const _PasscodeDisableModal(),
    );
  }

  void _showTimeoutDialog(BuildContext context, HavenState state) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: BorderSide(color: borderColor, width: 1.0),
          ),
          title: Text(
            'Auto-Lock Timeout',
            style: HavenTypography.headlineSm(primaryTextColor)
                .copyWith(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTimeoutTile(ctx, state, 0, 'Immediately'),
              _buildTimeoutTile(ctx, state, 60, 'After 1 minute'),
              _buildTimeoutTile(ctx, state, 300, 'After 5 minutes'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeoutTile(
    BuildContext ctx,
    HavenState state,
    int seconds,
    String label,
  ) {
    final isSelected = state.settings.lockTimeoutSeconds == seconds;
    return ListTile(
      title: Text(
        label,
        style: HavenTypography.bodyMd(
          primaryTextColor,
        ).copyWith(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400),
      ),
      trailing: isSelected
          ? Icon(Icons.check_rounded, color: primaryTextColor, size: 20.0)
          : null,
      onTap: () {
        state.updateSettings(
          state.settings.copyWith(lockTimeoutSeconds: seconds),
        );
        Navigator.pop(ctx);
      },
    );
  }

  String _formatTimeout(int seconds) {
    if (seconds <= 0) return 'Immediately upon exit';
    if (seconds == 60) return 'After 1 minute in background';
    return 'After ${seconds ~/ 60} minutes in background';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HavenState>();

    return Material(
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: borderColor, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SwitchListTile(
            value: settings.isAppLockEnabled,
            onChanged: (val) {
              if (val) {
                _showPasscodeSetup(context);
              } else {
                _showPasscodeDisable(context);
              }
            },
            title: Text(
              'App Lock',
              style: HavenTypography.bodyMd(primaryTextColor),
            ),
            subtitle: Text(
              'Require authentication to open Haven',
              style: HavenTypography.caption(secondaryTextColor),
            ),
            activeThumbColor: primaryTextColor,
          ),
          if (settings.isAppLockEnabled) ...[
            Divider(height: 1.0, color: borderColor),
            SwitchListTile(
              value: settings.useBiometrics,
              onChanged: (val) {
                state.updateSettings(settings.copyWith(useBiometrics: val));
              },
              title: Text(
                'Unlock with Biometrics',
                style: HavenTypography.bodyMd(primaryTextColor),
              ),
              subtitle: Text(
                'Use Face ID or fingerprint when available',
                style: HavenTypography.caption(secondaryTextColor),
              ),
              activeThumbColor: primaryTextColor,
            ),
            Divider(height: 1.0, color: borderColor),
            ListTile(
              onTap: () => _showPasscodeSetup(context),
              title: Text(
                'Change Passcode',
                style: HavenTypography.bodyMd(primaryTextColor),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                size: 20.0,
                color: secondaryTextColor,
              ),
            ),
            Divider(height: 1.0, color: borderColor),
            ListTile(
              onTap: () => _showTimeoutDialog(context, state),
              title: Text(
                'Auto-Lock Timeout',
                style: HavenTypography.bodyMd(primaryTextColor),
              ),
              subtitle: Text(
                _formatTimeout(settings.lockTimeoutSeconds),
                style: HavenTypography.caption(secondaryTextColor),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                size: 20.0,
                color: secondaryTextColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PasscodeSetupModal extends StatefulWidget {
  const _PasscodeSetupModal();

  @override
  State<_PasscodeSetupModal> createState() => _PasscodeSetupModalState();
}

class _PasscodeSetupModalState extends State<_PasscodeSetupModal> {
  int _step = 1; // 1: set, 2: confirm
  String _firstCode = '';
  String? _errorMessage;

  void _onCodeEntered(String code) async {
    if (_step == 1) {
      setState(() {
        _firstCode = code;
        _step = 2;
        _errorMessage = null;
      });
    } else {
      if (code == _firstCode) {
        final state = context.read<HavenState>();
        await state.enableAppLock(
          passcode: code,
          useBiometrics: state.settings.useBiometrics,
          lockTimeoutSeconds: state.settings.lockTimeoutSeconds,
        );
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('App Lock enabled successfully.')),
          );
        }
      } else {
        setState(() {
          _step = 1;
          _firstCode = '';
          _errorMessage = 'Passcodes did not match. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
        child: HavenPasscodePad(
          title: _step == 1 ? 'Set 4-Digit Passcode' : 'Confirm Passcode',
          subtitle: _step == 1
              ? 'Choose a passcode to protect your Haven journals and notes.'
              : 'Re-enter your passcode to confirm.',
          errorMessage: _errorMessage,
          onPasscodeComplete: _onCodeEntered,
          onCancel: () => Navigator.pop(context),
        ),
      ),
    );
  }
}

class _PasscodeDisableModal extends StatefulWidget {
  const _PasscodeDisableModal();

  @override
  State<_PasscodeDisableModal> createState() => _PasscodeDisableModalState();
}

class _PasscodeDisableModalState extends State<_PasscodeDisableModal> {
  String? _errorMessage;

  void _onCodeEntered(String code) async {
    final valid = await AuthLockService.instance.verifyPasscode(code);
    if (valid) {
      if (mounted) {
        await context.read<HavenState>().disableAppLock();
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('App Lock disabled.')));
        }
      }
    } else {
      setState(() {
        _errorMessage = 'Incorrect passcode.';
      });
    }
  }

  void _onBiometrics() async {
    final success = await AuthLockService.instance.authenticateBiometrics();
    if (success && mounted) {
      await context.read<HavenState>().disableAppLock();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('App Lock disabled.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HavenState>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
        child: HavenPasscodePad(
          title: 'Enter Passcode to Disable',
          subtitle: 'Verify your identity to turn off App Lock.',
          errorMessage: _errorMessage,
          showBiometrics: state.settings.useBiometrics,
          onBiometricsTap: _onBiometrics,
          onPasscodeComplete: _onCodeEntered,
          onCancel: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
