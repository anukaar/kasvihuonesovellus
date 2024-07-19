import 'package:flutter/material.dart';
import 'package:kasvihuonesovellus/views/greenhouse_monitor.dart';
import 'package:kasvihuonesovellus/views/settings_page.dart';
import 'package:kasvihuonesovellus/views/statistics_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    GreenhouseMonitor(),
    StatisticsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        height: 120,
        child: BottomNavigationBar(
          backgroundColor: Colors.white.withOpacity(0.5),
          elevation: 0,
          currentIndex: _currentIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black87,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 60), label: 'Koti'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart, size: 60), label: 'Historia'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings, size: 60), label: 'Asetukset'),
          ],
          selectedLabelStyle:
              TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
