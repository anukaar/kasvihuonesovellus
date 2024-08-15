import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kasvihuonesovellus/greenhouse_viewmodel.dart';

class GreenhouseMonitor extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greenhouseData = ref.watch(greenhouseViewModelProvider);
    // Haetaan ensimmäinen yhdistetty laite, jos sellainen on olemassa
    final connectedDevice =
        greenhouseData.devices.isNotEmpty ? greenhouseData.devices.first : null;

    // Tarkista, onko dataa saatavilla
    if (greenhouseData.temperatures.isEmpty ||
        greenhouseData.humidities.isEmpty) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.7),
          elevation: 0,
          toolbarHeight: 120,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: Text("Kasvihuone",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.pacifico(fontSize: 40))),
            ],
          ),
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
              child: Text(
                'Tietoja ei saatavilla',
                style: TextStyle(color: Colors.red, fontSize: 24),
              ),
            ),
          ],
        ),
      );
    }

    // Muunna viimeisin lämpötila ja kosteus desimaaleiksi ja pyöristä yhteen desimaaliin
    final latestTemperature =
        greenhouseData.temperatures.last.toStringAsFixed(1);
    final latestHumidity = greenhouseData.humidities.last.toStringAsFixed(1);

    final List<String> notifications = [
      'Ilmoitus',
      'Ilmoitus',
      'Ilmoitus',
    ];

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Näytetään laitteen nimi ja tila
                if (connectedDevice != null) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Näytetään laitteen nimi tai "Unknown device", jos nimeä ei ole
                      Text(
                        connectedDevice.name.isNotEmpty
                            ? connectedDevice.name
                            : 'Unknown device',
                        style: GoogleFonts.lato(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8.0),
                      // Vihreä ympyrä osoittaa yhteyden tilan
                      Icon(
                        Icons.circle,
                        color: Colors.green,
                        size: 16,
                      ),
                    ],
                  ),
                  SizedBox(
                      height:
                          20), // Lisää tilaa laitteen nimen ja mittaustietojen väliin
                ],
                Container(
                  padding: EdgeInsets.all(50.0),
                  margin: EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.lightGreen.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(100.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Lämpötila",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10, width: 10),
                      Text('$latestTemperature°C',
                          style: TextStyle(fontSize: 24)),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(50.0),
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(100.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Kosteus',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10, width: 10),
                      Text('$latestHumidity%', style: TextStyle(fontSize: 24)),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  // Nappi, jolla voi etsiä tarvittaessa RuuviTagia
                  child: ElevatedButton(
                    onPressed: () {
                      // Käynnistetään Bluetooth-skannaus viewmodelista
                      ref
                          .read(greenhouseViewModelProvider.notifier)
                          .startScan();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    child: Text(
                      'Etsi RuuviTag',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
