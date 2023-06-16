import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_radar_view/src/spot.dart';
import 'package:touchable/touchable.dart';

class RadarPainter extends CustomPainter {
  /// The Painter for the radar view
  RadarPainter({
    required this.context,
    required this.offset,
    required this.constraints,
    this.scale = 1.0,
    this.spots = const [],
    this.onTapSpot,
    this.backgroundColor,
    this.foregroundColor,
    this.backgroundPainter,
    this.spotPainter,
    Rect? rect,
  }) : rect = rect ??
            Rect.fromLTRB(
              20,
              20,
              constraints.maxWidth - 20,
              constraints.maxHeight - 20,
            );

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

  /// A function that overrides the default background painter
  Function(Canvas, Size)? backgroundPainter;

  /// A function that overrides the default spot painter
  Function(Spot, Canvas, TouchyCanvas)? spotPainter;

  _defaultSpotPainter(Spot spot, Canvas canvas, TouchyCanvas touchyCanvas) {
    final borderPaint = Paint()..color = Colors.black;
    final backgroundPaint = Paint()..color = Colors.white;

    touchyCanvas.drawCircle(
      spot.position(this),
      spot.size,
      borderPaint,
      onTapDown:
          onTapSpot != null ? (details) => onTapSpot!(spot, details) : null,
    );

    touchyCanvas.drawCircle(
      spot.position(this),
      spot.size - 2,
      backgroundPaint,
      onTapDown:
          onTapSpot != null ? (details) => onTapSpot!(spot, details) : null,
    );

    TextPainter textPainter = TextPainter(textDirection: TextDirection.rtl);
    textPainter.text = TextSpan(
      text: String.fromCharCode(spot.icon.codePoint),
      style: TextStyle(
          fontSize: 30.0,
          fontFamily: spot.icon.fontFamily,
          color: Colors.black),
    );
    textPainter.layout();
    textPainter.paint(canvas, spot.position(this).translate(-14, -14));
  }

  _defaultOverflowPainter(Spot spot, Canvas canvas, TouchyCanvas touchyCanvas) {
    Offset edgePosition;
    double dx;
    double dy;

    Offset position = spot.position(this);

    if (position.dx > rect.left) {
      dx = min(position.dx, rect.right);
    } else {
      dx = max(position.dx, rect.left);
    }
    if (position.dy > rect.top) {
      dy = min(position.dy, rect.bottom);
    } else {
      dy = max(position.dy, rect.left);
    }

    edgePosition = Offset(dx, dy);
    double theta = atan2(
      rect.center.dy - edgePosition.dy,
      rect.center.dx - edgePosition.dx,
    );

    TextPainter textPainter = TextPainter(textDirection: TextDirection.rtl);
    textPainter.text = TextSpan(
      text: String.fromCharCode(Icons.arrow_forward_ios.codePoint),
      style: TextStyle(
        fontSize: 30.0,
        fontFamily: Icons.arrow_forward_ios.fontFamily,
        color: Theme.of(context).colorScheme.onBackground,
      ),
    );
    textPainter.layout();

    canvas.save();
    canvas.translate(edgePosition.dx, edgePosition.dy);
    canvas.rotate(theta + pi);
    canvas.translate(-edgePosition.dx, -edgePosition.dy);
    textPainter.paint(canvas, edgePosition.translate(-14, -14));
    canvas.restore();
  }

  _paintSpots({
    required Canvas canvas,
    required TouchyCanvas touchyCanvas,
    required Spot spot,
    required Rect rect,
  }) {
    if (rect.contains(spot.position(this))) {
      if (spotPainter == null) {
        _defaultSpotPainter(spot, canvas, touchyCanvas);
      } else {
        spotPainter!(spot, canvas, touchyCanvas);
      }
    } else {
      _defaultOverflowPainter(spot, canvas, touchyCanvas);
    }
  }

  _paintBackground(Canvas canvas, Size size) {
    final ballpaint = Paint();
    ballpaint.color = foregroundColor ?? Theme.of(context).colorScheme.primary;
    ballpaint.style = PaintingStyle.stroke;

    final bgpaint = Paint();
    bgpaint.color = backgroundColor ?? Theme.of(context).colorScheme.background;

    var center = rect.center;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgpaint);
    for (var i = 0; i < 10; i++) {
      canvas.drawCircle(
        center.translate(offset.dx, offset.dy),
        50 * i.toDouble() * scale,
        ballpaint,
      );
    }

    ballpaint.style = PaintingStyle.fill;

    canvas.drawCircle(
      center.translate(offset.dx, offset.dy),
      15 * scale,
      ballpaint,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    if (backgroundPainter == null) {
      _paintBackground(canvas, size);
    } else {
      backgroundPainter!(canvas, size);
    }

    var touchyCanvas = TouchyCanvas(context, canvas);

    for (var spot in spots) {
      _paintSpots(
        canvas: canvas,
        touchyCanvas: touchyCanvas,
        spot: spot,
        rect: rect,
      );
    }
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) {
    if (oldDelegate.offset != offset) return true;
    if (oldDelegate.scale != scale) return true;
    if (oldDelegate.spots != spots) return true;
    return false;
  }
}
