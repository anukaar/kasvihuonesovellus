import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LineChartWidget extends StatelessWidget {
  final List<double> data; // luodaan lista kaavion datapisteille
  final List<DateTime>
      timestamps; // luodaan lista datapisteitä vastaaville aikaleimoille
  final Color color;

  const LineChartWidget({
    Key? key,
    required this.data,
    required this.timestamps,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // tarkista, onko aikaleiman data tyhjä
    if (data.isEmpty || timestamps.isEmpty) {
      return Center(
        child: Text(
          'Tietoja ei saatavilla', // jos aikaleiman data on tyhjä, palauta tämä teksti
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    return Container(
      color: Colors.lightGreenAccent.withOpacity(0.5),
      // välitetään data, aikaleimat ja väri yksityiselle _LineChartWidget
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
      // määritellään kaavion rakenne
      LineChartData(
        lineTouchData: lineTouchData(),
        gridData: gridData(),
        titlesData: titlesData(),
        borderData: borderData(),
        backgroundColor: Colors.grey.withOpacity(0.7),
        lineBarsData: lineBarsData(),
        // asetetaan x-akselin minimi- ja maksimiarvot
        minX: timestamps.first.millisecondsSinceEpoch.toDouble(),
        maxX: timestamps.last.millisecondsSinceEpoch.toDouble(),
        // asetetaan y-akselin minimi- ja maksimiarvot
        minY:
            data.reduce((value, element) => value < element ? value : element),
        maxY:
            data.reduce((value, element) => value > element ? value : element),
      ),
    );
  }

  LineTouchData lineTouchData() => LineTouchData(
        // määritetään kaavion viivan arvopisteet ja selitystekstit
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
                '${flSpot.y.toStringAsFixed(1)}', // pyöristetään y-akselin arvo 1 desimaaliin
                const TextStyle(color: Colors.white),
              );
            }).toList();
          },
        ),
      );

  FlGridData gridData() => FlGridData(
        //määritetään ruudukon ulkoasu
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (double _) => FlLine(
          color: Colors.green.withOpacity(0.2),
          strokeWidth: 1,
        ),
        getDrawingVerticalLine: (double _) => FlLine(
          color: Colors.white.withOpacity(0.2),
          strokeWidth: 1,
        ),
      );

  FlTitlesData titlesData() => FlTitlesData(
        // asetetaaan kaavioiden otsikoiden näkyvyys
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
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 4, // akselin ja otsikoiden riviväli
                child: Transform.rotate(
                  angle: -45 * 3.14159 / 180, // tekstin kääntö 45 astetta
                  child: Text(
                    DateFormat('dd/MM').format(date),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
            /* interval: (timestamps.last.millisecondsSinceEpoch -
                        timestamps.first.millisecondsSinceEpoch)
                    .toDouble() /
                5,*/
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(value
                  .toStringAsFixed(0)); // arvon muotoilu ja palautus tekstinä
            },
          ),
        ),
      );

  FlBorderData borderData() => FlBorderData(
        // asetetaan kaavion reunojen ulkoasu
        show: true,
        border: Border(
          bottom: BorderSide(
            color: Colors.lightGreenAccent.withOpacity(0.1),
            width: 5,
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
                  .toDouble(), // muunnetaan aikaleima double-arvoksi FlSpot:a varten
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
