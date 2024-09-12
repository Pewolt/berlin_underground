import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

class TimesLoader {
  final String csvPath;
  final Map<String, Map<String, int>> times = {}; // Zeiten zwischen den Stationen

  TimesLoader(this.csvPath, Map<String, Map<String, int>> times);

  // Lade die Zeiten aus der CSV-Datei
  Future<void> loadTimes() async {
    String csvData = await rootBundle.loadString(csvPath);
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvData);

    List<String> stations = []; // Liste der Stationen aus der ersten Zeile

    // Fülle die Liste der Stationen aus der ersten Zeile der CSV-Datei
    for (int i = 1; i < csvTable[0].length; i++) {
      stations.add(csvTable[0][i].toString()); // Konvertiere zu String
    }

    // Durchlaufe die restlichen Zeilen und erstelle die Zeit-Matrix
    for (int i = 1; i < csvTable.length; i++) {
      String fromStation = csvTable[i][0].toString(); // Station aus der ersten Spalte
      times[fromStation] = {};

      for (int j = 1; j < csvTable[i].length; j++) {
        String toStation = stations[j - 1].toString(); // Zielstation
        int time = int.tryParse(csvTable[i][j].toString()) ?? -1; // Zeit sicherstellen
        times[fromStation]![toStation] = time;
      }
    }
  }

  // Zeit zwischen zwei Stationen abrufen
  int getTimeBetweenStations(String fromStation, String toStation) {
    return times[fromStation]?[toStation] ?? -1; // -1 für keine Verbindung
  }
}
