import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasvihuonesovellus/greenhouse_viewmodel.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GreenhouseMonitor(),
    );
  }
}

class GreenhouseMonitor extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greenhouseData = ref.watch(greenhouseViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Greenhouse Monitor')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Lämpötila: ${greenhouseData.temperature}°C',
                style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            Text('Kosteus: ${greenhouseData.humidity}%',
                style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              ref
                  .read(greenhouseViewModelProvider.notifier)
                  .updateTemperature(25.0);
              ref
                  .read(greenhouseViewModelProvider.notifier)
                  .updateHumidity(60.0);
            },
            child: Icon(Icons.update),
          ),
        ],
      ),
    );
  }
}
