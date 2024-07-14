import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LineChartWidget extends StatelessWidget {
  final List<double> data;
  final List<DateTime> timestamps;
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
      LineChartData(
        lineTouchData: lineTouchData(),
        gridData: gridData(),
        titlesData: titlesData(),
        borderData: borderData(),
        backgroundColor: Colors.lightGreen.withOpacity(0.3),
        lineBarsData: lineBarsData(),
        minX: timestamps.first.millisecondsSinceEpoch.toDouble(),
        maxX: timestamps.last.millisecondsSinceEpoch.toDouble(),
        minY:
            data.reduce((value, element) => value < element ? value : element),
        maxY:
            data.reduce((value, element) => value > element ? value : element),
      ),
    );
  }

  LineTouchData lineTouchData() => const LineTouchData(
        handleBuiltInTouches: true,
      );

  FlGridData gridData() => FlGridData(
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
              DateTime date =
                  DateTime.fromMillisecondsSinceEpoch(value.toInt());
              return Text(DateFormat('dd/MM').format(date));
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(value.toStringAsFixed(0));
            },
          ),
        ),
      );

  FlBorderData borderData() => FlBorderData(
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
              timestamps[index].millisecondsSinceEpoch.toDouble(),
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
