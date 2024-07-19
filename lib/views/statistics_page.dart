import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kasvihuonesovellus/greenhouse_viewmodel.dart';

class StatisticsPage extends ConsumerWidget {
  // Change to ConsumerWidget
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Add WidgetRef
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.7),
        elevation: 0,
        centerTitle: true,
        title: Text('Kasvihuone', style: GoogleFonts.pacifico(fontSize: 50)),
        toolbarHeight: 120,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Positioned(
            top: kToolbarHeight + 150,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Historia',
                style: TextStyle(fontSize: 36),
              ),
            ),
          ),
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Lämpötila', style: TextStyle(fontSize: 24)),
                SizedBox(height: 8),
                Text('Kosteus', style: TextStyle(fontSize: 24)),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 150,
            child: FloatingActionButton(
              onPressed: () {
                ref
                    .read(greenhouseViewModelProvider.notifier)
                    .updateTemperature(25.0);
                ref
                    .read(greenhouseViewModelProvider.notifier)
                    .updateHumidity(60.0);
              },
              child: const Icon(Icons.update),
            ),
          ),
        ],
      ),
    );
  }
}
