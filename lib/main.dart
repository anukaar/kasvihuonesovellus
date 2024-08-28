import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasvihuonesovellus/views/home_page.dart';

// Odotetaan, että Firebase on alustettu ja anonyymi kirjautuminen on suoritettu ennen sovelluksen käynnistämistä
void main() async {
  // Varmistetaan Flutterin widgettien alustus ennen sovelluksen käynnistystä
  WidgetsFlutterBinding.ensureInitialized();
  // Alustetaan Firebase-projekti
  await Firebase.initializeApp();
  // Suoritetaan anonyymi kirjautuminen Firebase Authenticationiin
  await signInAnonymously();

  // Käynnistetään sovellus, ja ProviderScope mahdollistaa Riverpod-tilanhallinnan
  runApp(const ProviderScope(child: MyApp()));
}

// Määritellään sovelluksen teema
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xFFC8E6C9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF66BB6A),
        ),
      ),
      home: HomePage(), // Asetetaan sovelluksen aloitussivuksi HomePage
    );
  }
}

// Suoritetaan anonyymi kirjautuminen Firebase Authenticationiin
// Tämä mahdollistaa sovelluksen käytön ilman käyttäjän kirjautumista sisään.
//Tulostaa konsoliin käyttäjän UID:n onnistuneen kirjautumisen jälkeen.
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
