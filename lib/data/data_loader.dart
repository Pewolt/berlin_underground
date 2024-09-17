import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'line.dart';
import 'station.dart';

class DataLoader {
  final String geoJsonPath;
  final List<Line> lines;

  DataLoader(this.geoJsonPath, this.lines);

  /// Lädt die U-Bahn-Verbindungen
  Future<void> loadUbahnConnections() async {
    final String data = await rootBundle.loadString(geoJsonPath);
    final Map<String, dynamic> jsonResult = json.decode(data);
    _parseGeoJson(jsonResult);
  }

  /// Parst das GeoJSON und speichert die Daten in Linien und Stationen
  void _parseGeoJson(Map<String, dynamic> json) {
    final Map<String, Station> stationMap = {}; // Zur Speicherung aller Stationen

    for (final feature in json['features']) {
      final properties = feature['properties'];
      final String lineName = properties['line'];
      final String fromStationName = properties['fromStation'];
      final String toStationName = properties['toStation'];
      final String colour = properties['colour'];
      final int time = properties['time']; // Die Zeit für diese Verbindung

      // Extrahiere die Koordinaten und speichere sie als LatLng-Liste
      final List<LatLng> coordinates = [];
      for (final lineString in feature['geometry']['coordinates']) {
        for (final point in lineString) {
          coordinates.add(LatLng(point[1], point[0])); // [lat, lng] Format
        }
      }

      // Stationen in das stationMap einfügen oder abrufen
      final fromStation = stationMap.putIfAbsent(
        fromStationName,
        () => Station(
          name: fromStationName,
          lines: [],
          coordinates: coordinates.first,
        ),
      );
      final toStation = stationMap.putIfAbsent(
        toStationName,
        () => Station(
          name: toStationName,
          lines: [],
          coordinates: coordinates.last,
        ),
      );

      // Linie in der Liste lines finden oder neue Linie erstellen
      var line = lines.firstWhere(
        (l) => l.name == lineName,
        orElse: () {
          final newLine = Line(
            name: lineName,
            stations: [],
            colour: colour,
            geometries: {},
            times: {},
          );
          lines.add(newLine);
          return newLine;
        },
      );

      // Stationen der Linie hinzufügen, falls sie noch nicht enthalten sind
      if (!line.stations.contains(fromStation)) {
        line.stations.add(fromStation);
        fromStation.addLine(line);
      }
      if (!line.stations.contains(toStation)) {
        line.stations.add(toStation);
        toStation.addLine(line);
      }

      // Zeit für die Verbindung speichern
      line.times['${fromStation.name}-${toStation.name}'] = time;

      // Geometrie zwischen den beiden Stationen speichern
      line.geometries['${fromStation.name}-${toStation.name}'] = coordinates;
    }
  }
}
