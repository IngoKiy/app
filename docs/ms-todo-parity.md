# Microsoft To Do — Referenzerfassung & Parity-Plan für BOOS Agenda

Stand: 27.07.2026. Erfasst auf dem echten iPhone (`iPhone von Ingo`, To Do
2.x, deutsch) über den Appium-Agenten aus `microsoft-todo-agent/`; Screenshots
liegen unter `microsoft-todo-agent/artifacts/` (enthalten private Inhalte,
nicht weitergeben). Vergleichsstand BOOS Agenda: Branch `feat/ms-todo-ui`
(Simulator-Build) bzw. 0.1.8 auf dem iPhone.

Ziel laut Ingo: **Optik, Bedienmodell und Funktionsumfang von Microsoft To Do
möglichst exakt nachbilden** — auf Basis der Offline-First-Architektur
(ergänzt docs/ms-todo-plan.md, ersetzt ihn nicht).

---

## 1. Screen-Inventar Microsoft To Do

### 1.1 Listen-Übersicht (Startseite)
- Kopf: rundes Avatarbild + Name (fett, ~17 pt) links, Lupe rechts. Kein
  App-Titel, keine Bottom-Navigation.
- Smart-Lists als flache Zeilen (kein Karten-Look): farbiges Icon links
  (~24 pt), Label, rechts graue Anzahl offener Aufgaben (ohne Badge).
  Reihenfolge: Mein Tag (Sonne), Wichtig (Stern, pink), Geplant (Kalender,
  teal), Alle (Unendlich, blau), Abgeschlossen (Haken, rot), Mir zugewiesen
  (Person, rot), Gekennzeichnete E-Mail (Flagge, grün), Aufgaben (Haus, blau).
  Jede Smart-List in Einstellungen einzeln abschaltbar; „Leere intelligente
  Listen automatisch ausblenden" als Option.
- Trennlinie, darunter Benutzerlisten: kleines Listen-Icon in der
  jeweiligen Listenfarbe, Name, rechts Anzahl. Freigegebene Listen tragen
  ein Personen-Symbol hinter dem Namen.
- Gruppen (Ordner-Icon) mit „…" und Auf-/Zuklapp-Chevron; Kindlisten
  eingerückt mit vertikaler Führungslinie.
- Fußzeile fixiert: „+ Neue Liste" (blau, Textlink) links, Symbol
  „Neue Gruppe" rechts.
- Verhalten: Tap öffnet Liste. Long-Press startet Drag-&-Drop-Umsortierung.

### 1.2 Mein Tag
- Voll eingefärbter Hintergrund (Foto/Verlauf, Standard Grün ~#368E68),
  weißer Großtitel „Mein Tag" + Untertitel mit Datum („Montag, 27. Juli").
