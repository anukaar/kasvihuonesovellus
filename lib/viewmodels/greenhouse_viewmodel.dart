import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasvihuonesovellus/models/greenhouse_data.dart';

// Riverpod-provider kasvihuoneen viewmodelille
final greenhouseViewModelProvider =
    StateNotifierProvider<GreenhouseViewModel, GreenhouseData>(
  (ref) => GreenhouseViewModel(),
);

// luokka kasvihuoneen datan hallintaan
class GreenhouseViewModel extends StateNotifier<GreenhouseData> {
  GreenhouseData _data = GreenhouseData.initial();
  final FlutterReactiveBle _ble;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _scanTimer;
  Timer? _averageTimer;

  GreenhouseData get data => _data;

  // Konstruktori, joka käynnistää säännöllisen skannauksen
  GreenhouseViewModel()
      : _ble = FlutterReactiveBle(),
        super(GreenhouseData.initial()) {
    startPeriodicScan();
    startAveraging();
  }

  // Aloittaa säännöllisen Bluetooth-skannauksen kahden minuutin välein
  void startPeriodicScan() {
    startScan();
    _scanTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      startScan();
    });
  }

  // Aloittaa Bluetooth-skannauksen
  void startScan() {
    print("Starting Bluetooth scan...");
    // Kuuntelee löydettyjä laitteita;
    final subscription = _ble.scanForDevices(
      withServices: [],
      scanMode: ScanMode.balanced,
    ).listen((device) {
      print("Found device: ${device.name}, id: ${device.id}");
      try {
        final manufacturerData =
            device.manufacturerData; // Haetaan laitteen valmistajan data
        print("Manufacturer data (raw): $manufacturerData");

        if (_isValidManufacturerData(manufacturerData)) {
          print("Valid manufacturer data found for device: ${device.name}");
          _processManufacturerData(
              manufacturerData); // Tarkistetaan, onko valmistajan data validi
          // Päivitetään tila uusilla tiedoilla
          state = state.copyWith(
            devices: [
              ...state.devices.where((element) => element.id != device.id),
              device, // Lisätään uusi laite
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

    // Pysäyttää skannauksen 5 sekunnin kuluttua
    Future.delayed(Duration(seconds: 5), () {
      subscription.cancel();
      print("Scan stopped.");
    });
  }

  // Tarkistaa, onko valmistajan data validi (RuuviTag)
  bool _isValidManufacturerData(Uint8List manufacturerData) {
    print("Manufacturer data length: ${manufacturerData.length}");
    if (manufacturerData.length >= 2) {
      // Lasketaan valmistajan ID
      final manufacturerId = (manufacturerData[1] << 8) | manufacturerData[0];
      print("Manufacturer ID: $manufacturerId (expected: 0x0499, ${0x0499})");
      // Tarkistetaan, onko ID oikea (RuuviTag)
      if (manufacturerId == 0x0499) {
        return true;
      }
    }
    return false;
  }

  // Käsittelee valmistajan datan ja tallentaa sen Firestoreen
  void _processManufacturerData(Uint8List manufacturerData) async {
    if (manufacturerData.length >= 24) {
      // Lasketaan lämpötila ja kosteus raakadatasta
      int tempRaw = (manufacturerData[3] << 8) | manufacturerData[2];
      if (tempRaw >= 32768) tempRaw -= 65536;
      double temperature = tempRaw * 0.005;

      int humidityRaw = (manufacturerData[5] << 8) | manufacturerData[4];
      double humidity = humidityRaw * 0.0025;

      // Haetaan käyttäjän ID tai käytetään "Unknown" jos ei kirjautunut
      String uid = FirebaseAuth.instance.currentUser?.uid ?? 'Unknown';

      // Tallennetaan tiedot Firestoreen
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
      List<double> updatedAvgHumidities = state.avgHumidities;
      List<DateTime> updatedAvgTimestamps = state.avgTimestamps;

      if (state.avgTemperatures.isEmpty) {
        updatedAvgTemperatures = [temperature];
        updatedAvgHumidities = [humidity];
        updatedAvgTimestamps = [DateTime.now()];
      }

      print("Updated timestamps: $updatedTimestamps");

      state = state.copyWith(
        temperatures: updatedTemperatures,
        humidities: updatedHumidities,
        timestamps: updatedTimestamps,
        avgTemperatures: updatedAvgTemperatures,
        avgHumidities: updatedAvgHumidities,
        avgTimestamps: updatedAvgTimestamps,
      );
    }
  }

  // Laskee liikkuvan keskiarvon
  List<double> calculateMovingAverage(List<double> values, int windowSize) {
    List<double> averages = [];
    for (int i = 0; i < values.length; i++) {
      int start = i - windowSize + 1;
      int end = i + 1;
      if (start >= 0) {
        double sum = values.sublist(start, end).reduce((a, b) => a + b);
        double average = sum / windowSize;
        averages.add(average);
      } else {
        averages.add(values[i]);
      }
    }
    return averages;
  }

  // Hakee ja keskiarvoistaa datan Firestoresta
  Future<void> fetchAndAverageData() async {
    final DateTime now = DateTime.now();
    final DateTime minutesAgo = now.subtract(Duration(minutes: 10));

    QuerySnapshot snapshot = await _firestore
        .collection('greenhouse_data')
        .where('timestamp', isGreaterThanOrEqualTo: minutesAgo)
        .orderBy('timestamp', descending: true)
        .get();

    List<double> temperatures = [];
    List<double> humidities = [];
    List<DateTime> avgTimestamps = [];

    snapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      temperatures.add(data['temperature']);
      humidities.add(data['humidity']);
      avgTimestamps.add((data['timestamp'] as Timestamp).toDate());
    });

    List<double> avgTemperatures = calculateMovingAverage(temperatures, 10);
    List<double> avgHumidities = calculateMovingAverage(humidities, 10);

    if (temperatures.isNotEmpty && humidities.isNotEmpty) {
      state = state.copyWith(
        avgTemperatures: avgTemperatures,
        avgHumidities: avgHumidities,
        avgTimestamps: avgTimestamps,
      );
    } else {
      print('No data available for averaging');
    }
  }

  // Aloittaa säännöllisen datan keskiarvon laskemisen
  void startAveraging() {
    fetchAndAverageData();
    _averageTimer = Timer.periodic(Duration(minutes: 10), (timer) {
      fetchAndAverageData();
    });
  }

  // pysäyttää ajastimet näkymän hävitessä
  @override
  void dispose() {
    _scanTimer?.cancel();
    _averageTimer?.cancel();
    super.dispose();
  }
}
