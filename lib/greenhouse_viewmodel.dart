import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasvihuonesovellus/models/greenhouse_data.dart';
import 'package:kasvihuonesovellus/services/simulated_bluetooth_service.dart';

final greenhouseViewModelProvider =
    StateNotifierProvider<GreenhouseViewModel, GreenhouseData>(
  (ref) => GreenhouseViewModel(),
);

class GreenhouseViewModel extends StateNotifier<GreenhouseData> {
  final SimulatedBluetoothService _bluetoothService =
      SimulatedBluetoothService();
  GreenhouseViewModel() : super(GreenhouseData.initial());

  void updateData(
      double newTemperature, double newHumidity, DateTime timestamp) {
    state = state.copyWith(
      temperatures: List.from(state.temperatures)..add(newTemperature),
      humidities: List.from(state.humidities)..add(newHumidity),
      timestamps: List.from(state.timestamps)..add(timestamp),
    );
  }

  void fetchData() async {
    double newTemperature = await _bluetoothService.getTemperature();
    double newHumidity = await _bluetoothService.getHumidity();
    DateTime timestamp = DateTime.now();

    updateData(newTemperature, newHumidity, timestamp);
  }
}
