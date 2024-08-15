import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// luodaan Riverpod-provider kasvihuoneen viewmodelille
final greenhouseViewModelProvider =
    StateNotifierProvider<GreenhouseViewModel, GreenhouseData>(
  (ref) => GreenhouseViewModel(),
);

// luokka kasvihuoneen datan säilömiseen
class GreenhouseData {
  final List<double> temperatures;
  final List<double> humidities;
  final List<DateTime> timestamps;
  final List<DiscoveredDevice> devices;
  final List<double> avgTemperatures;
  final List<double> avgHumidities;
  final List<DateTime> avgTimestamps;

  GreenhouseData({
    this.temperatures = const [],
    this.humidities = const [],
    this.timestamps = const [],
    this.devices = const [],
    this.avgTemperatures = const [],
    this.avgHumidities = const [],
    this.avgTimestamps = const [],
  });
}

// viewmodel kasvihuoneen datan hallintaan
class GreenhouseViewModel extends StateNotifier<GreenhouseData> {
  final FlutterReactiveBle _ble;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _scanTimer;
  Timer? _averageTimer;

  // konstruktori, joka käynnistää säännöllisen skannauksen
  GreenhouseViewModel()
      : _ble = FlutterReactiveBle(),
        super(GreenhouseData()) {
    startPeriodicScan();
    startAveraging();
  }

  // aloittaa säännöllisen Bluetooth-skannauksen kahden minuutin välein
  void startPeriodicScan() {
    startScan();
    _scanTimer = Timer.periodic(Duration(minutes: 2), (timer) {
      startScan();
    });
  }

  // aloittaa Bluetooth-skannauksen
  void startScan() {
    print("Starting Bluetooth scan...");
    final subscription = _ble.scanForDevices(
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
            avgTemperatures: state.avgTemperatures,
            avgHumidities: state.avgHumidities,
            avgTimestamps: state.avgTimestamps,
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

    Future.delayed(Duration(seconds: 5), () {
      subscription.cancel();
      print("Scan stopped.");
    });
  }

  // tarkistaa, onko valmistajan data validi (RuuviTag)
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

  // käsittelee valmistajan datan ja tallentaa sen Firestoreen
  void _processManufacturerData(Uint8List manufacturerData) async {
    if (manufacturerData.length >= 24) {
      int tempRaw = (manufacturerData[3] << 8) | manufacturerData[2];
      if (tempRaw >= 32768) tempRaw -= 65536;
      double temperature = tempRaw * 0.005;

      int humidityRaw = (manufacturerData[5] << 8) | manufacturerData[4];
      double humidity = humidityRaw * 0.0025;

      String uid = FirebaseAuth.instance.currentUser?.uid ?? 'Unknown';

      await _firestore.collection('greenhouse_data').add({
        'uid': uid,
        'temperature': temperature,
        'humidity': humidity,
        'timestamp': DateTime.now(),
      });

      List<double> updatedTemperatures = [...state.temperatures, temperature];
      List<double> updatedHumidities = [...state.humidities, humidity];
      List<DateTime> updatedTimestamps = [...state.timestamps, DateTime.now()];

      List<double> updatedAvgTemperatures = state.avgTemperatures;
      List<double> updatedAvgHumidities = state.av
