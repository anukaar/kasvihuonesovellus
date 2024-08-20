import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

// luokka kasvihuoneen datan säilömiseen
class GreenhouseData {
  final List<double> temperatures;
  final List<double> humidities;
  final List<DateTime> timestamps;
  final List<DiscoveredDevice> devices;
  final List<double> avgTemperatures;
  final List<double> avgHumidities;
  final List<DateTime> avgTimestamps;

  // Päätason konstruktori
  GreenhouseData({
    this.temperatures = const [],
    this.humidities = const [],
    this.timestamps = const [],
    this.devices = const [],
    this.avgTemperatures = const [],
    this.avgHumidities = const [],
    this.avgTimestamps = const [],
  });

  // Tehdasfunktio alkuarvojen asettamiseen
  factory GreenhouseData.initial() {
    return GreenhouseData(
      temperatures: [],
      humidities: [],
      timestamps: [],
      devices: [],
      avgTemperatures: [],
      avgHumidities: [],
      avgTimestamps: [],
    );
  }

  // copyWith-metodi, jonka avulla voidaan luoda uusi GreenhouseData-olio, johon on päivitetty vain tietyt kentät
  GreenhouseData copyWith({
    List<double>? temperatures,
    List<double>? humidities,
    List<DateTime>? timestamps,
    List<DiscoveredDevice>? devices,
    List<double>? avgTemperatures,
    List<double>? avgHumidities,
    List<DateTime>? avgTimestamps,
  }) {
    return GreenhouseData(
      temperatures: temperatures ?? this.temperatures,
      humidities: humidities ?? this.humidities,
      timestamps: timestamps ?? this.timestamps,
      devices: devices ?? this.devices,
      avgTemperatures: avgTemperatures ?? this.avgTemperatures,
      avgHumidities: avgHumidities ?? this.avgHumidities,
      avgTimestamps: avgTimestamps ?? this.avgTimestamps,
    );
  }
}
