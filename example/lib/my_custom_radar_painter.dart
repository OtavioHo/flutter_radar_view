import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_radar_view/flutter_radar_view.dart';

class MyCustomRadarPainter extends CustomRadarPainter {
  MyCustomRadarPainter({
    super.rect,
  });

  @override
  void backgroundPainter(canvas, size, customPainter) {
    final ballpaint = Paint();
    ballpaint.color = Colors.orange;
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
      canvas.drawPath(
        Path()
          ..addPolygon(
            [
              center.translate(
                customPainter.offset.dx + i * 100,
                customPainter.offset.dy,
              ),
              center.translate(
                customPainter.offset.dx,
                customPainter.offset.dy + i * 100,
              ),
              center.translate(
                customPainter.offset.dx - i * 100,
                customPainter.offset.dy,
              ),
              center.translate(
                customPainter.offset.dx,
                customPainter.offset.dy - i * 100,
              ),
            ],
            true,
          ),
        ballpaint,
      );
    }

    ballpaint.style = PaintingStyle.fill;

    canvas.drawPath(
      Path()
        ..addPolygon(
          [
            center.translate(
              customPainter.offset.dx + 30,
              customPainter.offset.dy,
            ),
            center.translate(
              customPainter.offset.dx,
              customPainter.offset.dy + 30,
            ),
            center.translate(
              customPainter.offset.dx - 30,
              customPainter.offset.dy,
            ),
            center.translate(
              customPainter.offset.dx,
              customPainter.offset.dy - 30,
            ),
          ],
          true,
        ),
      ballpaint,
    );
  }

  @override
  void overflowIconPainter(spot, canvas, touchyCanvas, customPainter) {
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

  @override
  void spotPainter(spot, canvas, touchyCanvas, customPainter) {
    final borderPaint = Paint()..color = Colors.black;
    final backgroundPaint = Paint()..color = Colors.white;

    touchyCanvas.drawRect(
      Rect.fromCircle(
        center: spot.painterPosition(customPainter),
        radius: spot.size,
      ),
      borderPaint,
      onTapDown:
          onTapSpot != null ? (details) => onTapSpot!(spot, details) : null,
    );

    touchyCanvas.drawRect(
      Rect.fromCircle(
        center: spot.painterPosition(customPainter),
        radius: spot.size - 2,
      ),
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
}
