import 'dart:async';

import 'package:flutter/material.dart';

import '../data/json_habit_store.dart';
import '../logic/habit_day_processor.dart';
import '../models/daily_status.dart';
import '../models/habit_track.dart';
import '../utils/date_keys.dart';

class HabitController extends ChangeNotifier {
  HabitController(this._store);

  final JsonHabitStore _store;

  StoredAppState? _state;
  PageController? _pageController;
  bool ready = false;

  List<HabitTrack> get habits => _state?.habits ?? [];

  int get selectedHabitIndex {
    if (_state == null || _state!.habits.isEmpty) return 0;
    return _state!.selectedHabitIndex.clamp(0, _state!.habits.length - 1);
  }

  HabitTrack? get selectedHabit {
    if (_state == null || _state!.habits.isEmpty) return null;
    return _state!.habits[selectedHabitIndex];
  }

  PageController get pageController {
    _pageController ??= PageController(initialPage: selectedHabitIndex);
    return _pageController!;
  }

  String get todayKey => dateKeyFromDateTime(dateOnly(DateTime.now()));

  Future<void> init() async {
    _state = await _store.loadProcessAndSave(DateTime.now());
    _clampSelection();
    _pageController?.dispose();
    _pageController = PageController(initialPage: selectedHabitIndex);
    ready = true;
    notifyListeners();
  }

  Future<void> refreshFromClock() async {
    if (_state == null) return;
    const processor = HabitDayProcessor();
    for (final h in _state!.habits) {
      processor.processClosedDays(h, DateTime.now());
    }
    await _store.save(_state!);
    notifyListeners();
  }

  void _clampSelection() {
    if (_state == null) return;
    if (_state!.habits.isEmpty) {
      _state!.selectedHabitIndex = 0;
      return;
    }
    if (_state!.selectedHabitIndex >= _state!.habits.length) {
      _state!.selectedHabitIndex = _state!.habits.length - 1;
    }
    if (_state!.selectedHabitIndex < 0) {
      _state!.selectedHabitIndex = 0;
    }
  }

  void onPageChanged(int index) {
    if (_state == null || _state!.habits.isEmpty) return;
    _state!.selectedHabitIndex = index;
    unawaited(_store.save(_state!));
    notifyListeners();
  }

  Future<void> setTodayStatus(DailyStatus status) async {
    final habit = selectedHabit;
    if (habit == null || _state == null) return;
    habit.daily[todayKey] = status.toJsonValue();
    await _store.save(_state!);
    notifyListeners();
  }

  Future<void> addHabit(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || _state == null) return;

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final today = todayKey;
    _state!.habits.add(
      HabitTrack(
        id: id,
        name: trimmed,
        createdDateKey: today,
      ),
    );
    _state!.selectedHabitIndex = _state!.habits.length - 1;
    _pageController?.dispose();
    _pageController = PageController(initialPage: _state!.selectedHabitIndex);
    await _store.save(_state!);
    notifyListeners();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }
}
