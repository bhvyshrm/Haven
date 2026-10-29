import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/state/haven_state.dart';
import '../../core/models/note_model.dart';
import '../../core/theme/haven_colors.dart';
import '../../core/theme/haven_typography.dart';
import '../../core/widgets/haven_empty_state.dart';
import '../../core/widgets/haven_header.dart';
import '../notes/note_editor_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

    final recentNotes = state.notes.take(6).toList();

    return Column(
      children: [
        HavenHeader(
          isHome: true,
          showBottomDivider: false,
          useSafeArea: false,
          trailing: IconButton(
            icon: Icon(
              Icons.settings_outlined,
              size: 21.0,
              color: secondaryTextColor,
            ),
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => state.loadNotes(),
            color: primaryTextColor,
            backgroundColor: isDark
                ? HavenColors.darkSurface
                : HavenColors.lightCanvas,
            child: ListView(
              key: const PageStorageKey('home_scroll_list'),
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 16.0,
                bottom: 120.0,
              ),
              children: [
                // Section Heading
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Recently saved',
                      style: HavenTypography.headlineSm(primaryTextColor)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (state.notes.isNotEmpty)
                      TextButton(
                        onPressed: () =>
                            state.setTabIndex(2), // Switch to Notes tab
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'See all',
                          style: HavenTypography.labelSm(secondaryTextColor),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16.0),

                // Content: Notes Grid or Empty State
                if (recentNotes.isEmpty)
                  HavenEmptyState(
                    icon: Icons.edit_note_rounded,
                    title: 'No notes yet',
                    description: 'Your saved notes will appear here.',
                    actionLabel: '+ Create a note',
                    onAction: () async {
                      final note = await state.createNewNote();
                      if (context.mounted) {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => NoteEditorScreen(noteId: note.id),
                          ),
                        );
                      }
                    },
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14.0,
                          mainAxisSpacing: 14.0,
                          childAspectRatio: 0.96,
                        ),
                    itemCount: recentNotes.length,
                    itemBuilder: (context, index) {
                      final note = recentNotes[index];
                      return _HomeNoteCard(
                        note: note,
                        onTap: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (_) => NoteEditorScreen(noteId: note.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeNoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const _HomeNoteCard({required this.note, required this.onTap});

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0 && now.day == dt.day) {
      return 'Today';
    } else if (diff.inDays <= 1 ||
        (now.day - dt.day == 1 && diff.inHours < 48)) {
      return 'Yesterday';
    } else {
      return DateFormat('d MMM').format(dt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = HavenColors.getColorById(note.colorId, isAppDark: isDark);

    final cardBg = note.colorId != null
        ? palette.color
        : (isDark ? HavenColors.darkSurface : HavenColors.lightSurfaceSubtle);
    final cardBorder = isDark
        ? HavenColors.darkBorder
        : HavenColors.lightBorder;
    final textPrimary = note.colorId != null
        ? palette.textColor
        : (isDark ? HavenColors.darkTextPrimary : HavenColors.lightTextPrimary);
    final textSecondary = note.colorId != null
        ? palette.secondaryColor
        : (isDark
              ? HavenColors.darkTextSecondary
              : HavenColors.lightTextSecondary);

    final titleText = note.title.trim().isNotEmpty
        ? note.title.trim()
        : (note.body.trim().isNotEmpty
              ? note.body.trim().split('\n').first
              : 'Untitled Note');

    final bodyPreview = note.body.trim().isNotEmpty
        ? (note.title.trim().isNotEmpty
              ? note.body.trim()
              : (note.body.trim().split('\n').length > 1
                    ? note.body.trim().split('\n').skip(1).join(' ')
                    : ''))
        : '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: cardBorder, width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top tag & relative date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    note.category.toUpperCase(),
                    style: HavenTypography.caption(textSecondary).copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      fontSize: 10.0,
                    ),
                  ),
                  Text(
                    _formatDate(note.updatedAt),
                    style: HavenTypography.caption(textSecondary)
                        .copyWith(fontSize: 11.0),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),

              // Title
              Text(
                titleText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: HavenTypography.bodyMd(textPrimary)
                    .copyWith(fontWeight: FontWeight.w600, height: 1.3),
              ),

              // Body preview
              if (bodyPreview.isNotEmpty) ...[
                const SizedBox(height: 4.0),
                Expanded(
                  child: Text(
                    bodyPreview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: HavenTypography.bodySm(textSecondary)
                        .copyWith(height: 1.35),
                  ),
                ),
              ] else
                const Spacer(),

              // Bottom arrow
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 18.0,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
