import 'package:flutter/material.dart';
import 'package:flutter_radar_view/src/spot.dart';
import 'package:touchable/touchable.dart';

abstract class RadarPainter extends CustomPainter {
  /// [rect] Defines the radar's boundaries, where the spots will be displayed.
  ///
  /// The radar will be centered within this rect.
  ///
  /// The background will still be painted in the full widget.
  ///
  /// Every spot outside the rect will be painted by the overflowIconPainter.
  RadarPainter({
    required this.context,
    required this.offset,
    required this.constraints,
    this.scale = 1.0,
    this.spots = const [],
    this.onTapSpot,
    this.backgroundColor,
    this.foregroundColor,
    Rect? rect,
  })  : rect = rect ??
            Rect.fromLTRB(
              20,
              20,
              constraints.maxWidth - 20,
              constraints.maxHeight - 20,
            ),
        assert(scale >= 0.0);

  /// The context of the widget that is using this painter.
  BuildContext context;

  /// The current offset of the radar.
  Offset offset;

  /// The constraints of the widget that is using this painter.
  BoxConstraints constraints;

  /// The current scale of the radar
  double scale = 1.0;

  /// The list of spots to be displayed in the radar
  List<Spot> spots;

  Rect rect;

  /// The callback for when a spot is tapped
  Function(Spot, TapDownDetails)? onTapSpot;

  /// The background color of the radar
  ///
  /// Defaults to the theme's background color
  Color? backgroundColor;

  /// The foreground color of the radar
  ///
  /// Defaults to the theme's primary color
  Color? foregroundColor;

  // A function that overrides the default spot painter
  void spotPainter(Spot spot, Canvas canvas, TouchyCanvas touchyCanvas);

  // A function that overrides the default overflow icon painter
  void overflowIconPainter(Spot spot, Canvas canvas, TouchyCanvas touchyCanvas);

  /// A function that overrides the default background painter
  void backgroundPainter(Canvas canvas, Size size);
}
