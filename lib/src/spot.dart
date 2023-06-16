import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_radar_view/flutter_radar_view.dart';

class Spot<T> {
  final double distance;
  late double theta;
  final IconData icon;
  final double size;
  final T? data;

  Offset position(RadarPainter painter) => painter.rect.center
      .translate(
        distance * cos(theta) * painter.scale,
        distance * sin(theta) * painter.scale,
      )
      .translate(painter.offset.dx, painter.offset.dy);

  Spot({
    required this.distance,
    this.icon = Icons.add,
    this.size = 25,
    this.data,
  }) {
    theta = Random().nextDouble() * 2 * pi;
  }
}
