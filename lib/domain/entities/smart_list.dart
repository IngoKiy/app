/// Projektübergreifende Smart-Lists im Stil von Microsoft To Do.
///
/// Alle Listen sind reine Sichten auf die lokale DB (offline-fähig):
/// - [today]     „Mein Tag": heute fällig oder überfällig, offen
/// - [important] „Wichtig": Favoriten (`is_favorite`), offen
/// - [planned]   „Geplant": mit Fälligkeitsdatum, offen
/// - [all]       „Alle": alle offenen Aufgaben
/// - [completed] „Erledigt": abgeschlossene Aufgaben
enum SmartList { today, important, planned, all, completed }

/// Ende des heutigen (lokalen) Tages als UTC-ISO-String — Vergleichsgrenze
/// für „Mein Tag" gegen die UTC-ISO-Spalte `dueDate`.
String endOfTodayUtcIso(DateTime now) {
  final local = now.toLocal();
  final endOfDay = DateTime(local.year, local.month, local.day + 1);
  return endOfDay.toUtc().toIso8601String();
}
