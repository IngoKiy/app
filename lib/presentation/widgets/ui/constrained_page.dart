import 'package:flutter/material.dart';
import 'package:vikunja_app/core/theming/dimensions.dart';

/// Centers its child and limits its width on wide screens so single-pane
/// content does not stretch across the whole window.
class ConstrainedPage extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ConstrainedPage({
    super.key,
    required this.child,
    this.maxWidth = AppDimensions.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
