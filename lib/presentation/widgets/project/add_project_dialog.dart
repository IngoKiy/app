import 'package:flutter/material.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/widgets/ui/app_button.dart';

class AddProjectDialog extends StatelessWidget {
  final ValueChanged<String> onAdd;
  final TextEditingController textController = TextEditingController();

  AddProjectDialog({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(16.0),
      content: TextField(
        autofocus: true,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).project,
          hintText: AppLocalizations.of(context).projectExample,
        ),
        controller: textController,
      ),
      actions: <Widget>[
        AppButton(
          label: AppLocalizations.of(context).cancel,
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.pop(context),
        ),
        AppButton(
          label: AppLocalizations.of(context).add,
          onPressed: () {
            if (textController.text.isNotEmpty) {
              onAdd(textController.text);
            }
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
