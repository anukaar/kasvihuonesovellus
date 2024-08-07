import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kasvihuonesovellus/greenhouse_viewmodel.dart';
import 'package:kasvihuonesovellus/widgets/line_chart_widget.dart';

class StatisticsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greenhouseData = ref.watch(greenhouseViewModelProvider);
    final connectedDevice =
        greenhouseData.devices.isNotEmpty ? greenhouseData.devices.first : null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.7),
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Kasvihuone',
              style: GoogleFonts.pacifico(fontSize: 50),
            ),
            if (connectedDevice != null) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    connectedDevice.name.isNotEmpty
                        ? connectedDevice.name
                        : 'Unknown device',
                    style: GoogleFonts.lato(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8.0),
                  Icon(
                    Icons.circle,
                    color: connectedDevice != null ? Colors.green : Colors.red,
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
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            top: kToolbarHeight + 100,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (greenhouseData.temperatures.isEmpty ||
                        greenhouseData.humidities.isEmpty)
                      CircularProgressIndicator()
                    else ...[
                      buildChartSectionTemperature(
                        context: context,
                        title: 'Lämpötila: ',
                        data: greenhouseData.temperatures,
                        timestamps: greenhouseData.timestamps,
                        color: Colors.orange,
                      ),
                      SizedBox(height: 16.0),
                      buildChartSectionHumidity(
                        context: context,
                        title: 'Kosteus: ',
                        data: greenhouseData.humidities,
                        timestamps: greenhouseData.timestamps,
                        color: Colors.blue,
                      ),
                    ],
                    SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: () {
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
                    SizedBox(height: 120.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildChartSectionTemperature({
    required BuildContext context,
    required String title,
    required List<double> data,
    required List<DateTime> timestamps,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.lightGreen.withOpacity(0.6),
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
