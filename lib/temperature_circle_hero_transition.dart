import 'package:flutter/material.dart';
import 'package:smart_therm/manage_device_page.dart';
import 'package:smart_therm/temperature_circle.dart';

class TemperatureCircleHeroTransition extends StatelessWidget {
  const TemperatureCircleHeroTransition({
    required this.temperatureCircle,
    required this.heroTag,
    required this.presets,
    required this.type,
    super.key,
  });

  final TemperatureCircle temperatureCircle;
  final String heroTag;
  final TemperaturePresets presets;
  final ControlType type;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) {
                return ManageDevicePage(
                  heroTag: heroTag,
                  targetTemperature: temperatureCircle.temperature,
                  temperatureCircle: temperatureCircle,
                  presets: presets,
                  controlType: type,
                );
              },
            ),
          );
        },
        child: Stack(
          children: [
            const Positioned(
              top: 0,
              right: 0,
              child: Icon(
                Icons.arrow_right,
                color: Colors.grey,
                size: 22,
              ),
            ),
            Hero(
              tag: heroTag,
              child: temperatureCircle,
            ),
          ],
        ),
      ),
    );
  }
}
