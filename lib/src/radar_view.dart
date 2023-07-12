import 'package:flutter/material.dart';
import 'package:flutter_radar_view/src/default_radar_painter.dart';
import 'package:touchable/touchable.dart';

import '../flutter_radar_view.dart';
import 'helpers/default_cluster_function.dart';

/// The radar view widget.
class RadarView<T> extends StatefulWidget {
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
    this.shouldClusterSpots = true,
    this.clusterFn,
    this.onTapCluster,
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
  final List<Spot<T>> spots;

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
  final CustomRadarPainter<T>? customRadarPainter;

  /// The background color of the radar
  final Color? backgroundColor;

  /// The foreground color of the radar
  final Color? foregroundColor;

  /// Callback of click spot
  final Function(Spot, TapDownDetails)? onTapSpot;

  /// A function that clusters the spots
  final Map<RadarPosition, List<Spot<T>>> Function(List<Spot<T>> spots)?
      clusterFn;

  /// Whether or not the spots should be clustered
  /// Defaults to true
  /// If false, the clusterFn will not be called
  /// and the spots will be drawn as they are
  final bool shouldClusterSpots;

  /// The callback for when a cluster is tapped
  /// If null, the cluster will not be tappable
  final void Function(List<Spot<T>>, TapDownDetails)? onTapCluster;

  @override
  State<RadarView> createState() => _RadarViewState<T>();
}

class _RadarViewState<T> extends State<RadarView<T>>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final AnimationController _offsetAnimationController;
  late Tween<Offset> _offsetTween;
  late Animation<Offset> _offsetAnimation;
  Offset _currentOffset = const Offset(0, 0);

  late final AnimationController _scaleAnimationController;
  late Tween<double> _scaleTween;
  late Animation<double> _scaleAnimation;
  double _currentScale = 1.0;

  bool _dragable = true;
  bool _scalable = true;

  @override
  void initState() {
    _offsetAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _offsetTween = Tween(begin: Offset.zero, end: Offset.zero);
    _offsetAnimation = _offsetTween.animate(_offsetAnimationController)
      ..addListener(() {
        if (mounted) setState(() {});
      });

    _scaleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleTween = Tween(begin: 1.0, end: 1.0);
    _scaleAnimation = _scaleTween.animate(_scaleAnimationController)
      ..addListener(() {
        if (mounted) setState(() {});
      });

    widget.controller?.addListener(() {
      if (widget.controller!.shouldStartAnimation &&
          !widget.controller!.isAnimating) {
        _animateToNewPosition(widget.controller!.animationEndOffset);
      }

      if (widget.controller!.shouldStartScaleAnimation &&
          !widget.controller!.isScaleAnimating) {
        _animateToScale(widget.controller!.animationEndScale);
      }
    });

    super.initState();
  }

  // Animate the radar to a new scale
  void _animateToScale(double scale) async {
    if (scale <= 0 || scale == _currentScale) return;
    widget.controller!.isScaleAnimating = true;
    widget.controller!.shouldStartScaleAnimation = false;
    setState(() {
      _scalable = false;
    });
    _scaleTween.begin = _currentScale;
    _scaleAnimationController.reset();
    _scaleTween.end = scale;
    await _scaleAnimationController.forward();
    setState(() {
      _currentScale = scale;
    });
    widget.controller!.isScaleAnimating = false;
  }

  // Animate the radar to a new position
  void _animateToNewPosition(Offset position) async {
    widget.controller?.isAnimating = true;
    widget.controller?.shouldStartAnimation = false;
    setState(() {
      _dragable = false;
    });
    _offsetTween.begin = _currentOffset;
    _offsetAnimationController.reset();
    _offsetTween.end = position;
    await _offsetAnimationController.forward();
    setState(() {
      _currentOffset = position;
    });
    widget.controller?.isAnimating = false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                    _scalable = true;
                    _currentScale = details.scale;
                  });
                }
              },
              child: CanvasTouchDetector(
                gesturesToOverride: const [GestureType.onTapDown],
                builder: (context) {
                  RadarPainter<T> radarPainter = RadarPainter(
                    context: context,
                    offset: _dragable ? _currentOffset : _offsetAnimation.value,
                    constraints: constraints,
                    spots: widget.spots,
                    painter: widget.customRadarPainter ??
                        DefaultRadarPainter<T>(
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
                          scale:
                              _scalable ? _currentScale : _scaleAnimation.value,
                          shouldClusterSpots: widget.shouldClusterSpots,
                          clusterFn: widget.clusterFn,
                          onTapCluster: widget.onTapCluster,
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

  @override
  bool get wantKeepAlive => true;
}
