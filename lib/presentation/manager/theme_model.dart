import 'package:flutter/material.dart';
import 'package:vikunja_app/core/theming/app_colors.dart';
import 'package:vikunja_app/core/theming/app_theme.dart';
import 'package:vikunja_app/core/theming/theme.dart';
import 'package:vikunja_app/core/theming/theme_mode.dart';

class ThemeModel {
  final FlutterThemeMode themeMode;
  final bool dynamicColors;

  ThemeModel({
    this.themeMode = FlutterThemeMode.light,
    this.dynamicColors = false,
  });

  ThemeData getTheme(ColorScheme? lightDynamic) {
    return buildAppTheme(
      colorScheme: (dynamicColors && lightDynamic != null)
          ? lightDynamic
          : MaterialTheme.lightScheme(),
      appColors: AppColors.light,
    );
  }

  ThemeData getDarkTheme(ColorScheme? darkDynamic) {
    return buildAppTheme(
      colorScheme: (dynamicColors && darkDynamic != null)
          ? darkDynamic
          : MaterialTheme.darkScheme(),
      appColors: AppColors.dark,
    );
  }

  ThemeMode getThemeMode() {
    switch (themeMode) {
      case FlutterThemeMode.light:
        return ThemeMode.light;
      case FlutterThemeMode.dark:
        return ThemeMode.dark;
      case FlutterThemeMode.system:
        return ThemeMode.system;
    }
  }

  ThemeModel copyWith({FlutterThemeMode? themeMode, bool? dynamicColors}) {
    return ThemeModel(
      themeMode: themeMode ?? this.themeMode,
      dynamicColors: dynamicColors ?? this.dynamicColors,
    );
  }
}
