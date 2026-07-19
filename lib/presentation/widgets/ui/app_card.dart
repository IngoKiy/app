import 'package:flutter/material.dart';
import 'package:vikunja_app/core/theming/dimensions.dart';

/// Card with theme radius, optional tap handling and sensible padding.
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppDimensions.md),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    return Card(
      color: color,
      clipBehavior: onTap != null ? Clip.antiAlias : Clip.none,
      child: onTap != null ? InkWell(onTap: onTap, child: content) : content,
    );
  }
}
