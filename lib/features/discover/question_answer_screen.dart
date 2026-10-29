import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/haven_state.dart';
import '../../core/models/question_model.dart';
import '../../core/theme/haven_colors.dart';
import '../../core/theme/haven_typography.dart';
import '../../core/widgets/haven_responsive_container.dart';

class QuestionAnswerScreen extends StatefulWidget {
  final Question question;
  final String source; // 'daily', 'random', 'category'

  const QuestionAnswerScreen({
    super.key,
    required this.question,
    this.source = 'daily',
  });

  @override
  State<QuestionAnswerScreen> createState() => _QuestionAnswerScreenState();
}

class _QuestionAnswerScreenState extends State<QuestionAnswerScreen> {
  late TextEditingController _answerController;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _answerController = TextEditingController();
    _loadExistingAnswer();
  }

  void _loadExistingAnswer() async {
    final state = context.read<HavenState>();
    final responses = await state.getResponsesForQuestion(widget.question.id);
    if (responses.isNotEmpty && mounted) {
      _answerController.text = responses.first.answerText;
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _submitAnswer() async {
    final text = _answerController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final state = context.read<HavenState>();
    final success = await state.answerQuestion(
      widget.question,
      text,
      source: widget.source,
    );

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Answer saved quietly to your Haven'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } else {
      setState(() {
        _errorMessage = 'Daily allowance reached (10 random responses per day). Come back tomorrow for fresh prompts.';
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
    final surfaceColor = isDark
        ? HavenColors.darkSurface
        : HavenColors.lightSurface;
    final borderColor = isDark
        ? HavenColors.darkBorder
        : HavenColors.lightBorder;
    final canvasColor = isDark
        ? HavenColors.darkCanvas
        : HavenColors.lightCanvas;

    final state = context.watch<HavenState>();

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, size: 24.0),
                      color: primaryTextColor,
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Back',
                    ),
                    if (widget.source == 'random')
                      Text(
                        '${state.remainingRandomAllowance} left today',
                        style: HavenTypography.caption(secondaryTextColor),
                      ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  children: [
                    // Category Tag
                    Text(
                      widget.question.category.toUpperCase(),
                      style: HavenTypography.caption(secondaryTextColor)
                          .copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                    ),
                    const SizedBox(height: 12.0),

                    // Question Text
                    Text(
                      widget.question.text,
                      style: HavenTypography.headlineMd(primaryTextColor)
                          .copyWith(fontWeight: FontWeight.w600, height: 1.35),
                    ),
                    const SizedBox(height: 24.0),

                    // Answer Box
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: borderColor, width: 1.0),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _answerController,
                        maxLines: 8,
                        style: HavenTypography.bodyMd(primaryTextColor)
                            .copyWith(height: 1.6),
                        cursorColor: primaryTextColor,
                        decoration: InputDecoration(
                          hintText: 'Write your thoughts here...',
                          hintStyle: HavenTypography.bodyMd(secondaryTextColor),
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12.0),
                      Text(
                        _errorMessage!,
                        style: HavenTypography.bodySm(HavenColors.error),
                      ),
                    ],

                    const SizedBox(height: 24.0),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _submitAnswer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryTextColor,
                              foregroundColor: canvasColor,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                vertical: 14.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 18.0,
                                    height: 18.0,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                    ),
                                  )
                                : Text(
                                    'Save reflection',
                                    style: HavenTypography.labelMd(canvasColor)
                                        .copyWith(fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),
                      ],
                    ),

                    if (widget.source == 'random') ...[
                      const SizedBox(height: 12.0),
                      Center(
                        child: TextButton(
                          onPressed: () async {
                            await state.nextRandomQuestion();
                            if (context.mounted &&
                                state.randomQuestion != null) {
                              Navigator.of(context).pushReplacement(
                                CupertinoPageRoute(
                                  builder: (_) => QuestionAnswerScreen(
                                    question: state.randomQuestion!,
                                    source: 'random',
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            'Skip to next question',
                            style: HavenTypography.labelSm(secondaryTextColor),
                          ),
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
