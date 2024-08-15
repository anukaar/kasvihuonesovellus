import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kasvihuonesovellus/greenhouse_viewmodel.dart';
import 'package:kasvihuonesovellus/widgets/line_chart_widget.dart';

class StatisticsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // haetaan kasvihuoneen tiedot viewmodelista
    final greenhouseData = ref.watch(greenhouseViewModelProvider);
    // haetaan ensimmäinen yhdistetty laite, jos sellainen on olemassa
    final connectedDevice =
        greenhouseData.devices.isNotEmpty ? greenhouseData.devices.first : null;

    return Scaffold(
      extendBodyBehindAppBar: true,  //AppBar ulottuu taustakuvan päälle
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.7),  //läpikuultava tausta
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            // otsikon tekstiominaisuudet
            Text(
              'Kasvihuone',
              style: GoogleFonts.pacifico(fontSize: 50),
            ),
            // jos laite on yhdistetty, näytetään laitteen nimi ja tila
            if (connectedDevice != null) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // näytetään laitteen nimi tai "unknown device", jos nimeä ei ole
                  Text(
                    connectedDevice.name.isNotEmpty
                        ? connectedDevice.name
                        : 'Unknown device',
                    style: GoogleFonts.lato(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8.0),
                  // vihreä ympyrä osoittaa yhteyden tilan
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
                fit: BoxFit.cover,  //taustakuva täyttää koko tilan
              ),
            ),
          ),
          // scrollaava sisältöalue
          Positioned.fill(
            top: kToolbarHeight + 100,  //jättää tilaa AppBarille ja ylämarginaalille
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // jos dataa ei ole vielä ladattu, näytä latausindikaattori
                    if (greenhouseData.temperatures.isEmpty ||
                        greenhouseData.humidities.isEmpty)
                      CircularProgressIndicator()
                    else ...[
                      // muuten näytä lämpötilakaavio
                      buildChartSectionTemperature(
                        context: context,
                        title: 'Lämpötila: ',
                        data: greenhouseData.temperatures,
                        timestamps: greenhouseData.timestamps,
                        color: Colors.orange,
                      ),
                      SizedBox(height: 16.0),
                      // näytä myös kosteuskaavio
                      buildChartSectionHumidity(
                        context: context,
                        title: 'Kosteus: ',
                        data: greenhouseData.humidities,
                        timestamps: greenhouseData.timestamps,
                        color: Colors.blue,
                      ),
                    ],
                    SizedBox(height: 10.0),
                    // nappi, jolla voi etsiä tarvittaessa RuuviTagia
                    ElevatedButton(
                      onPressed: () {
                        // käynnistetään Bluetooth-skannnus viewmodelista
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
                    SizedBox(height: 120.0),  //lisätilaa alareunaan
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  // funktio lämpötilakaavion luomiseen
  Widget buildChartSectionTemperature({
    required BuildContext context,
    required String title,
    required List<double> data,
    required List<DateTime> timestamps,
    required Color color,
  }) {
    return Container(
      // ulkoasun asettelut kaavion taustalla olevalle tilalle
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.lightGreen.withOpacity(0.6),  //taustan väri
        borderRadius: BorderRadius.circular(8.0),  // pyöristetyt kulmat
        boxShadow: [
          // varjoefekti
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,  //tasaus vasemmalle
        children: [
          Text(
            title,
            style: GoogleFonts.lato(
              textStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10.0),
          // kaavion kuvasuhde
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
// funktio kosteuskaavion luomiseen (samanlainen kuin lämpötilakaavio)
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
