import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasvihuonesovellus/models/greenhouse_data.dart';
import 'package:kasvihuonesovellus/services/simulated_bluetooth_service.dart';

final greenhouseViewModelProvider =
    StateNotifierProvider<GreenhouseViewModel, GreenhouseData>(
  (ref) => GreenhouseViewModel(),
);

class GreenhouseViewModel extends StateNotifier<GreenhouseData> {
  final SimulatedBluetoothService _bluetoothService =
      SimulatedBluetoothService(); // creating an instance of SimulatedBluetoothService
  GreenhouseViewModel()
      : super(GreenhouseData
            .initial()); // initializing the state with initial GreenhouseData

  // method for adding new temperature, humidity and timestamp to the list
  void updateData(
      double newTemperature, double newHumidity, DateTime timestamp) {
    state = state.copyWith(
      temperatures: List.from(state.temperatures)..add(newTemperature),
      humidities: List.from(state.humidities)..add(newHumidity),
      timestamps: List.from(state.timestamps)..add(timestamp),
    );
  }

  // method for fetching new temperature and humidity from the Bluetooth service
  void fetchData() async {
    double newTemperature = await _bluetoothService.getTemperature();
    double newHumidity = await _bluetoothService.getHumidity();
    DateTime timestamp =
        DateTime.now(); // getting the current time as a timestamp

    updateData(newTemperature, newHumidity,
        timestamp); // updating the state with new data
  }
}
