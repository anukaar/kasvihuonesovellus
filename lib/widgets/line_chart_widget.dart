import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LineChartWidget extends StatelessWidget {
  final List<double> data; // luodaan lista kaavion datapisteille
  final List<DateTime>
      timestamps; // luodaan lista datapisteitä vastaaville aikaleimoille
  final Color color;

  // konstruktori LineChartWidget-luokalle
  const LineChartWidget({
    Key? key,
    required this.data,
    required this.timestamps,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // tarkista, onko aikaleiman dataa saatavilla
    if (data.isEmpty || timestamps.isEmpty) {
      return Center(
        child: Text(
          'Tietoja ei saatavilla', // jos aikaleiman dataa ei ole, palauta virheilmoitus
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    // jos aikaleiman dataa on saatavilla, näytä kaavio
    return Container(
      color: Colors.lightGreenAccent.withOpacity(0.5), //taustaväri
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

  // konstruktori yksityiselle luokalle
  const _LineChartWidget({
    Key? key,
    required this.data,
    required this.timestamps,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // luodaan kaavio
    return LineChart(
      // määritellään kaavion rakenne
      LineChartData(
        lineTouchData: lineTouchData(), //kosketustoiminnot
        gridData: gridData(), //ruudukko
        titlesData: titlesData(), //otsikot
        borderData: borderData(), //reunat
        backgroundColor: Colors.white.withOpacity(0.7), //taustaväri
        lineBarsData: lineBarsData(), // data ja viivan ulkoasu
        // asetetaan x-akselin minimi- ja maksimiarvot
        minX: timestamps.first.millisecondsSinceEpoch.toDouble(),
        maxX: timestamps.last.millisecondsSinceEpoch.toDouble(),
        // asetetaan y-akselin laajennetut minimi- ja maksimiarvot
        minY:
            data.reduce((value, element) => value < element ? value : element) -
                0.2,
        maxY:
            data.reduce((value, element) => value > element ? value : element) +
                0.2,
      ),
    );
  }

  // määritellään kosketustoiminnalllisuudet
  LineTouchData lineTouchData() => LineTouchData(
        // määritetään kaavion viivan arvopisteet ja selitystekstit
        handleBuiltInTouches: true,
        getTouchedSpotIndicator:
            (LineChartBarData barData, List<int> spotIndexes) {
          return spotIndexes.map((index) {
            return TouchedSpotIndicatorData(
              FlLine(
                  color: Colors.blue, strokeWidth: 2), //viivan väri ja leveys
              FlDotData(show: true), //arvopiste viivalla näkyviin
            );
          }).toList();
        },
        touchTooltipData: LineTouchTooltipData(
          // määritellään tooltipsit
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
  // määritellään ruudukon ulkoasu
  FlGridData gridData() => FlGridData(
        //määritetään ruudukon ulkoasu
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (double _) => FlLine(
          color: Colors.green.withOpacity(0.2), //vaakaviivojen väri
          strokeWidth: 1,
        ),
        getDrawingVerticalLine: (double _) => FlLine(
          color: Colors.green.withOpacity(0.2), //pystyviivojen väri
          strokeWidth: 1,
        ),
      );
  //määritellään otsikoiden ulkoasu ja sisältö
  FlTitlesData titlesData() => FlTitlesData(
        // asetetaaan kaavioiden otsikoiden näkyvyys
        show: true,
        rightTitles: const AxisTitles(
          sideTitles:
              SideTitles(showTitles: false), //piilota oikean laidan otsikko
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false), //piilota ylälaidan otsikko
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true, //alalaidan otsikko näkyviin (x-akseli)
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              //muunnetaan x-akselin arvo päivämääräksi ja muotoillaan se
              final dateTime =
                  DateTime.fromMillisecondsSinceEpoch(value.toInt());
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 6,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0), // akselin ja otsikoiden riviväli
                  child: Transform.rotate(
                    angle: -45 * 3.14159 / 180, // tekstin kääntö 45 astetta
                    child: Text(
                      DateFormat('HH:mm').format(
                          dateTime), //näytetään aika muodossa tunnit:minuutit
                      style: TextStyle(fontSize: 10, color: Colors.black),
                    ),
                  ),
                ),
              );
            },
            interval: 60000,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true, //vasemman reunan otsikko näkyviin (y-akseli)
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  value.toStringAsFixed(1), //arvon pyöristys yhteen desimaaliin
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                  ),
                ),
              );
            },
          ),
        ),
      );

  FlBorderData borderData() => FlBorderData(
        // asetetaan kaavion reunojen ulkoasu
        show: true,
        border: Border(
          bottom: BorderSide(
            color: Colors.lightGreenAccent
                .withOpacity(0.1), //alareunan väri ja näkyvyys
            width: 5,
          ),
          //piilotetaan muut reunat
          left: const BorderSide(color: Colors.transparent),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      );
  // muodostetaa varsinainen data ja viivan ulkoasu
  List<LineChartBarData> lineBarsData() {
    if (data.length != timestamps.length) {
      //jos datan ja aikaleiman pituus eivät täsmää, palauta tyhjä lista
      return [];
    }
    return [
      LineChartBarData(
        spots: List.generate(
          data.length,
          (index) => FlSpot(
            timestamps[index].millisecondsSinceEpoch.toDouble(),
            // muunnetaan aikaleima double-arvoksi FlSpot:a varten
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
}
