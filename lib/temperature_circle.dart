import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TemperatureCircle extends StatelessWidget {
  const TemperatureCircle({
    required this.temperature,
    required this.minTemperature,
    required this.maxTemperature,
    this.targetTemperature,
    this.label,
    this.enabled = true,
    this.icon,
    super.key,
  });

  final double temperature;
  final double minTemperature;
  final double maxTemperature;
  final double? targetTemperature;
  final String? label;
  final bool enabled;
  final Icon? icon;

  Color getColorFromTemperature() {
    if (!enabled) {
      return Colors.grey;
    }
    final midpoint = (minTemperature + maxTemperature) / 2;
    final intensity =
        (temperature - midpoint).abs() / (maxTemperature - midpoint) * 0.4;
    return temperature < midpoint
        ? Colors.blue.withOpacity(0.6 + intensity)
        : const Color(0xFFF00000).withOpacity(0.6 + intensity);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerSize = screenWidth / 2 - 32;
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: containerSize,
                  height: containerSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: _PartialCirclePainter(
                      fillPercentage: enabled
                          ? (temperature - minTemperature) /
                              (maxTemperature - minTemperature)
                          : 1,
                      color: getColorFromTemperature(),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          icon!,
                          const SizedBox(width: 4),
                        ],
                        Text(
                          enabled
                              ? '${temperature.toStringAsFixed(1)}°'
                              : 'Off',
                          style: GoogleFonts.montserrat(
                            textStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (targetTemperature != null)
                      Text(
                        '${targetTemperature!.toStringAsFixed(1)}°',
                        style: GoogleFonts.montserrat(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            AutoSizeText(
              label ?? '',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _PartialCirclePainter extends CustomPainter {
  _PartialCirclePainter({
    required this.fillPercentage,
    required this.color,
  });

  final double fillPercentage;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * fillPercentage;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
