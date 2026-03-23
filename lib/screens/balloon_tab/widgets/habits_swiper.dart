import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/daily_status.dart';
import '../../../models/habit_track.dart';
import '../../../state/habit_controller.dart';
import 'balloon_view.dart';

class HabitsSwiper extends StatelessWidget {
  const HabitsSwiper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitController>(
      builder: (context, ctrl, _) {
        final habits = ctrl.habits;
        if (habits.isEmpty) {
          return const SizedBox.shrink();
        }

        return PageView.builder(
          key: ValueKey('habits_${habits.length}'),
          controller: ctrl.pageController,
          itemCount: habits.length,
          onPageChanged: ctrl.onPageChanged,
          itemBuilder: (context, index) {
            final habit = habits[index];
            return _HabitPage(habit: habit);
          },
        );
      },
    );
  }
}

class _HabitPage extends StatelessWidget {
  const _HabitPage({required this.habit});

  final HabitTrack habit;

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<HabitController>();
    final today = ctrl.todayKey;
    final status = habit.todayStatus(today);

    return BalloonView(
      habitName: habit.name,
      progressDays: habit.progressDays,
      livesRemaining: habit.livesRemaining,
      todayStatus: status,
      onCheck: () => ctrl.setTodayStatus(DailyStatus.check),
      onFail: () => ctrl.setTodayStatus(DailyStatus.fail),
    );
  }
}
