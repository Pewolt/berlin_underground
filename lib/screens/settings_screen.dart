import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  // StatefulWidget für dynamische Einstellungen
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool soundEnabled = true;
  String language = 'Deutsch';
  double realismLevel = 0.1; // Realismusgrad zwischen 0.0 und 0.5

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Lädt die Einstellungen aus dem Speicher
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      soundEnabled = prefs.getBool('soundEnabled') ?? true;
      language = prefs.getString('language') ?? 'Deutsch';
      realismLevel = prefs.getDouble('realismLevel') ?? 0.1;
    });
  }

  // Speichert die Einstellungen
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', soundEnabled);
    await prefs.setString('language', language);
    await prefs.setDouble('realismLevel', realismLevel);
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold mit AppBar und Einstellungen
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Schalter für Sound
            SwitchListTile(
              title: const Text('Sound aktivieren'),
              value: soundEnabled,
              onChanged: (bool value) {
                setState(() {
                  soundEnabled = value;
                });
                _saveSettings();
              },
            ),
            const SizedBox(height: 20),
            // Auswahl der Sprache
            ListTile(
              title: const Text('Sprache'),
              trailing: DropdownButton<String>(
                value: language,
                onChanged: (String? newValue) {
                  setState(() {
                    language = newValue!;
                  });
                  _saveSettings();
                },
                items: <String>['Deutsch', 'Englisch']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            // Slider für den Realismusgrad
            ListTile(
              title: const Text('Realismusgrad'),
              subtitle:
                  Text('Häufigkeit von Störungen: ${(realismLevel * 100).toInt()}%'),
              trailing: SizedBox(
                width: 150,
                child: Slider(
                  value: realismLevel,
                  min: 0.0,
                  max: 0.5,
                  divisions: 10,
                  label: '${(realismLevel * 100).toInt()}%',
                  onChanged: (double value) {
                    setState(() {
                      realismLevel = value;
                    });
                    _saveSettings();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
