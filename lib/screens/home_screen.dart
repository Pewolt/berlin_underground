import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'tutorial_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Scaffold mit AppBar und Buttons für Navigation
    return Scaffold(
      appBar: AppBar(
        title: const Text('Berlin Underground Controller'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Button zum Starten eines neuen Spiels
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Neues Spiel'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GameScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
              ),
            ),
            const SizedBox(height: 20),
            // Button zu den Einstellungen
            ElevatedButton.icon(
              icon: const Icon(Icons.settings),
              label: const Text('Einstellungen'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
              ),
            ),
            const SizedBox(height: 20),
            // Button zum Tutorial
            ElevatedButton.icon(
              icon: const Icon(Icons.help_outline),
              label: const Text('Tutorial'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TutorialScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
