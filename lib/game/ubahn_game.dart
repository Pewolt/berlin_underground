import 'dart:math';
import 'package:berlin_underground/data/line.dart';
import 'package:berlin_underground/data/station.dart';
import 'package:berlin_underground/data/times_loader.dart';
import 'package:berlin_underground/model/traveled_path.dart';
import 'package:berlin_underground/model/visited_station.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class UbahnGame {
  final List<Line> lines;
  Station? startStation;
  Station? endStation;
  Station? currentStation;
  Line? currentLine; // Startet jetzt als null
  final List<TraveledPath> traveledPaths = []; // Speichert die Geometrien mit Farben
  bool forward = true;
  bool gameOver = false;
  int traveledTime = 0;
  int? fastestTime = 0;

  // Verbindungszeiten-Loader
  late final TimesLoader timesLoader;

  // Liste der besuchten Stationen mit zugehöriger Farbe
  final List<VisitedStation> visitedStations = [];

  UbahnGame(this.lines) {
    timesLoader = TimesLoader('assets/times.json'); // Lade die Verbindungszeiten
  }

  Future<void> startGame() async {
    gameOver = false;
    currentLine = null; // Zu Beginn keine aktuelle Linie
    traveledTime = 0;
    traveledPaths.clear();
    visitedStations.clear();

    startStation = _getRandomStation();
    endStation = _getRandomStation(excludeStation: startStation);
    currentStation = startStation;

    // Startstation zur Liste hinzufügen (noch ohne Linienfarbe)
    visitedStations.add(VisitedStation(
      station: startStation!,
      color: Colors.grey, // Platzhalterfarbe
    ));

    await timesLoader.loadTimes(); // Lade die Verbindungszeiten
    fastestTime = timesLoader.getTimeBetweenStations(startStation!.name, endStation!.name);
  }

  /// Methode zur Auswahl einer zufälligen Station
  Station _getRandomStation({Station? excludeStation}) {
    final List<Station> allStations = lines
        .expand((line) => line.stations)
        .toSet()
        .toList(); // Duplikate entfernen
    if (excludeStation != null) {
      allStations.remove(excludeStation);
    }
    return allStations[Random().nextInt(allStations.length)];
  }

  /// Methode, um die verfügbaren Linien an der aktuellen Station zu erhalten
  List<Line> getLinesAtCurrentStation() {
    if (currentStation == null) return [];
    return lines.where((line) => line.stations.contains(currentStation)).toList();
  }

  /// Methode zur Auswahl der Fahrtrichtung (setzt auch die aktuelle Linie)
  void chooseLineAndDirection(Line line, bool forwardDirection) {
    currentLine = line;
    forward = forwardDirection;

    // Update der Farbe der aktuellen Station in visitedStations
    final visitedStation = visitedStations.firstWhere((vs) => vs.station == currentStation);
    visitedStation.color = _colorFromHex(currentLine!.colour);
  }

  /// Methode, um die nächste Station zu erreichen
  void moveToNextStation(Function(String) showMessageCallback) {
    if (currentStation != null && currentLine != null) {
      final nextStation = currentLine!.getNextStation(currentStation!, forward);
      if (nextStation != null) {
        _recordPath(currentStation!, nextStation);
        traveledTime += currentLine!.getTime(currentStation!, nextStation)!;
        currentStation = nextStation;

        // Station zur Liste der besuchten Stationen hinzufügen mit der Farbe der aktuellen Linie
        if (!visitedStations.any((vs) => vs.station == currentStation)) {
          visitedStations.add(VisitedStation(
            station: currentStation!,
            color: _colorFromHex(currentLine!.colour),
          ));
        }

        if (currentStation == endStation) {
          gameOver = true;
        }
      } else {
        // Wenn am Ende der Linie: Richtung wechseln und Spieler benachrichtigen
        forward = !forward;
        showMessageCallback("Endstation. Bitte alle aussteigen!");
        traveledTime += 2;
      }
    } else {
      // Falls keine Linie ausgewählt ist
      showMessageCallback("Bitte wählen Sie zuerst eine Linie und Richtung aus.");
    }
  }

  /// Methode, um eine Linie zu wechseln
  void changeLine(Line newLine) {
    if (newLine.stations.contains(currentStation)) {
      currentLine = newLine;
      forward = true; // Richtung neu setzen
      traveledTime += 2;
    }
  }

  /// Methode, um die Geometrie und Farbe zwischen zwei Stationen zu speichern
  void _recordPath(Station fromStation, Station toStation) {
    final geometry = currentLine!.getGeometry(fromStation, toStation);
    if (geometry != null) {
      traveledPaths.add(
        TraveledPath(
          geometry: geometry,
          color: _colorFromHex(currentLine!.colour),
        ),
      );
    }
  }

  /// Methode zur Auswahl der Fahrtrichtung
  void chooseDirection(bool forwardDirection) {
    forward = forwardDirection;
  }

  /// Zeigt die verfügbaren Linien zum Umsteigen
  List<Line> getAvailableLines() {
    if (currentStation == null) return [];

    return lines.where((line) => line != currentLine && line.stations.contains(currentStation)).toList();
  }

  /// Zeigt die aktuelle Richtung an
  String getCurrentDirection() {
    return forward ? currentLine!.lastStation.name : currentLine!.firstStation.name;
  }

  /// Methode zur Erstellung der Polylines für die Karte
  List<Polyline> createPolylines(bool gameStarted) {
    final List<Polyline> polylines = [];

    if (!gameStarted) {
      // Alle Linien in ihren Farben zeichnen
      for (final line in lines) {
        for (int i = 0; i < line.stations.length - 1; i++) {
          final geometry = line.getGeometry(line.stations[i], line.stations[i + 1]);
          if (geometry != null) {
            polylines.add(
              Polyline(
                points: geometry,
                color: _colorFromHex(line.colour),
                strokeWidth: 4.0,
              ),
            );
          }
        }
      }
      return polylines;
    }

    // Alle nicht befahrenen Verbindungen in Grau zeichnen
    final Set<String> untraveledGeometries = {};

    for (final line in lines) {
      for (int i = 0; i < line.stations.length - 1; i++) {
        final geometry = line.getGeometry(line.stations[i], line.stations[i + 1]);
        if (geometry != null &&
            !traveledPaths.any((path) => _compareGeometries(path.geometry, geometry))) {
          final String geometryKey = _geometryToString(geometry);
          if (!untraveledGeometries.contains(geometryKey)) {
            untraveledGeometries.add(geometryKey);
            polylines.add(
              Polyline(
                points: geometry,
                color: const Color(0xFF888888), // Grau für nicht befahrene Strecken
                strokeWidth: 4.0,
              ),
            );
          }
        }
      }
    }

    // Alle Verbindungen, die abgefahren wurden, farbig zeichnen
    for (final path in traveledPaths) {
      polylines.add(
        Polyline(
          points: path.geometry,
          color: path.color,
          strokeWidth: 4.0,
        ),
      );
    }

    return polylines;
  }

  /// Hilfsmethode zum Vergleichen von Geometrien
  bool _compareGeometries(List<LatLng> geom1, List<LatLng> geom2) {
    if (geom1.length != geom2.length) return false;
    for (int i = 0; i < geom1.length; i++) {
      if (geom1[i] != geom2[i]) return false;
    }
    return true;
  }

  /// Hilfsmethode, um eine Geometrie als String darzustellen
  String _geometryToString(List<LatLng> geometry) {
    return geometry.map((point) => '${point.latitude},${point.longitude}').join('-');
  }

  /// Methode, um eine Linie anhand des Farbwerts darzustellen
  Color _colorFromHex(String hexColor) {
    final String cleanedHex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$cleanedHex', radix: 16));
  }

  /// Methode zur Erstellung der Marker
  List<Marker> createMarkers(bool gameStarted) {
    final List<Marker> markers = [];

    if (!gameStarted) {
      return markers;
    }

    // Bereits besuchte Stationen markieren
    for (final visited in visitedStations) {
      markers.add(
        Marker(
          point: visited.station.coordinates,
          width: 10.0,
          height: 10.0,
          child: Container(
            decoration: BoxDecoration(
              color: visited.color, // Verwenden Sie die gespeicherte Farbe
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    // Startstation markieren
    if (startStation != null) {
      markers.add(
        Marker(
          point: startStation!.coordinates,
          width: 12.0,
          height: 12.0,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.green, // Startstation: Grün
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    // Endstation markieren
    if (endStation != null) {
      markers.add(
        Marker(
          point: endStation!.coordinates,
          width: 12.0,
          height: 12.0,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.red, // Endstation: Rot
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    // Aktuelle Station markieren
    if (currentStation != null) {
      markers.add(
        Marker(
          point: currentStation!.coordinates,
          width: 14.0,
          height: 14.0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.yellow, // Aktuelle Station: Gelb
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
          ),
        ),
      );
    }

    return markers;
  }
}
