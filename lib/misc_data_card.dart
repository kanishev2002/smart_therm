import 'package:flutter/material.dart';
import 'package:smart_therm/constants.dart';
import 'package:smart_therm/models/thermostat_data.dart';
import 'package:smart_therm/utils/extensions.dart';

class MiscDataCard extends StatelessWidget {
  const MiscDataCard({
    required this.data,
    super.key,
  });

  final ThermostatData data;

  @override
  Widget build(BuildContext context) {
    final miscData = data.miscellaneousData;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            _MiscDataRow(
              icon: Icons.whatshot,
              label: 'Горелка',
              value: miscData.burnerOn
                  ? HomePageConstants.on
                  : HomePageConstants.off,
            ),
            _MiscDataRow(
              icon: Icons.whatshot,
              label: 'Модуляция',
              value: '${miscData.modulation.toStringAsFixed(2)} %',
            ),
            _MiscDataRow(
              icon: Icons.thermostat,
              label: HomePageConstants.waterHeaterTemperature,
              value: '${data.actualHeatingTemperature.toStringAsFixed(2)} °C',
            ),
            _MiscDataRow(
              icon: Icons.thermostat,
              label: 'Температура обратки',
              value: '${miscData.returningTemp.toStringAsFixed(2)} °C',
            ),
            _MiscDataRow(
              icon: Icons.lan,
              label: 'Статус OpenTherm',
              value: switch (miscData.openThermStatus) {
                -1 => 'Не инициализировано',
                0 => 'Подключено',
                2 => 'Ошибка',
                _ => 'Ошибка',
              },
            ),
            _MiscDataRow(
              icon: Icons.speed,
              label: 'Давление',
              value: miscData.pressure.toStringAsFixed(2),
            ),
          ].separatedBy(
            const SizedBox(height: 16),
          ),
        ),
      ),
    );
  }
}

class _MiscDataRow extends StatelessWidget {
  const _MiscDataRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 16),
        Text(label),
        const Spacer(),
        Text(value),
      ],
    );
  }
}
