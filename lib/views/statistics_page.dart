import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kasvihuonesovellus/greenhouse_viewmodel.dart';
import 'package:kasvihuonesovellus/widgets/line_chart_widget.dart';

// Creating a ConsumerWidget for Riverpod state management
class StatisticsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greenhouseData = ref.watch(
        greenhouseViewModelProvider); // Watching the greenhouse view model provider for data.
    return Scaffold(
      appBar: AppBar(
        title: Text('Tilastot'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: buildChartSection(
                context: context,
                title: 'Lämpötila: ',
                data: greenhouseData
                    .temperatures, // Passing temperature data to the chart.
                timestamps: greenhouseData
                    .timestamps, // Passing timestamps to the chart.
                color: Colors.orange,
              ),
            ),
            SizedBox(
              height: 16.0, // Adding vertical space between chart sections.
            ),
            Expanded(
              child: buildChartSection(
                context: context,
                title: 'Kosteus: ',
                data: greenhouseData
                    .humidities, // Passing humidity data to the chart.
                timestamps: greenhouseData
                    .timestamps, // Passing timestamps to the chart.
                color: Colors.blue,
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(greenhouseViewModelProvider.notifier)
                    .fetchData(); // Fetching new data when button is pressed.
              },
              child: Text('Fetch Data'),
            ),
          ],
        ),
      ),
    );
  }

  // setting up the chart appearance
  Widget buildChartSection({
    required BuildContext context,
    required String title,
    required List<double> data,
    required List<DateTime> // Data points for the chart.
        timestamps, // Timestamps corresponding to the data points.
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.lightGreenAccent,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(
                0.5), // Adding a shadow with grey color and opacity.
            spreadRadius: 5, // Setting the spread radius for the shadow.
            blurRadius: 7, // Setting the blur radius for the shadow.
            offset: Offset(0, 3), // Setting the offset for the shadow.
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
          Expanded(
            child: AspectRatio(
              aspectRatio: 1.5, // Adjusted aspect ratio for better use of space
              child: LineChartWidget(
                // passing data and timestamps to the LineChartWidget, setting the color
                data: data,
                timestamps: timestamps,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
