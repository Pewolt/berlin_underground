import 'dart:convert';
import 'package:flutter/services.dart';

class TimesLoader {
  final String jsonPath;
  final Map<String, Map<String, int>> times = {}; // Zeiten zwischen den Stationen

  TimesLoader(this.jsonPath);

  /// Lade die Zeiten aus der JSON-Datei
  Future<void> loadTimes() async {
    // JSON-Datei als String einlesen
    final String jsonString = await rootBundle.loadString(jsonPath, cache: false);

    // JSON-String parsen
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);

    // Extrahiere die Indexe, Spalten und Daten
    final List<String> index = List<String>.from(jsonData['index']);
    final List<String> columns = List<String>.from(jsonData['columns']);
    final List<List<dynamic>> data = List<List<dynamic>>.from(jsonData['data']);

    // Erstelle die Zeit-Matrix
    for (int i = 0; i < index.length; i++) {
      final String fromStation = index[i];
      times[fromStation] = {};

      for (int j = 0; j < columns.length; j++) {
        final String toStation = columns[j];
        final dynamic timeValue = data[i][j];

        // Konvertiere das Zeitwert in int, falls möglich
        final int time = (timeValue is num) ? timeValue.toInt() : -1;

        times[fromStation]![toStation] = time;
      }
    }
  }

  /// Zeit zwischen zwei Stationen abrufen
  int getTimeBetweenStations(String fromStation, String toStation) {
    return times[fromStation]?[toStation] ?? -1; // -1 für keine Verbindung
  }
}
