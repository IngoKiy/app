import 'package:flutter/material.dart';
import 'package:vikunja_app/core/theming/app_colors.dart';
import 'package:vikunja_app/core/utils/priority.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';

class PriorityBatch extends StatelessWidget {
  final int priority;

  const PriorityBatch(this.priority, {super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Badge(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      label: Text(priorityToString(loc, priority)),
      backgroundColor: getBackgroundColor(context, priority),
      textColor: getTextColor(context, priority),
    );
  }

  Color? getBackgroundColor(BuildContext context, int priority) {
    final appColors = context.appColors;
    switch (priority) {
      case 1:
        return appColors.success;
      case 2:
        return appColors.warning;
      case 3:
      case 4:
      case 5:
        return appColors.danger;
      default:
        return null;
    }
  }

  Color? getTextColor(BuildContext context, int priority) {
    final appColors = context.appColors;
    switch (priority) {
      case 1:
        return appColors.onSuccess;
      case 2:
        return appColors.onWarning;
      case 3:
      case 4:
      case 5:
        return appColors.onDanger;
      default:
        return null;
    }
  }
}
