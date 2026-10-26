import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/state/haven_state.dart';
import '../../core/models/journal_entry_model.dart';
import '../../core/theme/haven_colors.dart';
import '../../core/theme/haven_typography.dart';
import '../planner/planner_screen.dart';
import 'journal_editor_screen.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

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
    final surfaceColor = isDark
        ? HavenColors.darkSurface
        : HavenColors.lightSurface;
    final borderColor = isDark
        ? HavenColors.darkBorder
        : HavenColors.lightBorder;

    final selectedDate = state.selectedDate;
    final selectedEntry = state.entryForSelectedDate;
    final previousEntries = state.journalEntries
        .where((e) => e.date != state.selectedDateFormatted)
        .toList();

    return RefreshIndicator(
      onRefresh: () => state.loadJournal(),
      color: primaryTextColor,
      backgroundColor: surfaceColor,
      child: ListView(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 16.0,
          bottom: 120.0,
        ),
        children: [
          // 1. Heading & Open Planner link
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Journal',
                style: HavenTypography.headlineLg(primaryTextColor),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PlannerScreen()),
                  );
                },
                icon: Icon(
                  Icons.calendar_month_outlined,
                  size: 16.0,
                  color: secondaryTextColor,
                ),
                label: Text(
                  'Weekly Planner & Goals',
                  style: HavenTypography.labelSm(secondaryTextColor),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4.0,
                    vertical: 4.0,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // 2. Date Navigation Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: borderColor, width: 1.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 18.0,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      DateFormat('EEEE, d MMMM').format(selectedDate),
                      style: HavenTypography.labelMd(primaryTextColor)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, size: 20.0),
                      color: secondaryTextColor,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32.0,
                        minHeight: 32.0,
                      ),
                      onPressed: () {
                        state.setSelectedDate(
                          selectedDate.subtract(const Duration(days: 1)),
                        );
                      },
                      tooltip: 'Previous day',
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, size: 20.0),
                      color: secondaryTextColor,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32.0,
                        minHeight: 32.0,
                      ),
                      onPressed: () {
                        state.setSelectedDate(
                          selectedDate.add(const Duration(days: 1)),
                        );
                      },
                      tooltip: 'Next day',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),

          // 3. This Week Strip (M T W T F S S)
          _WeekStrip(
            selectedDate: selectedDate,
            journalEntries: state.journalEntries,
            onSelectDate: (d) => state.setSelectedDate(d),
          ),
          const SizedBox(height: 16.0),

          // 4. Selected Day's Entry Card
          _TodayEntryCard(
            selectedDate: selectedDate,
            entry: selectedEntry,
            onWrite: () async {
              final entry = await state.getOrCreateEntryForDate(selectedDate);
              if (context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => JournalEditorScreen(entryId: entry.id),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 24.0),

          // 5. Previous Entries List
          if (previousEntries.isNotEmpty) ...[
            Text(
              'Previous entries',
              style: HavenTypography.bodyMd(primaryTextColor)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12.0),
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: borderColor, width: 1.0),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: previousEntries.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1.0, color: borderColor),
                itemBuilder: (context, index) {
                  final entry = previousEntries[index];
                  return _PreviousEntryTile(
                    entry: entry,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              JournalEditorScreen(entryId: entry.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  final DateTime selectedDate;
  final List<JournalEntry> journalEntries;
  final ValueChanged<DateTime> onSelectDate;

  const _WeekStrip({
    required this.selectedDate,
    required this.journalEntries,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? HavenColors.darkSurface
        : HavenColors.lightSurface;
    final borderColor = isDark
        ? HavenColors.darkBorder
        : HavenColors.lightBorder;
    final secondaryTextColor = isDark
        ? HavenColors.darkTextSecondary
        : HavenColors.lightTextSecondary;

    // Calculate Monday of the selected date's week
    final daysToMonday = selectedDate.weekday - DateTime.monday;
    final monday = selectedDate.subtract(Duration(days: daysToMonday));
    final weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));

    final dayInitials = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_available_rounded,
                size: 15.0,
                color: secondaryTextColor,
              ),
              const SizedBox(width: 6.0),
              Text(
                'This week',
                style: HavenTypography.caption(secondaryTextColor)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final day = weekDays[i];
              final isSelected =
                  day.year == selectedDate.year &&
                  day.month == selectedDate.month &&
                  day.day == selectedDate.day;

              final dateStr = DateFormat('yyyy-MM-dd').format(day);
              final hasEntry = journalEntries.any(
                (e) =>
                    e.date == dateStr &&
                    (e.title.isNotEmpty || e.body.isNotEmpty),
              );

              final activeBg = isDark ? Colors.white : const Color(0xFF171717);
              final activeText = isDark
                  ? const Color(0xFF171717)
                  : Colors.white;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onSelectDate(day),
                      borderRadius: BorderRadius.circular(12.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? activeBg
                              : (isDark
                                    ? HavenColors.darkCanvas
                                    : HavenColors.lightCanvas),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: isSelected ? activeBg : borderColor,
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              dayInitials[i],
                              style: TextStyle(
                                fontSize: 11.0,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? activeText
                                    : secondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              day.day.toString(),
                              style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? activeText
                                    : (isDark
                                          ? HavenColors.darkTextPrimary
                                          : HavenColors.lightTextPrimary),
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            if (isSelected)
                              Container(
                                width: 5.0,
                                height: 5.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: activeText,
                                ),
                              )
                            else if (hasEntry)
                              Icon(
                                Icons.check,
                                size: 12.0,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF171717),
                              )
                            else
                              const SizedBox(height: 12.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TodayEntryCard extends StatelessWidget {
  final DateTime selectedDate;
  final JournalEntry? entry;
  final VoidCallback onWrite;

  const _TodayEntryCard({
    required this.selectedDate,
    required this.entry,
    required this.onWrite,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? HavenColors.darkSurface
        : HavenColors.lightSurface;
    final borderColor = isDark
        ? HavenColors.darkBorder
        : HavenColors.lightBorder;
    final primaryTextColor = isDark
        ? HavenColors.darkTextPrimary
        : HavenColors.lightTextPrimary;
    final secondaryTextColor = isDark
        ? HavenColors.darkTextSecondary
        : HavenColors.lightTextSecondary;
    final canvasColor = isDark
        ? HavenColors.darkCanvas
        : HavenColors.lightCanvas;

    final hasContent =
        entry != null &&
        (entry!.title.trim().isNotEmpty || entry!.body.trim().isNotEmpty);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TODAY\'S ENTRY',
                style: HavenTypography.caption(secondaryTextColor)
                    .copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.8),
              ),
              if (hasContent)
                Text(
                  'Saved · ${DateFormat('HH:mm').format(entry!.updatedAt)}',
                  style: HavenTypography.caption(secondaryTextColor),
                ),
            ],
          ),
          const SizedBox(height: 12.0),
          if (hasContent) ...[
            if (entry!.title.isNotEmpty)
              Text(
                entry!.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: HavenTypography.bodyMd(primaryTextColor)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            if (entry!.body.isNotEmpty) ...[
              const SizedBox(height: 4.0),
              Text(
                entry!.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: HavenTypography.bodySm(secondaryTextColor)
                    .copyWith(height: 1.4),
              ),
            ],
            const SizedBox(height: 14.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onWrite,
                    icon: const Icon(Icons.edit_outlined, size: 16.0),
                    label: const Text('Continue writing'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTextColor,
                      foregroundColor: canvasColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              'No entry for this day yet.',
              style: HavenTypography.bodyMd(primaryTextColor)
                  .copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Take a quiet moment to write down what happened or what you noticed.',
              style: HavenTypography.bodySm(secondaryTextColor),
            ),
            const SizedBox(height: 14.0),
            ElevatedButton.icon(
              onPressed: onWrite,
              icon: const Icon(Icons.edit_note_rounded, size: 18.0),
              label: const Text('Start writing'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTextColor,
                foregroundColor: canvasColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PreviousEntryTile extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;

  const _PreviousEntryTile({required this.entry, required this.onTap});

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final now = DateTime.now();
      if (now.difference(dt).inDays == 1 ||
          (now.day - dt.day == 1 && now.month == dt.month)) {
        return 'Yesterday, ${DateFormat('d MMM').format(dt)}';
      }
      return DateFormat('EEEE, d MMM').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? HavenColors.darkTextPrimary
        : HavenColors.lightTextPrimary;
    final secondaryTextColor = isDark
        ? HavenColors.darkTextSecondary
        : HavenColors.lightTextSecondary;

    final title = entry.title.trim().isNotEmpty
        ? entry.title.trim()
        : (entry.body.trim().isNotEmpty
              ? entry.body.trim().split('\n').first
              : 'Untitled Entry');

    final body = entry.body.trim().isNotEmpty
        ? (entry.title.trim().isNotEmpty
              ? entry.body.trim()
              : (entry.body.trim().split('\n').length > 1
                    ? entry.body.trim().split('\n').skip(1).join(' ')
                    : ''))
        : '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(entry.date),
                      style: HavenTypography.caption(secondaryTextColor)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: HavenTypography.bodyMd(primaryTextColor)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (body.isNotEmpty) ...[
                      const SizedBox(height: 4.0),
                      Text(
                        body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: HavenTypography.bodySm(secondaryTextColor)
                            .copyWith(height: 1.35),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Icon(
                Icons.chevron_right_rounded,
                size: 20.0,
                color: secondaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
