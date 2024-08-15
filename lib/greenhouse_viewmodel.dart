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
  // listat tiedoille
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
// viewmodel kasvihuoneen datan hallintaan
class GreenhouseViewModel extends StateNotifier<GreenhouseData> {
  final FlutterReactiveBle _ble;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _scanTimer;

  // konstruktori, joka käynnistää säännöllisen skannauksen
  GreenhouseViewModel()
      : _ble = FlutterReactiveBle(),
        super(GreenhouseData()) {
    startPeriodicScan();
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
    // kuuntelee löydettyjä laitteita
    final subscription = _ble.scanForDevices(
      withServices: [], //ei suodatusta palveluiden perusteella
      scanMode: ScanMode.balanced, // tasapainotettu skannaustila
    ).listen((device) {
      print("Found device: ${device.name}, id: ${device.id}");
      try {
        final manufacturerData = device.manufacturerData; // haetaan laitteen valmistajan data
        print("Manufacturer data (raw): $manufacturerData");
        // tarkistetaan, onko valmistajan data validi
        if (_isValidManufacturerData(manufacturerData)) {
          print("Valid manufacturer data found for device: ${device.name}");
          _processManufacturerData(manufacturerData); //käsitellään data
          // Päivitetään tila uusilla tiedoilla
          // päivitetään tila uusilla tiedoilla
          state = GreenhouseData(
            temperatures: state.temperatures,
            humidities: state.humidities,
            timestamps: state.timestamps,
            devices: [
              ...state.devices.where((element) => element.id != device.id),
              device, //lisätään uusi laite
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
    // pysäyttää skannauksen 5 sekunnin kuluttua
    Future.delayed(Duration(seconds: 5), () {
      subscription.cancel();
      print("Scan stopped.");
    });
  }
  // tarkistaa, onko valmistajan data validi (RuuviTag)
  bool _isValidManufacturerData(Uint8List manufacturerData) {
    print("Manufacturer data length: ${manufacturerData.length}");
    if (manufacturerData.length >= 2) {
      // lasketaan valmistajan ID
      final manufacturerId = (manufacturerData[1] << 8) | manufacturerData[0];
      print("Manufacturer ID: $manufacturerId (expected: 0x0499, ${0x0499})");
      // tarkistetaan, onko ID oikea (RuuviTag)
      if (manufacturerId == 0x0499) {
        return true;
      }
    }
    return false;
  }
  // käsittelee valmistajan datan ja tallentaa sen Firestoreen
  void _processManufacturerData(Uint8List manufacturerData) async {
    if (manufacturerData.length >= 24) {
      // lasketaan lämpötila ja kosteus raakadatasta
      int tempRaw = (manufacturerData[3] << 8) | manufacturerData[2];
      if (tempRaw >= 32768) tempRaw -= 65536;
      double temperature = tempRaw * 0.005;

      int humidityRaw = (manufacturerData[5] << 8) | manufacturerData[4];
      double humidity = humidityRaw * 0.0025;

      // haetaan käyttäjän ID tai käytetään "Unknown" jos ei kirjautunut
      String uid = FirebaseAuth.instance.currentUser?.uid ?? 'Unknown';

      // tallennetaan tiedot Firestoreen
      await _firestore.collection('greenhouse_data').add({
        'uid': uid,
        'temperature': temperature,
        'humidity': humidity,
        'timestamp': DateTime.now(),
      });

      // Suodatus: otetaan vain joka 3. arvo
      if (state.temperatures.length % 3 == 0) {
        List<double> updatedTemperatures = [...state.temperatures, temperature];
        List<double> updatedHumidities = [...state.humidities, humidity];
        List<DateTime> updatedTimestamps = [...state.timestamps, DateTime.now()];

        state = GreenhouseData(
          temperatures: updatedTemperatures,
          humidities: updatedHumidities,
          timestamps: updatedTimestamps,
          devices: state.devices,
        );
      }
    }
  }
  // pysäyttää ajastimen näkymän hävitessä
  @override
  void dispose() {
    _scanTimer?.cancel();
    super.dispose();
  }
}

/*import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final greenhouseViewModelProvider =
    StateNotifierProvider<GreenhouseViewModel, GreenhouseData>(
  (ref) => GreenhouseViewModel(),
);

// luodaan GreenhouseData-luokka, joka pitää sisällään listat kasvihuoneen tiedoille
class GreenhouseData {
  final List<double> temperatures;
  final List<double> humidities;
  final List<DateTime> timestamps;
  final List<DiscoveredDevice> devices;
  // listat keskiarvoistettua dataa varten
  final List<double> avgTemperatures;
  final List<double> avgHumidities;
  final List<DateTime> avgTimestamps;

  // konstruktorit, jotka alustavat tyhjät listat
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

class GreenhouseViewModel extends StateNotifier<GreenhouseData> {
  // määritellään FlutterReactiveBle-olio Bluetooth-yhteyden hallintaan
  final FlutterReactiveBle _ble;
  // määritellään FirebaseFirestore-olio, jonka avulla voi tallentaa dataa Firestoreen
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _scanTimer;
  Timer? _averageTimer;

  // määritellään konstruktori, joka alustaa oliot ja käynnistää Bluetooth-haun
  GreenhouseViewModel()
      : _ble = FlutterReactiveBle(),
        super(GreenhouseData()) {
    startPeriodicScan();
    startAveraging();
  }

  // metodi, joka käynnistää ajastetun skannauksen minuutin välein
  void startPeriodicScan() {
    // Suoritetaan skannaus heti alussa, jotta graafi ei ole tyhjä
    startScan();
    // Asetetaan ajastin suorittamaan skannaus  minuutin välein
    _scanTimer = Timer.periodic(Duration(minutes: 2), (timer) {
      startScan();
    });
  }

  // metodi, joka käynnsitää Bluetooth-haun laitteiden löytämiseksi
  void startScan() {
    print("Starting Bluetooth scan...");
    final subscription = _ble.scanForDevices(
      withServices: [], // ei haeta mitään tiettyä palvelua
      scanMode: ScanMode.balanced, // tasapainoinen hakutila
    ).listen((device) {
      // tulostetaan konsoliin löydettyjen laitteden nimi ja id
      print("Found device: ${device.name}, id: ${device.id}");
      try {
        // tulostetaan laitteen tietoja
        final manufacturerData = device.manufacturerData;
        print("Manufacturer data (raw): $manufacturerData");
        // jos löytyy _isValidManufacturerData-metodin ehtoja vastaava laite, tulostetaan tieto löytymisestä
        if (_isValidManufacturerData(manufacturerData)) {
          print("Valid manufacturer data found for device: ${device.name}");
          _processManufacturerData(manufacturerData);
          // päivitetään tila löydetyllä laitteella
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
          // jos löydetty laite ei vastaa _isValidManufacturerData-metodin ehtoja, tulostetaan tieto siitä
        } else {
          print("Invalid manufacturer data for device: ${device.name}");
        }
        // jos ei pysty käsittelemään laitteen tietoja, tulostetaan tieto virheestä
      } catch (e) {
        print('Error processing scan result: $e');
      }
      // jos skannaus ei onnistu, tulostetaan tieto siitä
    }, onError: (error) {
      print('Error during scan: $error');
    });

    // Peruuta skannaus 5 sekunnin jälkeen, jotta skannaus ei pyöri jatkuvasti
    Future.delayed(Duration(seconds: 5), () {
      subscription.cancel();
      print("Scan stopped.");
    });
  }

  // metodi, joka tarkistaa, ovatko laitteelta saadut valmistajan tiedot oikeanlaisia
  bool _isValidManufacturerData(Uint8List manufacturerData) {
    // datan pituuden tarkastus
    print("Manufacturer data length: ${manufacturerData.length}");
    if (manufacturerData.length >= 2) {
      // suoritetaan bittimuunnos valmistajan id:n tunnistamiseksi
      final manufacturerId = (manufacturerData[1] << 8) | manufacturerData[0];
      print("Manufacturer ID: $manufacturerId (expected: 0x0499, ${0x0499})");
      // verrataan, onko valmistajan id oikea
      if (manufacturerId == 0x0499) {
        return true;
      }
    }
    return false;
  }

  // käsitellään valmistajan tiedot sekä parsitaan lämpötila- ja kosteusdata
  void _processManufacturerData(Uint8List manufacturerData) async {
    if (manufacturerData.length >= 24) {
      // lämpötila (offset 2-3), 0.005 asteen tarkkuudella
      int tempRaw = (manufacturerData[3] << 8) | manufacturerData[2];
      // käsitellään allekirjoitettu 16-bit luku oikein
      if (tempRaw >= 32768) tempRaw -= 65536;
      double temperature = tempRaw * 0.005;

      // kosteus (offset 4-5), 0.0025% tarkkuudella
      int humidityRaw = (manufacturerData[5] << 8) | manufacturerData[4];
      double humidity = humidityRaw * 0.0025;

      // hae nykyisen käyttäjän UID
      String uid = FirebaseAuth.instance.currentUser?.uid ?? 'Unknown';

      // tallennetaan tiedot Firestoreen greenhouse_data-kokoelmaan
      await _firestore.collection('greenhouse_data').add({
        'uid': uid, // Käyttäjän UID lisätty
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

      // Jos keskiarvolistat ovat tyhjiä, lisää ensimmäinen skannauksen arvo
      if (state.avgTemperatures.isEmpty) {
        updatedAvgTemperatures = [temperature];
        updatedAvgHumidities = [humidity];
        updatedAvgTimestamps = [DateTime.now()];
      }
      print("Updated timestamps: $updatedTimestamps");
      // päivitetään tila ja tallennetaan uudet arvot
      state = GreenhouseData(
        temperatures: updatedTemperatures,
        humidities: updatedHumidities,
        timestamps: updatedTimestamps,
        devices: state.devices,
        avgTemperatures: updatedAvgTemperatures,
        avgHumidities: updatedAvgHumidities,
        avgTimestamps: updatedAvgTimestamps,
      );
    }
  }

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

  Future<void> fetchAndAverageData() async {
    final DateTime now = DateTime.now();
    final DateTime MinutesAgo = now.subtract(Duration(minutes: 10));

    QuerySnapshot snapshot = await _firestore
        .collection('greenhouse_data')
        .where('timestamp', isGreaterThanOrEqualTo: MinutesAgo)
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

    // Lasketaan liukuva keskiarvo viimeisimmille 5 mittaukselle
    List<double> avgTemperatures = calculateMovingAverage(temperatures, 10);
    List<double> avgHumidities = calculateMovingAverage(humidities, 10);

    // Tarkistetaan, että listat eivät ole tyhjiä
    if (temperatures.isNotEmpty && humidities.isNotEmpty) {
      state = GreenhouseData(
        temperatures: state.temperatures,
        humidities: state.humidities,
        timestamps: state.timestamps,
        devices: state.devices,
        avgTemperatures: avgTemperatures,
        avgHumidities: avgHumidities,
        avgTimestamps: avgTimestamps,
      );
    } else {
      print('No data available for averaging');
    }
  }

  void startAveraging() {
    fetchAndAverageData();
    _averageTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      fetchAndAverageData();
    });
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _averageTimer?.cancel();
    super.dispose();
  }
}*/
