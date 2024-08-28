import 'package:flutter/material.dart';
import 'package:kasvihuonesovellus/views/greenhouse_monitor.dart';
import 'package:kasvihuonesovellus/views/settings_page.dart';
import 'package:kasvihuonesovellus/views/statistics_page.dart';

// Päänavigointisivu, jossa käyttäjä voi siirtyä eri näkymien (Monitori, Tilastot, Asetukset) välillä.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // _currentIndex pitää kirjaa siitä, mikä näkymä on parhaillaan aktiivinen (valittuna).
  int _currentIndex = 0;
  // Lista sivuista, joita käyttäjä voi selata BottomNavigationBarin kautta.
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
        // Alavalikon määrittelyt
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
                icon: Icon(Icons.bar_chart, size: 60), label: 'Tilastot'),
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
