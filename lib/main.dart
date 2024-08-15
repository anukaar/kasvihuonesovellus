import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasvihuonesovellus/views/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await signInAnonymously();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xFFC8E6C9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF66BB6A),
        ),
      ),
      home: HomePage(),
    );
  }
}

// Anonyymi kirjautuminen Firebase Authenticationiin
Future<void> signInAnonymously() async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInAnonymously();
    print(
        "Kirjauduttu sisään anonyymisti UID:llä: ${userCredential.user?.uid}");
  } catch (e) {
    print("Anonyymissä kirjautumisessa tapahtui virhe: $e");
  }
}
