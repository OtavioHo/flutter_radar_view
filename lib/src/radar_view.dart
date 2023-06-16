import 'dart:math';

import 'package:flutter/material.dart';
import 'package:touchable/touchable.dart';

import '../flutter_radar_view.dart';

class RadarView extends StatefulWidget {
  final List<Spot> spots;
  final double initialScale;
  const RadarView({
    super.key,
    required this.spots,
    this.initialScale = 1.0,
  });

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
                setState(() {
                  _dragable = true;
                  _currentOffset = _currentOffset.translate(
                    details.focalPointDelta.dx,
                    details.focalPointDelta.dy,
                  );
                });

                if (details.pointerCount == 2) {
                  setState(() {
                    scale = details.scale;
                  });
                }
              },
              child: CanvasTouchDetector(
                gesturesToOverride: const [GestureType.onTapDown],
                builder: (context) => CustomPaint(
                  painter: RadarPainter(
                    onTapSpot: (spot, details) => animateToNewPosition(Offset(
                      -spot.distance * cos(spot.theta) * scale,
                      -spot.distance * sin(spot.theta) * scale,
                    )),
                    context: context,
                    offset: _dragable ? _currentOffset : _offsetAnimation.value,
                    constraints: constraints,
                    scale: scale,
                    spots: widget.spots,
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
