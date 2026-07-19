import 'package:flutter/material.dart';

/// Returns a legible text color (black or white) for an arbitrary,
/// user-chosen background color such as task, label or bucket colors.
/// Theme roles cannot be used here because the background is not a
/// theme surface.
Color contrastingTextColor(Color background) =>
    background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
