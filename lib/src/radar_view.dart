import 'package:flutter/material.dart';
import 'package:flutter_radar_view/src/default_radar_painter.dart';
import 'package:touchable/touchable.dart';

import '../flutter_radar_view.dart';

class RadarView extends StatefulWidget {
  const RadarView({
    super.key,
    this.controller,
    required this.spots,
    this.initialScale = 1.0,
    this.rect,
    this.isDragable = true,
    this.customRadarPainter,
    this.backgroundColor,
    this.foregroundColor,
    this.onTapSpot,
  })  : assert(
          customRadarPainter == null || backgroundColor == null,
          'You can\'t use a custom painter and a background color at the same time, define the background color in your custom painter',
        ),
        assert(
          customRadarPainter == null || foregroundColor == null,
          'You can\'t use a custom painter and a foreground color at the same time, define the foreground color in your custom painter',
        ),
        assert(
          customRadarPainter == null || onTapSpot == null,
          'You can\'t use a custom painter and a onTapSpot at the same time, define the onTapSpot in your custom painter',
        ),
        assert(
          customRadarPainter == null || rect == null,
          'You can\'t use a custom painter and a rect at the same time, define the rect in your custom painter',
        );

  /// Controller
  final RadarController? controller;

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

  /// A custom painter for the radar
  final CustomRadarPainter? customRadarPainter;

  /// The background color of the radar
  final Color? backgroundColor;

  /// The foreground color of the radar
  final Color? foregroundColor;

  /// Callback of click spot
  final Function(Spot, TapDownDetails)? onTapSpot;

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

    widget.controller?.addListener(() {
      if (widget.controller!.shouldStartAnimation &&
          !widget.controller!.isAnimating) {
        animateToNewPosition(widget.controller!.animationEndOffset);
      }
    });

    super.initState();
  }

  void animateToNewPosition(Offset position) async {
    widget.controller?.isAnimating = true;
    widget.controller?.shouldStartAnimation = false;
    _dragable = false;
    _offsetTween.begin = _currentOffset;
    _offsetAnimationController.reset();
    _offsetTween.end = position;
    await _offsetAnimationController.forward();
    _currentOffset = position;
    widget.controller?.isAnimating = false;
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
                builder: (context) {
                  RadarPainter radarPainter = RadarPainter(
                    context: context,
                    offset: _dragable ? _currentOffset : _offsetAnimation.value,
                    constraints: constraints,
                    spots: widget.spots,
                    painter: widget.customRadarPainter ??
                        DefaultRadarPainter(
                          rect: widget.rect ??
                              Rect.fromLTRB(
                                20,
                                20,
                                constraints.maxWidth - 20,
                                constraints.maxHeight - 20,
                              ),
                          backgroundColor: widget.backgroundColor,
                          foregroundColor: widget.foregroundColor,
                          onTapSpot: widget.onTapSpot,
                          scale: scale,
                        ),
                  );

                  return CustomPaint(painter: radarPainter);
                },
              ),
            ),
          ),
        ],
      );
    });
  }
}
