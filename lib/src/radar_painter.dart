import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_radar_view/src/spot.dart';
import 'package:touchable/touchable.dart';

class RadarPainter extends CustomPainter {
  BuildContext context;
  Offset offset;
  double scale = 1.0;
  List<Spot> spots;
  Rect rect;
  Function(Spot, TapDownDetails) onTapSpot;

  RadarPainter({
    required this.context,
    required this.offset,
    this.scale = 1.0,
    this.spots = const [],
    required this.onTapSpot,
  }) : rect = Rect.fromLTRB(
          20,
          20,
          MediaQuery.of(context).size.width - 20,
          MediaQuery.of(context).size.height - 20,
        );

  _paintSpot({
    required Canvas canvas,
    required TouchyCanvas touchyCanvas,
    required Offset center,
    required Offset offset,
    required Spot spot,
    required Rect rect,
  }) {
    final borderPaint = Paint()..color = Colors.black;
    final backgroundPaint = Paint()..color = Colors.white;
    const double spotSize = 25;

    Offset position = center
        .translate(
          spot.distance * cos(spot.theta) * scale,
          spot.distance * sin(spot.theta) * scale,
        )
        .translate(offset.dx, offset.dy);

    if (position.dx > rect.left - spotSize / 2 &&
        position.dx < rect.width + spotSize / 2 &&
        position.dy > rect.top - spotSize / 2 &&
        position.dy < rect.height + spotSize / 2) {
      touchyCanvas.drawCircle(
        position,
        spotSize,
        borderPaint,
        onTapDown: (details) => onTapSpot(spot, details),
      );

      touchyCanvas.drawCircle(
        position,
        spotSize - 2,
        backgroundPaint,
        onTapDown: (details) => onTapSpot(spot, details),
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
      textPainter.paint(canvas, position.translate(-14, -14));
    } else {
      Offset edgePosition;
      double dx;
      double dy;

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
        center.dy - edgePosition.dy,
        center.dx - edgePosition.dx,
      );

      TextPainter textPainter = TextPainter(textDirection: TextDirection.rtl);
      textPainter.text = TextSpan(
        text: String.fromCharCode(Icons.arrow_forward_ios.codePoint),
        style: TextStyle(
          fontSize: 30.0,
          fontFamily: Icons.arrow_forward_ios.fontFamily,
          color: Colors.black,
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
  }

  @override
  void paint(Canvas canvas, Size size) {
    final ballpaint = Paint();
    ballpaint.color = Colors.green;
    ballpaint.style = PaintingStyle.stroke;

    final bgpaint = Paint();
    bgpaint.color = Colors.yellow.withOpacity(0.2);

    var center = Offset(size.width / 2, size.height / 2);
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
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

    var touchyCanvas = TouchyCanvas(context, canvas);

    for (var spot in spots) {
      _paintSpot(
        canvas: canvas,
        touchyCanvas: touchyCanvas,
        center: center,
        offset: offset,
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
