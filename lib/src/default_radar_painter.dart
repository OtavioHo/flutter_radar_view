import 'dart:math';

import 'package:flutter/material.dart';
import 'package:touchable/touchable.dart';

import '../flutter_radar_view.dart';

class DefaultRadarPainter extends CustomRadarPainter {
  /// The Default Painter for the radar view
  DefaultRadarPainter({
    super.scale,
    super.onTapSpot,
    super.backgroundColor,
    super.foregroundColor,
    required super.rect,
  });

  @override
  spotPainter(
    Spot spot,
    Canvas canvas,
    TouchyCanvas touchyCanvas,
    RadarPainter customPainter,
  ) {
    final borderPaint = Paint()..color = Colors.black;
    final backgroundPaint = Paint()..color = Colors.white;

    touchyCanvas.drawCircle(
      spot.position(customPainter),
      spot.size,
      borderPaint,
      onTapDown:
          onTapSpot != null ? (details) => onTapSpot!(spot, details) : null,
    );

    touchyCanvas.drawCircle(
      spot.position(customPainter),
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
    textPainter.paint(canvas, spot.position(customPainter).translate(-14, -14));
  }

  @override
  overflowIconPainter(
    Spot spot,
    Canvas canvas,
    TouchyCanvas touchyCanvas,
    RadarPainter customPainter,
  ) {
    Offset edgePosition;
    double dx;
    double dy;

    Offset position = spot.position(customPainter);

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

  @override
  backgroundPainter(Canvas canvas, Size size, RadarPainter customPainter) {
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
