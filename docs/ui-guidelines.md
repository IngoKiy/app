# UI-Guidelines (Designsystem)

Diese Regeln gelten für allen neuen UI-Code. Sie sind die Grundlage der
UI-Modernisierung (Branch `claude/flutter-ui-modernisierung-n2q81d`) und
sollen von allen parallel laufenden Arbeiten eingehalten werden, damit die
App über Android, iOS und Web einheitlich bleibt.

## Theming

- **Eine Theme-Quelle:** `buildAppTheme()` in `lib/core/theming/app_theme.dart`
  baut das komplette `ThemeData` — für die Vikunja-Farbschemata **und** für
  Material-You/dynamic-color. Neue Komponenten-Subthemes (Radien, Formen,
  Farben) gehören dorthin, nicht in einzelne Widgets.
- **Keine hard-coded Farben** (`Colors.grey`, `Color(0xFF…)`) in Widgets.
  Stattdessen:
  - `Theme.of(context).colorScheme.*` (z. B. `error`, `onSurfaceVariant`,
    `surfaceContainerHigh`, `outlineVariant`, `scrim`)
  - `context.appColors` (`success`/`warning`/`danger` + on-Farben) aus
    `lib/core/theming/app_colors.dart`
  - Ausnahme: Kontrastfarbe auf **benutzergewählten** Farben (Task-,
    Label-Farben) über `contrastingTextColor()` aus
    `lib/core/theming/color_utils.dart`; Vollbild-Medienviewer dürfen
    bewusst Schwarz nutzen.
- **Tokens:** Abstände/Radien aus `AppDimensions`
  (`lib/core/theming/dimensions.dart`), Breakpoints aus `AppBreakpoints`
  (`lib/core/theming/breakpoints.dart`).
- „Kein Farbwert" wird vom Server als Schwarz codiert → `task.hasCustomColor`
  verwenden, nicht gegen `Colors.black` vergleichen.

## Komponenten (`lib/presentation/widgets/ui/`)

| Statt … | Bitte … |
| --- | --- |
| rohe `TextButton`/`ElevatedButton`-Mischung | `AppButton` (`filled`/`tonal`/`outlined`/`text`/`danger`, `loading`, `expand`) |
| eigene Lösch-/Bestätigungs-`AlertDialog`s | `ConfirmationDialog` / `showConfirmationDialog()` |
| ad-hoc Empty-States | `EmptyState` |
| eigene `TextFormField`-Dekoration | `AppTextField` (erbt das globale `inputDecorationTheme`) |
| `Card` + manuelles Padding/Radius | `AppCard` |

Button-Regeln: Primäraktion = `filled`, Sekundär = `tonal`/`outlined`,
Dialog-Aktionen = `text`, destruktiv = `danger`.

Komponenten nehmen **Strings als Parameter** — `AppLocalizations` wird vom
Aufrufer aufgelöst, nie in der Komponente hart codiert (36 Sprachen!). Neue
Keys in `lib/l10n/app_en.arb` anlegen und `flutter gen-l10n` laufen lassen.

## Responsive

- Breakpoints: compact < 600, medium 600–1023, expanded ≥ 1024
  (`context.isCompact/isMedium/isExpanded` aus `widgets/ui/adaptive.dart`).
- Auf großen Screens Layout-**Struktur** ändern (NavigationRail,
  Master-Detail wie `ProjectSplitPage`), nicht skalieren.
- Einspaltige Inhalte in `ConstrainedPage` wrappen (max. 840 px).
- Modal-Bottom-Sheets auf breiten Screens mit `maxWidth: 640` begrenzen.

## Qualitätssicherung

- **Widgetbook** (`widgetbook/`, eigenes Package): neue geteilte Komponenten
  dort als Use-Case registrieren. Start: `cd widgetbook && flutter run -d chrome`.
- **Golden Tests** (`test/goldens/`, alchemist): bei visuellen Änderungen
  `flutter test --update-goldens test/goldens` ausführen; nur die
  deterministischen `goldens/ci/`-PNGs sind eingecheckt, Plattform-Goldens
  sind gitignored.
- Vor jedem Push: `dart format lib test`, `flutter analyze` (keine neuen
  Issues), `flutter test`.

## Abstimmung zwischen parallelen Sessions

- Vor jedem Push `git fetch` + Rebase auf den aktuellen Stand des eigenen
  Branches bzw. `main`; klein und häufig committen.
- Feature-Arbeit (z. B. Attachments/Assignees) bitte direkt mit den
  `ui/`-Komponenten und Theme-Rollen bauen — dann entfällt spätere Migration.
- Geteilte Dateien (`main.dart`, `theme_model.dart`, `app_theme.dart`)
  minimal und semantisch editieren, keine fremden Regionen umformatieren.
