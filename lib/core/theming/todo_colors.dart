import 'package:flutter/material.dart';

/// Referenzfarben aus Microsoft To Do (gemessen, siehe
/// docs/ms-todo-parity.md Abschnitt 3). Bewusst konstante Markenfarben der
/// nachgebauten Optik — nur für Elemente verwenden, die im Vorbild exakt
/// diese Farben tragen (Swipe-Aktionen etc.); alles andere läuft weiter
/// über Theme-Rollen.
abstract final class TodoColors {
  /// Blau der „Mein Tag"-Swipe-Aktion und Aktions-Links.
  static const actionBlue = Color(0xFF436AF2);

  /// Orange der „Verschieben"-Swipe-Aktion.
  static const actionOrange = Color(0xFFE8A33D);

  /// Rot der Löschen-Swipe-Aktion.
  static const actionRed = Color(0xFFE32C2E);

  /// Listen-Farbpalette des „Design auswählen"-Panels (Reihenfolge wie im
  /// Vorbild: Blau, Lila, Magenta, Rot, Grün, Teal, Grau + helle Varianten).
  static const listPalette = [
    Color(0xFF6579C8),
    Color(0xFF8764B8),
    Color(0xFFC3487E),
    Color(0xFFD64550),
    Color(0xFF2E8B57),
    Color(0xFF068387),
    Color(0xFF69797E),
    Color(0xFFD4E5F6),
    Color(0xFFE5D9F2),
  ];
}
