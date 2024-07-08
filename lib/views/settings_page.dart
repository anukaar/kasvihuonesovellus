import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _minTemperatureController = TextEditingController();
  final TextEditingController _maxTemperatureController = TextEditingController();
  final TextEditingController _minHumidityController = TextEditingController();
  final TextEditingController _maxHumidityController = TextEditingController();

  void _saveSettings() {
    // Yritetään muuntaa syötetyt arvot liukuluvuiksi (double)
    final double? minTemperature = double.tryParse(_minTemperatureController.text);
    final double? maxTemperature = double.tryParse(_maxTemperatureController.text);
    final double? minHumidity = double.tryParse(_minHumidityController.text);
    final double? maxHumidity = double.tryParse(_maxHumidityController.text);

    if (minTemperature != null && maxTemperature != null &&
        minHumidity != null && maxHumidity != null) {
      // Tarkistetaan, että syötetyt arvot ovat kelvollisissa rajoissa
      if (minTemperature >= -50 && maxTemperature <= 50 &&
          minHumidity >= 0 && maxHumidity <= 100 &&
          minTemperature <= maxTemperature && minHumidity <= maxHumidity) {
        // Tallenna lämpötilan ja kosteuden raja-arvot
        // Tässä voisi lisätä koodin tallentaaksesi nämä arvot johonkin tietovarastoon tai tilaan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Asetukset tallennettu: Lämpötila: $minTemperature - $maxTemperature °C, Kosteus: $minHumidity - $maxHumidity %')),
        );
      } else {
        // Näytä virheilmoitus, jos arvot eivät ole kelvollisissa rajoissa
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Syötä kelvolliset arvot: Lämpötila (-50°C - 50°C) ja Kosteus (0% - 100%) ja rajojen järjestys')),
        );
      }
    } else {
      // Näytä virheilmoitus, jos syöte ei ole kelvollinen luku
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Syötä kelvolliset arvot')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kasvihuoneeni')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Asetukset', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            // Syötekenttä lämpötilan ala- ja ylärajoille
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minTemperatureController,
                    decoration: const InputDecoration(
                      labelText: 'Lämpötila alaraja (°C)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,1}$')),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _maxTemperatureController,
                    decoration: const InputDecoration(
                      labelText: 'Lämpötila yläraja (°C)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,1}$')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Syötekenttä kosteuden ala- ja ylärajoille
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minHumidityController,
                    decoration: const InputDecoration(
                      labelText: 'Kosteus alaraja (%)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}$')),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _maxHumidityController,
                    decoration: const InputDecoration(
                      labelText: 'Kosteus yläraja (%)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}$')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Tallenna-painike, joka kutsuu _saveSettings-metodia
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Aseta'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Vapauta muistiresurssit käytön jälkeen
    _minTemperatureController.dispose();
    _maxTemperatureController.dispose();
    _minHumidityController.dispose();
    _maxHumidityController.dispose();
    super.dispose();
  }
}