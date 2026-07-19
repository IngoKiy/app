import 'package:flutter/material.dart';
import 'package:vikunja_app/core/theming/color_utils.dart';
import 'package:vikunja_app/domain/entities/label.dart';

class LabelWidget extends StatelessWidget {
  final Label label;
  final VoidCallback? onDelete;

  const LabelWidget({super.key, required this.label, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text(label.title, style: TextStyle(color: getTextColor())),
      backgroundColor:
          label.color ?? Theme.of(context).colorScheme.surfaceBright,
      iconTheme: IconThemeData(color: getTextColor()),
      onDeleted: onDelete,
    );
  }

  Color? getTextColor() {
    if (label.color != null) {
      return contrastingTextColor(label.color!);
    }
    return null;
  }
}
