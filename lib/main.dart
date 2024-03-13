import 'package:flutter/material.dart';
import 'package:smart_therm/devices_page.dart';
import 'package:smart_therm/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: const ColorScheme.light().copyWith(
          primary: Colors.green,
        ),
      ),
      home: const MyHomePage(title: 'Smart Therm'),
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
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.list_alt),
      label: 'Devices',
    ),
    NavigationDestination(
      icon: Icon(Icons.auto_graph),
      label: 'Graphs',
    ),
  ];
  final _destinationPages = [
    const HomePage(),
    const DevicesPage(),
    const Text('Graphs'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            _pageIndex == 0 ? const HeaterPickerButton() : Text(widget.title),
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

class HeaterPickerButton extends StatelessWidget {
  const HeaterPickerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          builder: (ctx) {
            return SizedBox(
              height: 200,
              child: ListView(
                children: const [
                  ListTile(
                    title: Text('Heater 1'),
                    trailing: Icon(Icons.check),
                  ),
                  ListTile(
                    title: Text('Heater 2'),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Heater 1', style: Theme.of(context).textTheme.headlineSmall),
          const Icon(
            Icons.arrow_drop_down,
          ),
        ],
      ),
    );
  }
}
