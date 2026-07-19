# Offline-Architektur (Local-First) — im Umbau

**Status:** In Arbeit auf Branch `feat/offline-local-first` (Start 2026-07-19, orchestriert
von der Mac-Session). Meilensteine werden einzeln nach `main` gemergt.

## ⚠️ Hinweis an parallele Sessions

Die **Datenschicht ist im Umbau**: `data/repositories/*`, `presentation/manager/*`
und `core/di/*` werden auf eine lokale Drift/SQLite-Datenbank als Wahrheitsquelle
umgestellt. Bitte bis zum Abschluss:

- Diese Schichten **nur nach Absprache** anfassen (Merge-Konflikt-Gefahr hoch)
- Neue Features möglichst auf UI-Ebene bauen oder als eigene Branches von `main`
- `data/data_sources/*` bleibt stabil (wird zum reinen Sync-Transport) — dort sind
  additive Änderungen unkritisch

## Architektur (Kurzfassung)

- **Wahrheitsquelle der UI:** lokale Drift-DB (`lib/data/local/`), Controller lesen
  reaktive `watch*()`-Streams aus DAOs
- **Pull-Sync:** Vollabgleich (Vikunja hat keine Delta-API) in Reihenfolge
  users → labels → projects(+views) → buckets + tasks; Kommentare/Anhänge lazy.
  Merge: lokale dirty-Datensätze gewinnen bis zum Push; sonst Server-Upsert per
  `remote_id`; Tombstones werden nie wiederbelebt
- **Push-Sync:** Outbox (`pending_ops`-Tabelle), FIFO mit Abhängigkeitssortierung,
  Temp-IDs (negativ) für offline Erzeugtes, Mapping bei Create-Erfolg transaktional
  auf alle FKs + restliche Outbox; Konflikte = Last-Write-Wins
- **Offline-Start:** `init_controller` startet aus der DB, Sync läuft im Hintergrund
- **UI:** globaler Sync-/Offline-Banner (`MaterialApp.builder`), Sync-Status-Sheet
- Vollständiger Plan: siehe Meilensteine M1–M4 im Projektplan der Haupt-Session
