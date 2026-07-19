# BOOS Agenda

Die interne Aufgaben-App der BOOS Metallveredelung — ein eigenständiger Fork der
offiziellen [Vikunja-Flutter-App](https://github.com/go-vikunja/app), angepasst
und erweitert für den Firmeneinsatz gegen unsere selbst gehostete
Vikunja-Instanz.

## Unterschiede zum Upstream

- **Anhänge vollständig:** Anzeige mit Bild-Thumbnails in der Aufgaben-Ansicht,
  Vollbild-Viewer, Upload über Kamera/Fotomediathek/Dateien, Löschen
  (`lib/presentation/widgets/task_attachments_section.dart`)
- **Aufgaben-Zuweisung:** Personen zuweisen/entfernen mit Nutzersuche,
  Avatar-Chips in Detail- und Bearbeiten-Ansicht, Mini-Avatare in der
  Aufgabenliste (`task_assignees_section.dart`, `user_avatar.dart`)
- **Eigene Identität:** App-Name „BOOS Agenda", Bundle-ID
  `de.boos-metallveredlung.agenda` (iOS) bzw. `de.boos_metallveredlung.agenda`
  (Android), eigenes Icon
- iOS-Deployment-Target 14.0

## Entwicklung

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter build ios --release   # bzw. flutter build apk --release
```

Upstream-Änderungen können bei Bedarf selektiv übernommen werden
(`git remote upstream` zeigt auf go-vikunja/app; Cherry-Picks statt Voll-Merges).

## Lizenz

GPL-3.0 (geerbt vom Upstream-Projekt). Bei Weitergabe der App außerhalb der
Firma muss der Quellcode dieses Forks zugänglich sein.
