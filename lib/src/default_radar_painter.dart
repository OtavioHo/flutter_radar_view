import '../flutter_radar_view.dart';

class DefaultRadarPainter<T> extends CustomRadarPainter<T> {
  /// The Default Painter for the radar view
  DefaultRadarPainter({
    super.scale,
    super.onTapSpot,
    super.backgroundColor,
    super.foregroundColor,
    required super.rect,
    super.clusterFn,
    super.onTapCluster,
    super.shouldClusterSpots,
  });
}
