import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vikunja_app/core/di/database_provider.dart';
import 'package:vikunja_app/data/local/dao/key_value_dao.dart';

/// Lokale To-Do-Präferenzen (KeyValue-Store), analog zu Microsoft To Do:
/// „Sound bei Fertigstellung wiedergeben" und „Erkennen von Daten und Zeiten
/// in Aufgabentiteln". Beide Standard: an (wie im Vorbild).
const _kCompletionSound = 'pref/completion_sound';
const _kDateDetection = 'pref/date_detection';
const _kDateStrip = 'pref/date_strip';

final completionSoundEnabledProvider = StreamProvider<bool>(
  (ref) => ref
      .watch(keyValueDaoProvider)
      .watch(_kCompletionSound)
      .map((v) => v != '0'),
);

final dateDetectionEnabledProvider = StreamProvider<bool>(
  (ref) => ref
      .watch(keyValueDaoProvider)
      .watch(_kDateDetection)
      .map((v) => v != '0'),
);

final dateStripEnabledProvider = StreamProvider<bool>(
  (ref) =>
      ref.watch(keyValueDaoProvider).watch(_kDateStrip).map((v) => v != '0'),
);

Future<void> setDateStripEnabled(KeyValueDao kv, bool value) =>
    kv.set(_kDateStrip, value ? '1' : '0');

Future<void> setCompletionSoundEnabled(KeyValueDao kv, bool value) =>
    kv.set(_kCompletionSound, value ? '1' : '0');

Future<void> setDateDetectionEnabled(KeyValueDao kv, bool value) =>
    kv.set(_kDateDetection, value ? '1' : '0');

/// Bündelte „Foto"-Hintergründe für Listen (Design-Sheet, Tab Foto).
const listBackgroundAssets = [
  'assets/backgrounds/bg_ocean.png',
  'assets/backgrounds/bg_forest.png',
  'assets/backgrounds/bg_sunset.png',
  'assets/backgrounds/bg_lavender.png',
  'assets/backgrounds/bg_graphite.png',
  'assets/backgrounds/bg_mint.png',
];

/// Gewählter Foto-Hintergrund einer Liste (Asset-Pfad) oder `null`.
final listBackgroundProvider = StreamProvider.family<String?, String>(
  (ref, listKey) => ref.watch(keyValueDaoProvider).watch('list_bg/$listKey'),
);

Future<void> setListBackground(KeyValueDao kv, String listKey, String? asset) =>
    asset == null
    ? kv.remove('list_bg/$listKey')
    : kv.set('list_bg/$listKey', asset);

/// Spielt den Erledigt-Sound (Systemklick), wenn die Präferenz aktiv ist.
Future<void> playCompletionSound(KeyValueDao kv) async {
  final enabled = await kv.get(_kCompletionSound);
  if (enabled != '0') {
    await SystemSound.play(SystemSoundType.click);
  }
}
