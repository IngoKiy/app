/// Projektübergreifende Smart-Lists im Stil von Microsoft To Do.
///
/// Alle Listen sind reine Sichten auf die lokale DB (offline-fähig):
/// - [today]        „Mein Tag": heute fällig/überfällig + manuell für heute
///                  hinzugefügte Aufgaben (Hybrid), offen
/// - [important]    „Wichtig": Favoriten (`is_favorite`), offen
/// - [planned]      „Geplant": mit Fälligkeitsdatum, offen
/// - [assignedToMe] „Mir zugewiesen": dem aktuellen Benutzer zugewiesen, offen
/// - [all]          „Alle": alle offenen Aufgaben
/// - [completed]    „Erledigt": abgeschlossene Aufgaben
enum SmartList { today, important, planned, assignedToMe, all, completed }

/// Ende des heutigen (lokalen) Tages als UTC-ISO-String — Vergleichsgrenze
/// für „Mein Tag" gegen die UTC-ISO-Spalte `dueDate`.
String endOfTodayUtcIso(DateTime now) {
  final local = now.toLocal();
  final endOfDay = DateTime(local.year, local.month, local.day + 1);
  return endOfDay.toUtc().toIso8601String();
}

/// Lokaler Kalendertag als Schlüssel (yyyy-MM-dd) für `my_day_entries` —
/// manuelle Mein-Tag-Einträge gelten genau für diesen Tag.
String localDayKey(DateTime now) {
  final local = now.toLocal();
  final mm = local.month.toString().padLeft(2, '0');
  final dd = local.day.toString().padLeft(2, '0');
  return '${local.year}-$mm-$dd';
}
