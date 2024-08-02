import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kasvihuonesovellus/greenhouse_viewmodel.dart';

import '../widgets/line_chart_widget.dart';

class StatisticsPage extends ConsumerWidget {
  // Change to ConsumerWidget
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greenhouseData = ref.watch(greenhouseViewModelProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.7),
        elevation: 0,
        centerTitle: true,
        title: Text('Kasvihuone', style: GoogleFonts.pacifico(fontSize: 50)),
        toolbarHeight: 120,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Positioned(
            top: kToolbarHeight + 150,
            left: 0,
            right: 0,
            child: Center(),
          ),
          Positioned.fill(
            top: kToolbarHeight + 100,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    buildChartSection(
                      context: context,
                      title: 'Lämpötila: ',
                      data: greenhouseData.temperatures,
                      timestamps: greenhouseData.timestamps,
                      color: Colors.orange,
                    ),
                    SizedBox(height: 16.0),
                    buildChartSection(
                      context: context,
                      title: 'Kosteus: ',
                      data: greenhouseData.humidities,
                      timestamps: greenhouseData.timestamps,
                      color: Colors.blue,
                    ),
                    SizedBox(
                        height:
                            100.0), // Add space to push the button above the bottom nav bar
                  ],
                ),
              ),
            ),
          ),
          /*Positioned(
            right: 16,
            bottom:
                100, // Adjusted to be clearly above the bottom navigation bar
            child: FloatingActionButton(
              onPressed: () {
                ref
                    .read(greenhouseViewModelProvider.notifier)
                    .updateTemperature(25.0);
                ref
                    .read(greenhouseViewModelProvider.notifier)
                    .updateHumidity(60.0);
              },
              child: const Icon(Icons.update),
            ),
          ),*/
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 130.0), // Ensure padding above the bottom nav bar
              child: ElevatedButton(
                onPressed: () {
                  ref.read(greenhouseViewModelProvider.notifier).fetchData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text(
                  'Hae tiedot',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildChartSection({
    required BuildContext context,
    required String title,
    required List<double> data,
    required List<DateTime> timestamps,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.lightGreen.withOpacity(0.7),
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
