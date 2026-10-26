import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/state/haven_state.dart';
import '../../core/models/note_model.dart';
import '../../core/theme/haven_colors.dart';
import '../../core/theme/haven_typography.dart';
import '../../core/widgets/haven_empty_state.dart';
import '../../core/widgets/haven_pill_chip.dart';
import '../templates/templates_screen.dart';
import 'note_editor_screen.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

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
    final surfaceColor = isDark
        ? HavenColors.darkSurface
        : HavenColors.lightSurface;
    final borderColor = isDark
        ? HavenColors.darkBorder
        : HavenColors.lightBorder;

    final categories = ['All', 'Personal', 'People', 'Ideas', 'Other'];
    final notes = state.filteredNotes;

    return RefreshIndicator(
      onRefresh: () => state.loadNotes(),
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
          // 1. Heading & Explore Templates
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Notes',
                style: HavenTypography.headlineLg(primaryTextColor),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TemplatesScreen()),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4.0,
                    vertical: 4.0,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Explore templates',
                  style: HavenTypography.labelSm(secondaryTextColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // 2. Search & New Note Row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: borderColor, width: 1.0),
                  ),
                  child: TextField(
                    onChanged: (val) => state.setSearchQuery(val),
                    style: HavenTypography.bodySm(primaryTextColor),
                    cursorColor: primaryTextColor,
                    decoration: InputDecoration(
                      hintText: 'Search your notes',
                      hintStyle: HavenTypography.bodySm(secondaryTextColor),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 20.0,
                        color: secondaryTextColor,
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 40.0,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: () async {
                  final newNote = await state.createNewNote(
                    category: state.selectedCategory != 'All'
                        ? state.selectedCategory
                        : 'Personal',
                  );
                  if (context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => NoteEditorScreen(noteId: newNote.id),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTextColor,
                  foregroundColor: canvasColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  '+ New note',
                  style: HavenTypography.labelMd(canvasColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // 3. Category Filter Pills
          SizedBox(
            height: 36.0,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8.0),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = state.selectedCategory == cat;
                return HavenPillChip(
                  label: cat,
                  isSelected: isSelected,
                  onTap: () => state.setSelectedCategory(cat),
                );
              },
            ),
          ),
          const SizedBox(height: 20.0),

          // 4. Notes Grid or Empty State
          if (notes.isEmpty) ...[
            if (state.searchQuery.isNotEmpty)
              HavenEmptyState(
                icon: Icons.search_off_rounded,
                title: 'No results found',
                description:
                    'No notes match "${state.searchQuery}". Try a different keyword.',
              )
            else if (state.selectedCategory != 'All')
              HavenEmptyState(
                icon: Icons.folder_open_rounded,
                title: 'No ${state.selectedCategory} notes',
                description:
                    'You have not added any notes under ${state.selectedCategory} yet.',
                actionLabel: '+ Add ${state.selectedCategory} note',
                onAction: () async {
                  final newNote = await state.createNewNote(
                    category: state.selectedCategory,
                  );
                  if (context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => NoteEditorScreen(noteId: newNote.id),
                      ),
                    );
                  }
                },
              )
            else
              HavenEmptyState(
                icon: Icons.edit_note_rounded,
                title: 'No notes yet',
                description: 'Your notes library is empty. Start writing your first note.',
                actionLabel: '+ Create a note',
                onAction: () async {
                  final newNote = await state.createNewNote();
                  if (context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => NoteEditorScreen(noteId: newNote.id),
                      ),
                    );
                  }
                },
              ),
          ] else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 1.05,
              ),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return _NoteLibraryCard(
                  note: note,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => NoteEditorScreen(noteId: note.id),
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class _NoteLibraryCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const _NoteLibraryCard({required this.note, required this.onTap});

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
        : (isDark ? HavenColors.darkSurface : HavenColors.lightSurface);
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.category.toUpperCase(),
                    style: HavenTypography.caption(textSecondary).copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      fontSize: 10.0,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    titleText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: HavenTypography.bodyMd(textPrimary)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (bodyPreview.isNotEmpty) ...[
                    const SizedBox(height: 4.0),
                    Text(
                      bodyPreview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: HavenTypography.caption(textSecondary)
                          .copyWith(height: 1.35),
                    ),
                  ],
                ],
              ),
              Container(
                padding: const EdgeInsets.only(top: 6.0),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: cardBorder.withValues(alpha: 0.6),
                      width: 1.0,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(note.updatedAt),
                      style: HavenTypography.caption(textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
