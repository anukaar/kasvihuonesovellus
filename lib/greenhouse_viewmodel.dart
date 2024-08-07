import 'dart:typed_data';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final greenhouseViewModelProvider =
    StateNotifierProvider<GreenhouseViewModel, GreenhouseData>(
  (ref) => GreenhouseViewModel(),
);

class GreenhouseData {
  final List<double> temperatures;
  final List<double> humidities;
  final List<DateTime> timestamps;
  final List<DiscoveredDevice> devices;

  GreenhouseData({
    this.temperatures = const [],
    this.humidities = const [],
    this.timestamps = const [],
    this.devices = const [],
  });
}

class GreenhouseViewModel extends StateNotifier<GreenhouseData> {
  final FlutterReactiveBle _ble;

  GreenhouseViewModel()
      : _ble = FlutterReactiveBle(),
        super(GreenhouseData()) {
    startScan();
  }

  void startScan() {
    print("Starting Bluetooth scan...");
    _ble.scanForDevices(
      withServices: [],
      scanMode: ScanMode.balanced,
    ).listen((device) {
      print("Found device: ${device.name}, id: ${device.id}");
      try {
        final manufacturerData = device.manufacturerData;
        print("Manufacturer data (raw): $manufacturerData");
        if (_isValidManufacturerData(manufacturerData)) {
          print("Valid manufacturer data found for device: ${device.name}");
          _processManufacturerData(manufacturerData);
          state = GreenhouseData(
            temperatures: state.temperatures,
            humidities: state.humidities,
            timestamps: state.timestamps,
            devices: [
              ...state.devices.where((element) => element.id != device.id),
              device,
            ],
          );
        } else {
          print("Invalid manufacturer data for device: ${device.name}");
        }
      } catch (e) {
        print('Error processing scan result: $e');
      }
    }, onError: (error) {
      print('Error during scan: $error');
    });
  }

  bool _isValidManufacturerData(Uint8List manufacturerData) {
    print("Manufacturer data length: ${manufacturerData.length}");
    if (manufacturerData.length >= 2) {
      final manufacturerId = (manufacturerData[1] << 8) | manufacturerData[0];
      print("Manufacturer ID: $manufacturerId (expected: 0x0499, ${0x0499})");

      if (manufacturerId == 0x0499) {
        return true;
      }
    }
    return false;
  }

  void _processManufacturerData(Uint8List manufacturerData) {
    if (manufacturerData.length >= 24) {
      // Lämpötila (offset 2-3), 0.005 asteen tarkkuudella
      int tempRaw = (manufacturerData[3] << 8) | manufacturerData[2];
      // Käsitellään allekirjoitettu 16-bit luku oikein
      if (tempRaw >= 32768) tempRaw -= 65536;
      double temperature = tempRaw * 0.005;

      // Kosteus (offset 4-5), 0.0025% tarkkuudella
      int humidityRaw = (manufacturerData[5] << 8) | manufacturerData[4];
      double humidity = humidityRaw * 0.0025;

      print("Parsed temperature: $temperature, humidity: $humidity");

      // Päivitä tila tallentaaksesi uudet arvot
      state = GreenhouseData(
        temperatures: [...state.temperatures, temperature],
        humidities: [...state.humidities, humidity],
        timestamps: [...state.timestamps, DateTime.now()],
        devices: state.devices,
      );
    }
  }
}
