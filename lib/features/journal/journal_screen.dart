import 'package:flutter/cupertino.dart';
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
    final otherEntries = state.journalEntries
        .where((e) => e.date != state.selectedDateFormatted)
        .toList();

    return RefreshIndicator(
      onRefresh: () => state.loadJournal(),
      color: primaryTextColor,
      backgroundColor: surfaceColor,
      child: ListView(
        key: const PageStorageKey('journal_scroll_list'),
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
                    CupertinoPageRoute(builder: (_) => const PlannerScreen()),
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
          const SizedBox(height: 14.0),

          // 2. Compact iOS-Inspired Monthly Calendar
          _CompactMonthCalendar(
            selectedDate: selectedDate,
            journalEntries: state.journalEntries,
            onSelectDate: (d) => state.setSelectedDate(d),
          ),
          const SizedBox(height: 16.0),

          // 3. Selected Day's Entry Card
          _TodayEntryCard(
            selectedDate: selectedDate,
            entry: selectedEntry,
            onWrite: () async {
              final entry = await state.getOrCreateEntryForDate(selectedDate);
              if (context.mounted) {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => JournalEditorScreen(entryId: entry.id),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 24.0),

          // 4. Other Entries List
          if (otherEntries.isNotEmpty) ...[
            Text(
              'Other entries',
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
                itemCount: otherEntries.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1.0, color: borderColor),
                itemBuilder: (context, index) {
                  final entry = otherEntries[index];
                  return _PreviousEntryTile(
                    entry: entry,
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
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

class _CompactMonthCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final List<JournalEntry> journalEntries;
  final ValueChanged<DateTime> onSelectDate;

  const _CompactMonthCalendar({
    required this.selectedDate,
    required this.journalEntries,
    required this.onSelectDate,
  });

  @override
  State<_CompactMonthCalendar> createState() => _CompactMonthCalendarState();
}

class _CompactMonthCalendarState extends State<_CompactMonthCalendar> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      1,
    );
  }

  @override
  void didUpdateWidget(covariant _CompactMonthCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate.year != widget.selectedDate.year ||
        oldWidget.selectedDate.month != widget.selectedDate.month) {
      _displayedMonth = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        1,
      );
    }
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
        1,
      );
    });
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _displayedMonth = DateTime(now.year, now.month, 1);
    });
    widget.onSelectDate(now);
  }

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

    final now = DateTime.now();
    final isCurrentMonth =
        _displayedMonth.year == now.year && _displayedMonth.month == now.month;

    // Set of entry dates for fast lookup
    final entryDates = <String>{};
    for (final e in widget.journalEntries) {
      if (e.title.trim().isNotEmpty || e.body.trim().isNotEmpty) {
        entryDates.add(e.date);
      }
    }

    // Days in current displayed month
    final firstDayOfMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    );
    final daysInMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    ).day;

    // Monday is 1, Sunday is 7. Offset = firstDayOfMonth.weekday - 1
    final leadingOffset = firstDayOfMonth.weekday - DateTime.monday;
    final prevMonthLastDay = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      0,
    ).day;

    final List<DateTime> calendarDays = [];

    // Leading days from previous month
    for (int i = leadingOffset - 1; i >= 0; i--) {
      calendarDays.add(
        DateTime(
          _displayedMonth.year,
          _displayedMonth.month - 1,
          prevMonthLastDay - i,
        ),
      );
    }

    // Days in current month
    for (int day = 1; day <= daysInMonth; day++) {
      calendarDays.add(
        DateTime(_displayedMonth.year, _displayedMonth.month, day),
      );
    }

    // Trailing days from next month to complete the last row
    final trailingCount = (7 - (calendarDays.length % 7)) % 7;
    for (int day = 1; day <= trailingCount; day++) {
      calendarDays.add(
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, day),
      );
    }

    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Month Header: e.g. "November 2026" with controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(_displayedMonth),
                    style: HavenTypography.labelLg(primaryTextColor).copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (!isCurrentMonth) ...[
                    const SizedBox(width: 8.0),
                    GestureDetector(
                      onTap: _goToToday,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF242424)
                              : const Color(0xFFEEEEEE),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          'Today',
                          style: HavenTypography.caption(primaryTextColor)
                              .copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 10.5,
                              ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, size: 20.0),
                    color: secondaryTextColor,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28.0,
                      minHeight: 28.0,
                    ),
                    onPressed: _previousMonth,
                    tooltip: 'Previous month',
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, size: 20.0),
                    color: secondaryTextColor,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28.0,
                      minHeight: 28.0,
                    ),
                    onPressed: _nextMonth,
                    tooltip: 'Next month',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8.0),

          // Day of week row (M T W T F S S)
          Row(
            children: List.generate(7, (i) {
              return Expanded(
                child: Center(
                  child: Text(
                    dayLabels[i],
                    style: HavenTypography.caption(secondaryTextColor)
                        .copyWith(fontWeight: FontWeight.w500, fontSize: 11.0),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6.0),

          // Grid of days
          ...List.generate((calendarDays.length / 7).ceil(), (rowIndex) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                children: List.generate(7, (colIndex) {
                  final dayIndex = rowIndex * 7 + colIndex;
                  final day = calendarDays[dayIndex];

                  final isCurrentMonthDay = day.month == _displayedMonth.month;
                  final isSelected =
                      day.year == widget.selectedDate.year &&
                      day.month == widget.selectedDate.month &&
                      day.day == widget.selectedDate.day;
                  final isToday =
                      day.year == now.year &&
                      day.month == now.month &&
                      day.day == now.day;

                  final dateStr = DateFormat('yyyy-MM-dd').format(day);
                  final hasEntry = entryDates.contains(dateStr);

                  // Colors & styling
                  final Color cellText;
                  final Color cellBg;
                  final BoxBorder? cellBorder;

                  if (isSelected) {
                    cellBg = isDark ? Colors.white : const Color(0xFF171717);
                    cellText = isDark ? const Color(0xFF171717) : Colors.white;
                    cellBorder = null;
                  } else if (isToday) {
                    cellBg = Colors.transparent;
                    cellText = primaryTextColor;
                    cellBorder = Border.all(
                      color: isDark
                          ? const Color(0xFF555555)
                          : const Color(0xFFB0B0B0),
                      width: 1.0,
                    );
                  } else {
                    cellBg = Colors.transparent;
                    cellText = isCurrentMonthDay
                        ? primaryTextColor
                        : secondaryTextColor.withValues(alpha: 0.35);
                    cellBorder = null;
                  }

                  return Expanded(
                    child: Center(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (day.month != _displayedMonth.month) {
                              setState(() {
                                _displayedMonth = DateTime(
                                  day.year,
                                  day.month,
                                  1,
                                );
                              });
                            }
                            widget.onSelectDate(day);
                          },
                          borderRadius: BorderRadius.circular(16.0),
                          child: Container(
                            width: 32.0,
                            height: 32.0,
                            decoration: BoxDecoration(
                              color: cellBg,
                              shape: BoxShape.circle,
                              border: cellBorder,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isSelected || isToday
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: cellText,
                                  ),
                                ),
                                if (hasEntry)
                                  Positioned(
                                    bottom: 3.0,
                                    child: Container(
                                      width: 3.5,
                                      height: 3.5,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? cellText
                                            : (isDark
                                                  ? const Color(0xFFE0E0E0)
                                                  : const Color(0xFF202020)),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
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

    final now = DateTime.now();
    final isToday =
        selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

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
                isToday
                    ? 'TODAY\'S ENTRY'
                    : 'ENTRY FOR ${DateFormat('d MMMM').format(selectedDate).toUpperCase()}',
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
              isToday
                  ? 'Nothing written for today.'
                  : 'Nothing written for this date.',
              style: HavenTypography.bodyMd(primaryTextColor)
                  .copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Take a moment to write if you feel like it.',
              style: HavenTypography.bodySm(secondaryTextColor),
            ),
            const SizedBox(height: 14.0),
            ElevatedButton.icon(
              onPressed: onWrite,
              icon: const Icon(Icons.edit_note_rounded, size: 18.0),
              label: Text(
                isToday
                    ? 'Start writing'
                    : 'Write for ${DateFormat('d MMM').format(selectedDate)}',
              ),
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
