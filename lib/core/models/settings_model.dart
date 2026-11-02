import 'package:flutter/material.dart';

class HavenSettings {
  final ThemeMode themeMode;
  final bool isAppLockEnabled;
  final bool useBiometrics;
  final int
  lockTimeoutSeconds; // 0 = Immediately, 60 = 1 minute, 300 = 5 minutes
  final bool hasPasscode;
  final bool isDailyReminderEnabled;
  final String dailyReminderTime; // '20:00'
  final bool isWeeklyPlanReminderEnabled;
  final bool isSundayReviewReminderEnabled;
  final bool isWeeklyBackupReminderEnabled;
  final DateTime? lastBackupDate;
  final String? googleAccountEmail;

  const HavenSettings({
    this.themeMode = ThemeMode.system,
    this.isAppLockEnabled = false,
    this.useBiometrics = true,
    this.lockTimeoutSeconds = 0,
    this.hasPasscode = false,
    this.isDailyReminderEnabled = false,
    this.dailyReminderTime = '20:00',
    this.isWeeklyPlanReminderEnabled = false,
    this.isSundayReviewReminderEnabled = false,
    this.isWeeklyBackupReminderEnabled = false,
    this.lastBackupDate,
    this.googleAccountEmail,
  });

  HavenSettings copyWith({
    ThemeMode? themeMode,
    bool? isAppLockEnabled,
    bool? useBiometrics,
    int? lockTimeoutSeconds,
    bool? hasPasscode,
    bool? isDailyReminderEnabled,
    String? dailyReminderTime,
    bool? isWeeklyPlanReminderEnabled,
    bool? isSundayReviewReminderEnabled,
    bool? isWeeklyBackupReminderEnabled,
    DateTime? lastBackupDate,
    String? googleAccountEmail,
  }) {
    return HavenSettings(
      themeMode: themeMode ?? this.themeMode,
      isAppLockEnabled: isAppLockEnabled ?? this.isAppLockEnabled,
      useBiometrics: useBiometrics ?? this.useBiometrics,
      lockTimeoutSeconds: lockTimeoutSeconds ?? this.lockTimeoutSeconds,
      hasPasscode: hasPasscode ?? this.hasPasscode,
      isDailyReminderEnabled:
          isDailyReminderEnabled ?? this.isDailyReminderEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      isWeeklyPlanReminderEnabled:
          isWeeklyPlanReminderEnabled ?? this.isWeeklyPlanReminderEnabled,
      isSundayReviewReminderEnabled:
          isSundayReviewReminderEnabled ?? this.isSundayReviewReminderEnabled,
      isWeeklyBackupReminderEnabled:
          isWeeklyBackupReminderEnabled ?? this.isWeeklyBackupReminderEnabled,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
      googleAccountEmail: googleAccountEmail ?? this.googleAccountEmail,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'theme_mode': themeMode.name,
      'is_app_lock_enabled': isAppLockEnabled ? 1 : 0,
      'use_biometrics': useBiometrics ? 1 : 0,
      'lock_timeout_seconds': lockTimeoutSeconds,
      'has_passcode': hasPasscode ? 1 : 0,
      'is_daily_reminder_enabled': isDailyReminderEnabled ? 1 : 0,
      'daily_reminder_time': dailyReminderTime,
      'is_weekly_plan_reminder_enabled': isWeeklyPlanReminderEnabled ? 1 : 0,
      'is_sunday_review_reminder_enabled': isSundayReviewReminderEnabled
          ? 1
          : 0,
      'is_weekly_backup_reminder_enabled': isWeeklyBackupReminderEnabled
          ? 1
          : 0,
      'last_backup_date': lastBackupDate?.toIso8601String(),
      'google_account_email': googleAccountEmail,
    };
  }

  factory HavenSettings.fromMap(Map<String, dynamic> map) {
    ThemeMode mode = ThemeMode.system;
    final modeStr = map['theme_mode'] as String?;
    if (modeStr == 'light') mode = ThemeMode.light;
    if (modeStr == 'dark') mode = ThemeMode.dark;

    return HavenSettings(
      themeMode: mode,
      isAppLockEnabled: (map['is_app_lock_enabled'] as int? ?? 0) == 1,
      useBiometrics: (map['use_biometrics'] as int? ?? 1) == 1,
      lockTimeoutSeconds: map['lock_timeout_seconds'] as int? ?? 0,
      hasPasscode: (map['has_passcode'] as int? ?? 0) == 1,
      isDailyReminderEnabled:
          (map['is_daily_reminder_enabled'] as int? ?? 0) == 1,
      dailyReminderTime: (map['daily_reminder_time'] as String?) ?? '20:00',
      isWeeklyPlanReminderEnabled:
          (map['is_weekly_plan_reminder_enabled'] as int? ?? 0) == 1,
      isSundayReviewReminderEnabled:
          (map['is_sunday_review_reminder_enabled'] as int? ?? 0) == 1,
      isWeeklyBackupReminderEnabled:
          (map['is_weekly_backup_reminder_enabled'] as int? ?? 0) == 1,
      lastBackupDate: DateTime.tryParse(
        map['last_backup_date'] as String? ?? '',
      ),
      googleAccountEmail: map['google_account_email'] as String?,
    );
  }
}
