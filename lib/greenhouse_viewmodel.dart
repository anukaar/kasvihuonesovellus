import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final greenhouseViewModelProvider =
    StateNotifierProvider<GreenhouseViewModel, GreenhouseData>(
  (ref) => GreenhouseViewModel(),
);

// luodaan listat tiedoille
class GreenhouseData {
  final List<double> temperatures;
  final List<double> humidities;
  final List<DateTime> timestamps;
  final List<DiscoveredDevice> devices;

  // konstruktorit
  GreenhouseData({
    this.temperatures = const [],
    this.humidities = const [],
    this.timestamps = const [],
    this.devices = const [],
  });
}

class GreenhouseViewModel extends StateNotifier<GreenhouseData> {
  final FlutterReactiveBle _ble;
  // määritellään _firestore-muuttuja, jonka avulla voi tallentaa dataa Firestoreen
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      // lämpötila (offset 2-3), 0.005 asteen tarkkuudella
      int tempRaw = (manufacturerData[3] << 8) | manufacturerData[2];
      // käsitellään allekirjoitettu 16-bit luku oikein
      if (tempRaw >= 32768) tempRaw -= 65536;
      double temperature = tempRaw * 0.005;

      // kosteus (offset 4-5), 0.0025% tarkkuudella
      int humidityRaw = (manufacturerData[5] << 8) | manufacturerData[4];
      double humidity = humidityRaw * 0.0025;

      print("Parsed temperature: $temperature, humidity: $humidity");

      // tallennetaan tiedot Firestoreen greenhouse_data-kokoelmaan
      _firestore.collection('greenhouse_data').add({
        'temperature': temperature,
        'humidity': humidity,
        'timestamp': DateTime.now(),
      });

      // päivitetään tila ja tallenetaan uudet arvot
      state = GreenhouseData(
        temperatures: [...state.temperatures, temperature],
        humidities: [...state.humidities, humidity],
        timestamps: [...state.timestamps, DateTime.now()],
        devices: state.devices,
      );
    }
  }

  // metodi tietojen hakemiseen Firestoresta
  Future<void> fetchHistoricalData() async {
    QuerySnapshot snapshot = await _firestore
        .collection('greenhouse_data')
        .orderBy('timestamp', descending: true)
        .get();

    List<double> temperatures = [];
    List<double> humidities = [];
    List<DateTime> timestamps = [];

    snapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      temperatures.add(data['temperature']);
      humidities.add(data['humidity']);
      timestamps.add((data['timestamp'] as Timestamp).toDate());
    });
  }
}
