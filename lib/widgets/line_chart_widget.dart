import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LineChartWidget extends StatelessWidget {
  final List<double> data; // List of data points for the chart.
  final List<DateTime>
      timestamps; // List of timestamps corresponding to the data points.
  final Color color;

  const LineChartWidget({
    Key? key,
    required this.data,
    required this.timestamps,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.lightGreenAccent,
      // passing data, timestamps and color to private _LineChartWidget
      child: _LineChartWidget(
        data: data,
        timestamps: timestamps,
        color: color,
      ),
    );
  }
}

class _LineChartWidget extends StatelessWidget {
  final List<double> data;
  final List<DateTime> timestamps;
  final Color color;

  const _LineChartWidget({
    Key? key,
    required this.data,
    required this.timestamps,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LineChart(
      // setting all the data for the chart
      LineChartData(
        lineTouchData: lineTouchData(),
        gridData: gridData(),
        titlesData: titlesData(),
        borderData: borderData(),
        backgroundColor: Colors.lightGreen.withOpacity(0.3),
        lineBarsData: lineBarsData(),
        // setting the min and max values for x-axis
        minX: timestamps.first.millisecondsSinceEpoch.toDouble(),
        maxX: timestamps.last.millisecondsSinceEpoch.toDouble(),
        // finding the min and max values for the y-axis
        minY:
            data.reduce((value, element) => value < element ? value : element),
        maxY:
            data.reduce((value, element) => value > element ? value : element),
      ),
    );
  }

  LineTouchData lineTouchData() => LineTouchData(
        // setting touched spots and tooltips in the line
        handleBuiltInTouches: true,
        getTouchedSpotIndicator:
            (LineChartBarData barData, List<int> spotIndexes) {
          return spotIndexes.map((index) {
            return TouchedSpotIndicatorData(
              FlLine(color: Colors.blue, strokeWidth: 2),
              FlDotData(show: true),
            );
          }).toList();
        },
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((touchedSpot) {
              final flSpot = touchedSpot;
              return LineTooltipItem(
                '${flSpot.y.toStringAsFixed(1)}',
                const TextStyle(color: Colors.white),
              );
            }).toList();
          },
        ),
      );

  FlGridData gridData() => FlGridData(
        //setting the appearance of the grid
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (double _) => FlLine(
          color: Colors.white.withOpacity(0.2),
          strokeWidth: 1,
        ),
        getDrawingVerticalLine: (double _) => FlLine(
          color: Colors.white.withOpacity(0.2),
          strokeWidth: 1,
        ),
      );

  FlTitlesData titlesData() => FlTitlesData(
        // setting titles of the chart to be visible or not
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              DateTime date = DateTime.fromMillisecondsSinceEpoch(
                  value.toInt()); // converting value to DateTime
              return Text(DateFormat('dd/MM')
                  .format(date)); // formatting date and returning it as text
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(value.toStringAsFixed(
                  0)); // formatting value and returning it as text
            },
          ),
        ),
      );

  FlBorderData borderData() => FlBorderData(
        // setting borders appearance
        show: true,
        border: Border(
          bottom: BorderSide(
            color: Colors.lightGreenAccent.withOpacity(0.2),
            width: 4,
          ),
          left: const BorderSide(color: Colors.transparent),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      );

  List<LineChartBarData> lineBarsData() => [
        LineChartBarData(
          spots: List.generate(
            data.length,
            (index) => FlSpot(
              timestamps[index]
                  .millisecondsSinceEpoch
                  .toDouble(), // Converting timestamp to double for FlSpot.
              data[index],
            ),
          ),
          isCurved: true,
          color: color,
          barWidth: 2,
          belowBarData: BarAreaData(show: false),
        ),
      ];
}
