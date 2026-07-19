import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/theming/app_colors.dart';

void main() {
  const base = AppColors(
    success: Color(0xFF111111),
    onSuccess: Color(0xFF222222),
    warning: Color(0xFF333333),
    onWarning: Color(0xFF444444),
    danger: Color(0xFF555555),
    onDanger: Color(0xFF666666),
  );

  group('AppColors.copyWith', () {
    test('returns identical values when called without arguments', () {
      final copy = base.copyWith();
      expect(copy.success, base.success);
      expect(copy.onSuccess, base.onSuccess);
      expect(copy.warning, base.warning);
      expect(copy.onWarning, base.onWarning);
      expect(copy.danger, base.danger);
      expect(copy.onDanger, base.onDanger);
    });

    test('overrides each field independently', () {
      const override = Color(0xFFABCDEF);
      expect(base.copyWith(success: override).success, override);
      expect(base.copyWith(onSuccess: override).onSuccess, override);
      expect(base.copyWith(warning: override).warning, override);
      expect(base.copyWith(onWarning: override).onWarning, override);
      expect(base.copyWith(danger: override).danger, override);
      expect(base.copyWith(onDanger: override).onDanger, override);
    });

    test('changing warning does not affect danger', () {
      const override = Color(0xFFABCDEF);
      final copy = base.copyWith(warning: override);
      expect(copy.warning, override);
      expect(copy.danger, base.danger);
    });
  });
}
