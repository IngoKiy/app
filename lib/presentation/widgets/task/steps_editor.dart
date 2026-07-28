import 'package:flutter/material.dart';
import 'package:vikunja_app/core/theming/dimensions.dart';
import 'package:vikunja_app/core/utils/task_steps.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:vikunja_app/presentation/widgets/task/round_checkbox.dart';

/// Schritte-Editor („Nächster Schritt", MS-To-Do-Stil).
///
/// Der Elternteil ([TaskEditPage]) hält die Schritte-Liste als eigenen
/// State und reicht sie samt Callbacks herein — dieses Widget selbst ist
/// von außen betrachtet zustandslos für die Daten; lokal verwaltet es nur
/// Fokus-Knoten, damit eine neu hinzugefügte Zeile sofort den Fokus bekommt.
class StepsEditor extends StatefulWidget {
  final List<TaskStep> steps;

  /// Text einer Zeile hat sich geändert (Debounce-Save durch den Elternteil).
  final void Function(int index, String text) onTextChanged;

  /// Zeile ab-/wieder aufgehakt (sofortiger Save durch den Elternteil).
  final void Function(int index, bool done) onToggle;

  /// Zeile entfernt (sofortiger Save durch den Elternteil).
  final void Function(int index) onRemove;

  /// Neue leere Zeile anfügen.
  final VoidCallback onAdd;

  const StepsEditor({
    super.key,
    required this.steps,
    required this.onTextChanged,
    required this.onToggle,
    required this.onRemove,
    required this.onAdd,
  });

  @override
  State<StepsEditor> createState() => _StepsEditorState();
}

class _StepsEditorState extends State<StepsEditor> {
  // Stabile IDs je Zeile (statt Index), damit TextFormField-Elemente ihrer
  // Zeile treu bleiben, wenn eine andere Zeile entfernt wird (sonst würde
  // Flutter den Text der falschen Zeile zuordnen). Add/Remove werden lokal
  // synchron mitgeführt, bevor der Elternteil informiert wird.
  final List<int> _rowIds = [];
  final Map<int, FocusNode> _focusNodes = {};
  int _nextId = 0;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.steps.length; i++) {
      _rowIds.add(_nextId++);
    }
  }

  @override
  void dispose() {
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  FocusNode _focusNodeFor(int rowId) =>
      _focusNodes.putIfAbsent(rowId, () => FocusNode());

  void _handleAdd() {
    setState(() => _rowIds.add(_nextId++));
    widget.onAdd();
    final newRowId = _rowIds.last;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodeFor(newRowId).requestFocus();
      }
    });
  }

  void _handleRemove(int index) {
    final rowId = _rowIds.removeAt(index);
    _focusNodes.remove(rowId)?.dispose();
    widget.onRemove(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < widget.steps.length; i++) ...[
          _buildStepRow(theme, i),
          Divider(
            height: 1,
            thickness: 1,
            indent: AppDimensions.taskRowTextInset,
            color: theme.colorScheme.outlineVariant,
          ),
        ],
        _buildAddRow(context, theme),
      ],
    );
  }

  Widget _buildStepRow(ThemeData theme, int index) {
    final step = widget.steps[index];
    final rowId = _rowIds[index];
    final baseStyle = theme.textTheme.bodyLarge;
    return Row(
      children: [
        RoundCheckbox(
          value: step.done,
          onChanged: (value) => widget.onToggle(index, value),
        ),
        const SizedBox(width: AppDimensions.taskRowGap),
        Expanded(
          child: TextFormField(
            key: ValueKey('step_row_$rowId'),
            focusNode: _focusNodeFor(rowId),
            initialValue: step.text,
            style: step.done
                ? baseStyle?.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: theme.colorScheme.onSurfaceVariant,
                  )
                : baseStyle,
            // Das globale InputDecorationTheme legt jede Zeile sonst in einen
            // grauen, umrandeten Kasten — To Do zeigt hier schlichte Zeilen
            // mit Trennlinie. `border` allein genügt nicht: enabledBorder und
            // focusedBorder aus dem Theme haben Vorrang und müssen einzeln
            // abgeräumt werden.
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (text) => widget.onTextChanged(index, text),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 18),
          color: theme.colorScheme.onSurfaceVariant,
          visualDensity: VisualDensity.compact,
          onPressed: () => _handleRemove(index),
        ),
      ],
    );
  }

  Widget _buildAddRow(BuildContext context, ThemeData theme) {
    return InkWell(
      onTap: _handleAdd,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            // Plus sitzt mittig über der Kreis-Spalte, damit es mit den
            // Checkboxen darüber fluchtet.
            SizedBox(
              width: AppDimensions.taskRowLeadingWidth,
              child: Icon(
                Icons.add,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppDimensions.taskRowGap),
            Text(
              AppLocalizations.of(context).stepAdd,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
