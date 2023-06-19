import 'dart:ui';

import 'package:flutter/foundation.dart';

/// A controller for the radar view
class RadarController extends ChangeNotifier {
  /// Triggers the animation
  bool shouldStartAnimation = false;

  /// Is the animation currently running
  bool isAnimating = false;

  /// The end offset of the current/last animation
  Offset animationEndOffset = Offset.zero;

  /// Trugger the scale animation
  bool shouldStartScaleAnimation = false;

  /// Is the scale animation currently running
  bool isScaleAnimating = false;

  /// The end scale of the current/last animation
  double animationEndScale = 1.0;

  /// Animate the radar to a new position
  void animateTo(Offset offset) {
    shouldStartAnimation = true;
    animationEndOffset = offset;
    notifyListeners();
  }

  /// Animate the radar to a new scale
  void scaleTo(double scale) {
    shouldStartScaleAnimation = true;
    animationEndScale = scale;
    notifyListeners();
  }
}
