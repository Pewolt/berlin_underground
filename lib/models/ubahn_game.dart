import 'dart:math';
import 'package:berlin_underground/data/shortest_time_loader.dart';
import 'package:berlin_underground/models/line.dart';
import 'package:berlin_underground/models/station.dart';
import 'package:berlin_underground/utils/color_utils.dart';
import 'package:berlin_underground/utils/distance_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'traveled_path.dart';
import 'visited_station.dart';
import 'disruptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UbahnGame {
  final List<Line> lines;
  Station? startStation;
  Station? endStation;
  Station? currentStation;
  Line? currentLine;
  bool forward = true;
  bool gameOver = false;
  int traveldTime = 0;
  int? fastestTime = 0;
  double realismLevel = 0.1; // Realismusgrad für Störungen

  // Statistikvariablen
  double totalDistance = 0.0;
  int numberOfTransfers = 0;
  int totalDelays = 0;

  // Verbindungszeiten-Loader
  TimesLoader? timesLoader;

  // Listen für das Spiel
  List<VisitedStation> visitedStations = [];
  List<TraveledPath> traveledPaths = [];
  List<Disruption> activeDisruptions = [];

  final Random random = Random();

  UbahnGame(this.lines) {
    timesLoader = TimesLoader('assets/times.json');
    _loadSettings();
  }

  // Lädt den Realismusgrad aus den Einstellungen
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    realismLevel = prefs.getDouble('realismLevel') ?? 0.1;
  }

  // Startet das Spiel
  Future<void> startGame() async {
    gameOver = false;
    currentLine = null;
    traveldTime = 0;
    totalDistance = 0.0;
    numberOfTransfers = 0;
    totalDelays = 0;
    traveledPaths = [];
    visitedStations = [];
    activeDisruptions = [];

    startStation = _getRandomStation();
    endStation = _getRandomStation(excludeStation: startStation);
    currentStation = startStation;

    // Startstation zur Liste hinzufügen
    visitedStations.add(VisitedStation(
      station: startStation!,
      color: Colors.grey,
    ));

    // Lade die Verbindungszeiten und berechne die schnellste Zeit
    await timesLoader!.loadTimes();
    fastestTime = timesLoader!.getTimeBetweenStations(startStation!.name, endStation!.name);
  }

  // Wählt eine zufällige Station aus
  Station _getRandomStation({Station? excludeStation}) {
    List<Station> allStations = lines.expand((line) => line.stations).toList();
    allStations = allStations.toSet().toList(); // Entferne Duplikate
    if (excludeStation != null) {
      allStations.remove(excludeStation);
    }
    return allStations[random.nextInt(allStations.length)];
  }

  // Gibt die verfügbaren Linien an der aktuellen Station zurück
  List<Line> getLinesAtCurrentStation() {
    if (currentStation == null) return [];
    return lines.where((line) => line.stations.contains(currentStation)).toList();
  }

  // Wählt eine Linie und Fahrtrichtung
  void chooseLineAndDirection(Line line, bool forwardDirection) {
    currentLine = line;
    forward = forwardDirection;

    // Aktualisiere die Farbe der aktuellen Station
    var visitedStation = visitedStations.firstWhere((vs) => vs.station == currentStation);
    visitedStation.color = colorFromHex(currentLine!.colour);
  }

  // Bewegt sich zur nächsten Station
  void moveToNextStation(Function(String) showMessageCallback) {
    if (currentStation != null && currentLine != null) {
      checkForDisruptions(showMessageCallback);

      // Prüfe auf Linien- oder Stationssperrung
      if (isLineClosed(currentLine!)) {
        showMessageCallback("Die Linie ${currentLine!.name} ist gesperrt.");
        return;
      }
      if (isStationClosed(currentStation!)) {
        showMessageCallback("Die Station ${currentStation!.name} ist gesperrt.");
        return;
      }

      var nextStation = currentLine!.getNextStation(currentStation!, forward);

      if (nextStation != null) {
        if (isStationClosed(nextStation)) {
          showMessageCallback("Die nächste Station ${nextStation.name} ist gesperrt.");
          return;
        }

        _recordPath(currentStation!, nextStation);

        // Fahrzeit hinzufügen
        int timeToNextStation = currentLine!.getTime(currentStation!, nextStation)!;
        traveldTime += timeToNextStation;

        // Verspätungen prüfen
        int delayAtStation = getDelayAtStation(currentStation!);
        if (delayAtStation > 0) {
          traveldTime += delayAtStation;
          totalDelays += delayAtStation;
          showMessageCallback("Verspätung von $delayAtStation Minuten an der Station ${currentStation!.name}.");
        }

        // Gesamtstrecke aktualisieren
        double distance = calculateDistance(currentStation!.coordinates, nextStation.coordinates);
        totalDistance += distance;

        currentStation = nextStation;

        // Station zur Liste der besuchten Stationen hinzufügen
        if (!visitedStations.any((vs) => vs.station == currentStation)) {
          visitedStations.add(VisitedStation(
            station: currentStation!,
            color: colorFromHex(currentLine!.colour),
          ));
        }

        if (currentStation == endStation) {
          gameOver = true;
        }
      } else {
        // Ende der Linie erreicht
        forward = !forward;
        showMessageCallback("Endstation erreicht. Bitte Fahrtrichtung wechseln.");
        traveldTime += 2;
      }
    } else {
      showMessageCallback("Bitte wählen Sie zuerst eine Linie und Richtung aus.");
    }
  }

  // Zeichnet den zurückgelegten Pfad auf
  void _recordPath(Station fromStation, Station toStation) {
    var geometry = currentLine!.getGeometry(fromStation, toStation);
    if (geometry != null) {
      traveledPaths.add(
        TraveledPath(
          geometry: geometry,
          color: colorFromHex(currentLine!.colour),
        ),
      );
    }
  }

  // Wechselt die Linie
  void changeLine(Function(String) showMessageCallback) {
    List<Line> availableLines = getAvailableLines();
    if (availableLines.isEmpty) {
      showMessageCallback("Keine Linien zum Umsteigen verfügbar.");
      return;
    }

    // Implementierung der Linienauswahl erforderlich
    // Hier könnte ein Dialog angezeigt werden, um die Linie auszuwählen
  }

  // Gibt die verfügbaren Linien zum Umsteigen zurück
  List<Line> getAvailableLines() {
    if (currentStation == null) return [];
    return lines.where((line) => line != currentLine && line.stations.contains(currentStation)).toList();
  }

  // Prüft und erzeugt Störungen
  void checkForDisruptions(Function(String) showMessageCallback) {
    // Wahrscheinlichkeit, eine neue Störung zu erzeugen, basierend auf dem Realismusgrad
    if (random.nextDouble() < realismLevel) {
      Disruption disruption = generateRandomDisruption();
      activeDisruptions.add(disruption);

      // Informiere den Spieler über die neue Störung
      String message = '';
      if (disruption is LineClosure) {
        message = 'Linie ${disruption.affectedLine.name} ist für ${disruption.remainingTurns} Züge gesperrt.';
      } else if (disruption is StationClosure) {
        message = 'Station ${disruption.affectedStation.name} ist für ${disruption.remainingTurns} Züge gesperrt.';
      } else if (disruption is Delay) {
        message = 'Verspätung von ${disruption.delayTime} Minuten an Station ${disruption.affectedStation.name}.';
      }

      // Verwende modalen Dialog, um die Nachricht anzuzeigen
      showMessageCallback(message);
    }

    // Abgelaufene Störungen entfernen
    for (var disruption in activeDisruptions) {
      disruption.decrementTurns();
    }
    activeDisruptions.removeWhere((disruption) => disruption.isExpired());
  }

  // Erzeugt eine zufällige Störung
  Disruption generateRandomDisruption() {
    int disruptionType = random.nextInt(3);
    switch (disruptionType) {
      case 0:
        // Linienunterbrechung
        Line affectedLine = lines[random.nextInt(lines.length)];
        int duration = random.nextInt(5) + 1; // Dauer zwischen 1 und 5 Zügen
        return LineClosure(affectedLine, duration);
      case 1:
        // Stationssperrung
        List<Station> allStations = lines.expand((line) => line.stations).toList();
        Station affectedStation = allStations[random.nextInt(allStations.length)];
        int duration = random.nextInt(5) + 1;
        return StationClosure(affectedStation, duration);
      case 2:
        // Verspätung
        int delayTime = (random.nextDouble() * 5).round() + 1; // Verspätung zwischen 1 und 5 Minuten
        return Delay(currentStation!, delayTime);
      default:
        return Delay(currentStation!, 1);
    }
  }

  // Prüft, ob eine Linie gesperrt ist
  bool isLineClosed(Line line) {
    return activeDisruptions.any((disruption) => disruption is LineClosure && disruption.affectedLine == line);
  }

  // Prüft, ob eine Station gesperrt ist
  bool isStationClosed(Station station) {
    return activeDisruptions.any((disruption) => disruption is StationClosure && disruption.affectedStation == station);
  }

  // Gibt die Verspätung an einer Station zurück
  int getDelayAtStation(Station station) {
    var delay = activeDisruptions.firstWhere(
      (disruption) => disruption is Delay && disruption.affectedStation == station,
    );
    if (delay is Delay) {
      return delay.delayTime;
    }
    return 0;
  }

  // Erstellt die Polylinien für die Karte
  List<Polyline> createPolylines(bool gameStarted) {
    List<Polyline> polylines = [];

    if (!gameStarted) {
      // Alle Linien in ihren Farben zeichnen
      for (var line in lines) {
        Color lineColor = colorFromHex(line.colour);

        for (int i = 0; i < line.stations.length - 1; i++) {
          var geometry = line.getGeometry(line.stations[i], line.stations[i + 1]);
          if (geometry != null) {
            polylines.add(
              Polyline(
                points: geometry,
                color: lineColor,
                strokeWidth: 4.0,
              ),
            );
          }
        }
      }
      return polylines;
    }

    // Linien zeichnen, gesperrte Linien rot färben
    for (var line in lines) {
      Color lineColor = colorFromHex(line.colour);

      if (isLineClosed(line)) {
        lineColor = Colors.red; // Gesperrte Linie rot färben
      }

      for (int i = 0; i < line.stations.length - 1; i++) {
        var geometry = line.getGeometry(line.stations[i], line.stations[i + 1]);
        if (geometry != null) {
          polylines.add(
            Polyline(
              points: geometry,
              color: lineColor,
              strokeWidth: 4.0,
            ),
          );
        }
      }
    }

    // Befahrene Strecken übermalen
    for (var path in traveledPaths) {
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

  // Erstellt die Marker für die Karte
  List<Marker> createMarkers(bool gameStarted) {
    List<Marker> markers = [];

    if (!gameStarted) {
      return markers;
    }

    // Marker für gesperrte Stationen
    for (var disruption in activeDisruptions) {
      if (disruption is StationClosure) {
        markers.add(
          Marker(
            point: LatLng(disruption.affectedStation.coordinates.latitude, disruption.affectedStation.coordinates.longitude),
            width: 16.0,
            height: 16.0,
            child: Icon(Icons.block, color: Colors.red, size: 16.0),
          ),
        );
      }
    }

    // Bereits besuchte Stationen markieren
    for (var visited in visitedStations) {
      markers.add(
        Marker(
          point: LatLng(visited.station.coordinates.latitude, visited.station.coordinates.longitude),
          width: 10.0,
          height: 10.0,
          child: Container(
            decoration: BoxDecoration(
              color: visited.color,
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
          point: LatLng(startStation!.coordinates.latitude, startStation!.coordinates.longitude),
          width: 12.0,
          height: 12.0,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.green,
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
          point: LatLng(endStation!.coordinates.latitude, endStation!.coordinates.longitude),
          width: 12.0,
          height: 12.0,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.red,
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
          point: LatLng(currentStation!.coordinates.latitude, currentStation!.coordinates.longitude),
          width: 14.0,
          height: 14.0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.yellow,
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
