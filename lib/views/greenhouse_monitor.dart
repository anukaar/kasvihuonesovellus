import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kasvihuonesovellus/viewmodels/greenhouse_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../viewmodels/notification_provider.dart';

class GreenhouseMonitor extends ConsumerStatefulWidget {
  @override
  _GreenhouseMonitorState createState() => _GreenhouseMonitorState();
}

class _GreenhouseMonitorState extends ConsumerState<GreenhouseMonitor> {
  // Käyttäjän määrittelemät lämpötila- ja kosteusrajat
  double minTemperature = 15.0;
  double maxTemperature = 30.0;
  double minHumidity = 30.0;
  double maxHumidity = 70.0;

  @override
  void initState() {
    super.initState();
    _loadSettings(); // Lataa tallennetut asetukset

    // Suoritetaan tilapäivitys vasta widgetin rakentamisen jälkeen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // GreenhouseViewModel-data Riverpodin kautta
      final greenhouseData = ref.read(greenhouseViewModelProvider);
      final hasData = greenhouseData.temperatures.isNotEmpty &&
          greenhouseData.humidities.isNotEmpty;

      final latestTemperature =
          hasData ? greenhouseData.temperatures.last : null;
      final latestHumidity = hasData ? greenhouseData.humidities.last : null;

      // Tarkistetaan raja-arvot NotificationProviderin kautta
      ref.read(notificationProvider.notifier).checkThresholds(
            minTemperature,
            maxTemperature,
            minHumidity,
            maxHumidity,
            latestTemperature: latestTemperature,
            latestHumidity: latestHumidity,
          );
    });
  }

  // Funktio tallennettujen asetusten lataamiselle
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      minTemperature = prefs.getDouble('minTemperature') ?? 15.0;
      maxTemperature = prefs.getDouble('maxTemperature') ?? 30.0;
      minHumidity = prefs.getDouble('minHumidity') ?? 30.0;
      maxHumidity = prefs.getDouble('maxHumidity') ?? 70.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // GreenhouseViewModel-data Riverpodin kautta
    final greenhouseData = ref.watch(greenhouseViewModelProvider);
    // Hakee ensimmäisen löydetyn laitteen
    final connectedDevice =
        greenhouseData.devices.isNotEmpty ? greenhouseData.devices.first : null;

    // Tarkistaa, onko mittausdataa saatavilla
    final hasData = greenhouseData.temperatures.isNotEmpty &&
        greenhouseData.humidities.isNotEmpty;

    // Hakee viimeisimmän lämpötilan ja kosteuden
    final latestTemperature = hasData ? greenhouseData.temperatures.last : null;
    final latestHumidity = hasData ? greenhouseData.humidities.last : null;

    final notifications = ref.watch(notificationProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.7),
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 120,
        title: Column(
          children: [
            Text("Kasvihuone", style: GoogleFonts.pacifico(fontSize: 41)),
            const SizedBox(height: 3.0),
            // Tarkistaa, onko laite yhdistetty
            if (connectedDevice != null) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    connectedDevice.name.isNotEmpty
                        ? connectedDevice.name
                        : 'Unknown device',
                    style: GoogleFonts.lato(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 3.0),
                  // Jos laite on yhdistetty, näytetään vihreä ympyrä laitteen nimen perässä
                  const Icon(
                    Icons.circle,
                    color: Colors.green,
                    size: 12,
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0, bottom: 15.0),
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
            // Taustakuvan määrittely
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            // Lämpötilan ja kosteuden esittämisen määrittelyt
            child: hasData
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCircularDisplay(
                        context: context,
                        label: "Lämpötila",
                        value: latestTemperature != null
                            ? '${latestTemperature.toStringAsFixed(1)}°C'
                            : 'N/A',
                        color: Colors.lightGreen.withOpacity(0.6),
                      ),
                      const SizedBox(height: 16),
                      _buildCircularDisplay(
                        context: context,
                        label: "Kosteus",
                        value: latestHumidity != null
                            ? '${latestHumidity.toStringAsFixed(1)}%'
                            : 'N/A',
                        color: Colors.lightBlueAccent.withOpacity(0.4),
                      ),
                    ],
                  )
                : const Text(
                    'Tietoja ei saatavilla',
                    style: TextStyle(color: Colors.red, fontSize: 24),
                  ),
          ),
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Center(
              // Päivityspainike tietojen hakemiselle
              child: ElevatedButton(
                onPressed: () {
                  ref.read(greenhouseViewModelProvider.notifier).startScan();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                child: Text(
                  'Päivitä',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Rakentaa ympyränmuotoisen näkymän mittausdatalle
  Widget _buildCircularDisplay({
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(50.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100.0),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }
}
