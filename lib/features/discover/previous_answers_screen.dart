import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/state/haven_state.dart';
import '../../core/models/question_model.dart';
import '../../core/theme/haven_colors.dart';
import '../../core/theme/haven_typography.dart';
import '../../core/widgets/haven_empty_state.dart';
import '../../core/widgets/haven_responsive_container.dart';

class PreviousAnswersScreen extends StatefulWidget {
  const PreviousAnswersScreen({super.key});

  @override
  State<PreviousAnswersScreen> createState() => _PreviousAnswersScreenState();
}

class _PreviousAnswersScreenState extends State<PreviousAnswersScreen> {
  List<QuestionResponse> _responses = [];
  Map<String, Question> _questionsMap = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final state = context.read<HavenState>();
    final responses = await state.getAllResponses();
    final allQuestions = state.dailyQuestion != null
        ? [state.dailyQuestion!]
        : <Question>[];

    final Map<String, Question> qMap = {for (var q in allQuestions) q.id: q};

    if (mounted) {
      setState(() {
        _responses = responses;
        _questionsMap = qMap;
        _loading = false;
      });
    }
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy').format(dt);
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
            children: [
              // Header
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
                      'Previous Answers',
                      style: HavenTypography.headlineSm(primaryTextColor)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              // Answers List
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _responses.isEmpty
                    ? const HavenEmptyState(
                        icon: Icons.history_edu_rounded,
                        title: 'No answers yet',
                        description: 'Reflections you answer will appear here in chronological order.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 16.0,
                        ),
                        itemCount: _responses.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 14.0),
                        itemBuilder: (context, index) {
                          final resp = _responses[index];
                          final question = _questionsMap[resp.questionId];

                          return Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color: borderColor,
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      (question?.category ?? 'REFLECTION')
                                          .toUpperCase(),
                                      style:
                                          HavenTypography.caption(
                                            secondaryTextColor,
                                          ).copyWith(
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.8,
                                          ),
                                    ),
                                    Text(
                                      _formatDate(resp.responseDate),
                                      style: HavenTypography.caption(
                                        secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                                if (question != null) ...[
                                  const SizedBox(height: 8.0),
                                  Text(
                                    question.text,
                                    style: HavenTypography.bodyMd(
                                      primaryTextColor,
                                    ).copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                                const SizedBox(height: 10.0),
                                Text(
                                  resp.answerText,
                                  style: HavenTypography.bodySm(
                                    secondaryTextColor,
                                  ).copyWith(height: 1.5),
                                ),
                              ],
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
