import 'dart:async';
import 'dart:math';

class SimulatedBluetoothService {
  final Random _random =
      Random(); // Creating an instance of Random for generating random numbers.

  Future<double> getTemperature() async {
    // simulates 1 second delay
    await Future.delayed(Duration(seconds: 1));
    return 15 +
        _random.nextDouble() * 10; // generates random temperature between 15-25
  }

  Future<double> getHumidity() async {
    // simulates 1 second delay
    await Future.delayed(Duration(seconds: 1));
    return 40 +
        _random.nextDouble() * 20; // generates random humidity between 40-60
  }
}
