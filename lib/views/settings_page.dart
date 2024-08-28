import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kasvihuonesovellus/viewmodels/notification_provider.dart';
import 'package:kasvihuonesovellus/viewmodels/settings_notifier.dart';

import '../viewmodels/greenhouse_viewmodel.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Asetusten hakeminen Riverpodin kautta
    final settings = ref.watch(settingsProvider);
    final notifications = ref.watch(notificationProvider);

    // Määritellään TextEditingControllerit asetusten alkuarvoilla
    final minTemperatureController =
        TextEditingController(text: settings['minTemperature'].toString());
    final maxTemperatureController =
        TextEditingController(text: settings['maxTemperature'].toString());
    final minHumidityController =
        TextEditingController(text: settings['minHumidity'].toString());
    final maxHumidityController =
        TextEditingController(text: settings['maxHumidity'].toString());

    // Rakentaa näkymän asetusten syöttöä varten
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.7),
        elevation: 0,
        centerTitle: true,
        title: Text("Kasvihuone", style: GoogleFonts.pacifico(fontSize: 41)),
        toolbarHeight: 120,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0, top: 10.0),
            // Ilmoituskuvakkeen määrittely
            child: Badge(
              isLabelVisible:
                  notifications.isNotEmpty, // Näytä merkki, jos ilmoituksia on
              label: Text(
                notifications.length.toString(), // Näytetään ilmoitusten määrä
                style: const TextStyle(color: Colors.white),
              ),
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.notifications),
                iconSize: 30.0,
                onSelected: (String result) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result)),
                  );
                },
                itemBuilder: (BuildContext context) {
                  if (notifications.isEmpty) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'Ei uusia ilmoituksia',
                        child: Text('Ei uusia ilmoituksia'),
                      )
                    ];
                  } else {
                    return notifications.map((String notification) {
                      return PopupMenuItem<String>(
                        value: notification,
                        child: Text(notification),
                      );
                    }).toList();
                  }
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
          // Asetusten syöttölomake
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                // Lomakkeen asettelut
                children: [
                  const SizedBox(height: 30),
                  // Asetuksien syötön määrittely
                  _buildSettingsSection(
                    label: 'Lämpötila-asetukset',
                    backgroundColor: Colors.lightGreen.withOpacity(0.6),
                    children: [
                      Row(
                        children: [
                          _buildTextField(
                            'Alaraja',
                            minTemperatureController,
                            '°C',
                            Icons.thermostat,
                          ),
                          const SizedBox(width: 10),
                          _buildTextField(
                            'Yläraja',
                            maxTemperatureController,
                            '°C',
                            Icons.thermostat,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _buildSettingsSection(
                    label: 'Kosteusasetukset',
                    backgroundColor: Colors.lightBlueAccent.withOpacity(0.4),
                    children: [
                      Row(
                        children: [
                          _buildTextField(
                            'Alaraja',
                            minHumidityController,
                            '%',
                            Icons.water,
                          ),
                          const SizedBox(width: 10),
                          _buildTextField(
                            'Yläraja',
                            maxHumidityController,
                            '%',
                            Icons.water,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    // Tallennuspainikkeen määrittely
                    child: ElevatedButton(
                      onPressed: () {
                        final minTemp =
                            double.tryParse(minTemperatureController.text) ??
                                -50;
                        final maxTemp =
                            double.tryParse(maxTemperatureController.text) ??
                                50;
                        final minHumidity =
                            double.tryParse(minHumidityController.text) ?? 0;
                        final maxHumidity =
                            double.tryParse(maxHumidityController.text) ?? 100;

                        // Tallenna asetukset Riverpodin notifierin kautta
                        ref.read(settingsProvider.notifier).saveSettings(
                              minTemp,
                              maxTemp,
                              minHumidity,
                              maxHumidity,
                            );

                        // Hae viimeisin data GreenhouseViewModelista
                        final greenhouseData =
                            ref.read(greenhouseViewModelProvider);
                        final hasData =
                            greenhouseData.temperatures.isNotEmpty &&
                                greenhouseData.humidities.isNotEmpty;

                        final latestTemperature =
                            hasData ? greenhouseData.temperatures.last : null;
                        final latestHumidity =
                            hasData ? greenhouseData.humidities.last : null;

                        // Tarkista rajojen ylittyminen/alittuminen ja luo ilmoitukset
                        ref.read(notificationProvider.notifier).checkThresholds(
                              minTemp,
                              maxTemp,
                              minHumidity,
                              maxHumidity,
                              latestTemperature: latestTemperature,
                              latestHumidity: latestHumidity,
                            );

                        // Ilmoitus käyttäjälle, että asetukset tallennettiin
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Asetukset tallennettu: Lämpötila: $minTemp - $maxTemp °C, Kosteus: $minHumidity - $maxHumidity %'),
                          ),
                        );
                      },
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

  // Asetusten syöttökentän luominen
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
          FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,2}')),
        ],
      ),
    );
  }

  // Asetuskentän taustan ulkoasun määrittely
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
