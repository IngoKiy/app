import 'package:flutter/material.dart';
import 'package:vikunja_app/core/theming/theme.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color danger;
  final Color onDanger;

  const AppColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.danger,
    required this.onDanger,
  });

  static final light = AppColors(
    success: MaterialTheme.success.light.colorContainer,
    onSuccess: MaterialTheme.success.light.onColorContainer,
    warning: MaterialTheme.warning.light.colorContainer,
    onWarning: MaterialTheme.warning.light.onColorContainer,
    danger: MaterialTheme.danger.light.colorContainer,
    onDanger: MaterialTheme.danger.light.onColorContainer,
  );

  static final dark = AppColors(
    success: MaterialTheme.success.dark.color,
    onSuccess: MaterialTheme.success.dark.onColor,
    warning: MaterialTheme.warning.dark.color,
    onWarning: MaterialTheme.warning.dark.onColor,
    danger: MaterialTheme.danger.dark.color,
    onDanger: MaterialTheme.danger.dark.onColor,
  );

  @override
  AppColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? danger,
    Color? onDanger,
  }) => AppColors(
    success: success ?? this.success,
    onSuccess: onSuccess ?? this.onSuccess,
    warning: warning ?? this.warning,
    onWarning: onWarning ?? this.onWarning,
    danger: danger ?? this.danger,
    onDanger: onDanger ?? this.onDanger,
  );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  /// The [AppColors] installed by `buildAppTheme` — always present.
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
