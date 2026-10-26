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
                    Material(
                      color: surfaceColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        side: BorderSide(color: borderColor, width: 1.0),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: SwitchListTile(
                        value: settings.isAppLockEnabled,
                        onChanged: (val) async {
                          if (val) {
                            final canAuth = await AuthLockService.instance
                                .isDeviceSupported();
                            if (!canAuth) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Device authentication is not available on this platform.',
                                    ),
                                  ),
                                );
                              }
                              return;
                            }
                            final authed = await AuthLockService.instance
                                .authenticate(
                                  reason:
                                      'Authenticate to enable Haven app lock',
                                );
                            if (authed) {
                              await state.updateSettings(
                                settings.copyWith(isAppLockEnabled: true),
                              );
                            }
                          } else {
                            await state.updateSettings(
                              settings.copyWith(isAppLockEnabled: false),
                            );
                          }
                        },
                        title: Text(
                          'App Lock',
                          style: HavenTypography.bodyMd(primaryTextColor),
                        ),
                        subtitle: Text(
                          'Require biometrics or device PIN to open Haven',
                          style: HavenTypography.caption(secondaryTextColor),
                        ),
                        activeThumbColor: primaryTextColor,
                      ),
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
