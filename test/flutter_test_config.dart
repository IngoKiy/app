import 'dart:async';
import 'dart:typed_data';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vikunja_app/core/theming/app_colors.dart';
import 'package:vikunja_app/core/theming/app_theme.dart';
import 'package:vikunja_app/core/theming/theme.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  const isRunningInCi = bool.fromEnvironment('CI');
  // Plattform-Goldens werden mit echten Fonts gerendert und unterscheiden
  // sich je Host-OS; committet sind nur die CI-Varianten (Ahem-basiert).
  // Lokal deshalb nur auf ausdrücklichen Wunsch rendern:
  //   flutter test --dart-define=PLATFORM_GOLDENS=true --update-goldens
  const platformGoldens = bool.fromEnvironment('PLATFORM_GOLDENS');

  // Auch die Ahem-basierten CI-Goldens weichen zwischen Linux und macOS
  // minimal ab (Antialiasing, <1 %). Kleine Toleranz statt Plattform-Zwang.
  if (goldenFileComparator is LocalFileComparator) {
    final basedir = (goldenFileComparator as LocalFileComparator).basedir;
    goldenFileComparator = _TolerantGoldenFileComparator(
      basedir.resolve('config.dart'),
    );
  }

  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      theme: buildAppTheme(
        colorScheme: MaterialTheme.lightScheme(),
        appColors: AppColors.light,
      ),
      platformGoldensConfig: const PlatformGoldensConfig(
        enabled: !isRunningInCi && platformGoldens,
      ),
    ),
    run: testMain,
  );
}

class _TolerantGoldenFileComparator extends LocalFileComparator {
  _TolerantGoldenFileComparator(super.testFile);

  /// Maximal erlaubte Abweichung (Anteil unterschiedlicher Pixel).
  static const double _tolerance = 0.01;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed) return true;
    if (result.diffPercent <= _tolerance) {
      debugPrint(
        'Golden "$golden": Abweichung ${(result.diffPercent * 100).toStringAsFixed(2)} % '
        'innerhalb der Toleranz (${(_tolerance * 100).toStringAsFixed(0)} %).',
      );
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    throw FlutterError(error);
  }
}
