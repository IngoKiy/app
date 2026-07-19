import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:vikunja_app/core/theming/breakpoints.dart';

/// Window-size-class helpers. Prefers the responsive_framework ancestor
/// installed in main.dart and falls back to MediaQuery so widgets stay
/// usable in tests and Widgetbook without a responsive wrapper.
extension AdaptiveContext on BuildContext {
  double get _windowWidth {
    final data =
        dependOnInheritedWidgetOfExactType<InheritedResponsiveBreakpoints>()
            ?.data;
    return data?.screenWidth ?? MediaQuery.sizeOf(this).width;
  }

  bool get isCompact => _windowWidth < AppBreakpoints.mediumMin;

  bool get isMedium =>
      _windowWidth >= AppBreakpoints.mediumMin &&
      _windowWidth < AppBreakpoints.expandedMin;

  bool get isExpanded => _windowWidth >= AppBreakpoints.expandedMin;
}
