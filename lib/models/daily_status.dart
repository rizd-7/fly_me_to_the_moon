/// User response for a given calendar day (stored as strings in JSON).
enum DailyStatus {
  check,
  fail;

  static DailyStatus? tryParse(String? raw) {
    if (raw == null) return null;
    switch (raw) {
      case 'check':
        return DailyStatus.check;
      case 'fail':
        return DailyStatus.fail;
      default:
        return null;
    }
  }

  String toJsonValue() => name;
}
