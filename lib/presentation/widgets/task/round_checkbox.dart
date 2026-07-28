import 'package:flutter/material.dart';

/// Runde Checkbox im Stil von Microsoft To Do: leerer Kreis, der beim
/// Abhaken zum gefüllten Kreis mit Häkchen wird.
class RoundCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const RoundCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkResponse(
      radius: 22,
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: value ? scheme.primary : null,
            border: value
                ? null
                : Border.all(color: scheme.onSurfaceVariant, width: 2),
          ),
          child: value
              ? Icon(Icons.check, size: 16, color: scheme.onPrimary)
              : null,
        ),
      ),
    );
  }
}
