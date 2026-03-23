import 'package:test/test.dart';
import 'package:kernetl_flutter/logic/habit_day_processor.dart';
import 'package:kernetl_flutter/models/habit_track.dart';

void main() {
  const processor = HabitDayProcessor();

  test('unset past days default to fail and decrement lives', () {
    final habit = HabitTrack(
      id: 'a',
      name: 'Test',
      createdDateKey: '2020-01-01',
      progressDays: 0,
      livesRemaining: 3,
    );

    processor.processClosedDays(habit, DateTime(2020, 1, 3));

    expect(habit.lastClosedDateKey, '2020-01-02');
    expect(habit.livesRemaining, 1);
    expect(habit.progressDays, 0);
    expect(habit.daily['2020-01-01'], 'fail');
    expect(habit.daily['2020-01-02'], 'fail');
  });

  test('check day increases balloon score on close', () {
    final habit = HabitTrack(
      id: 'b',
      name: 'Test',
      createdDateKey: '2020-01-05',
      daily: {'2020-01-05': 'check'},
    );

    processor.processClosedDays(habit, DateTime(2020, 1, 6));

    expect(habit.lastClosedDateKey, '2020-01-05');
    expect(habit.progressDays, 1);
    expect(habit.livesRemaining, 3);
    expect(habit.daily['2020-01-05'], 'check');
  });

  test('third consecutive fail resets progress and restores lives', () {
    final habit = HabitTrack(
      id: 'c',
      name: 'Test',
      createdDateKey: '2020-01-01',
      progressDays: 10,
      livesRemaining: 3,
    );

    processor.processClosedDays(habit, DateTime(2020, 1, 4));

    expect(habit.progressDays, 0);
    expect(habit.livesRemaining, 3);
    expect(habit.lastClosedDateKey, '2020-01-03');
  });

  test('does not process today (only through yesterday)', () {
    final habit = HabitTrack(
      id: 'd',
      name: 'Test',
      createdDateKey: '2020-01-10',
      daily: {'2020-01-10': 'check'},
    );

    processor.processClosedDays(habit, DateTime(2020, 1, 10));

    expect(habit.progressDays, 0);
    expect(habit.lastClosedDateKey, isNull);
  });
}
