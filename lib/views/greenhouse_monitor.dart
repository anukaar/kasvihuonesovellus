import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kasvihuonesovellus/greenhouse_viewmodel.dart';

class GreenhouseMonitor extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greenhouseData = ref.watch(greenhouseViewModelProvider);

    // tarkista, onko dataa saatavilla
    if (greenhouseData.temperatures.isEmpty ||
        greenhouseData.humidities.isEmpty) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.7),
          elevation: 0,
          centerTitle: true,
          title: Text("Kasvihuone", style: GoogleFonts.pacifico(fontSize: 50)),
          toolbarHeight: 120,
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.7),
        elevation: 0,
        centerTitle: true,
        title: Text("Kasvihuone", style: GoogleFonts.pacifico(fontSize: 50)),
        toolbarHeight: 120,
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
                      Text(
                        'Lämpötila',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10, width: 10),
                      Text(
                        '$latestTemperature°C',
                        style: TextStyle(fontSize: 24),
                      ),
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
                        'Kosteus: ',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$latestHumidity%',
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          /*Positioned(
            right: 16,
            bottom: 150,
            child: FloatingActionButton(
              onPressed: () {
                ref
                    .read(greenhouseViewModelProvider.notifier)
                    .updateData(25, 60, DateTime.timestamp());
              },
              child: const Icon(Icons.update),
            ),
          ),*/
        ],
      ),
    );
  }
}
