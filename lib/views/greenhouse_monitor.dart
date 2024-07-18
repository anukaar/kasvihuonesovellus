import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasvihuonesovellus/greenhouse_viewmodel.dart';

class GreenhouseMonitor extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greenhouseData = ref.watch(greenhouseViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Kasvihuoneeni')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                'Lämpötila: ${greenhouseData.temperature.toStringAsFixed(1)}°C',
                style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            Text('Kosteus: ${greenhouseData.humidity.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ref.read(greenhouseViewModelProvider.notifier).fetchData();
              },
              child: Text('Fetch Data'),
            ),
          ],
        ),
      ),
    );
  }
}
