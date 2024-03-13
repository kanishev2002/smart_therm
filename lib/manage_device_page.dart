import 'package:flutter/material.dart';
import 'package:smart_therm/temperature_circle.dart';

class ManageDevicePage extends StatelessWidget {
  const ManageDevicePage({
    required this.heroTag,
    required this.targetTemperature,
    required this.temperatureCircle,
    super.key,
  });

  final String heroTag;
  final double targetTemperature;
  final TemperatureCircle temperatureCircle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(temperatureCircle.label ?? ''),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Hero(
                tag: heroTag,
                child: TemperatureCircle(
                  temperature: temperatureCircle.temperature,
                  minTemperature: temperatureCircle.minTemperature,
                  maxTemperature: temperatureCircle.maxTemperature,
                  icon: temperatureCircle.icon,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Set Target Temperature',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              const Wrap(
                alignment: WrapAlignment.spaceAround,
                runSpacing: 16,
                spacing: 8,
                children: [
                  TemperaturePresetButton(
                    temperature: 22,
                    title: 'Normal ☀️',
                    selected: true,
                  ),
                  TemperaturePresetButton(
                    temperature: 30,
                    title: 'Hot 🔥',
                  ),
                  TemperaturePresetButton(
                    temperature: 10,
                    title: 'Eco 🌱',
                  ),
                  TemperaturePresetButton(
                    temperature: 14,
                    title: 'Custom ⚙️',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TemperaturePresetButton extends StatelessWidget {
  const TemperaturePresetButton({
    required this.temperature,
    required this.title,
    this.selected = false,
    super.key,
  });

  final int temperature;
  final String title;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        side: selected
            ? const MaterialStatePropertyAll(
                BorderSide(
                  color: Colors.lightGreenAccent,
                ),
              )
            : null,
      ),
      onPressed: () {},
      child: SizedBox(
        height: 80,
        width: MediaQuery.of(context).size.width / 2 - 80,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall!
                  .copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                '$temperature°',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
