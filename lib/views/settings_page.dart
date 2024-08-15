import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _minTemperatureController =
      TextEditingController();
  final TextEditingController _maxTemperatureController =
      TextEditingController();
  final TextEditingController _minHumidityController = TextEditingController();
  final TextEditingController _maxHumidityController = TextEditingController();
  final List<String> notifications = [
    'Ilmoitus',
    'Ilmoitus',
    'Ilmoitus',
  ];

  @override
  void dispose() {
    _minTemperatureController.dispose();
    _maxTemperatureController.dispose();
    _minHumidityController.dispose();
    _maxHumidityController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final double? minTemperature =
        double.tryParse(_minTemperatureController.text);
    final double? maxTemperature =
        double.tryParse(_maxTemperatureController.text);
    final double? minHumidity = double.tryParse(_minHumidityController.text);
    final double? maxHumidity = double.tryParse(_maxHumidityController.text);

    if (_areValuesValid(
        minTemperature, maxTemperature, minHumidity, maxHumidity)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Asetukset tallennettu: Lämpötila: $minTemperature - $maxTemperature °C, Kosteus: $minHumidity - $maxHumidity %')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Syötä kelvolliset arvot: Lämpötila (-50°C - 50°C) & Kosteus (0% - 100%)')),
      );
    }
  }

  bool _areValuesValid(double? minTemperature, double? maxTemperature,
      double? minHumidity, double? maxHumidity) {
    return minTemperature != null &&
        maxTemperature != null &&
        minHumidity != null &&
        maxHumidity != null &&
        minTemperature >= -50 &&
        maxTemperature <= 50 &&
        minHumidity >= 0 &&
        maxHumidity <= 100 &&
        minTemperature <= maxTemperature &&
        minHumidity <= maxHumidity;
  }

  Widget _buildTextField(String label, TextEditingController controller,
      String suffix, IconData? prefixIcon) {
    return Expanded(
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          fillColor: Colors.white,
          filled: true,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixText: suffix,
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,1}$')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.7),
        elevation: 0,
        centerTitle: true,
        title: Text("Kasvihuone", style: GoogleFonts.pacifico(fontSize: 40)),
        toolbarHeight: 120,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Transform.scale(
              scale: 1.5,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.notifications),
                onSelected: (String result) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result)),
                  );
                },
                itemBuilder: (BuildContext context) {
                  return notifications.map((String notification) {
                    return PopupMenuItem<String>(
                      value: notification,
                      child: Text(notification),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  _buildSettingsSection(
                    label: 'Lämpötila-asetukset',
                    backgroundColor:
                        Colors.lightGreen.withOpacity(0.6), // Vihreä tausta
                    children: [
                      Row(
                        children: [
                          _buildTextField('Alaraja', _minTemperatureController,
                              '°C', Icons.thermostat),
                          const SizedBox(width: 10),
                          _buildTextField('Yläraja', _maxTemperatureController,
                              '°C', Icons.thermostat),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildSettingsSection(
                    label: 'Kosteusasetukset',
                    backgroundColor: Colors.lightBlueAccent
                        .withOpacity(0.4), // Sininen tausta
                    children: [
                      Row(
                        children: [
                          _buildTextField('Alaraja', _minHumidityController,
                              '%', Icons.water),
                          const SizedBox(width: 10),
                          _buildTextField('Yläraja', _maxHumidityController,
                              '%', Icons.water),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        backgroundColor: Colors.lightGreen,
                      ),
                      child: Text(
                        'Tallenna',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String label,
    required Color backgroundColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.lato(
              textStyle:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10.0),
          ...children,
        ],
      ),
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _minTemperatureController =
      TextEditingController();
  final TextEditingController _maxTemperatureController =
      TextEditingController();
  final TextEditingController _minHumidityController = TextEditingController();
  final TextEditingController _maxHumidityController = TextEditingController();
  final List<String> notifications = [
    'Ilmoitus',
    'Ilmoitus',
    'Ilmoitus',
  ];
  // Vapautetaan kontrollerien käyttämät resurssit, kun widget tuhotaan
  @override
  void dispose() {
    _minTemperatureController.dispose();
    _maxTemperatureController.dispose();
    _minHumidityController.dispose();
    _maxHumidityController.dispose();
    super.dispose();
  }

  // Tallennetaan asetukset, JOS arvot kelvolliset
  void _saveSettings() {
    final double? minTemperature =
        double.tryParse(_minTemperatureController.text);
    final double? maxTemperature =
        double.tryParse(_maxTemperatureController.text);
    final double? minHumidity = double.tryParse(_minHumidityController.text);
    final double? maxHumidity = double.tryParse(_maxHumidityController.text);

    if (_areValuesValid(
        minTemperature, maxTemperature, minHumidity, maxHumidity)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Asetukset tallennettu: Lämpötila: $minTemperature - $maxTemperature °C, Kosteus: $minHumidity - $maxHumidity %')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Syötä kelvolliset arvot: Lämpötila (-50°C - 50°C) & Kosteus (0% - 100%)')),
      );
    }
  }

  // Tarkistetaan syötetyt arvot
  bool _areValuesValid(double? minTemperature, double? maxTemperature,
      double? minHumidity, double? maxHumidity) {
    return minTemperature != null &&
        maxTemperature != null &&
        minHumidity != null &&
        maxHumidity != null &&
        minTemperature >= -50 &&
        maxTemperature <= 50 &&
        minHumidity >= 0 &&
        maxHumidity <= 100 &&
        minTemperature <= maxTemperature &&
        minHumidity <= maxHumidity;
  }

  // Tekstikenttä
  Widget _buildTextField(String label, TextEditingController controller,
      String suffix, IconData? prefixIcon) {
    return Expanded(
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          fillColor: Colors.white,
          filled: true,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixText: suffix,
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,1}$')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.7),
        elevation: 0,
        centerTitle: true,
        title: Text("Kasvihuone", style: GoogleFonts.pacifico(fontSize: 40)),
        toolbarHeight: 120,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Transform.scale(
              scale: 1.5,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.notifications),
                onSelected: (String result) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result)),
                  );
                },
                itemBuilder: (BuildContext context) {
                  return notifications.map((String notification) {
                    return PopupMenuItem<String>(
                      value: notification,
                      child: Text(notification),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Asetukset',
                    style: TextStyle(fontSize: 20), // Muuttaa fonttia
                  ),
                  const SizedBox(height: 20),
                  // Rivi lämpötilan ala- ja ylärajojen tekstikentille
                  Row(
                    children: [
                      _buildTextField('Lämpötila alaraja',
                          _minTemperatureController, '°C', Icons.thermostat),
                      const SizedBox(width: 10),
                      _buildTextField('Lämpötila yläraja',
                          _maxTemperatureController, '°C', Icons.thermostat),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildTextField('Kosteus alaraja', _minHumidityController,
                          '%', Icons.water),
                      const SizedBox(width: 10),
                      _buildTextField('Kosteus yläraja', _maxHumidityController,
                          '%', Icons.water),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Tallenna-painike, joka kutsuu _saveSettings-metodia
                  ElevatedButton(
                    onPressed: _saveSettings,
                    child: const Text('Tallenna'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/
