import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatisticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tilastot')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TemperatureChart(),
            ),
            SizedBox(
              height: 16.0,
            ),
            Expanded(
              child: HumidityChart(),
            ),
          ],
        ),
      ),
    );
  }
}

class TemperatureChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 20),
              FlSpot(1, 22),
              FlSpot(2, 23),
              FlSpot(3, 21),
              FlSpot(4, 19),
              FlSpot(5, 18),
              FlSpot(6, 17),
            ],
            isCurved: true,
            color: Colors.blue,
            barWidth: 4,
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}

class HumidityChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 60),
              FlSpot(1, 62),
              FlSpot(2, 65),
              FlSpot(3, 63),
              FlSpot(4, 61),
              FlSpot(5, 59),
              FlSpot(6, 58),
            ],
            isCurved: true,
            color: Colors.green,
            barWidth: 4,
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}
