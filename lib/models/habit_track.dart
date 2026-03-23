import 'daily_status.dart';

/// One habit ("axe") with balloon score, lives, and per-day responses.
class HabitTrack {
  HabitTrack({
    required this.id,
    required this.name,
    required this.createdDateKey,
    this.progressDays = 0,
    this.livesRemaining = 3,
    this.lastClosedDateKey,
    Map<String, String>? daily,
  }) : daily = daily ?? <String, String>{};

  final String id;
  String name;

  /// First calendar day this habit exists (used to bound back-processing).
  String createdDateKey;

  /// Balloon units / flame count — incremented when a closed day is `check`.
  int progressDays;

  /// Lives left for this habit (starts at 3).
  int livesRemaining;

  /// Last calendar day fully processed (closed). Days after this until yesterday
  /// are closed on the next process pass.
  String? lastClosedDateKey;

  /// `yyyy-MM-dd` -> `check` | `fail`. Absent for a past day means default fail at close.
  final Map<String, String> daily;

  factory HabitTrack.fromJson(Map<String, dynamic> json) {
    final rawDaily = json['daily'];
    final map = <String, String>{};
    if (rawDaily is Map) {
      rawDaily.forEach((key, value) {
        if (key is String && value is String) {
          map[key] = value;
        }
      });
    }
    return HabitTrack(
      id: json['id'] as String,
      name: json['name'] as String,
      createdDateKey: json['createdDateKey'] as String,
      progressDays: (json['progressDays'] as num?)?.toInt() ?? 0,
      livesRemaining: (json['livesRemaining'] as num?)?.toInt() ?? 3,
      lastClosedDateKey: json['lastClosedDateKey'] as String?,
      daily: map,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdDateKey': createdDateKey,
        'progressDays': progressDays,
        'livesRemaining': livesRemaining,
        'lastClosedDateKey': lastClosedDateKey,
        'daily': Map<String, String>.from(daily),
      };

  /// Today's draft status, if any.
  DailyStatus? todayStatus(String todayKey) => DailyStatus.tryParse(daily[todayKey]);
}
