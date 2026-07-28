import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';

/// Anzeigename einer Liste. Vikunja liefert zwei Listen mit fest im Server
/// verdrahteten englischen Titeln aus: das Favoriten-Pseudo-Projekt (ID -1)
/// und den Standard-Posteingang („Inbox"). Microsoft To Do zeigt an dieser
/// Stelle „Aufgaben" bzw. „Favoriten" in der Systemsprache — deshalb wird der
/// Titel hier nur für die Darstellung übersetzt.
///
/// Der gespeicherte [Project.title] bleibt unangetastet: Umbenennen-Dialog,
/// Bearbeiten-Formular und alles, was zum Server zurückgeschrieben wird,
/// müssen weiterhin den echten Titel verwenden — sonst würde der Web-Client
/// eine plötzlich umbenannte Liste sehen. Benennt Ingo die Inbox selbst um,
/// greift die Übersetzung nicht mehr, und der eigene Name gewinnt.
String projectDisplayTitle(AppLocalizations l10n, Project project) {
  if (project.id == -1) return l10n.favoritesListTitle;
  if (project.id > 0 && project.title == 'Inbox') return l10n.inboxListTitle;
  return project.title;
}
