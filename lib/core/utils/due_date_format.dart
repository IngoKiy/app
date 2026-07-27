import 'package:intl/intl.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';

/// Fälligkeits-Label im Stil von Microsoft To Do: „Gestern"/„Heute"/„Morgen"
/// für die Nachbartage, sonst „Mi. 22. Juli" bzw. mit Jahr („Sa. 30. Sept.
/// 2028"), wenn das Datum nicht im laufenden Jahr liegt. Verglichen wird auf
/// Kalendertag-Basis in lokaler Zeit.
String formatDueDate(
  AppLocalizations l10n,
  String localeName,
  DateTime dueDate, {
  DateTime? now,
}) {
  final ref = now ?? DateTime.now();
  final today = DateTime(ref.year, ref.month, ref.day);
  final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
  final diff = dueDay.difference(today).inDays;

  if (diff == -1) return l10n.dueYesterday;
  if (diff == 0) return l10n.dueToday;
  if (diff == 1) return l10n.dueTomorrow;

  final pattern = dueDay.year == today.year ? 'E d. MMM' : 'E d. MMM y';
  return DateFormat(pattern, localeName).format(dueDay);
}

/// Überfällig im Sinne von To Do: der Fälligkeits-Kalendertag liegt vor heute.
bool isOverdue(DateTime dueDate, {DateTime? now}) {
  final ref = now ?? DateTime.now();
  final today = DateTime(ref.year, ref.month, ref.day);
  final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
  return dueDay.isBefore(today);
}
