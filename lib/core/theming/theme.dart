import "package:flutter/material.dart";

class MaterialTheme {
  /// BOOS-Markenfarbe (Stahlblau aus dem App-Icon).
  static const Color brandSeed = Color(0xFF264685);

  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return ColorScheme.fromSeed(
      seedColor: brandSeed,
      brightness: Brightness.light,
      contrastLevel: 0.0,
      dynamicSchemeVariant: DynamicSchemeVariant.content,
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return ColorScheme.fromSeed(
      seedColor: brandSeed,
      brightness: Brightness.light,
      contrastLevel: 0.5,
      dynamicSchemeVariant: DynamicSchemeVariant.content,
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return ColorScheme.fromSeed(
      seedColor: brandSeed,
      brightness: Brightness.light,
      contrastLevel: 1.0,
      dynamicSchemeVariant: DynamicSchemeVariant.content,
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return ColorScheme.fromSeed(
      seedColor: brandSeed,
      brightness: Brightness.dark,
      contrastLevel: 0.0,
      dynamicSchemeVariant: DynamicSchemeVariant.content,
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return ColorScheme.fromSeed(
      seedColor: brandSeed,
      brightness: Brightness.dark,
      contrastLevel: 0.5,
      dynamicSchemeVariant: DynamicSchemeVariant.content,
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return ColorScheme.fromSeed(
      seedColor: brandSeed,
      brightness: Brightness.dark,
      contrastLevel: 1.0,
      dynamicSchemeVariant: DynamicSchemeVariant.content,
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
  );

  /// success
  static const success = ExtendedColor(
    seed: Color(0xff00db60),
    value: Color(0xff00db60),
    light: ColorFamily(
      color: Color(0xff006e2c),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff00db60),
      onColorContainer: Color(0xff005a23),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff006e2c),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff00db60),
      onColorContainer: Color(0xff005a23),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff006e2c),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xff00db60),
      onColorContainer: Color(0xff005a23),
    ),
    dark: ColorFamily(
      color: Color(0xff43f879),
      onColor: Color(0xff003913),
      colorContainer: Color(0xff00db60),
      onColorContainer: Color(0xff005a23),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xff43f879),
      onColor: Color(0xff003913),
      colorContainer: Color(0xff00db60),
      onColorContainer: Color(0xff005a23),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xff43f879),
      onColor: Color(0xff003913),
      colorContainer: Color(0xff00db60),
      onColorContainer: Color(0xff005a23),
    ),
  );

  /// danger
  static const danger = ExtendedColor(
    seed: Color(0xffff4136),
    value: Color(0xffff4136),
    light: ColorFamily(
      color: Color(0xffbb020c),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffe02923),
      onColorContainer: Color(0xfffffbff),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xffbb020c),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffe02923),
      onColorContainer: Color(0xfffffbff),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xffbb020c),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffe02923),
      onColorContainer: Color(0xfffffbff),
    ),
    dark: ColorFamily(
      color: Color(0xffffb4aa),
      onColor: Color(0xff690003),
      colorContainer: Color(0xffff5446),
      onColorContainer: Color(0xff4f0002),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffffb4aa),
      onColor: Color(0xff690003),
      colorContainer: Color(0xffff5446),
      onColorContainer: Color(0xff4f0002),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffffb4aa),
      onColor: Color(0xff690003),
      colorContainer: Color(0xffff5446),
      onColorContainer: Color(0xff4f0002),
    ),
  );

  /// warning
  static const warning = ExtendedColor(
    seed: Color(0xffff851b),
    value: Color(0xffff851b),
    light: ColorFamily(
      color: Color(0xff964900),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffff851b),
      onColorContainer: Color(0xff612d00),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff964900),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffff851b),
      onColorContainer: Color(0xff612d00),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff964900),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffff851b),
      onColorContainer: Color(0xff612d00),
    ),
    dark: ColorFamily(
      color: Color(0xffffb787),
      onColor: Color(0xff502400),
      colorContainer: Color(0xffff851b),
      onColorContainer: Color(0xff612d00),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffffb787),
      onColor: Color(0xff502400),
      colorContainer: Color(0xffff851b),
      onColorContainer: Color(0xff612d00),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffffb787),
      onColor: Color(0xff502400),
      colorContainer: Color(0xffff851b),
      onColorContainer: Color(0xff612d00),
    ),
  );

  List<ExtendedColor> get extendedColors => [success, danger, warning];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
