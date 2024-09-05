import 'dart:math';
import 'dart:ui';
import 'package:berlin_underground/data/line.dart';
import 'package:berlin_underground/data/station.dart';
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

  UbahnGame(this.lines);

  void startGame() {
    gameOver = false;
    startStation = _getRandomStation();
    endStation = _getRandomStation(excludeStation: startStation);
    currentStation = startStation;
    currentLine = _getLineForStation(startStation!);
    print("Start Game at ${startStation!.name} on Line ${currentLine!.name}");
  }

  // Methode zur Auswahl einer zufälligen Station
  Station _getRandomStation({Station? excludeStation}) {
    final random = Random();
    List<Station> allStations = lines.expand((line) => line.stations).toList();
    allStations.remove(excludeStation);
    return allStations[random.nextInt(allStations.length)];
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
        currentStation = nextStation;

        if (currentStation == endStation) {
          gameOver = true;
        }

        print("Moved to ${currentStation!.name} on Line ${currentLine!.name}");
      } else {
        // Wenn am Ende der Linie: Richtung wechseln und Spieler benachrichtigen
        forward = !forward;
        showMessageCallback("Sackgasse! Drehe um.");
        print("Reached end of line: turning around at ${currentStation!.name}");
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
    print("Richtung gewählt: ${forward ? 'Vorwärts' : 'Rückwärts'}");
  }

  // Methode, um eine Linie zu wechseln
  void changeLine(Line newLine) {
    if (newLine.stations.contains(currentStation)) {
      currentLine = newLine;
      forward = true; // Richtung neu setzen
      print("Changed to Line ${currentLine!.name} at ${currentStation!.name}");
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

  // Prüft, ob der Spieler am Ziel angekommen ist
  bool hasReachedEndStation() {
    return currentStation == endStation;
  }

  // Methode zur Erstellung der Polylines für die Karte
  List<Polyline> createPolylines() {
    List<Polyline> polylines = [];

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
