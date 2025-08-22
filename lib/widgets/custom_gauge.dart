import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GaugePainter extends CustomPainter {
  final double speed;
  GaugePainter(this.speed);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 20;

    // Draw background arc (full range)
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    // Segments: green, yellow, red
    final greenArc = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;
    final yellowArc = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;
    final redArc = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    const startAngle = pi;          // 180 degrees
    const sweepAngle = pi;          // 180 degrees

    // Green segment (0-60)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * 0.25,
      false,
      greenArc,
    );

    // Yellow segment (60-150)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + sweepAngle * 0.25,
      sweepAngle * 0.4167,
      false,
      yellowArc,
    );

    // Red segment (150-240)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + sweepAngle * 0.6667,
      sweepAngle * 0.3333,
      false,
      redArc,
    );

    // Draw ticks and labels
    const totalTicks = 9; // e.g., every 30 km/h up to 240
    for (int i = 0; i <= totalTicks; i++) {
      final angle = startAngle + (sweepAngle / totalTicks) * i;
      final tickLength = 10.0;

      final p1 = Offset(
        center.dx + (radius - tickLength) * cos(angle),
        center.dy + (radius - tickLength) * sin(angle),
      );
      final p2 = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2,
      );

      // Draw label
      final labelPainter = TextPainter(
        text: TextSpan(
          text: '${i * 30}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();

      final labelOffset = Offset(
        center.dx + (radius - 25) * cos(angle) - labelPainter.width / 2,
        center.dy + (radius - 25) * sin(angle) - labelPainter.height / 2,
      );

      labelPainter.paint(canvas, labelOffset);
    }

    // Draw needle
    final needleAngle = startAngle + sweepAngle * (speed / 240);
    final needleLength = radius - 30;


    final needlePaint = Paint()

      ..color = Colors.lightBlueAccent
      ..strokeWidth = 4;


    canvas.drawLine(

      center,
      Offset(
        center.dx + needleLength * cos(needleAngle),
        center.dy + needleLength * sin(needleAngle),
      ),
      needlePaint,
    );

    // Draw center circle
    canvas.drawCircle(center, 10, Paint()..color = Colors.lightBlueAccent);

    // Draw digital speed
    final speedPainter = TextPainter(

      text: TextSpan(
        text: '${speed.toInt()} KM/H',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),


      textDirection: TextDirection.ltr,
    );
    speedPainter.layout();

    speedPainter.paint(
      canvas,
      Offset(center.dx - speedPainter.width / 2, center.dy + 40),
    );
  }


  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) {
    return oldDelegate.speed != speed;
  }
}

