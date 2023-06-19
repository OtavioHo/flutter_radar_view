import 'dart:math';

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
      RadarPainter customPainter) {
    final borderPaint = Paint()..color = Colors.black;
    final backgroundPaint = Paint()..color = Colors.white;

    touchyCanvas.drawCircle(
      spot.painterPosition(customPainter),
      spot.size,
      borderPaint,
      onTapDown:
          onTapSpot != null ? (details) => onTapSpot!(spot, details) : null,
    );

    touchyCanvas.drawCircle(
      spot.painterPosition(customPainter),
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
    textPainter.paint(
        canvas, spot.painterPosition(customPainter).translate(-14, -14));
  }

  // A function that overrides the default overflow icon painter
  void overflowIconPainter(Spot spot, Canvas canvas, TouchyCanvas touchyCanvas,
      RadarPainter customPainter) {
    Offset edgePosition;
    double dx;
    double dy;

    Offset position = spot.painterPosition(customPainter);

    final Rect consideredRect = rect ??
        Rect.fromLTWH(
          0,
          0,
          customPainter.constraints.maxWidth,
          customPainter.constraints.maxHeight,
        );

    if (position.dx > consideredRect.left) {
      dx = min(position.dx, consideredRect.right);
    } else {
      dx = max(position.dx, consideredRect.left);
    }
    if (position.dy > consideredRect.top) {
      dy = min(position.dy, consideredRect.bottom);
    } else {
      dy = max(position.dy, consideredRect.left);
    }

    edgePosition = Offset(dx, dy);
    double theta = atan2(
      consideredRect.center.dy - edgePosition.dy,
      consideredRect.center.dx - edgePosition.dx,
    );

    TextPainter textPainter = TextPainter(textDirection: TextDirection.rtl);
    textPainter.text = TextSpan(
      text: String.fromCharCode(Icons.arrow_forward_ios.codePoint),
      style: TextStyle(
        fontSize: 30.0,
        fontFamily: Icons.arrow_forward_ios.fontFamily,
        color: Theme.of(customPainter.context).colorScheme.onBackground,
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

  /// A function that overrides the default background painter
  void backgroundPainter(Canvas canvas, Size size, RadarPainter customPainter) {
    final ballpaint = Paint();
    ballpaint.color =
        foregroundColor ?? Theme.of(customPainter.context).colorScheme.primary;
    ballpaint.style = PaintingStyle.stroke;

    final bgpaint = Paint();
    bgpaint.color = backgroundColor ??
        Theme.of(customPainter.context).colorScheme.background;

    final Rect consideredRect = rect ??
        Rect.fromLTWH(
          0,
          0,
          customPainter.constraints.maxWidth,
          customPainter.constraints.maxHeight,
        );

    var center = consideredRect.center;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgpaint);
    for (var i = 0; i < 10; i++) {
      canvas.drawCircle(
        center.translate(customPainter.offset.dx, customPainter.offset.dy),
        50 * i.toDouble() * scale,
        ballpaint,
      );
    }

    ballpaint.style = PaintingStyle.fill;

    canvas.drawCircle(
      center.translate(customPainter.offset.dx, customPainter.offset.dy),
      15 * scale,
      ballpaint,
    );
  }
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
    if (rect.contains(spot.painterPosition(this))) {
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
