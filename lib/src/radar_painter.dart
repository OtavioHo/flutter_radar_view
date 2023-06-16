import 'package:flutter/material.dart';
import 'package:flutter_radar_view/src/spot.dart';
import 'package:touchable/touchable.dart';

abstract class CustomRadarPainter {
  CustomRadarPainter({
    this.scale = 1.0,
    this.onTapSpot,
    this.backgroundColor,
    this.foregroundColor,
    this.rect,
  });

  /// The current scale of the radar
  double scale = 1.0;

  Rect? rect;

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
  void spotPainter(Spot spot, Canvas canvas, TouchyCanvas touchyCanvas,
      RadarPainter customPainter);

  // A function that overrides the default overflow icon painter
  void overflowIconPainter(Spot spot, Canvas canvas, TouchyCanvas touchyCanvas,
      RadarPainter customPainter);

  /// A function that overrides the default background painter
  void backgroundPainter(Canvas canvas, Size size, RadarPainter customPainter);
}

class RadarPainter extends CustomPainter {
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
    required this.spots,
    required this.painter,
  });

  /// The context of the widget that is using this painter.
  BuildContext context;

  /// The current offset of the radar.
  Offset offset;

  /// The constraints of the widget that is using this painter.
  BoxConstraints constraints;

  /// The list of spots to be displayed in the radar
  List<Spot> spots;

  /// The painter that will be used to paint the radar
  CustomRadarPainter painter;

  _paintSpots({
    required Canvas canvas,
    required TouchyCanvas touchyCanvas,
    required Spot spot,
    required Rect rect,
  }) {
    if (rect.contains(spot.position(this))) {
      painter.spotPainter(spot, canvas, touchyCanvas, this);
    } else {
      painter.overflowIconPainter(spot, canvas, touchyCanvas, this);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    painter.backgroundPainter(canvas, size, this);

    var touchyCanvas = TouchyCanvas(context, canvas);

    for (var spot in spots) {
      _paintSpots(
        canvas: canvas,
        touchyCanvas: touchyCanvas,
        spot: spot,
        rect: painter.rect ?? Rect.fromLTWH(0, 0, size.width, size.height),
      );
    }
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) {
    if (oldDelegate.offset != offset) return true;
    if (oldDelegate.painter.scale != painter.scale) return true;
    if (oldDelegate.spots != spots) return true;
    return false;
  }
}
