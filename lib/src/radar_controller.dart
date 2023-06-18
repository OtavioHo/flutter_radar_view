import 'dart:ui';

import 'package:flutter/foundation.dart';

/// A controller for the radar view
class RadarController extends ChangeNotifier {
  bool shouldStartAnimation = false;
  bool isAnimating = false;
  Offset animationEndOffset = Offset.zero;

  /// Animate the radar to a new position
  void animateTo(Offset offset) {
    shouldStartAnimation = true;
    animationEndOffset = offset;
    notifyListeners();
  }
}
