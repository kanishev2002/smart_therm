import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_therm/blocs/thermostat_control_bloc.dart';
import 'package:smart_therm/constants.dart';
import 'package:smart_therm/manage_device_page.dart';
import 'package:smart_therm/misc_data_card.dart';
import 'package:smart_therm/models/thermostat_control_state.dart';
import 'package:smart_therm/temperature_circle.dart';
import 'package:smart_therm/temperature_circle_hero_transition.dart';
import 'package:smart_therm/utils/utilities.dart';
import 'package:smart_therm/weather_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ThermostatControlBloc, ThermostatControlState>(
      listener: (context, state) {
        final isDisplaying = ModalRoute.of(context)?.isCurrent ?? false;
        if (state.status.isError && isDisplaying) {
          Utilities.showError(
            context,
            content: const Text(
              HomePageConstants.connectionError,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.deviceData.isEmpty) {
          return const Center(
            child: Text(
              HomePageConstants.noDevicesAdded,
              textAlign: TextAlign.center,
            ),
          );
        }
        final device = state.deviceData[state.selectedDevice];
        final data = device.data!;
        final temp1 = data.roomTemperature1;
        final temp2 = data.roomTemperature2;
        final averageTemperature = (temp1 + temp2) / 2;
        return RefreshIndicator(
          onRefresh: () async {
            final bloc = context.read<ThermostatControlBloc>();
            // ignore: cascade_invocations
            bloc.add(const FetchThermostatData());
            await bloc.stream.first;
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const WeatherCard(),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.spaceAround,
                  runSpacing: 16,
                  children: [
                    TemperatureCircleHeroTransition(
                      temperatureCircle: TemperatureCircle(
                        enabled: data.heatingOn,
                        targetTemperature: device.heatingTemperature.toDouble(),
                        actualTemperature:
                            device.usePID ? averageTemperature : data.actualHeatingTemperature,
                        minTemperature: -5,
                        maxTemperature: device.usePID ? 35 : 100,
                        label: HomePageConstants.waterHeaterTemperature,
                        icon: const Icon(
                          Icons.local_fire_department,
                          size: 28,
                          color: Colors.orange,
                        ),
                      ),
                      heroTag: HomePageConstants.waterHeaterTemperature,
                      type: ControlType.temperature,
                    ),
                    TemperatureCircleHeroTransition(
                      temperatureCircle: TemperatureCircle(
                        enabled: data.hotWaterOn,
                        targetTemperature: device.hotWaterTemperature.toDouble(),
                        actualTemperature: data.actualHotWaterTemperature,
                        maxTemperature: 100,
                        minTemperature: 5,
                        label: HomePageConstants.hotWaterTemperature,
                        icon: const Icon(
                          Icons.water_drop_outlined,
                          size: 28,
                          color: Colors.blue,
                        ),
                      ),
                      heroTag: HomePageConstants.hotWaterTemperature,
                      type: ControlType.hotWater,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 32,
                ),
                MiscDataCard(data: data),
              ],
            ),
          ),
        );
      },
    );
  }
}
