# Plan: BOOS Agenda im Stil von Microsoft To Do

Beschlossene Ausrichtung (26.07.2026, mit Ingo abgestimmt): Die App übernimmt
Optik und Bedienmodell von Microsoft To Do vollständig, auf Basis der
Offline-First-Architektur (Drift + Outbox, siehe docs/offline.md).

## Entscheidungen

- **Listen-Design: voll wie To Do.** Jede Liste (Smart-List wie Projekt) hat
  eine Akzentfarbe; die Listen-Seite färbt Hintergrund/AppBar damit ein,
  großer Titel, weiße Aufgaben-Karten, Zurück-Button beschriftet „Listen".
  Projektfarbe = Vikunja-Projektfarbe (in der App wählbar), Smart-Lists haben
  feste Farben (`smartListLook`).
- **Mein Tag: Hybrid.** Automatisch enthalten: heute fällig + überfällig.
  Zusätzlich manuell hinzufügbar/entfernbar; manuelle Einträge gelten nur für
  den aktuellen (lokalen) Tag und verfallen um Mitternacht. Speicherung
  lokal (Tabelle `my_day_entries`), kein Server-Sync (Vikunja kennt kein
  Mein-Tag-Konzept).
- **Schritte: Checkliste in der Beschreibung.** Format: TipTap-Task-List-HTML
  (`<ul data-type="taskList"><li data-checked="…">`), damit Vikunja-Web
  dieselben Schritte anzeigt und als „x von y" zählt. Util:
  `lib/core/utils/task_steps.dart`.
- **Sortierung je Liste:** Fälligkeit, Wichtigkeit, Alphabet, Erstellt;
  Auswahl wird pro Liste im KeyValue-Store gemerkt (`sort_mode/<listKey>`).
- **Erledigt einklappbar** unten in jeder Projektliste (wie To Do), die
  Erledigt-Smart-List bleibt zusätzlich bestehen.
- **Swipe-Aktionen** auf Zeilen: abhaken, zu Mein Tag, löschen.
- **Globale Suche** (lokal, offline) über alle Aufgaben.
- **Übersicht:** Kopf mit Avatar + Name + Suchsymbol, darunter Smart-Lists
  (inkl. „Mir zugewiesen"), Projektbaum, unten fixiert „+ Neue Liste".
- **Wiederholen-Presets:** täglich, werktags, wöchentlich, monatlich,
  jährlich, benutzerdefiniert.

## Arbeitspakete

1. **Foundations** (Hauptsession): Drift v3 (`my_day_entries` + Migration),
   `SmartList.assignedToMe`, Suche-/Zugewiesen-Queries, Schritte-Util,
   Sortier-Persistenz, sämtliche l10n-Keys, Codegen, Tests.
2. **Agent A — Listen-Design:** Akzent-Theming der Listen-Seiten,
   Sortier-Chip, Erledigt-Gruppe, Listenfarbe wählbar.
3. **Agent B — Übersicht:** Kopfzeile, „+ Neue Liste" unten, Suchseite.
4. **Agent C — Detailseite:** Schritte-Editor, Mein-Tag-Aktion,
   Wiederholen-Presets.
5. **Agent D — Zeilen:** Swipe-Aktionen, „x von y", Mein-Tag-Kennzeichen.
6. **Integration:** Merge der Worktree-Branches, Gesamttests, Goldens,
   Build + Installation.

Bewusst verschoben: echtes To-Do-„Vorschläge"-Panel, Listen-Fotohintergründe,
echte Subtasks über Task-Relationen.
