import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:vikunja_app/core/theming/app_colors.dart';
import 'package:vikunja_app/core/theming/app_theme.dart';
import 'package:vikunja_app/core/theming/theme.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  const isRunningInCi = bool.fromEnvironment('CI');
  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      theme: buildAppTheme(
        colorScheme: MaterialTheme.lightScheme(),
        appColors: AppColors.light,
      ),
      // Platform goldens are rendered with real fonts and differ between
      // host OSes; only the CI variants (Ahem-based, deterministic) are
      // committed.
      platformGoldensConfig: const PlatformGoldensConfig(
        enabled: !isRunningInCi,
      ),
    ),
    run: testMain,
  );
}
