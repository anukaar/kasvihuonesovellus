import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasvihuonesovellus/greenhouse_viewmodel.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GreenhouseMonitor(),
    );
  }
}

class GreenhouseMonitor extends ConsumerWidget {
  const GreenhouseMonitor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greenhouseData = ref.watch(greenhouseViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Greenhouse Monitor')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Temperature: ${greenhouseData.temperature}°C',
                style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            Text('Humidity: ${greenhouseData.humidity}%',
                style: const TextStyle(fontSize: 24)),
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
            child: const Icon(Icons.update),
          ),
        ],
      ),
    );
  }
}
