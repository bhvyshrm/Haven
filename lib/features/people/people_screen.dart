import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/state/haven_state.dart';
import '../../core/models/person_model.dart';
import '../../core/theme/haven_colors.dart';
import '../../core/theme/haven_typography.dart';
import '../../core/widgets/haven_empty_state.dart';
import '../../core/widgets/haven_responsive_container.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  String _searchQuery = '';

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

    final filteredPeople = state.people.where((p) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(q) ||
          p.relationship.toLowerCase().contains(q) ||
          p.notes.toLowerCase().contains(q);
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            size: 24.0,
                          ),
                          color: primaryTextColor,
                          onPressed: () => Navigator.pop(context),
                          tooltip: 'Back',
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          'My People',
                          style: HavenTypography.headlineSm(primaryTextColor)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _openPersonDialog(context),
                      icon: const Icon(Icons.add, size: 16.0),
                      label: const Text('Add person'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTextColor,
                        foregroundColor: canvasColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 8.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search input
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 6.0,
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
                      hintText: 'Search people or memories',
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
              const SizedBox(height: 8.0),

              Expanded(
                child: filteredPeople.isEmpty
                    ? HavenEmptyState(
                        icon: Icons.group_outlined,
                        title: 'No people recorded yet',
                        description: 'A private directory for friends, mentors, family, and conversations worth keeping.',
                        actionLabel: '+ Add a person',
                        onAction: () => _openPersonDialog(context),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 12.0,
                        ),
                        itemCount: filteredPeople.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12.0),
                        itemBuilder: (context, index) {
                          final person = filteredPeople[index];
                          return _PersonTile(
                            person: person,
                            onTap: () =>
                                _openPersonDialog(context, person: person),
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

  void _openPersonDialog(BuildContext context, {Person? person}) {
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
    final canvasColor = isDark
        ? HavenColors.darkCanvas
        : HavenColors.lightCanvas;

    final nameController = TextEditingController(text: person?.name ?? '');
    final relController = TextEditingController(
      text: person?.relationship ?? 'Friend',
    );
    final notesController = TextEditingController(text: person?.notes ?? '');
    final datesController = TextEditingController(
      text: person?.importantDates ?? '',
    );

    showDialog(
      context: context,
      builder: (dlgContext) {
        return AlertDialog(
          backgroundColor: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(color: borderColor, width: 1.0),
          ),
          title: Text(
            person == null ? 'Add to My People' : 'Edit Person',
            style: HavenTypography.headlineSm(primaryTextColor)
                .copyWith(fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: HavenTypography.bodyMd(primaryTextColor),
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    labelStyle: HavenTypography.bodySm(secondaryTextColor),
                  ),
                ),
                const SizedBox(height: 12.0),
                TextField(
                  controller: relController,
                  style: HavenTypography.bodyMd(primaryTextColor),
                  decoration: InputDecoration(
                    labelText: 'Relationship (e.g. Friend, Family, Mentor)',
                    labelStyle: HavenTypography.bodySm(secondaryTextColor),
                  ),
                ),
                const SizedBox(height: 12.0),
                TextField(
                  controller: datesController,
                  style: HavenTypography.bodyMd(primaryTextColor),
                  decoration: InputDecoration(
                    labelText: 'Important dates / Birthdays',
                    labelStyle: HavenTypography.bodySm(secondaryTextColor),
                  ),
                ),
                const SizedBox(height: 12.0),
                TextField(
                  controller: notesController,
                  maxLines: 4,
                  style: HavenTypography.bodyMd(primaryTextColor),
                  decoration: InputDecoration(
                    labelText: 'Memories, shared conversations, details',
                    labelStyle: HavenTypography.bodySm(secondaryTextColor),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            if (person != null)
              TextButton(
                onPressed: () async {
                  Navigator.pop(dlgContext);
                  await context.read<HavenState>().deletePerson(person.id);
                },
                child: Text(
                  'Delete',
                  style: HavenTypography.labelMd(HavenColors.error),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pop(dlgContext),
              child: Text(
                'Cancel',
                style: HavenTypography.labelMd(secondaryTextColor),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                final p = Person(
                  id: person?.id ?? const Uuid().v4(),
                  name: name,
                  relationship: relController.text.trim().isNotEmpty
                      ? relController.text.trim()
                      : 'Friend',
                  notes: notesController.text.trim(),
                  importantDates: datesController.text.trim(),
                  createdAt: person?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                await context.read<HavenState>().savePerson(p);
                if (dlgContext.mounted) {
                  Navigator.pop(dlgContext);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTextColor,
                foregroundColor: canvasColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text('Save', style: HavenTypography.labelMd(canvasColor)),
            ),
          ],
        );
      },
    );
  }
}

class _PersonTile extends StatelessWidget {
  final Person person;
  final VoidCallback onTap;

  const _PersonTile({required this.person, required this.onTap});

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
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
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
                    person.name,
                    style: HavenTypography.bodyMd(primaryTextColor)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? HavenColors.darkCanvas
                          : HavenColors.lightCanvas,
                      borderRadius: BorderRadius.circular(999.0),
                      border: Border.all(color: borderColor, width: 1.0),
                    ),
                    child: Text(
                      person.relationship,
                      style: HavenTypography.caption(
                        secondaryTextColor,
                      ).copyWith(fontSize: 10.0, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              if (person.importantDates.isNotEmpty) ...[
                const SizedBox(height: 6.0),
                Row(
                  children: [
                    Icon(
                      Icons.cake_outlined,
                      size: 14.0,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      person.importantDates,
                      style: HavenTypography.caption(secondaryTextColor),
                    ),
                  ],
                ),
              ],
              if (person.notes.isNotEmpty) ...[
                const SizedBox(height: 8.0),
                Text(
                  person.notes,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: HavenTypography.bodySm(secondaryTextColor)
                      .copyWith(height: 1.4),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
