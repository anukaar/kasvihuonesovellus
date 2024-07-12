import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kasvihuonesovellus/greenhouse_viewmodel.dart';

class StatisticsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greenhouseData = ref.watch(greenhouseViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Tilastot')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Lämpötila: ',
              style: GoogleFonts.lato(
                textStyle:
                    TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            AspectRatio(
              aspectRatio: 4,
              child: TemperatureChart(
                  greenhouseData.temperatures, greenhouseData.timestamps),
            ),
            SizedBox(
              height: 16.0,
            ),
            Text(
              'Kosteus: ',
              style: GoogleFonts.lato(
                textStyle:
                    TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            AspectRatio(
              aspectRatio: 4,
              child: HumidityChart(
                  greenhouseData.humidities, greenhouseData.timestamps),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(greenhouseViewModelProvider.notifier).fetchData();
              },
              child: Text('Fetch Data'),
            ),
          ],
        ),
      ),
    );
  }
}

class TemperatureChart extends StatelessWidget {
  final List<double> temperatures;
  final List<DateTime> timestamps;
  TemperatureChart(this.temperatures, this.timestamps);

  @override
  Widget build(BuildContext context) {
    final bottomInterval = timestamps.length > 1
        ? (timestamps.last.difference(timestamps.first).inDays / 5)
            .ceilToDouble()
        : 1.0;
    return LineChart(
      LineChartData(
        backgroundColor: Colors.lightGreenAccent,
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: bottomInterval,
              getTitlesWidget: (value, meta) {
                DateTime date =
                    DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Text(DateFormat('dd/MM').format(date));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              getTitlesWidget: (value, meta) {
                return Text(value.toStringAsFixed(0));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              temperatures.length,
              (index) => FlSpot(
                timestamps[index].millisecondsSinceEpoch.toDouble(),
                temperatures[index],
              ),
            ),
            isCurved: true,
            color: Colors.orange,
            barWidth: 2,
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}

class HumidityChart extends StatelessWidget {
  final List<double> humidities;
  final List<DateTime> timestamps;
  HumidityChart(this.humidities, this.timestamps);

  @override
  Widget build(BuildContext context) {
    final bottomInterval = timestamps.length > 1
        ? (timestamps.last.difference(timestamps.first).inDays / 5)
            .ceilToDouble()
        : 1.0;
    return LineChart(
      LineChartData(
        backgroundColor: Colors.lightGreenAccent,
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: bottomInterval,
              getTitlesWidget: (value, meta) {
                DateTime date =
                    DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Text(DateFormat('dd/MM').format(date));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 10,
              getTitlesWidget: (value, meta) {
                return Text(value.toStringAsFixed(0));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              humidities.length,
              (index) => FlSpot(
                timestamps[index].millisecondsSinceEpoch.toDouble(),
                humidities[index],
              ),
            ),
            isCurved: true,
            color: Colors.blue,
            barWidth: 2,
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}
