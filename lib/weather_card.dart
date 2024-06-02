import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_therm/blocs/weather_bloc.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherBloc, WeatherBlocState>(
      builder: (context, state) {
        if (state is! Success) {
          return const SizedBox();
        }
        final currentTemperature = state.weatherData.current.temp_c;
        final locationName = state.weatherData.location.name;
        final highTemp = state.weatherData.forecast.forecastday.first.day.maxtemp_c;
        final lowTemp = state.weatherData.forecast.forecastday.first.day.mintemp_c;
        // final weatherDescription = state.weatherData.current.condition.text;
        final conditionsCode = state.weatherData.current.condition.code;
        final isDay = (state.weatherData.current.is_day == 1);
        final conditions =
            state.weatherCodeMapping[conditionsCode.toString()] as Map<String, dynamic>;
        final iconName = conditions['icon'] as int;
        final dayOrNight = isDay ? 'day' : 'night';
        final iconPath = 'assets/weather_icons/64x64/$dayOrNight/$iconName.png';
        final conditionsDescription = conditions[isDay ? 'day_text' : 'night_text'] as String;
        final textTheme = Theme.of(context).textTheme;

        return Card(
          child: SizedBox(
            height: 96,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8),
                  child: Text(
                    locationName,
                    style: textTheme.labelLarge,
                  ),
                ),
                Row(
                  children: [
                    Image.asset(iconPath),
                    Text(
                      '${currentTemperature.toStringAsFixed(1)}°',
                      style: textTheme.headlineLarge,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Max ${highTemp.toStringAsFixed(0)}°',
                          style: textTheme.bodySmall,
                        ),
                        Text(
                          'Min ${lowTemp.toStringAsFixed(0)}°',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        conditionsDescription,
                        style: textTheme.bodyLarge,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
