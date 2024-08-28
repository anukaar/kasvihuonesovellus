import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, Map<String, dynamic>>((ref) {
  return SettingsNotifier();
});

// Tämä luokka hallitsee asetusten lukemista ja tallentamista
class SettingsNotifier extends StateNotifier<Map<String, dynamic>> {
  SettingsNotifier() : super({}) {
    loadSettings(); // Lataa asetukset, kun notifier luodaan
  }

  // Lataa asetukset SharedPreferencesista
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = {
      'minTemperature': prefs.getDouble('minTemperature') ?? -50,
      'maxTemperature': prefs.getDouble('maxTemperature') ?? 50,
      'minHumidity': prefs.getDouble('minHumidity') ?? 0,
      'maxHumidity': prefs.getDouble('maxHumidity') ?? 100,
    };
  }

  // Tallenna asetukset SharedPreferencesiin ja päivitä tila
  Future<void> saveSettings(double minTemperature, double maxTemperature,
      double minHumidity, double maxHumidity) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('minTemperature', minTemperature);
    await prefs.setDouble('maxTemperature', maxTemperature);
    await prefs.setDouble('minHumidity', minHumidity);
    await prefs.setDouble('maxHumidity', maxHumidity);

    // Päivitä tila Riverpodissa
    state = {
      'minTemperature': minTemperature,
      'maxTemperature': maxTemperature,
      'minHumidity': minHumidity,
      'maxHumidity': maxHumidity,
    };
  }
}
