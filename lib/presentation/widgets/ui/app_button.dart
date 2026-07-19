import 'package:flutter/material.dart';

enum AppButtonVariant { filled, tonal, outlined, text, danger }

/// Unified button for the app.
///
/// Usage rules: primary action per screen = [AppButtonVariant.filled],
/// secondary = [AppButtonVariant.tonal] or [AppButtonVariant.outlined],
/// dialog actions = [AppButtonVariant.text],
/// destructive = [AppButtonVariant.danger].
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;

  /// Stretches the button to the full available width.
  final bool expand;

  /// Shows a progress indicator instead of the label and disables the button.
  final bool loading;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.icon,
    this.expand = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = loading ? null : onPressed;
    final child = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Theme.of(context).colorScheme.primary,
            ),
          )
        : Text(label);

    Widget button;
    switch (variant) {
      case AppButtonVariant.filled:
        button = icon != null && !loading
            ? FilledButton.icon(
                onPressed: effectiveOnPressed,
                icon: Icon(icon),
                label: child,
              )
            : FilledButton(onPressed: effectiveOnPressed, child: child);
      case AppButtonVariant.tonal:
        button = icon != null && !loading
            ? FilledButton.tonalIcon(
                onPressed: effectiveOnPressed,
                icon: Icon(icon),
                label: child,
              )
            : FilledButton.tonal(onPressed: effectiveOnPressed, child: child);
      case AppButtonVariant.outlined:
        button = icon != null && !loading
            ? OutlinedButton.icon(
                onPressed: effectiveOnPressed,
                icon: Icon(icon),
                label: child,
              )
            : OutlinedButton(onPressed: effectiveOnPressed, child: child);
      case AppButtonVariant.text:
        button = icon != null && !loading
            ? TextButton.icon(
                onPressed: effectiveOnPressed,
                icon: Icon(icon),
                label: child,
              )
            : TextButton(onPressed: effectiveOnPressed, child: child);
      case AppButtonVariant.danger:
        final colorScheme = Theme.of(context).colorScheme;
        final style = FilledButton.styleFrom(
          backgroundColor: colorScheme.error,
          foregroundColor: colorScheme.onError,
        );
        button = icon != null && !loading
            ? FilledButton.icon(
                onPressed: effectiveOnPressed,
                style: style,
                icon: Icon(icon),
                label: child,
              )
            : FilledButton(
                onPressed: effectiveOnPressed,
                style: style,
                child: child,
              );
    }

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
