import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

// Luokka kasvihuoneen datan säilömiseen
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

  // Funktio alkuarvojen asettamiseen
  factory GreenhouseData.initial() {
    return GreenhouseData(
      temperatures: [],
      humidities: [],
      timestamps: [],
      devices: [],
    );
  }

  // CopyWith-metodi, jonka avulla voidaan luoda uusi GreenhouseData-olio, johon on päivitetty vain tietyt kentät
  GreenhouseData copyWith({
    List<double>? temperatures,
    List<double>? humidities,
    List<DateTime>? timestamps,
    List<DiscoveredDevice>? devices,
  }) {
    return GreenhouseData(
      temperatures: temperatures ?? this.temperatures,
      humidities: humidities ?? this.humidities,
      timestamps: timestamps ?? this.timestamps,
      devices: devices ?? this.devices,
    );
  }
}
