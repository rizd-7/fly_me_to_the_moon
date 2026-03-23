// Local calendar date helpers (no time / timezone shifts for "day" semantics).

String dateKeyFromDateTime(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

DateTime parseDateKey(String key) {
  final parts = key.split('-');
  if (parts.length != 3) {
    throw FormatException('Invalid date key: $key');
  }
  return DateTime(
    int.parse(parts[0], radix: 10),
    int.parse(parts[1], radix: 10),
    int.parse(parts[2], radix: 10),
  );
}

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
