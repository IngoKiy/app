import 'package:flutter/material.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/widgets/ui/app_button.dart';

class TaskSaveDialog extends StatelessWidget {
  final Function onConfirm;
  final Function onCancel;

  const TaskSaveDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).unsavedChangesTitle),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Text(AppLocalizations.of(context).unsavedChangesMessage),
          ],
        ),
      ),
      actions: <Widget>[
        AppButton(
          label: AppLocalizations.of(context).dismiss,
          variant: AppButtonVariant.text,
          onPressed: () {
            onConfirm();
          },
        ),
        AppButton(
          label: AppLocalizations.of(context).keepEditing,
          onPressed: () {
            onCancel();
          },
        ),
      ],
    );
  }
}
