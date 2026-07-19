import 'package:flutter/material.dart';
import 'package:vikunja_app/core/theming/app_colors.dart';
import 'package:vikunja_app/core/theming/app_theme.dart';
import 'package:vikunja_app/core/theming/theme.dart';
import 'package:vikunja_app/l10n/gen/app_localizations.dart';
import 'package:widgetbook/widgetbook.dart';

import 'components.dart';
import 'foundations.dart';

void main() {
  runApp(const WidgetbookApp());
}

class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(
              name: 'Light',
              data: buildAppTheme(
                colorScheme: MaterialTheme.lightScheme(),
                appColors: AppColors.light,
              ),
            ),
            WidgetbookTheme(
              name: 'Dark',
              data: buildAppTheme(
                colorScheme: MaterialTheme.darkScheme(),
                appColors: AppColors.dark,
              ),
            ),
          ],
        ),
        ViewportAddon(Viewports.all),
        TextScaleAddon(min: 1.0, max: 2.0),
        LocalizationAddon(
          locales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          initialLocale: const Locale('en'),
        ),
        InspectorAddon(),
        AlignmentAddon(),
      ],
      directories: [
        WidgetbookCategory(name: 'Foundations', children: foundationComponents),
        WidgetbookCategory(name: 'Components', children: uiComponents),
      ],
    );
  }
}
