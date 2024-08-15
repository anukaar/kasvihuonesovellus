import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kasvihuonesovellus/greenhouse_viewmodel.dart';
import 'package:kasvihuonesovellus/widgets/line_chart_widget.dart';

class StatisticsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Haetaan kasvihuoneen tiedot viewmodelista
    final greenhouseData = ref.watch(greenhouseViewModelProvider);
    // Haetaan ensimmäinen yhdistetty laite, jos sellainen on olemassa
    final connectedDevice =
        greenhouseData.devices.isNotEmpty ? greenhouseData.devices.first : null;

    return Scaffold(
      extendBodyBehindAppBar: true, // AppBar ulottuu taustakuvan päälle
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.7), // läpikuultava tausta
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            // Otsikon tekstiominaisuudet
            Text(
              'Kasvihuone',
              style: GoogleFonts.pacifico(fontSize: 50),
            ),
            // Jos laite on yhdistetty, näytetään laitteen nimi ja tila
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
            ],
          ],
        ),
        toolbarHeight: 120,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.jpg"),
                fit: BoxFit.cover, // Taustakuva täyttää koko tilan
              ),
            ),
          ),
          Positioned.fill(
            top: kToolbarHeight + 100, // Jättää tilaa AppBarille ja ylämarginaalille
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Jos dataa ei ole vielä ladattu, näytä latausindikaattori
                    if (greenhouseData.temperatures.isEmpty ||
                        greenhouseData.humidities.isEmpty)
                      CircularProgressIndicator()
                    else ...[
                      // Muussa tapauksessa näytetään lämpötilakaavio
                      buildChartSectionTemperature(
                        context: context,
                        title: 'Lämpötila: ',
                        data: greenhouseData.temperatures,
                        timestamps: greenhouseData.timestamps,
                        color: Colors.orange,
                      ),
                      SizedBox(height: 16.0),
                      // Näytetään myös kosteuskaavio
                      buildChartSectionHumidity(
                        context: context,
                        title: 'Kosteus: ',
                        data: greenhouseData.humidities,
                        timestamps: greenhouseData.timestamps,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 100.0), // Lisätilaa alareunaan
                    ],
                    SizedBox(height: 10.0),
                    // Nappi, jolla voi etsiä tarvittaessa RuuviTagia
                    ElevatedButton(
                      onPressed: () {
                        // Käynnistetään Bluetooth-skannaus viewmodelista
                        ref
                            .read(greenhouseViewModelProvider.notifier)
                            .startScan();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Funktio lämpötilakaavion luomiseen
  Widget buildChartSectionTemperature({
    required BuildContext context,
    required String title,
    required List<double> data,
    required List<DateTime> timestamps,
    required Color color,
  }) {
    return Container(
      // Ulkoasun asettelut kaavion taustalla olevalle tilalle
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.lightGreen.withOpacity(0.6), // Taustan väri
        borderRadius: BorderRadius.circular(8.0), // Pyöristetyt kulmat
        boxShadow: [
          // Varjoefekti
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Tasaus vasemmalle
        children: [
          Text(
            title,
            style: GoogleFonts.lato(
              textStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10.0),
          // Kaavion kuvasuhde
          AspectRatio(
            aspectRatio: 1.5,
            child: LineChartWidget(
              data: data,
              timestamps: timestamps,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Funktio kosteuskaavion luomiseen
  Widget buildChartSectionHumidity({
    required BuildContext context,
    required String title,
    required List<double> data,
    required List<DateTime> timestamps,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.lightBlueAccent.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8.0),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lato(
              textStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10.0),
          AspectRatio(
            aspectRatio: 1.5,
            child: LineChartWidget(
              data: data,
              timestamps: timestamps,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
