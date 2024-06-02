import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_therm/blocs/thermostat_control_bloc.dart';
import 'package:smart_therm/blocs/weather_bloc.dart';
import 'package:smart_therm/constants.dart';
import 'package:smart_therm/devices_page.dart';
import 'package:smart_therm/graphs_page.dart';
import 'package:smart_therm/heater_picker_header.dart';
import 'package:smart_therm/home_page.dart';
import 'package:smart_therm/services/network_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThermostatControlBloc>(
          create: (ctx) {
            final bloc = ThermostatControlBloc(
              networkService: NetworkService(),
            );

            if (bloc.state.deviceData.isNotEmpty) {
              bloc.add(const AppStartRefresh());
            }

            return bloc;
          },
        ),
        BlocProvider<WeatherBloc>(
          create: (ctx) {
            final apiKey = dotenv.get('WEATHER_API_KEY');
            return WeatherBloc(apiKey: apiKey)..add(const GetWeather());
          },
        ),
      ],
      child: MaterialApp(
        title: 'Smart Therm',
        color: Colors.white,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: const ColorScheme.light().copyWith(
            primary: Colors.green,
          ),
        ),
        home: const MyHomePage(title: 'Smart Therm'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    required this.title,
    super.key,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _pageIndex = 0;

  final _destinations = const <Widget>[
    NavigationDestination(
      selectedIcon: Icon(Icons.home),
      icon: Icon(Icons.home_outlined),
      label: NavigationBarConstants.dashboard,
    ),
    NavigationDestination(
      icon: Icon(Icons.list_alt),
      label: NavigationBarConstants.devices,
    ),
    NavigationDestination(
      icon: Icon(Icons.auto_graph),
      label: NavigationBarConstants.graphs,
    ),
  ];
  final _destinationPages = [
    const HomePage(),
    const DevicesPage(),
    GraphsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _pageIndex == 0 ? const HeaterPickerHeader() : Text(widget.title),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: _destinations,
        onDestinationSelected: (value) => setState(() {
          _pageIndex = value;
        }),
        selectedIndex: _pageIndex,
      ),
      body: _destinationPages[_pageIndex],
    );
  }
}
