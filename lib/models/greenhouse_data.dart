class GreenhouseData {
  final double temperature; // current temperature value
  final double humidity; // current humidity value
  final List<double> temperatures; // list of past temperature values
  final List<double> humidities; // list of past humidity values
  final List<DateTime>
      timestamps; // list of timestamps corresponding to the temperature and humidity values

  GreenhouseData({
    required this.temperature,
    required this.humidity,
    required this.temperatures,
    required this.humidities,
    required this.timestamps,
  });

  factory GreenhouseData.initial() {
    return GreenhouseData(
      temperature: 0.0, // ínitial temperature value set to 0.0
      humidity: 0.0, // initial humidity value set to 0.0
      // initial empty lists for the values (temperatures, humidities, timestamps)
      temperatures: [],
      humidities: [],
      timestamps: [],
    );
  }

  // method to create a copy of the current GreenhouseData object with optional new values
  GreenhouseData copyWith({
    // optional new values and lists
    double? temperature,
    double? humidity,
    List<double>? temperatures,
    List<double>? humidities,
    List<DateTime>? timestamps,
  }) {
    return GreenhouseData(
      temperature: temperature ??
          this.temperature, // use the new temperature value if provides, otherwise use the current temperature
      humidity: humidity ?? this.humidity,
      temperatures: temperatures ?? this.temperatures,
      humidities: humidities ?? this.humidities,
      timestamps: timestamps ?? this.timestamps,
    );
  }
}
