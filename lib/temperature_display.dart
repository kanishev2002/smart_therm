import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TemperatureDisplay extends StatelessWidget {
  const TemperatureDisplay({
    required this.temperature,
    required this.minTemperature,
    required this.maxTemperature,
    super.key,
    this.label,
    this.enabled = true,
  });

  final double temperature;
  final double minTemperature;
  final double maxTemperature;
  final String? label;
  final bool enabled;

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
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 80,
              height: 192,
              decoration: BoxDecoration(
                color: getColorFromTemperature(),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
            ),
            Text(
              enabled ? temperature.toStringAsFixed(1) : 'Off',
              style: GoogleFonts.montserrat(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (label != null) Text(label!),
      ],
    );
  }
}
