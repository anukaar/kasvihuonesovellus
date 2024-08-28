import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasvihuonesovellus/models/greenhouse_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

final greenhouseViewModelProvider =
    StateNotifierProvider<GreenhouseViewModel, GreenhouseData>(
  (ref) => GreenhouseViewModel(),
);

class GreenhouseViewModel extends StateNotifier<GreenhouseData> {
  // Luodaan GreenhouseData, joka sisältää mittausdatan
  GreenhouseData _data = GreenhouseData.initial();

  // Määritellään muuttuja Bluetooth-yhteyden hallintaan
  final FlutterReactiveBle _ble;

  // Määritellään muuttuja datan tallentamiseen Firestoreen
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Määritellään ajastin säännöllisiin Bluetooth-hakuihin
  Timer? _scanTimer;

  // Muuttuja skannauksen tilan hallintaan
  bool _isScanning =
      false; // Alustetaan falseksi, kun skannaus ei ole käynnissä

  GreenhouseViewModel()
      : _ble = FlutterReactiveBle(),
        super(GreenhouseData()) {
    // Käynnistä säännöllinen Bluetooth-skannaus
    startPeriodicScan();
  }
  GreenhouseData get data => _data;

  // Käynnistä säännöllinen Bluetooth-skannaus 5 minuutin välein
  void startPeriodicScan() {
    startScan();
    _scanTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      startScan();
    });
  }

  // Suorita Bluetooth-skannaus laitteiden löytämiseksi
  void startScan() {
    // Tarkista, onko skannaus jo käynnissä
    if (_isScanning) {
      print("Scan already in progress. Skipping new scan.");
      return; // Jos skannaus on käynnissä, älä käynnistä uutta skannausta
    }

    // Aseta isScanning todeksi, kun skannaus alkaa
    _isScanning = true;

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
          // Päivitä laitelista vain, jos laite on uusi
          state = state.copyWith(
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

    // Lopeta haku 5 sekunnin kuluttua
    Future.delayed(Duration(seconds: 5), () {
      subscription.cancel();
      print("Scan stopped.");
      _isScanning = false; // Aseta isScanning epätodeksi, kun skannaus päättyy
    });
  }

  // Tarkista, onko vastaanotettu data validia laitteen valmistajadataa
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

  // Uusi muuttuja viimeiselle tallennusajalle
  DateTime? _lastSavedTimestamp; // Uusi muuttuja viimeiselle tallennusajalle

  // Prosessoi vastaanotettu valmistajan data
  void _processManufacturerData(Uint8List manufacturerData) async {
    if (manufacturerData.length >= 24) {
      // Pura data lämpötilaksi ja kosteudeksi
      int tempRaw = (manufacturerData[3] << 8) | manufacturerData[2];
      if (tempRaw >= 32768) tempRaw -= 65536;
      double temperature = tempRaw * 0.005;

      int humidityRaw = (manufacturerData[5] << 8) | manufacturerData[4];
      double humidity = humidityRaw * 0.0025;

      final now = DateTime.now();

      // Hae asetetut lämpötila- ja kosteusrajat asetuksista
      SharedPreferences prefs = await SharedPreferences.getInstance();
      double minTemperature = prefs.getDouble('minTemperature') ?? -50.0;
      double maxTemperature = prefs.getDouble('maxTemperature') ?? 50.0;
      double minHumidity = prefs.getDouble('minHumidity') ?? 0.0;
      double maxHumidity = prefs.getDouble('maxHumidity') ?? 100.0;

      // Tarkista, ylittyvätkö arvot
      if (temperature < minTemperature ||
          temperature > maxTemperature ||
          humidity < minHumidity ||
          humidity > maxHumidity) {
        print(
            'Raja-arvo ylittynyt/alittunut! Temp: $temperature°C, Hum: $humidity%');
      }

      // Tarkista, onko kulunut vähintään 5 minuuttia viimeisestä tallennuksesta
      if (_lastSavedTimestamp == null ||
          now.difference(_lastSavedTimestamp!).inMinutes >= 5) {
        // Päivitä viimeinen tallennusaika
        _lastSavedTimestamp = now;

        List<double> updatedTemperatures = [...state.temperatures, temperature];
        List<double> updatedHumidities = [...state.humidities, humidity];
        List<DateTime> updatedTimestamps = [...state.timestamps, now];

        // Pidä listojen koko hallinnassa
        final maxDataPoints = 100;

        if (updatedTemperatures.length > maxDataPoints) {
          updatedTemperatures.removeRange(
              0, updatedTemperatures.length - maxDataPoints);
        }

        if (updatedHumidities.length > maxDataPoints) {
          updatedHumidities.removeRange(
              0, updatedHumidities.length - maxDataPoints);
        }

        if (updatedTimestamps.length > maxDataPoints) {
          updatedTimestamps.removeRange(
              0, updatedTimestamps.length - maxDataPoints);
        }

        // Päivitä tila
        state = state.copyWith(
          temperatures: updatedTemperatures,
          humidities: updatedHumidities,
          timestamps: updatedTimestamps,
        );

        // Tallennetaan Firestoreen
        String uid = FirebaseAuth.instance.currentUser?.uid ?? 'Unknown';
        await _firestore.collection('greenhouse_data').add({
          'uid': uid,
          'temperature': temperature,
          'humidity': humidity,
          'timestamp': now,
        });
      }
    }
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    super.dispose();
  }
}
