import 'dart:math';
import 'package:berlin_underground/data/line.dart';
import 'package:berlin_underground/data/shortest_time_loader.dart';
import 'package:berlin_underground/data/station.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class UbahnGame {
  final List<Line> lines;
  Station? startStation;
  Station? endStation;
  Station? currentStation;
  Line? currentLine;
  List<TraveledPath> traveledPaths = []; // Speichert die Geometrien mit Farben
  bool forward = true;
  bool gameOver = false;
  int traveldTime = 0;
  Map<String, int>? fastestPath;
  int? fastestTime = 0;

  // Verbindungszeiten-Loader und Map
  final Map<String, Map<String, int>> times = {};
  TimesLoader? timesLoader;

  UbahnGame(this.lines) {
    timesLoader = TimesLoader('assets/times.json'); // Lade die Verbindungszeiten
  }

  Future<void> startGame() async {
    gameOver = false;
    startStation = _getRandomStation();
    endStation = _getRandomStation(excludeStation: startStation);
    currentStation = startStation;
    currentLine = _getLineForStation(startStation!);
    traveldTime = 0;
    traveledPaths = [];

    await timesLoader!.loadTimes(); // Lade die CSV-Daten
    fastestTime = timesLoader!.getTimeBetweenStations(startStation!.name, endStation!.name);
    print(fastestTime.toString());
  }

  // Methode zur Abfrage der Verbindungsdauer zwischen zwei Stationen
  int? getConnectionTime(String fromStation, String toStation) {
    return timesLoader!.getTimeBetweenStations(fromStation, toStation);
  }

  // Methode zur Auswahl einer zufälligen Station
  Station _getRandomStation({Station? excludeStation}) {
    List<Station> allStations = lines.expand((line) => line.stations).toList();
    allStations.remove(excludeStation);
    return allStations[Random().nextInt(allStations.length)];
  }

  // Methode, um die aktuelle Linie für eine Station zu finden
  Line? _getLineForStation(Station station) {
    return lines.firstWhere((line) => line.stations.contains(station));
  }

  // Methode, um die nächste Station zu erreichen
  void moveToNextStation(Function showMessageCallback) {
    if (currentStation != null && currentLine != null) {
      var nextStation = currentLine!.getNextStation(currentStation!, forward);
      if (nextStation != null) {
        _recordPath(currentStation!, nextStation);
        traveldTime += currentLine!.getTime(currentStation!, nextStation)!;
        currentStation = nextStation;

        if (currentStation == endStation) {
          gameOver = true;
        }

      } else {
        // Wenn am Ende der Linie: Richtung wechseln und Spieler benachrichtigen
        forward = !forward;
        showMessageCallback("Endstation. Bitte alle aussteigen!");
        traveldTime += 2;
      }
    }
  }

  // Methode, um die Geometrie und Farbe zwischen zwei Stationen zu speichern
  void _recordPath(Station fromStation, Station toStation) {
    var geometry = currentLine!.getGeometry(fromStation, toStation);
    if (geometry != null) {
      traveledPaths.add(
        TraveledPath(
          geometry: geometry,
          color: _colorFromHex(currentLine!.colour),
        ),
      );
    }
  }

  // Methode zur Auswahl der Fahrtrichtung
  void chooseDirection(bool forwardDirection) {
    forward = forwardDirection;
  }

  // Methode, um eine Linie zu wechseln
  void changeLine(Line newLine) {
    if (newLine.stations.contains(currentStation)) {
      currentLine = newLine;
      forward = true; // Richtung neu setzen
      traveldTime += 2;
    }
  }

  // Zeigt die verfügbaren Linien zum Umsteigen
  List<Line> getAvailableLines() {
    if (currentStation == null) return [];

    return lines.where((line) => line != currentLine && line.stations.contains(currentStation)).toList();
  }

  // Zeigt die aktuelle Richtung an
  String getCurrentDirection() {
    return forward ? currentLine!.getLastStation().name : currentLine!.getFirstStation().name;
  }

  // Methode zur Erstellung der Polylines für die Karte
  List<Polyline> createPolylines(bool gameStarted) {
    List<Polyline> polylines = [];

    // Wenn das Spiel noch nicht gestartet wurde, farbig zeichnen
    if (!gameStarted) {
      for (var line in lines) {
        for (int i = 0; i < line.stations.length - 1; i++) {
          var geometry = line.getGeometry(line.stations[i], line.stations[i + 1]);
          if (geometry != null && !traveledPaths.any((path) => path.geometry == geometry)) {
            polylines.add(
              Polyline(
                points: geometry,
                color: _colorFromHex(line.colour), // Grau für nicht abgefahrene Strecken
                strokeWidth: 4.0,
              ),
            );
          }
        }
      }
      return polylines;
    }

    // Alle Verbindungen, die abgefahren wurden, farbig zeichnen
    for (var path in traveledPaths) {
      polylines.add(
        Polyline(
          points: path.geometry,
          color: path.color,
          strokeWidth: 4.0,
        ),
      );
    }

    // Alle anderen Verbindungen in Grau zeichnen
    for (var line in lines) {
      for (int i = 0; i < line.stations.length - 1; i++) {
         var geometry = line.getGeometry(line.stations[i], line.stations[i + 1]);
        if (geometry != null && !traveledPaths.any((path) => path.geometry == geometry)) {
          polylines.add(
            Polyline(
              points: geometry,
              color: const Color(0xFF888888), // Grau für nicht abgefahrene Strecken
              strokeWidth: 4.0,
            ),
          );
        }
      }
    }
    return polylines;
  }

  // Methode, um eine Linie anhand des Farbwerts darzustellen
  Color _colorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  List<Marker> createMarkers(bool gameStarted) {
    // Hier erstellen wir die Marker für Start- und Endstation
    List<Marker> markers = [];

    // Wenn das Spiel noch nicht gestartet wurde gib eine leere Liste zurück
    if (!gameStarted) {
      return markers;
    }

    if (startStation != null) {
      markers.add(
        Marker(
          point: LatLng(startStation!.coordinates.latitude, startStation!.coordinates.longitude),
          width: 20.0,  // Breite des Markers
          height: 20.0,  // Höhe des Markers
          child: const Icon(
            Icons.start,
            color: Colors.green,  // Startpunkt: grün
            size: 40.0,
          ),
        ),
      );
    }

  if (endStation != null) {
    markers.add(
      Marker(
        point: LatLng(endStation!.coordinates.latitude, endStation!.coordinates.longitude),
        width: 20.0,  // Breite des Markers
        height: 20.0,  // Höhe des Markers
        child: const Icon(
          Icons.flag,
          color: Colors.red,  // Endpunkt: rot
          size: 40.0,
        ),
      ),
    );
  }

  if (currentStation != null) {
    markers.add(
      Marker(
        point: LatLng(currentStation!.coordinates.latitude, currentStation!.coordinates.longitude),
        width: 20.0,  // Breite des Markers
        height: 20.0,  // Höhe des Markers
        child: const Icon(
          Icons.directions_subway,
          color: Colors.red,  // Endpunkt: rot
          size: 40.0,
        ),
      ),
    );
  }

  return markers;
}


}

// Klasse zur Speicherung der abgefahrenen Geometrien und deren Farben
class TraveledPath {
  final List<LatLng> geometry;
  final Color color;

  TraveledPath({
    required this.geometry,
    required this.color,
  });
}

