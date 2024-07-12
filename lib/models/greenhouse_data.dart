class GreenhouseData {
  final double temperature;
  final double humidity;
  final List<double> temperatures;
  final List<double> humidities;
  final List<DateTime> timestamps;

  GreenhouseData({
    required this.temperature,
    required this.humidity,
    required this.temperatures,
    required this.humidities,
    required this.timestamps,
  });

  factory GreenhouseData.initial() {
    return GreenhouseData(
      temperature: 0.0,
      humidity: 0.0,
      temperatures: [],
      humidities: [],
      timestamps: [],
    );
  }

  GreenhouseData copyWith({
    double? temperature,
    double? humidity,
    List<double>? temperatures,
    List<double>? humidities,
    List<DateTime>? timestamps,
  }) {
    return GreenhouseData(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      temperatures: temperatures ?? this.temperatures,
      humidities: humidities ?? this.humidities,
      timestamps: timestamps ?? this.timestamps,
    );
  }
}
