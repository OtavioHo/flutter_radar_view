import 'dart:math';
import 'dart:ui';

import 'package:flutter_radar_view/flutter_radar_view.dart';

class RadarPosition {
  RadarPosition(this.distance, this.theta);

  final double distance;
  final double theta;

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

  @override
  int get hashCode => (distance.hashCode * 2) + (theta.hashCode * 3);

  @override
  bool operator ==(dynamic other) {
    if (other is! RadarPosition) return false;
    RadarPosition position = other;
    return position.distance == distance && position.theta == theta;
  }
}

Map<RadarPosition, List<Spot<T>>> defaultClusterFunction<T>(
    List<Spot<T>> spots, int p, int d) {
  Map<RadarPosition, List<Spot<T>>> clusters = {};

  for (var spot in spots) {
    int layer = (spot.distance ~/ d) + 1;
    double thetaDivisions = 2 * pi / p / layer;
    int quadrant = (spot.theta ~/ thetaDivisions) + 1;

    double distance = layer * d - (d / 2);
    double theta = thetaDivisions * quadrant - (thetaDivisions / 2);

    var position = RadarPosition(distance, theta);

    clusters[position] = [...clusters[position] ?? [], spot];
  }

  return clusters;
}
