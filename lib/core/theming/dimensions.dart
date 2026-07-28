/// Design tokens for spacing, corner radii and layout sizing.
abstract final class AppDimensions {
  // Spacing scale
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  // Corner radii
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusDialog = 28;

  // Layout
  static const double maxContentWidth = 840;
  static const double masterPaneWidth = 320;

  // Aufgaben-Detailseite: In Microsoft To Do stehen Checkbox, Schritt-Kreise
  // und die Icons der Aktionszeilen in einer gemeinsamen Spalte, alle Texte
  // beginnen an derselben Kante. [taskRowLeadingWidth] ist die Breite dieser
  // Spalte (24er Symbol + 8 Luft je Seite, wie in RoundCheckbox),
  // [taskRowGap] der Abstand bis zum Text.
  static const double taskRowLeadingWidth = 40;
  static const double taskRowGap = 12;
  static const double taskRowTextInset = taskRowLeadingWidth + taskRowGap;
}
