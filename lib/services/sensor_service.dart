import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sensorServiceProvider =
    StateNotifierProvider<SensorService, List<DiscoveredDevice>>(
        (ref) => SensorService());

class SensorService extends StateNotifier<List<DiscoveredDevice>> {
  SensorService() : super([]) {
    startScan();
  }

  void startScan() {
    final reactiveBle = FlutterReactiveBle();

    reactiveBle.scanForDevices(
      withServices: [],
      scanMode: ScanMode.balanced,
    ).listen((device) {
      try {
        final manufacturerData = device.manufacturerData;
        if (manufacturerData.containsKey(0x0499)) {
          state = [
            ...state.where((element) => element.id != device.id),
            device,
          ];
        }
      } catch (e) {
        print('Error during scan results: $e');
      }
    }, onError: (error) {
      print('Error during scan: $error');
    });
  }
}
