import '../models/daily_status.dart';
import '../models/habit_track.dart';
import '../utils/date_keys.dart';

/// Closes past calendar days: default-fail when unset, apply check/fail effects.
///
/// [todayLocal] should be a `DateTime` in local time; only its date part is used.
/// Effects apply only to days strictly before that calendar date.
class HabitDayProcessor {
  const HabitDayProcessor();

  /// Apply fail: decrement life; at 0, reset balloon and restore 3 lives.
  static void applyFail(HabitTrack habit) {
    habit.livesRemaining -= 1;
    if (habit.livesRemaining <= 0) {
      habit.progressDays = 0;
      habit.livesRemaining = 3;
    }
  }

  static void applyCheckClose(HabitTrack habit) {
    habit.progressDays += 1;
  }

  /// Process all days from (lastClosed + 1) through yesterday inclusive.
  void processClosedDays(HabitTrack habit, DateTime todayLocal) {
    final today = dateOnly(todayLocal);
    final yesterday = today.subtract(const Duration(days: 1));
    final created = parseDateKey(habit.createdDateKey);

    DateTime start;
    if (habit.lastClosedDateKey == null) {
      start = created;
    } else {
      start = parseDateKey(habit.lastClosedDateKey!).add(const Duration(days: 1));
    }

    if (start.isAfter(yesterday)) {
      return;
    }

    // Do not process days before habit existed.
    if (start.isBefore(created)) {
      start = created;
    }

    for (var d = start; !d.isAfter(yesterday); d = d.add(const Duration(days: 1))) {
      final key = dateKeyFromDateTime(d);
      final raw = habit.daily[key];
      final isCheck = raw == DailyStatus.check.toJsonValue();

      if (isCheck) {
        applyCheckClose(habit);
        habit.daily[key] = DailyStatus.check.toJsonValue();
      } else {
        // Absent or explicit fail => fail day (effects only at close; no double apply)
        applyFail(habit);
        habit.daily[key] = DailyStatus.fail.toJsonValue();
      }
      habit.lastClosedDateKey = key;
    }
  }
}
