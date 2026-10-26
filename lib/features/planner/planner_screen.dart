import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/haven_state.dart';
import '../../core/models/planner_model.dart';
import '../../core/theme/haven_colors.dart';
import '../../core/theme/haven_typography.dart';
import '../../core/widgets/haven_responsive_container.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();

  // Sunday Review Controllers
  final TextEditingController _achievedController = TextEditingController();
  final TextEditingController _wentWellController = TextEditingController();
  final TextEditingController _unfinishedController = TextEditingController();
  final TextEditingController _learnedController = TextEditingController();
  final TextEditingController _changesController = TextEditingController();

  String _goalPeriod = 'monthly';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _initReviewControllers();
  }

  void _initReviewControllers() {
    final state = context.read<HavenState>();
    final review = state.sundayReview;
    if (review != null) {
      _achievedController.text = review.achievedNotes;
      _wentWellController.text = review.wentWell;
      _unfinishedController.text = review.unfinishedNotes;
      _learnedController.text = review.lessonsLearned;
      _changesController.text = review.changesNextWeek;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _taskController.dispose();
    _goalController.dispose();
    _achievedController.dispose();
    _wentWellController.dispose();
    _unfinishedController.dispose();
    _learnedController.dispose();
    _changesController.dispose();
    super.dispose();
  }

  Future<void> _saveReview() async {
    final state = context.read<HavenState>();
    final review = SundayReview(
      id:
          state.sundayReview?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      weekId: state.currentWeekId,
      achievedNotes: _achievedController.text.trim(),
      wentWell: _wentWellController.text.trim(),
      unfinishedNotes: _unfinishedController.text.trim(),
      lessonsLearned: _learnedController.text.trim(),
      changesNextWeek: _changesController.text.trim(),
      createdAt: DateTime.now(),
    );
    await state.saveSundayReview(review);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sunday review saved quietly')),
      );
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
                      'Planner & Goals',
                      style: HavenTypography.headlineSm(primaryTextColor)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: borderColor, width: 1.0),
                ),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: primaryTextColor,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  labelColor: canvasColor,
                  unselectedLabelColor: secondaryTextColor,
                  labelStyle: HavenTypography.labelSm(canvasColor)
                      .copyWith(fontWeight: FontWeight.w600),
                  unselectedLabelStyle: HavenTypography.labelSm(
                    secondaryTextColor,
                  ),
                  tabs: const [
                    Tab(text: 'Weekly Plan'),
                    Tab(text: 'Sunday Review'),
                    Tab(text: 'Goals'),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildWeeklyPlanTab(
                      state,
                      isDark,
                      primaryTextColor,
                      secondaryTextColor,
                      surfaceColor,
                      borderColor,
                      canvasColor,
                    ),
                    _buildSundayReviewTab(
                      state,
                      isDark,
                      primaryTextColor,
                      secondaryTextColor,
                      surfaceColor,
                      borderColor,
                      canvasColor,
                    ),
                    _buildGoalsTab(
                      state,
                      isDark,
                      primaryTextColor,
                      secondaryTextColor,
                      surfaceColor,
                      borderColor,
                      canvasColor,
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

  Widget _buildWeeklyPlanTab(
    HavenState state,
    bool isDark,
    Color primaryTextColor,
    Color secondaryTextColor,
    Color surfaceColor,
    Color borderColor,
    Color canvasColor,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      children: [
        // Week Header & Carry Forward Action
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT WEEK',
                  style: HavenTypography.caption(
                    secondaryTextColor,
                  ).copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.8),
                ),
                const SizedBox(height: 2.0),
                Text(
                  state.currentWeekId,
                  style: HavenTypography.bodyMd(primaryTextColor)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => state.carryForwardUnfinishedTasks(),
              icon: Icon(
                Icons.arrow_forward_rounded,
                size: 14.0,
                color: secondaryTextColor,
              ),
              label: Text(
                'Carry unfinished',
                style: HavenTypography.labelSm(secondaryTextColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),

        // Add task input
        Container(
          height: 46.0,
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _taskController,
                  style: HavenTypography.bodySm(primaryTextColor),
                  cursorColor: primaryTextColor,
                  decoration: InputDecoration(
                    hintText: 'Add an intention or task for this week...',
                    hintStyle: HavenTypography.bodySm(secondaryTextColor),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 12.0,
                    ),
                  ),
                  onSubmitted: (val) {
                    state.addPlannerTask(val);
                    _taskController.clear();
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_rounded, color: primaryTextColor),
                onPressed: () {
                  state.addPlannerTask(_taskController.text);
                  _taskController.clear();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16.0),

        // Tasks Reorderable List
        if (state.tasks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Center(
              child: Text(
                'Start with one thing you would like to do this week.',
                style: HavenTypography.bodySm(secondaryTextColor),
              ),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.tasks.length,
            onReorderItem: (oldIndex, newIndex) =>
                state.reorderPlannerTasks(oldIndex, newIndex),
            itemBuilder: (context, index) {
              final task = state.tasks[index];
              return Container(
                key: ValueKey(task.id),
                margin: const EdgeInsets.only(bottom: 8.0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: borderColor, width: 1.0),
                ),
                child: Row(
                  children: [
                    // Design spec check box (20x20px, 6px radius)
                    GestureDetector(
                      onTap: () => state.toggleTaskCompletion(task),
                      child: Container(
                        width: 20.0,
                        height: 20.0,
                        decoration: BoxDecoration(
                          color: task.isCompleted
                              ? primaryTextColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6.0),
                          border: Border.all(
                            color: task.isCompleted
                                ? primaryTextColor
                                : borderColor,
                            width: 1.5,
                          ),
                        ),
                        child: task.isCompleted
                            ? Icon(Icons.check, size: 14.0, color: canvasColor)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        task.title,
                        style:
                            HavenTypography.bodySm(
                              task.isCompleted
                                  ? secondaryTextColor
                                  : primaryTextColor,
                            ).copyWith(
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18.0,
                        color: secondaryTextColor,
                      ),
                      onPressed: () => state.deletePlannerTask(task.id),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8.0),
                    Icon(
                      Icons.drag_indicator_rounded,
                      size: 18.0,
                      color: secondaryTextColor,
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSundayReviewTab(
    HavenState state,
    bool isDark,
    Color primaryTextColor,
    Color secondaryTextColor,
    Color surfaceColor,
    Color borderColor,
    Color canvasColor,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      children: [
        Text(
          'Sunday Weekly Review',
          style: HavenTypography.headlineSm(primaryTextColor)
              .copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4.0),
        Text(
          'A quiet 5-minute pause to reflect on the week before the next begins.',
          style: HavenTypography.bodySm(secondaryTextColor),
        ),
        const SizedBox(height: 16.0),

        _buildReviewField(
          'Did you achieve your weekly intentions?',
          _achievedController,
          isDark,
          primaryTextColor,
          secondaryTextColor,
          surfaceColor,
          borderColor,
        ),
        const SizedBox(height: 14.0),
        _buildReviewField(
          'What went well this week?',
          _wentWellController,
          isDark,
          primaryTextColor,
          secondaryTextColor,
          surfaceColor,
          borderColor,
        ),
        const SizedBox(height: 14.0),
        _buildReviewField(
          'What remained unfinished or challenged you?',
          _unfinishedController,
          isDark,
          primaryTextColor,
          secondaryTextColor,
          surfaceColor,
          borderColor,
        ),
        const SizedBox(height: 14.0),
        _buildReviewField(
          'What was a lesson or realization you had?',
          _learnedController,
          isDark,
          primaryTextColor,
          secondaryTextColor,
          surfaceColor,
          borderColor,
        ),
        const SizedBox(height: 14.0),
        _buildReviewField(
          'What would you like to change next week?',
          _changesController,
          isDark,
          primaryTextColor,
          secondaryTextColor,
          surfaceColor,
          borderColor,
        ),
        const SizedBox(height: 20.0),

        ElevatedButton(
          onPressed: _saveReview,
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
            'Save Sunday Review',
            style: HavenTypography.labelMd(canvasColor)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 40.0),
      ],
    );
  }

  Widget _buildReviewField(
    String label,
    TextEditingController controller,
    bool isDark,
    Color primaryTextColor,
    Color secondaryTextColor,
    Color surfaceColor,
    Color borderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: HavenTypography.bodySm(primaryTextColor)
              .copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6.0),
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
          child: TextField(
            controller: controller,
            maxLines: 3,
            style: HavenTypography.bodySm(primaryTextColor),
            cursorColor: primaryTextColor,
            decoration: InputDecoration(
              hintText: 'Notes...',
              hintStyle: HavenTypography.bodySm(secondaryTextColor),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsTab(
    HavenState state,
    bool isDark,
    Color primaryTextColor,
    Color secondaryTextColor,
    Color surfaceColor,
    Color borderColor,
    Color canvasColor,
  ) {
    final goals = _goalPeriod == 'monthly'
        ? state.monthlyGoals
        : state.yearlyGoals;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      children: [
        // Period Selector (Monthly vs Yearly)
        Row(
          children: [
            ChoiceChip(
              label: const Text('Monthly Goals'),
              selected: _goalPeriod == 'monthly',
              onSelected: (val) => setState(() => _goalPeriod = 'monthly'),
              selectedColor: primaryTextColor,
              labelStyle: TextStyle(
                color: _goalPeriod == 'monthly'
                    ? canvasColor
                    : secondaryTextColor,
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999.0),
                side: BorderSide(color: borderColor, width: 1.0),
              ),
            ),
            const SizedBox(width: 8.0),
            ChoiceChip(
              label: const Text('Yearly Goals'),
              selected: _goalPeriod == 'yearly',
              onSelected: (val) => setState(() => _goalPeriod = 'yearly'),
              selectedColor: primaryTextColor,
              labelStyle: TextStyle(
                color: _goalPeriod == 'yearly'
                    ? canvasColor
                    : secondaryTextColor,
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999.0),
                side: BorderSide(color: borderColor, width: 1.0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14.0),

        // Add Goal Input
        Container(
          height: 46.0,
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _goalController,
                  style: HavenTypography.bodySm(primaryTextColor),
                  cursorColor: primaryTextColor,
                  decoration: InputDecoration(
                    hintText: 'Add a $_goalPeriod goal...',
                    hintStyle: HavenTypography.bodySm(secondaryTextColor),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 12.0,
                    ),
                  ),
                  onSubmitted: (val) {
                    state.addGoal(val, _goalPeriod);
                    _goalController.clear();
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_rounded, color: primaryTextColor),
                onPressed: () {
                  state.addGoal(_goalController.text, _goalPeriod);
                  _goalController.clear();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16.0),

        if (goals.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Center(
              child: Text(
                'No $_goalPeriod goals yet.',
                style: HavenTypography.bodySm(secondaryTextColor),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: goals.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8.0),
            itemBuilder: (context, index) {
              final g = goals[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: borderColor, width: 1.0),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => state.toggleGoal(g),
                      child: Container(
                        width: 20.0,
                        height: 20.0,
                        decoration: BoxDecoration(
                          color: g.isCompleted
                              ? primaryTextColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6.0),
                          border: Border.all(
                            color: g.isCompleted
                                ? primaryTextColor
                                : borderColor,
                            width: 1.5,
                          ),
                        ),
                        child: g.isCompleted
                            ? Icon(Icons.check, size: 14.0, color: canvasColor)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        g.title,
                        style:
                            HavenTypography.bodySm(
                              g.isCompleted
                                  ? secondaryTextColor
                                  : primaryTextColor,
                            ).copyWith(
                              decoration: g.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18.0,
                        color: secondaryTextColor,
                      ),
                      onPressed: () => state.deleteGoal(g.id),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
