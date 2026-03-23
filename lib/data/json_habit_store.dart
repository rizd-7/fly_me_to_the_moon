import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../logic/habit_day_processor.dart';
import '../models/habit_track.dart';

/// Loads/saves app state as JSON under app documents directory.
class JsonHabitStore {
  JsonHabitStore({HabitDayProcessor? processor})
      : _processor = processor ?? const HabitDayProcessor();

  static const _fileName = 'kernetl_habits.json';

  final HabitDayProcessor _processor;

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<StoredAppState> load() async {
    try {
      final f = await _file();
      if (!await f.exists()) {
        return StoredAppState.empty();
      }
      final text = await f.readAsString();
      if (text.trim().isEmpty) {
        return StoredAppState.empty();
      }
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        return StoredAppState.empty();
      }
      return StoredAppState.fromJson(decoded);
    } catch (_) {
      return StoredAppState.empty();
    }
  }

  Future<void> save(StoredAppState state) async {
    final f = await _file();
    await f.writeAsString(jsonEncode(state.toJson()));
  }

  /// Close past days for every habit and persist.
  Future<StoredAppState> loadProcessAndSave(DateTime todayLocal) async {
    final state = await load();
    for (final h in state.habits) {
      _processor.processClosedDays(h, todayLocal);
    }
    await save(state);
    return state;
  }
}

class StoredAppState {
  StoredAppState({
    required this.habits,
    this.selectedHabitIndex = 0,
  });

  final List<HabitTrack> habits;
  int selectedHabitIndex;

  factory StoredAppState.empty() => StoredAppState(habits: []);

  factory StoredAppState.fromJson(Map<String, dynamic> json) {
    final raw = json['habits'];
    final list = <HabitTrack>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          list.add(HabitTrack.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return StoredAppState(
      habits: list,
      selectedHabitIndex: (json['selectedHabitIndex'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'habits': habits.map((h) => h.toJson()).toList(),
        'selectedHabitIndex': selectedHabitIndex,
      };
}
