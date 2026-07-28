import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vikunja_app/core/theming/color_utils.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/domain/entities/project.dart';
import 'package:vikunja_app/presentation/manager/project_controller.dart';
import 'package:vikunja_app/presentation/widgets/task/color_picker_dialog.dart';
import 'package:vikunja_app/presentation/widgets/ui/app_button.dart';
import 'package:vikunja_app/presentation/widgets/ui/constrained_page.dart';

class ProjectEditPage extends ConsumerStatefulWidget {
  final Project project;
  final bool displayDoneTask;

  const ProjectEditPage({
    super.key,
    required this.project,
    required this.displayDoneTask,
  });

  @override
  ProjectEditPageState createState() => ProjectEditPageState();
}

class ProjectEditPageState extends ConsumerState<ProjectEditPage> {
  final _formKey = GlobalKey<FormState>();

  String? title;
  String? description;
  bool? displayDoneTask;
  Color? _color;

  @override
  void initState() {
    displayDoneTask = widget.displayDoneTask;
    _color = widget.project.color;

    super.initState();
  }

  @override
  Widget build(BuildContext ctx) {
    final l10n = AppLocalizations.of(ctx);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProjectTitle)),
      body: ConstrainedPage(
        child: Builder(
          builder: (BuildContext context) => Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: TextFormField(
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    initialValue: widget.project.title,
                    validator: (title) {
                      if (title == null) {
                        return l10n.title;
                      }

                      if (title.isEmpty || title.length > 250) {
                        return 'The title needs to have between 1 and 250 characters.';
                      }

                      return null;
                    },
                    onSaved: (value) {
                      title = value;
                    },
                    decoration: InputDecoration(
                      labelText: l10n.title,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: TextFormField(
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    initialValue: widget.project.description,
                    validator: (description) {
                      if (description == null) return null;
                      if (description.length > 1000) {
                        return 'The description can have a maximum of 1000 characters.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      description = value;
                    },
                    decoration: InputDecoration(
                      labelText: l10n.description,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: _buildColor(context, l10n),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: CheckboxListTile(
                    value: displayDoneTask,
                    title: Text(l10n.showDoneTasks),
                    onChanged: (value) {
                      value ??= false;

                      setState(() {
                        displayDoneTask = value;
                      });
                    },
                  ),
                ),
                Builder(
                  builder: (context) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: AppButton(
                      label: l10n.save,
                      expand: true,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState?.save();
                          _saveProject(ref, widget.project);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColor(BuildContext context, AppLocalizations l10n) {
    final color = _color;
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 15, left: 2),
          child: Icon(
            Icons.palette,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        ElevatedButton(
          style: color == null
              ? null
              : ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith(
                    (_) => color,
                  ),
                ),
          onPressed: _onColorEdit,
          child: Text(
            l10n.listColor,
            style: color == null
                ? null
                : TextStyle(color: contrastingTextColor(color)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Text(
            color != null ? "#${color.toHexString()}" : l10n.none,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  void _onColorEdit() {
    final pickerColor = _color ?? Colors.black;
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(pickerColor, (color) {
        setState(() {
          _color = color == Colors.black ? null : color;
        });
        Navigator.of(context).pop();
      }, () => Navigator.of(context).pop()),
    );
  }

  Future<void> _saveProject(WidgetRef ref, Project project) async {
    if (_formKey.currentState?.validate() == true) {
      var context = ref.context;
      final loc = AppLocalizations.of(context);

      _formKey.currentState?.save();

      project.title = title!;
      project.description = description!;
      project.color = _color;

      var success = await ref
          .read(projectControllerProvider(project).notifier)
          .updateProject(project);

      if (success && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.projectUpdatedSuccess)));

        Navigator.of(context).pop();

        await ref
            .read(projectControllerProvider(project).notifier)
            .setDisplayDoneTasks(displayDoneTask!);
      } else if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.projectUpdateError)));
      }
    }
  }
}
