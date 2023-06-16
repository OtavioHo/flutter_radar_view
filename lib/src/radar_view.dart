import 'dart:math';

import 'package:flutter/material.dart';
import 'package:touchable/touchable.dart';

import '../flutter_radar_view.dart';
import 'default_radar_painter.dart';

class RadarView extends StatefulWidget {
  const RadarView({
    super.key,
    required this.spots,
    this.initialScale = 1.0,
    this.rect,
    this.isDragable = true,
    this.customRadarPainter,
  });

  /// The list of spots to be displayed in the radar
  final List<Spot> spots;

  /// The initial scale of the radar
  final double initialScale;

  /// The Rect param defines the radar's boundaries
  /// The spots will only be displayed within this rect.
  /// The radar will be centered within this rect.
  /// the background will still be painted in the full widget.
  /// Defaults to the widget constraints with 20px padding
  final Rect? rect;

  /// If the radar is dragable or not
  /// Defaults to true
  final bool isDragable;

  final RadarPainter? customRadarPainter;

  @override
  State<RadarView> createState() => _RadarViewState();
}

class _RadarViewState extends State<RadarView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _offsetAnimationController;
  late Tween<Offset> _offsetTween;
  late Animation<Offset> _offsetAnimation;
  Offset _currentOffset = const Offset(0, 0);
  bool _dragable = true;
  late double scale;

  @override
  void initState() {
    _offsetAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _offsetTween = Tween(begin: Offset.zero, end: Offset.zero);
    _offsetAnimation = _offsetTween.animate(_offsetAnimationController)
      ..addListener(() {
        setState(() {});
      });

    scale = widget.initialScale;
    super.initState();
  }

  void animateToNewPosition(Offset position) {
    _dragable = false;
    _offsetTween.begin = _currentOffset;
    _offsetAnimationController.reset();
    _offsetTween.end = position;
    _offsetAnimationController.forward();
    _currentOffset = position;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onScaleUpdate: (details) {
                if (widget.isDragable) {
                  setState(() {
                    _dragable = true;
                    _currentOffset = _currentOffset.translate(
                      details.focalPointDelta.dx,
                      details.focalPointDelta.dy,
                    );
                  });
                }

                if (details.pointerCount == 2) {
                  setState(() {
                    scale = details.scale;
                  });
                }
              },
              child: CanvasTouchDetector(
                gesturesToOverride: const [GestureType.onTapDown],
                builder: (context) => CustomPaint(
                  painter: widget.customRadarPainter ??
                      DefaultRadarPainter(
                        onTapSpot: (spot, details) =>
                            animateToNewPosition(Offset(
                          -spot.distance * cos(spot.theta) * scale,
                          -spot.distance * sin(spot.theta) * scale,
                        )),
                        context: context,
                        offset:
                            _dragable ? _currentOffset : _offsetAnimation.value,
                        constraints: constraints,
                        scale: scale,
                        spots: widget.spots,
                        rect: widget.rect,
                      ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
