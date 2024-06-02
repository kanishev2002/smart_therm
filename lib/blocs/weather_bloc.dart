// ignore_for_file: avoid_dynamic_calls

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:smart_therm/models/weather/weather_api_response.dart';

class WeatherBloc extends Bloc<WeatherBlocEvent, WeatherBlocState> {
  WeatherBloc({
    required this.apiKey,
  }) : super(const Loading()) {
    on<GetWeather>(_onGetWeather);
  }

  final String apiKey;

  Future<void> _onGetWeather(GetWeather event, Emitter<WeatherBlocState> emit) async {
    try {
      final url = Uri.parse(
        'https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=auto:ip&days=1&aqi=no&alerts=no&lang=ru',
      );
      final response = await http.get(url);
      final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final data = WeatherApiResponse.fromJson(decoded);

      final weatherMapping = await rootBundle.loadString('assets/weather_conditions.json');
      final weatherJson = jsonDecode(weatherMapping) as Map<String, dynamic>;
      emit(
        Success(
          weatherData: data,
          weatherCodeMapping: weatherJson,
        ),
      );
    } catch (e) {
      debugPrint('Failed to fetch weather: $e');
      emit(const Error());
    }
  }
}

abstract base class WeatherBlocEvent {
  const WeatherBlocEvent();
}

final class GetWeather extends WeatherBlocEvent {
  const GetWeather();
}

abstract base class WeatherBlocState {
  const WeatherBlocState();
}

final class Loading extends WeatherBlocState {
  const Loading();
}

final class Error extends WeatherBlocState {
  const Error();
}

final class Success extends WeatherBlocState {
  const Success({
    required this.weatherData,
    required this.weatherCodeMapping,
  });

  final WeatherApiResponse weatherData;
  final Map<String, dynamic> weatherCodeMapping;
}