- Kein Icon neben dem Titel. Oben rechts: Glühbirne (Vorschläge) und „…".
- Sort-Chip links unter dem Titel („Nach Wichtigkeit sortiert" + Chevron),
  daneben eigenes „×" zum Entfernen der Sortierung.
- Leerer Zustand: dezente horizontale Linien (Notizzeilen-Optik), kein
  Illustrations-Empty-State.
- Aufgaben von heute + manuell hinzugefügte; Inhalt verfällt um Mitternacht
  (deckt sich mit Hybrid-Beschluss in ms-todo-plan.md).
- „Vorschläge"-Sheet (Glühbirne): weißes Sheet, Grabber, Titel zentriert,
  „Fertig" rechts. Abschnitte „Später"/„Früher" mit Aufgabenzeilen
  (Kreis, Titel, Meta: Listenname • Fälligkeit rot bei überfällig •
  Wiederholungs-Icon) und blauem „+" rechts (fügt zu Mein Tag hinzu).

### 1.3 Smart-List „Alle" / normale Projektliste (z. B. „Aufgaben")
- Voll eingefärbter Hintergrund in Listenfarbe (Standardblau ~#6579C8).
- „< Listen" beschrifteter Zurück-Button oben links (weiß), oben rechts „…".
- Weißer Großtitel (~34 pt, bold). Beim Scrollen wandert der Titel als
  zentrierter Navbar-Titel nach oben (Großtitel kollabiert).
- Sort-Chip: halbtransparent dunkler (~#5C6FB2), weißer Text
  „Sortiert nach Fälligkeitsdatum" + Chevron; separates „×"-Quadrat daneben.
  In „Alle" gruppiert die Sortierung mit einklappbaren Gruppen-Chips
  (z. B. Herkunftsliste bei Planner-Aufgaben).
- Aufgaben als weiße Karten: Radius ~10–12 pt, flach (kein Schatten),
  ~8 pt vertikaler Abstand, volle Breite mit ~16 pt Rand.
  - Links Kreis-Checkbox (grau, ~28 pt). Tap = erledigen (optional Sound).
  - Titel schwarz ~17 pt, mehrzeilig erlaubt.
  - Meta-Zeile klein grau (~13 pt): „x von y" (Schritte) • Fälligkeit
    (rot ~#E32C2E wenn überfällig, sonst grau; relative Labels „Gestern",
    sonst „Do. 23. Apr.") • Herkunfts-Icons (Notiz, Nachricht, Wiederholen).
  - Rechts Stern: outline grau = normal, gefüllt in Akzentfarbe = wichtig.
- „Erledigt"-Gruppe: einklappbarer Chip „⌄ Erledigt" unten in der Liste;
  erledigte Karten mit gefülltem Akzent-Kreis + weißem Haken,
  durchgestrichenem grauem Titel.
- Fußleiste fixiert: „+ Aufgabe hinzufügen", volle Breite, halbtransparent
  dunkler als Hintergrund (~#5C70BD), weißer Text.
- „Geplant" ist die helle Variante: Hintergrund Mint ~#D4F1EF, Titel/Akzente
  dunkel-teal ~#166F6B, Chips ~#CBE9E7. Statt Sort-Chip: Filter-Chip
  („Alles geplant" — Überfällig/Heute/… Auswahl) + Chip „Nach
  Fälligkeitsdatum ×". Aufgaben unter Datums-Gruppenchips („Mi. 31. Dez.").
  Gefüllte Sterne hier dunkel-teal (immer Akzentfarbe der Liste).
- Wichtig-Liste: analoges Prinzip mit eigener Farbe; enthält alle
  markierten Aufgaben.

### 1.4 Composer („Aufgabe hinzufügen")
- Tap auf die Fußleiste öffnet ein weißes Sheet direkt über der Tastatur:
  Kreis + Eingabefeld mit Platzhalter „Aufgabe hinzufügen" (randlos!),
  darunter Icon-Zeile: Sonne (Mein Tag), Glocke (Erinnerung), Kalender
  (Fälligkeit), Notizblatt (Notiz) — setzen Attribute vor dem Anlegen.
- Return legt die Aufgabe an und lässt den Composer für die nächste Eingabe
  offen. „Fertig" oben rechts schließt. Titel-Erkennung von Datumsangaben
  („morgen") ist als Einstellung zuschaltbar.

### 1.5 Aufgaben-Detailseite
- Weißer Vollbild-Screen (keine farbige AppBar!), Zurück-Button beschriftet
  mit Listennamen in Akzentblau ~#436AF2.
- Kopf: großer Kreis + Titel (fett ~22 pt, frei stehend, kein Textfeld-Look),
  Stern rechts.
- Danach reine Aktionszeilen (Icon + Label, keine Umrandungen/Formulare):
  1. „+ Schritt hinzufügen" (blau); vorhandene Schritte als Zeilen mit
     eigenem Kreis darüber, zählen als „x von y" in der Listenansicht.
  2. „Zu ‚Mein Tag' hinzufügen" (Sonne) — Toggle-Zeile.
  3. „Erinnerung" (Glocke) → Sheet: Später am Tag / Morgen / Nächste Woche
     (je mit konkreter Zeit rechts) / „Datum und Uhrzeit auswählen >".
  4. „Fälligkeitsdatum hinzufügen" (Kalender) → Sheet: Heute / Morgen /
     Nächste Woche (Wochentag rechts) / „Datum auswählen >".
  5. „Wiederholen" (Pfeile) → Sheet: Täglich / Wöchentlich / Wochentage /
     Monatlich / Jährlich / „Benutzerdefiniert >".
  6. „Datei hinzufügen" (Büroklammer).
  7. „Notiz hinzufügen" (mehrzeiliger Bereich unten).
- Gesetzte Werte färben die Zeile blau und zeigen ein „×" zum Entfernen.
- Fußzeile: „Erstellt am …" zentriert grau, Papierkorb rechts (löschen mit
  Bestätigungsdialog).

### 1.6 Listenoptionen („…"-Sheet)
- Weißes Sheet, Grabber, Titel „Listenoptionen" zentriert, „Fertig" rechts.
- Benutzerliste: Liste umbenennen / Liste verschieben in… (Gruppe) > /
  Sortieren > / Design ändern > / Liste duplizieren / Liste ausdrucken /
  Kopie senden / **Liste löschen** (rot). Oben rechts außerdem
  Freigabe-Symbol (Personen+) in der Navbar.
- Smart-List „Aufgaben": Bearbeiten / Sortieren > / Design ändern > /
  Liste duplizieren / Liste ausdrucken / Kopie senden (kein Löschen).
- Submenü Sortieren: Wichtigkeit / Alphabetisch / Fälligkeitsdatum /
  Erstellungsdatum / Zu „Mein Tag" hinzugefügt — mit rundem „<"-Zurück
  im Sheet-Kopf.
- Submenü „Design auswählen": Tabs Farbe / Foto / Benutzerdefiniert;
  Farbreihe (Blau, Lila, Magenta, Rot, Grün, Teal, Grau, helle Varianten …)
  mit Auswahlpunkt. Foto-Hintergründe für Listen.

### 1.7 „Neue Liste"-Flow
- Tap auf „+ Neue Liste" legt **sofort** eine Liste „Unbenannte Liste [n]"
  an und öffnet sie mit aktivem Titel-Edit (Tastatur offen); Benennung ist
  Umbenennen. Löschen: „…" → Liste löschen → Dialog
  „»…« wird endgültig gelöscht." [Abbrechen | Liste löschen (rot)].
  Nach dem Löschen springt die App zur nächsten Liste.

### 1.8 Suche
- Eigener Vollbild-Screen in Grau-Blau: Suchfeld oben (Lupe + „Suchen"),
  „Abbrechen" rechts, Tastatur sofort offen. Empty-State mit Illustration
  und Text „Sie können in Aufgaben, Schritten und Notizen suchen."
  Ergebnisse gruppiert nach Listen (Live-Suche).

### 1.9 Einstellungen (über Avatar)
- Sheet mit Profil (Avatar, Name, E-Mail), „Konten verwalten".
- Allgemeines: Neue Aufgaben oben hinzufügen · Stern-Aufgaben nach oben ·
  Sound bei Fertigstellung · Linkvorschauen · Datums-/Zeit-Erkennung in
  Titeln · Erkanntes Datum aus Titel entfernen · App-Einstellungen ·
  Siri-Kurzbefehle · App-Badge · Wochenanfang.
- Smart-Lists einzeln ein/aus + „Leere intelligente Listen ausblenden" +
  „‚Heute fällig'-Aufgaben in ‚Mein Tag' anzeigen".
- Verbundene Apps (Planner, Gekennzeichnete E-Mail) — für BOOS irrelevant.
- Benachrichtigungen: Erinnerungen · Heute-fällig-Push · Zeitpunkt (09:00) ·
  Aktivität in freigegebenen Listen.
- Hilfe/Feedback (FAQ etc.).

---

## 2. Interaktionsmodell (Gesten & Verhalten)

| Geste | Ort | Verhalten in To Do |
| --- | --- | --- |
| Tap auf Karte | Liste | öffnet Detailseite |
| Tap auf Kreis | Liste/Detail | erledigt (Animation, optional Sound); erneuter Tap macht rückgängig |
| Tap auf Stern | Liste/Detail | wichtig an/aus (Stern füllt sich in Akzentfarbe) |
| Swipe rechts (leading, partiell) | Aufgabenzeile | zeigt zwei runde Buttons: Blau/Sonne = zu Mein Tag, Orange/Listen-Pfeil = in Liste verschieben; Vollswipe führt erste Aktion aus |
| Swipe links (trailing) | Aufgabenzeile | roter runder Löschen-Button; Vollswipe löscht (mit Undo-Snackbar) |
| Long-Press auf Zeile | Liste | startet Drag-&-Drop-Umsortieren (kein Kontextmenü); bei aktiver Sortierung wirkungslos |
| Long-Press auf Liste | Übersicht | Drag-&-Drop-Reorder von Listen/Gruppen |
| Scroll | Listen-Seite | Großtitel kollabiert in die Navbar (zentriert) |
| Tap „Erledigt"-Chip | Liste | Gruppe ein-/ausklappen |
| Pull-down / „Fertig" | Sheets | schließen; Submenüs mit rundem „<" im Sheet |
| Return im Composer | Composer | legt an, bleibt offen (Serien-Eingabe) |

Wichtig: **Erledigen geht in To Do nur über den Kreis, nicht per Swipe.**

---

## 3. Design-Tokens (gemessen)

| Token | Wert | Verwendung |
| --- | --- | --- |
| Akzent Blau (Fläche) | ≈ #6579C8 | Listen-Hintergrund Standardblau |
| Add-Bar/Sort-Chip auf Blau | ≈ #5C70BD / #5C6FB2 | halbtransparente Weiß-Overlays auf Akzent (Weiß ~12–18 % bzw. Schwarz-Overlay) |
| Akzent Grün (Mein Tag) | ≈ #368E68 | Standard-Hintergrund Mein Tag |
| Mint hell (Geplant) | ≈ #D4F1EF | helle Akzentvariante; Chips #CBE9E7 |
| Teal dunkel (Geplant) | ≈ #166F6B | Titel/Stern/Icons auf heller Fläche |
| Überfällig-Rot | ≈ #E32C2E | Fälligkeits-Text |
| Link-/Aktionsblau | ≈ #436AF2 | Detailseite, Textlinks, „Fertig" |
| Karte | #FFFFFF, Radius ~10–12 pt, ohne Schatten | Aufgabenzeilen |
| Typo | System (SF Pro); Großtitel ~34 bold, Titel 17 regular, Meta 13 | durchgängig |

Prinzipien: Farbe kommt **nur** aus dem vollflächigen Listen-Hintergrund;
alle Bedienelemente darauf sind Weiß bzw. halbtransparente Overlays; Inhalte
liegen auf weißen flachen Karten; Sheets sind immer weiß mit zentriertem
Titel + „Fertig". Jede Listenfarbe hat eine dunkle (weißer Text) oder helle
(dunkler Text) Ausprägung — Kontrast entscheidet.

---

## 4. Gap-Analyse BOOS Agenda (Stand feat/ms-todo-ui, Simulator 27.07.)

**Passt schon (Basis steht):**
- Übersicht: Kopf mit Avatar/Name/Lupe, Smart-Lists mit farbigen Icons +
  Zählern, „Neue Liste" unten.
- Listen-Seiten: vollflächige Akzentfarbe, „< Listen", Großtitel, weiße
  Karten, Sort-Chip, „Aufgabe hinzufügen"-Leiste, Mein-Tag-Hybrid wirkt.
- Detailseite: Schritte („Nächster Schritt"), Mein-Tag-Toggle,
  Wiederholen-Presets, Erstellt-Fußzeile + Papierkorb.
- Quick-Add-Sheet vorhanden.

**Abweichungen (nach Priorität):**

P0 — Politur, sofort sichtbar
1. Sprachmix: „Edit Task", „Due Date", „Priority", „Start/End Date",
   „Add a reminder", „No description", „13 days ago", „No tasks or sub
   project in this project", „Set Color", Bottom-Tabs „Home/Projects/
   Settings/List/Gantt/Table/Kanban". Alles über l10n (de) abdecken.
2. Sort-Chip: weißer Text auf weißem Chip (unlesbar); zudem zentriert statt
   links und ohne „×". → Stil wie To Do (halbtransparent, linksbündig,
   Chevron + separates ×).
3. Fälligkeit „13 days ago" → deutsches To-Do-Format: relative Kurzlabels
   („Gestern", „Heute", „Morgen"), sonst „Mi. 22. Juli", rot bei überfällig;
   als Badge-Hintergrund entfernen (To Do nutzt reinen Text).

P1 — Kernabweichungen im Layout
4. Detailseite vom Formular- auf Aktionszeilen-Layout umbauen: weiße Seite
   ohne farbige AppBar, freistehender Titel + Kreis + Stern,
   Aktionszeilen (Erinnerung/Fällig/Wiederholen als Preset-Sheets wie 1.5),
   Notiz-Bereich; Vikunja-Extras (Priorität, Start/Ende, Labels, Farbe,
   Zuweisung, Anhänge, Kommentare) in einklappbaren Bereich „Mehr" darunter
   — To-Do-Optik oben, Vikunja-Power unten.
5. Übersicht: Projekte als flache Zeilen statt dicker Ordner-Karten
   (kleines Listen-Icon in Projektfarbe, Zähler rechts, Personen-Symbol bei
   geteilten Projekten); Gruppen/Unterprojekte als einklappbare Knoten mit
   Führungslinie; „+ Neue Liste" als dezente Fußzeile links + „Neue
   Gruppe"-Symbol rechts (statt fettem Button); Smart-List-Reihenfolge und
   Benennung wie To Do („Erledigt" → „Abgeschlossen").
6. Bottom-Navigation (Home/Projects/Settings) entfernen; Einstellungen
   hinter den Avatar legen (Sheet wie 1.9), Projekte sind die Startseite.
   Projekt-Ansichten Gantt/Table/Kanban: raus aus der Hauptnavigation,
   optional über „…"-Menü erreichbar.
7. Projektseite: FAB durch „+ Aufgabe hinzufügen"-Leiste ersetzen
   (Konsistenz mit Mein Tag); Empty-State im To-Do-Stil (dezente Linien
   statt dunkler Illustration); Sort-Chip statt „Sortieren"-Pill.

P2 — Verhalten & Feinschliff
8. Swipes an To Do angleichen: leading = Mein Tag + Verschieben,
   trailing = Löschen (rot) mit Undo; **kein Abhaken per Swipe**.
   Long-Press = Reorder (nur bei manueller Sortierung).
9. Mein Tag: Datums-Untertitel ergänzen, Sonnen-Icon neben dem Titel
   entfernen, Vorschläge-Panel (Glühbirne, Später/Früher, „+") — war
   „bewusst verschoben", jetzt einplanen.
10. Composer: randloses Feld, Icon-Zeile (Mein Tag/Erinnerung/Fällig/Notiz)
    statt Projekt-Chip + Pfeil-Button; Return legt an und bleibt offen.
11. Scroll-Verhalten: Großtitel kollabiert in Navbar.
12. Geplant: helle Akzentvariante, Datums-Gruppenchips, Filter-Chip
    („Alles geplant" u. a.).
13. Erledigt-Kreis: gefüllt in Akzentfarbe + Haken, Titel durchgestrichen;
    Stern gefüllt in Akzentfarbe der Liste (aktuell immer Dunkelblau).
14. Listenoptionen-Sheet nach 1.6 (inkl. Design-ändern-Farbwahl aus den
    9 To-Do-Farben je hell/dunkel; Foto-Hintergründe optional später).
15. „Neue Liste"-Flow: sofort anlegen + Inline-Rename (wie To Do) statt
    Editor-Dialog.
16. Suche als Vollbild-Seite mit Empty-State-Text (in Aufgaben, Schritten
    und Notizen).

P3 — Nice-to-have / später
17. Foto-/Benutzerdefinierte Listen-Hintergründe, Liste drucken/duplizieren/
    Kopie senden, Sound bei Fertigstellung, Datumserkennung im Titel,
    App-Badge, Siri-Shortcuts, Heute-fällig-Push (vikunja-push nutzen).
18. Typografie-Entscheidung: To Do nutzt die System-Schrift; BOOS nutzt
    aktuell eine runde Display-Schrift (Quicksand-artig). Für „möglichst
    genau" → auf System-Schrift (SF/Roboto) wechseln; Alternative:
    Rundschrift bewusst als Markenelement behalten (mit Ingo klären).

---

## 5. Arbeitspakete

1. **AP0 Sprache & Politur (P0.1–P0.3)** — l10n-Keys vervollständigen
   (de für alle sichtbaren Strings), Datumsformatierung zentral
   (`due_date_format.dart`-Util), Sort-Chip-Komponente korrigieren.
   Kleine PRs, sofort.
2. **AP1 Detailseite** — Neuaufbau `task_edit_page.dart` als
   To-Do-Aktionsliste + „Mehr"-Sektion; Preset-Sheets (Erinnerung, Fällig,
   Wiederholen) als wiederverwendbare `ui/`-Sheets.
3. **AP2 Übersicht & Navigation** — flache Listenzeilen, Gruppenbaum,
   Fußzeile, Bottom-Nav-Entfernung, Einstellungen-Sheet hinter Avatar.
4. **AP3 Listen-Seite Verhalten** — Add-Bar statt FAB überall, Sort-Chip,
   Scroll-Kollaps, Erledigt-/Stern-Styling, Empty-States, Geplant-Variante
   mit Datumsgruppen.
5. **AP4 Gesten** — Swipe-Belegung wie To Do (inkl. „Verschieben"-Sheet),
   Undo-Snackbar beim Löschen, Long-Press-Reorder bei manueller Sortierung.
6. **AP5 Composer & Neue-Liste-Flow** — Composer-Icons, Serien-Eingabe,
   Inline-Anlegen von Listen, Listenoptionen-Sheet + Design-ändern.
7. **AP6 Mein Tag Vorschläge** — Vorschläge-Sheet (Später/Früher aus
   überfälligen/kommenden Aufgaben), Glühbirnen-Button.
8. **AP7 Extras (P3)** — nach Bedarf.

Jedes AP wie gehabt über Worktree-Agenten parallelisierbar; AP0 gehört in
die Hauptsession (viele geteilte Dateien: arb, Theme, ui/-Komponenten).
Goldens nach jedem AP aktualisieren (`flutter test --update-goldens
test/goldens`), UI-Guidelines (docs/ui-guidelines.md) gelten unverändert —
Farben über Theme-Rollen, keine Hardcodes; die Token-Tabelle aus Abschnitt 3
gehört als To-Do-Palette nach `lib/core/theming/`.

## 6. Umsetzungsstand (27.07.2026, Branch feat/ms-todo-ui)

**Umgesetzt (AP0–AP6 + Schrift):** vollständige deutsche l10n;
To-Do-Fälligkeitsformat (Gestern/Heute/Morgen bzw. „Mi. 22. Juli", rot);
Sort-Chip im To-Do-Stil; Detailseite als Aktionszeilen mit Preset-Sheets und
„Mehr"-Bereich; Übersicht mit flachen Zeilen, Gruppenbaum, To-Do-Reihenfolge
der Smart-Lists, Fußzeile, ohne Bottom-Navigation (Einstellungen hinter dem
Avatar); Add-Leiste statt FAB überall (akzentgetönt); Stern/Akzente in
Listenfarbe; „Geplant" hell mit Datums-Gruppenchips; „Mein Tag" mit
Datums-Untertitel und Vorschläge-Sheet; Swipes wie To Do (Mein Tag blau /
Verschieben orange / Löschen rot, kein Abhaken per Swipe); Composer mit
Erinnerung/Fälligkeit/Notiz; Listenoptionen-Sheet mit Farb-Design-Wahl;
„+ Neue Liste" legt sofort an; System-Schrift statt Quicksand.

**Zweite Runde (27.07. nachmittags) — ebenfalls umgesetzt:**
Titel-Kollaps in die Navbar (Smart-Lists + Projekte); „Liste löschen" durch
den ganzen Stack (PendingOp projectDelete, DataSource, OpExecutor,
OfflineWriter) mit To-Do-Bestätigungsdialog; Datumserkennung in Titeln
(heute/morgen/übermorgen/nächste Woche/Wochentage/31.12., Entfernen-Option,
beides abschaltbar); Erledigen-Sound (abschaltbar); drei neue
Einstellungs-Toggles; Einstellungen als hochgezogenes Sheet; Liste
duplizieren (inkl. offener Aufgaben); Kopie senden über das
System-Share-Sheet (Drucken über dessen Ziele); Foto-Listenhintergründe
(6 gebündelte Verläufe, je Liste wählbar, KeyValue-persistiert).

**Dritte Runde (27.07. abends) — ebenfalls umgesetzt:**
„Liste verschieben in…" (Gruppenzuordnung), Freigabe-Symbol in der Navbar +
Personen-Symbol bei geteilten Listen (fremder Besitzer), „Geplant"-Filter-Chip
(Alles geplant/Überfällig/Heute/Morgen/Diese Woche/Später), Smart-Lists
einzeln abschaltbar + „Leere intelligente Listen ausblenden", Composer mit
Mein-Tag-Sonne (addTaskReturningId), Neue Liste öffnet direkt den
Umbenennen-Dialog.

**Bekannte bewusste Näherungen:**
- Erledigen-Sound nutzt den System-Klick (kein eigenes Chime-Asset).
- Foto-Hintergründe sind generierte Verläufe statt lizenzierter Fotos.
- Heute-fällig-Push läuft weiter über vikunja-push serverseitig.
- Quicksand-Schrift liegt im Bundle, falls die Markenschrift zurück soll.

## 7. Bewusst NICHT übernommen aus To Do

Planner-Integration, Gekennzeichnete E-Mail, Microsoft-Konten („Konten
verwalten"), Drucken über AirPrint kann später kommen. Vikunja-Mehrwerte
(Kommentare, Anhänge, Zuweisungen, Labels, Priorität, Start-/Enddatum,
Kanban/Gantt/Tabelle) bleiben erhalten, wandern aber aus dem Hauptfluss in
den „Mehr"-Bereich bzw. das „…"-Menü, damit die To-Do-Optik führt.
