import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/haven_state.dart';
import '../../core/models/template_model.dart';
import '../../core/theme/haven_colors.dart';
import '../../core/theme/haven_typography.dart';
import '../templates/templates_screen.dart';
import '../people/people_screen.dart';
import '../notes/note_editor_screen.dart';
import 'question_answer_screen.dart';
import 'previous_answers_screen.dart';
import 'category_prompts_screen.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

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

    final dailyQuestion = state.dailyQuestion;
    final dailyResponse = state.todayDailyResponse;
    final previewTemplates = state.templates.take(5).toList();

    return RefreshIndicator(
      onRefresh: () => state.loadDiscover(),
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
          // 1. Heading
          Text('Discover', style: HavenTypography.headlineLg(primaryTextColor)),
          const SizedBox(height: 16.0),

          // 2. DAILY REFLECTION CARD
          Text(
            'DAILY REFLECTION',
            style: HavenTypography.caption(secondaryTextColor)
                .copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.8),
          ),
          const SizedBox(height: 8.0),
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: borderColor, width: 1.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dailyQuestion?.text ??
                      'What is something small that made today better?',
                  style: HavenTypography.headlineSm(primaryTextColor)
                      .copyWith(fontWeight: FontWeight.w600, height: 1.35),
                ),
                if (dailyResponse != null) ...[
                  const SizedBox(height: 8.0),
                  Text(
                    'Your answer: "${dailyResponse.answerText}"',
                    style: HavenTypography.bodySm(secondaryTextColor)
                        .copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
                const SizedBox(height: 16.0),
                Divider(height: 1.0, color: borderColor),
                const SizedBox(height: 12.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        if (dailyQuestion != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => QuestionAnswerScreen(
                                question: dailyQuestion,
                                source: 'daily',
                              ),
                            ),
                          );
                        }
                      },
                      icon: Text(
                        dailyResponse != null
                            ? 'Edit reflection'
                            : 'Answer question',
                        style: HavenTypography.labelSm(primaryTextColor)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      label: Icon(
                        Icons.chevron_right_rounded,
                        size: 18.0,
                        color: secondaryTextColor,
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PreviousAnswersScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Previous answers',
                        style: HavenTypography.labelSm(secondaryTextColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28.0),

          // 3. GET TO KNOW YOURSELF (2x2 Grid)
          Text(
            'Get to know yourself',
            style: HavenTypography.headlineSm(primaryTextColor)
                .copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Keep the little details that make you, you.',
            style: HavenTypography.bodySm(secondaryTextColor),
          ),
          const SizedBox(height: 12.0),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.25,
            children: [
              _SelfCard(
                title: 'My Story',
                description: 'Your life, memories, and journey.',
                icon: Icons.menu_book_rounded,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CategoryPromptsScreen(
                        category: 'My Story',
                        description: 'Quiet prompts about formative chapters, memories, and turning points.',
                      ),
                    ),
                  );
                },
              ),
              _SelfCard(
                title: 'My People',
                description: 'The people who are part of your story.',
                icon: Icons.group_rounded,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PeopleScreen()),
                  );
                },
              ),
              _SelfCard(
                title: 'My Interests',
                description: 'Things you love and want to explore.',
                icon: Icons.favorite_border_rounded,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CategoryPromptsScreen(
                        category: 'My Interests',
                        description: 'Questions exploring your crafts, curiosities, books, and deep focus.',
                      ),
                    ),
                  );
                },
              ),
              _SelfCard(
                title: 'My Future',
                description: 'Your hopes, goals, and possibilities.',
                icon: Icons.north_east_rounded,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CategoryPromptsScreen(
                        category: 'My Future',
                        description: 'Reflections on seasonal direction, horizons, boundaries, and growth.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 28.0),

          // 4. TEMPLATES SECTION (Horizontal Carousel)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Templates',
                style: HavenTypography.headlineSm(primaryTextColor)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TemplatesScreen()),
                  );
                },
                child: Text(
                  'See all',
                  style: HavenTypography.labelSm(secondaryTextColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2.0),
          Text(
            'Ready-made pages for the things you want to remember.',
            style: HavenTypography.bodySm(secondaryTextColor),
          ),
          const SizedBox(height: 12.0),
          SizedBox(
            height: 130.0,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: previewTemplates.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12.0),
              itemBuilder: (context, index) {
                final tpl = previewTemplates[index];
                return _TemplateCarouselCard(
                  template: tpl,
                  onTap: () async {
                    final newNote = await state.useTemplate(tpl);
                    if (context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => NoteEditorScreen(noteId: newNote.id),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24.0),

          // 5. ASK ME SOMETHING ELSE
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await state.nextRandomQuestion();
                if (context.mounted && state.randomQuestion != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => QuestionAnswerScreen(
                        question: state.randomQuestion!,
                        source: 'random',
                      ),
                    ),
                  );
                }
              },
              icon: Icon(
                Icons.refresh_rounded,
                size: 18.0,
                color: secondaryTextColor,
              ),
              label: Text(
                'Ask me something else',
                style: HavenTypography.labelMd(primaryTextColor)
                    .copyWith(fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: surfaceColor,
                foregroundColor: primaryTextColor,
                elevation: 0,
                side: BorderSide(color: borderColor, width: 1.0),
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelfCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _SelfCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
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
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: HavenTypography.bodyMd(primaryTextColor)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: HavenTypography.caption(secondaryTextColor)
                        .copyWith(fontSize: 10.5, height: 1.3),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, size: 18.0, color: secondaryTextColor),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16.0,
                    color: secondaryTextColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateCarouselCard extends StatelessWidget {
  final HavenTemplate template;
  final VoidCallback onTap;

  const _TemplateCarouselCard({required this.template, required this.onTap});

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
          width: 140.0,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.category.toUpperCase(),
                    style: HavenTypography.caption(secondaryTextColor).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 9.0,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    template.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: HavenTypography.bodySm(primaryTextColor)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    template.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: HavenTypography.caption(secondaryTextColor)
                        .copyWith(fontSize: 10.0, height: 1.25),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(Icons.add, size: 16.0, color: secondaryTextColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
