import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/haven_state.dart';
import '../../core/models/question_model.dart';
import '../../core/theme/haven_colors.dart';
import '../../core/theme/haven_typography.dart';
import '../../core/widgets/haven_responsive_container.dart';
import 'question_answer_screen.dart';

class CategoryPromptsScreen extends StatefulWidget {
  final String category; // 'My Story', 'My Interests', 'My Future'
  final String description;

  const CategoryPromptsScreen({
    super.key,
    required this.category,
    required this.description,
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
    _loadCategoryQuestions();
  }

  Future<void> _loadCategoryQuestions() async {
    final state = context.read<HavenState>();
    final all = await state.getQuestions(category: widget.category);
    if (mounted) {
      setState(() {
        _questions = all;
        _loading = false;
      });
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
                      widget.category,
                      style: HavenTypography.headlineSm(primaryTextColor)
                          .copyWith(fontWeight: FontWeight.w600),
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
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 12.0,
                        ),
                        itemCount: _questions.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12.0),
                        itemBuilder: (context, index) {
                          final q = _questions[index];
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => QuestionAnswerScreen(
                                      question: q,
                                      source: 'category',
                                    ),
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
                                    Expanded(
                                      child: Text(
                                        q.text,
                                        style:
                                            HavenTypography.bodyMd(
                                              primaryTextColor,
                                            ).copyWith(
                                              fontWeight: FontWeight.w500,
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
          ),
        ),
      ),
    );
  }
}
