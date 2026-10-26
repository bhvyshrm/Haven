import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/haven_state.dart';
import '../../core/models/template_model.dart';
import '../../core/theme/haven_colors.dart';
import '../../core/theme/haven_typography.dart';
import '../../core/widgets/haven_pill_chip.dart';
import '../../core/widgets/haven_responsive_container.dart';
import '../notes/note_editor_screen.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Personal',
    'People',
    'College',
    'School',
    'Interests',
    'Routines',
    'Books & Movies',
    'Ideas',
  ];

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

    final filtered = state.templates.where((t) {
      final matchesCategory =
          _selectedCategory == 'All' ||
          t.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch =
          _searchQuery.isEmpty ||
          t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

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
                      'Templates Library',
                      style: HavenTypography.headlineSm(primaryTextColor)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 8.0,
                ),
                child: Container(
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: borderColor, width: 1.0),
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: HavenTypography.bodySm(primaryTextColor),
                    cursorColor: primaryTextColor,
                    decoration: InputDecoration(
                      hintText: 'Search templates',
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

              // Category Pills
              SizedBox(
                height: 38.0,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8.0),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat;
                    return HavenPillChip(
                      label: cat,
                      isSelected: isSelected,
                      onTap: () => setState(() => _selectedCategory = cat),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16.0),

              // Templates List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    bottom: 40.0,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12.0),
                  itemBuilder: (context, index) {
                    final tpl = filtered[index];
                    return _TemplateCard(
                      template: tpl,
                      onUse: () => _useTemplate(context, tpl),
                      onPreview: () => _showPreview(context, tpl),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPreview(BuildContext context, HavenTemplate tpl) {
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          constraints: const BoxConstraints(maxWidth: 540.0),
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tpl.category.toUpperCase(),
                    style: HavenTypography.caption(
                      secondaryTextColor,
                    ).copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.8),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20.0),
                    onPressed: () => Navigator.pop(sheetContext),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                tpl.title,
                style: HavenTypography.headlineSm(primaryTextColor)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4.0),
              Text(
                tpl.description,
                style: HavenTypography.bodySm(secondaryTextColor),
              ),
              const SizedBox(height: 16.0),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 240.0),
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: isDark
                      ? HavenColors.darkCanvas
                      : HavenColors.lightCanvas,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: borderColor, width: 1.0),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    tpl.content,
                    style: HavenTypography.bodySm(primaryTextColor)
                        .copyWith(fontFamily: 'monospace', height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _useTemplate(context, tpl);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTextColor,
                    foregroundColor: canvasColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    'Use this template',
                    style: HavenTypography.labelMd(canvasColor)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _useTemplate(BuildContext context, HavenTemplate tpl) async {
    final state = context.read<HavenState>();
    final newNote = await state.useTemplate(tpl);
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => NoteEditorScreen(noteId: newNote.id)),
      );
    }
  }
}

class _TemplateCard extends StatelessWidget {
  final HavenTemplate template;
  final VoidCallback onUse;
  final VoidCallback onPreview;

  const _TemplateCard({
    required this.template,
    required this.onUse,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPreview,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.category.toUpperCase(),
                      style: HavenTypography.caption(secondaryTextColor)
                          .copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      template.title,
                      style: HavenTypography.bodyMd(primaryTextColor)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      template.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: HavenTypography.bodySm(secondaryTextColor)
                          .copyWith(height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              ElevatedButton(
                onPressed: onUse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? HavenColors.darkCanvas
                      : HavenColors.lightCanvas,
                  foregroundColor: primaryTextColor,
                  elevation: 0,
                  side: BorderSide(color: borderColor, width: 1.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  'Use',
                  style: HavenTypography.labelSm(primaryTextColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
