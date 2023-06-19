import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_radar_view/flutter_radar_view.dart';

/// The Spot class.
///
/// It represents a spot in the radar.
class Spot<T> {
  /// The distance from the center of the radar.
  final double distance;

  /// The angle of the spot in radians.
  late double theta;

  /// The icon of the spot.
  final IconData icon;

  /// The size of the spot.
  final double size;

  /// The data of the spot.
  final T? data;

  /// The position of the spot for a given painter.
  Offset painterPosition(RadarPainter painter) {
    Offset center = painter.painter.rect?.center ??
        painter.constraints.biggest.center(Offset.zero);

    return center
        .translate(
          distance * cos(theta) * painter.painter.scale,
          distance * sin(theta) * painter.painter.scale,
        )
        .translate(painter.offset.dx, painter.offset.dy);
  }

  /// The offset from the center of the radar with the scale 1.
  Offset offsetFromCenter() {
    return Offset(
      distance * cos(theta),
      distance * sin(theta),
    );
  }

  Spot({
    required this.distance,
    this.icon = Icons.add,
    this.size = 25,
    this.data,
  }) {
    theta = Random().nextDouble() * 2 * pi;
  }
}
