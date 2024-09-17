import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const BerlinUndergroundApp());
}

class BerlinUndergroundApp extends StatelessWidget {
  const BerlinUndergroundApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Haupt-App-Widget mit Theme und Startbildschirm
    return MaterialApp(
      title: 'Berlin Underground Controller',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey).copyWith(
          secondary: Colors.amberAccent,  // Ersetzt accentColor durch colorScheme.secondary
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16.0),  // Korrigiert: bodyText1 zu bodyMedium
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
