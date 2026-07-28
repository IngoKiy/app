/// Erkennung von Datumsangaben in Aufgabentiteln wie in Microsoft To Do
/// („Milch kaufen morgen" → Fälligkeit morgen). Unterstützt Deutsch und
/// Englisch: heute/morgen/übermorgen, nächste Woche, Wochentage (auch mit
/// „am …"/„on …") sowie numerische Daten (31.12. / 31.12.2026).
class DetectedDate {
  final DateTime dueDate;

  /// Titel ohne die erkannte Datumsangabe (für die Entfernen-Option).
  final String cleanedTitle;

  const DetectedDate(this.dueDate, this.cleanedTitle);
}

const _weekdaysDe = {
  'montag': DateTime.monday,
  'dienstag': DateTime.tuesday,
  'mittwoch': DateTime.wednesday,
  'donnerstag': DateTime.thursday,
  'freitag': DateTime.friday,
  'samstag': DateTime.saturday,
  'sonntag': DateTime.sunday,
};

const _weekdaysEn = {
  'monday': DateTime.monday,
  'tuesday': DateTime.tuesday,
  'wednesday': DateTime.wednesday,
  'thursday': DateTime.thursday,
  'friday': DateTime.friday,
  'saturday': DateTime.saturday,
  'sunday': DateTime.sunday,
};

DetectedDate? detectDueDateInTitle(String title, {DateTime? now}) {
  final ref = now ?? DateTime.now();
  final today = DateTime(ref.year, ref.month, ref.day, 12);

  DetectedDate? result(RegExpMatch match, DateTime due) {
    final cleaned =
        (title.substring(0, match.start) + title.substring(match.end))
            .replaceAll(RegExp(r'\s{2,}'), ' ')
            .trim();
    return DetectedDate(due, cleaned.isEmpty ? title.trim() : cleaned);
  }

  RegExpMatch? find(String pattern) =>
      RegExp(pattern, caseSensitive: false, unicode: true).firstMatch(title);

  // Relative Wörter.
  final uebermorgen = find(r'\bübermorgen\b');
  if (uebermorgen != null) {
    return result(uebermorgen, today.add(const Duration(days: 2)));
  }
  final morgen = find(r'\b(morgen|tomorrow)\b');
  if (morgen != null) {
    return result(morgen, today.add(const Duration(days: 1)));
  }
  final heute = find(r'\b(heute|today)\b');
  if (heute != null) return result(heute, today);
  final naechsteWoche = find(r'\b(nächste woche|next week)\b');
  if (naechsteWoche != null) {
    final daysUntilMonday = (DateTime.monday - ref.weekday + 7) % 7;
    final add = daysUntilMonday == 0 ? 7 : daysUntilMonday;
    return result(naechsteWoche, today.add(Duration(days: add)));
  }

  // Wochentage („freitag", „am freitag", „on friday") → nächstes Vorkommen.
  for (final entry in {..._weekdaysDe, ..._weekdaysEn}.entries) {
    final match = find(r'\b((am|on)\s+)?' + entry.key + r'\b');
    if (match != null) {
      var add = (entry.value - ref.weekday + 7) % 7;
      if (add == 0) add = 7;
      return result(match, today.add(Duration(days: add)));
    }
  }

  // Numerisch: 31.12. oder 31.12.2026.
  final numeric = find(r'\b(\d{1,2})\.(\d{1,2})\.(\d{4})?');
  if (numeric != null) {
    final day = int.parse(numeric.group(1)!);
    final month = int.parse(numeric.group(2)!);
    final year = numeric.group(3) != null
        ? int.parse(numeric.group(3)!)
        : ref.year;
    if (day >= 1 && day <= 31 && month >= 1 && month <= 12) {
      var due = DateTime(year, month, day, 12);
      // Ohne Jahresangabe: liegt das Datum in der Vergangenheit → nächstes
      // Jahr.
      if (numeric.group(3) == null && due.isBefore(today)) {
        due = DateTime(year + 1, month, day, 12);
      }
      if (due.day == day) return result(numeric, due);
    }
  }

  return null;
}
