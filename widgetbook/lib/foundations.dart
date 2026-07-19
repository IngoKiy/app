import 'package:flutter/material.dart';
import 'package:vikunja_app/core/theming/app_colors.dart';
import 'package:vikunja_app/core/theming/dimensions.dart';
import 'package:widgetbook/widgetbook.dart';

final foundationComponents = <WidgetbookNode>[
  WidgetbookComponent(
    name: 'Colors',
    useCases: [
      WidgetbookUseCase(name: 'Color scheme', builder: (_) => _SchemeGrid()),
      WidgetbookUseCase(
        name: 'Semantic colors',
        builder: (_) => _SemanticColors(),
      ),
    ],
  ),
  WidgetbookComponent(
    name: 'Typography',
    useCases: [
      WidgetbookUseCase(name: 'Type scale', builder: (_) => _TypeScale()),
    ],
  ),
  WidgetbookComponent(
    name: 'Spacing & Radii',
    useCases: [
      WidgetbookUseCase(name: 'Tokens', builder: (_) => _SpacingTokens()),
    ],
  ),
];

class _Swatch extends StatelessWidget {
  final String name;
  final Color color;
  final Color onColor;

  const _Swatch(this.name, this.color, this.onColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 64,
      padding: const EdgeInsets.all(AppDimensions.xs),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Text(name, style: TextStyle(color: onColor, fontSize: 12)),
    );
  }
}

class _SchemeGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final entries = <(String, Color, Color)>[
      ('primary', scheme.primary, scheme.onPrimary),
      ('primaryContainer', scheme.primaryContainer, scheme.onPrimaryContainer),
      ('secondary', scheme.secondary, scheme.onSecondary),
      (
        'secondaryContainer',
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
      ),
      ('tertiary', scheme.tertiary, scheme.onTertiary),
      ('error', scheme.error, scheme.onError),
      ('surface', scheme.surface, scheme.onSurface),
      ('surfaceContainerLow', scheme.surfaceContainerLow, scheme.onSurface),
      ('surfaceContainer', scheme.surfaceContainer, scheme.onSurface),
      ('surfaceContainerHigh', scheme.surfaceContainerHigh, scheme.onSurface),
      ('outline', scheme.outline, scheme.surface),
      ('outlineVariant', scheme.outlineVariant, scheme.onSurface),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Wrap(
        spacing: AppDimensions.xs,
        runSpacing: AppDimensions.xs,
        children: [
          for (final (name, color, onColor) in entries)
            _Swatch(name, color, onColor),
        ],
      ),
    );
  }
}

class _SemanticColors extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Wrap(
        spacing: AppDimensions.xs,
        runSpacing: AppDimensions.xs,
        children: [
          _Swatch('success', appColors.success, appColors.onSuccess),
          _Swatch('warning', appColors.warning, appColors.onWarning),
          _Swatch('danger', appColors.danger, appColors.onDanger),
        ],
      ),
    );
  }
}

class _TypeScale extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final styles = <(String, TextStyle?)>[
      ('displaySmall', textTheme.displaySmall),
      ('headlineMedium', textTheme.headlineMedium),
      ('titleLarge', textTheme.titleLarge),
      ('titleMedium', textTheme.titleMedium),
      ('titleSmall', textTheme.titleSmall),
      ('bodyLarge', textTheme.bodyLarge),
      ('bodyMedium', textTheme.bodyMedium),
      ('bodySmall', textTheme.bodySmall),
      ('labelLarge', textTheme.labelLarge),
      ('labelSmall', textTheme.labelSmall),
    ];
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.md),
      children: [
        for (final (name, style) in styles)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.sm),
            child: Text(name, style: style),
          ),
      ],
    );
  }
}

class _SpacingTokens extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spacings = <(String, double)>[
      ('xxs', AppDimensions.xxs),
      ('xs', AppDimensions.xs),
      ('sm', AppDimensions.sm),
      ('md', AppDimensions.md),
      ('lg', AppDimensions.lg),
      ('xl', AppDimensions.xl),
    ];
    final radii = <(String, double)>[
      ('radiusSm', AppDimensions.radiusSm),
      ('radiusMd', AppDimensions.radiusMd),
      ('radiusLg', AppDimensions.radiusLg),
      ('radiusDialog', AppDimensions.radiusDialog),
    ];
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.md),
      children: [
        for (final (name, value) in spacings)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.xs),
            child: Row(
              children: [
                SizedBox(width: 100, child: Text('$name ($value)')),
                Container(
                  width: value * 4,
                  height: AppDimensions.md,
                  color: scheme.primary,
                ),
              ],
            ),
          ),
        const SizedBox(height: AppDimensions.lg),
        Wrap(
          spacing: AppDimensions.xs,
          children: [
            for (final (name, value) in radii)
              Container(
                width: 120,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(value),
                ),
                child: Text('$name ($value)'),
              ),
          ],
        ),
      ],
    );
  }
}
