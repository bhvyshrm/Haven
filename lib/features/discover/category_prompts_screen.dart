import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/haven_state.dart';
import '../../core/models/question_model.dart';
import '../../core/theme/haven_colors.dart';
import '../../core/theme/haven_typography.dart';
import '../../core/widgets/haven_responsive_container.dart';
import '../notes/note_editor_screen.dart';
import '../people/people_screen.dart';
import 'question_answer_screen.dart';

class CategoryPromptsScreen extends StatefulWidget {
  final String category;
  final String description;
  final List<String> dbCategories;
  final bool isPeopleShortcut;

  const CategoryPromptsScreen({
    super.key,
    required this.category,
    required this.description,
    this.dbCategories = const [],
    this.isPeopleShortcut = false,
  });

  @override
  State<CategoryPromptsScreen> createState() => _CategoryPromptsScreenState();
}

class _CategoryPromptsScreenState extends State<CategoryPromptsScreen> {
  List<Question> _questions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final state = context.read<HavenState>();
    final categoriesToSearch = widget.dbCategories.isNotEmpty
        ? widget.dbCategories
        : [widget.category];

    final Set<String> questionIds = {};
    final List<Question> collectedQuestions = [];

    for (final cat in categoriesToSearch) {
      final qs = await state.getQuestions(category: cat);
      for (final q in qs) {
        if (!questionIds.contains(q.id)) {
          questionIds.add(q.id);
          collectedQuestions.add(q);
        }
      }
    }

    if (mounted) {
      setState(() {
        _questions = collectedQuestions;
        _loading = false;
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

    final categoriesToMatch = widget.dbCategories.isNotEmpty
        ? widget.dbCategories.map((c) => c.toLowerCase()).toSet()
        : {widget.category.toLowerCase()};

    final matchingTemplates = state.templates.where((t) {
      return categoriesToMatch.contains(t.category.toLowerCase());
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
                    Expanded(
                      child: Text(
                        widget.category,
                        style: HavenTypography.headlineSm(primaryTextColor)
                            .copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 4.0,
                ),
                child: Text(
                  widget.description,
                  style: HavenTypography.bodySm(secondaryTextColor),
                ),
              ),
              const SizedBox(height: 12.0),

              Expanded(
                child: _loading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: primaryTextColor,
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 12.0,
                        ),
                        children: [
                          // People shortcut button if applicable
                          if (widget.isPeopleShortcut) ...[
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (_) => const PeopleScreen(),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16.0),
                                child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: surfaceColor,
                                    borderRadius: BorderRadius.circular(16.0),
                                    border: Border.all(
                                      color: borderColor,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.group_rounded,
                                        size: 22.0,
                                        color: primaryTextColor,
                                      ),
                                      const SizedBox(width: 14.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'People Archive',
                                              style:
                                                  HavenTypography.bodyMd(
                                                    primaryTextColor,
                                                  ).copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            const SizedBox(height: 2.0),
                                            Text(
                                              'Browse and manage remembered people',
                                              style: HavenTypography.caption(
                                                secondaryTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        size: 20.0,
                                        color: secondaryTextColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                          ],

                          // Templates Section
                          if (matchingTemplates.isNotEmpty) ...[
                            Text(
                              'WRITING TEMPLATES',
                              style: HavenTypography.caption(secondaryTextColor)
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.8,
                                  ),
                            ),
                            const SizedBox(height: 8.0),
                            Container(
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  color: borderColor,
                                  width: 1.0,
                                ),
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: matchingTemplates.length,
                                separatorBuilder: (context, index) =>
                                    Divider(height: 1.0, color: borderColor),
                                itemBuilder: (context, index) {
                                  final tpl = matchingTemplates[index];
                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () async {
                                        final newNote = await state.useTemplate(
                                          tpl,
                                        );
                                        if (context.mounted) {
                                          Navigator.of(context).push(
                                            CupertinoPageRoute(
                                              builder: (_) => NoteEditorScreen(
                                                noteId: newNote.id,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    tpl.title,
                                                    style:
                                                        HavenTypography.bodyMd(
                                                          primaryTextColor,
                                                        ).copyWith(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                  if (tpl
                                                      .description
                                                      .isNotEmpty) ...[
                                                    const SizedBox(height: 3.0),
                                                    Text(
                                                      tpl.description,
                                                      style:
                                                          HavenTypography.bodySm(
                                                            secondaryTextColor,
                                                          ),
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
                                },
                              ),
                            ),
                            const SizedBox(height: 24.0),
                          ],

                          // Questions / Prompts Section
                          if (_questions.isNotEmpty) ...[
                            Text(
                              'GUIDED QUESTIONS',
                              style: HavenTypography.caption(secondaryTextColor)
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.8,
                                  ),
                            ),
                            const SizedBox(height: 8.0),
                            Container(
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  color: borderColor,
                                  width: 1.0,
                                ),
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _questions.length,
                                separatorBuilder: (context, index) =>
                                    Divider(height: 1.0, color: borderColor),
                                itemBuilder: (context, index) {
                                  final q = _questions[index];
                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          CupertinoPageRoute(
                                            builder: (_) =>
                                                QuestionAnswerScreen(
                                                  question: q,
                                                  source: 'category',
                                                ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                q.text,
                                                style:
                                                    HavenTypography.bodyMd(
                                                      primaryTextColor,
                                                    ).copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      height: 1.35,
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 12.0),
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
                                },
                              ),
                            ),
                          ],
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
