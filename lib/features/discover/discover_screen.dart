import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/haven_state.dart';
import '../../core/theme/haven_colors.dart';
import '../../core/theme/haven_typography.dart';
import 'question_answer_screen.dart';
import 'previous_answers_screen.dart';
import 'category_prompts_screen.dart';

class _CategoryData {
  final String title;
  final String description;
  final IconData icon;
  final List<String> dbCategories;
  final bool isPeopleShortcut;

  const _CategoryData({
    required this.title,
    required this.description,
    required this.icon,
    required this.dbCategories,
    this.isPeopleShortcut = false,
  });
}

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  static const List<_CategoryData> _categories = [
    _CategoryData(
      title: 'Get to know yourself',
      description: 'Explore your thoughts, personality, and the things that make you who you are.',
      icon: Icons.person_outline_rounded,
      dbCategories: ['About Me', 'My Story', 'General'],
    ),
    _CategoryData(
      title: 'Your Family & Home',
      description:
          'Reflect on the people, places, and memories that shaped your life.',
      icon: Icons.home_outlined,
      dbCategories: ['Family'],
    ),
    _CategoryData(
      title: 'People in Your Life',
      description:
          'Remember the relationships and connections that matter to you.',
      icon: Icons.people_outline_rounded,
      dbCategories: ['My People'],
      isPeopleShortcut: true,
    ),
    _CategoryData(
      title: 'Childhood & Memories',
      description: 'Early impressions, childhood games, and unforgettable formative days.',
      icon: Icons.history_edu_outlined,
      dbCategories: ['Childhood & Memories'],
    ),
    _CategoryData(
      title: 'School & College',
      description: 'Moments of learning, independence, and finding your way.',
      icon: Icons.school_outlined,
      dbCategories: ['College & School'],
    ),
    _CategoryData(
      title: 'Everyday Life',
      description:
          'The textures, small routines, and spaces of your ordinary days.',
      icon: Icons.wb_sunny_outlined,
      dbCategories: ['Everyday Life'],
    ),
    _CategoryData(
      title: 'Feelings & Reflection',
      description:
          'Inner seasons, emotional honesty, and quiet mental clarity.',
      icon: Icons.self_improvement_rounded,
      dbCategories: ['Feelings & Reflection'],
    ),
    _CategoryData(
      title: 'Things You Love',
      description: 'Books, music, cherished objects, and sensory comforts that ground you.',
      icon: Icons.favorite_border_rounded,
      dbCategories: ['Things I Love', 'My Interests'],
    ),
    _CategoryData(
      title: 'Dreams & Future',
      description: 'Horizons, quiet hopes, and what you wish for tomorrow.',
      icon: Icons.north_east_rounded,
      dbCategories: ['Dreams & Future', 'My Future'],
    ),
    _CategoryData(
      title: 'Gratitude & Small Joys',
      description: 'A sanctuary for everyday kindness and gentle gratitude.',
      icon: Icons.spa_outlined,
      dbCategories: ['Gratitude & Small Joys'],
    ),
    _CategoryData(
      title: 'Life Lessons',
      description:
          'Wisdom discovered gently through mistakes, growth, and time.',
      icon: Icons.lightbulb_outline_rounded,
      dbCategories: ['Life Lessons'],
    ),
    _CategoryData(
      title: 'Letters You Never Sent',
      description:
          'Words left unsaid to loved ones, friends, or your younger self.',
      icon: Icons.mail_outline_rounded,
      dbCategories: ['Letters I Never Sent'],
    ),
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
    final surfaceColor = isDark
        ? HavenColors.darkSurface
        : HavenColors.lightSurface;
    final borderColor = isDark
        ? HavenColors.darkBorder
        : HavenColors.lightBorder;

    final dailyQuestion = state.dailyQuestion;
    final dailyResponse = state.todayDailyResponse;

    return RefreshIndicator(
      onRefresh: () => state.loadDiscover(),
      color: primaryTextColor,
      backgroundColor: surfaceColor,
      child: ListView(
        key: const PageStorageKey('discover_scroll_list'),
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 16.0,
          bottom: 120.0,
        ),
        children: [
          // 1. Editorial Header
          Text('Discover', style: HavenTypography.headlineLg(primaryTextColor)),
          const SizedBox(height: 4.0),
          Text(
            'A quiet reflection library of guided prompts, personal templates, and thought exercises.',
            style: HavenTypography.bodySm(secondaryTextColor),
          ),
          const SizedBox(height: 20.0),

          // 2. DAILY REFLECTION
          Text(
            'DAILY REFLECTION',
            style: HavenTypography.caption(secondaryTextColor)
                .copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.8),
          ),
          const SizedBox(height: 8.0),
          Container(
            padding: const EdgeInsets.all(18.0),
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
                const SizedBox(height: 14.0),
                Divider(height: 1.0, color: borderColor),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        if (dailyQuestion != null) {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
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
                          CupertinoPageRoute(
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

          // 3. REFLECTION LIBRARY
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Reflection Library',
                  style: HavenTypography.headlineSm(primaryTextColor)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                '${_categories.length} categories',
                style: HavenTypography.caption(secondaryTextColor),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // 4. Refined Editorial List
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: borderColor, width: 1.0),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _categories.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1.0, color: borderColor),
              itemBuilder: (context, index) {
                final cat = _categories[index];

                // Calculate accurate count of templates in this category
                final catLower = cat.dbCategories.map((c) => c.toLowerCase());
                final templateCount = state.templates.where((t) {
                  return catLower.contains(t.category.toLowerCase());
                }).length;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (_) => CategoryPromptsScreen(
                            category: cat.title,
                            description: cat.description,
                            dbCategories: cat.dbCategories,
                            isPeopleShortcut: cat.isPeopleShortcut,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.vertical(
                      top: index == 0
                          ? const Radius.circular(16.0)
                          : Radius.zero,
                      bottom: index == _categories.length - 1
                          ? const Radius.circular(16.0)
                          : Radius.zero,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 38.0,
                            height: 38.0,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : const Color(0xFFF2F2F0),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Icon(
                              cat.icon,
                              size: 19.0,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(width: 14.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        cat.title,
                                        style: HavenTypography.bodyMd(
                                          primaryTextColor,
                                        ).copyWith(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    if (templateCount > 0)
                                      Text(
                                        '$templateCount templates',
                                        style: HavenTypography.caption(
                                          secondaryTextColor,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  cat.description,
                                  style: HavenTypography.bodySm(
                                    secondaryTextColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18.0,
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

          // 5. Ask me something else
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await state.nextRandomQuestion();
                if (context.mounted && state.randomQuestion != null) {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
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
