import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'line.dart';
import 'station.dart';

class DataLoader {
  final String geoJsonPath;
  final List<Line> lines;

  DataLoader(this.geoJsonPath, this.lines);

  // Lädt die U-Bahn-Verbindungen
  Future<void> loadUbahnConnections() async {
    String data = await rootBundle.loadString(geoJsonPath);
    final jsonResult = json.decode(data);
    _parseGeoJson(jsonResult);
  }

  // Parsed das GeoJSON und speichert die Daten in Linien und Stationen
  void _parseGeoJson(Map<String, dynamic> json) {
    Map<String, Station> stationMap = {};  // Zur Speicherung aller Stationen

    for (var feature in json['features']) {
      var properties = feature['properties'];
      var lineName = properties['line'];
      var fromStationName = properties['fromStation'];
      var toStationName = properties['toStation'];
      var colour = properties['colour'];
      var time = properties['time'];  // Die Zeit für diese Verbindung

      // Extrahiere die Koordinaten und speichere sie als LatLng-Liste
      List<LatLng> coordinates = [];
      for (var lineString in feature['geometry']['coordinates']) {
        for (var point in lineString) {
          coordinates.add(LatLng(point[1], point[0]));  // [lat, lng] Format
        }
      }

      // Stationen in das stationMap einfügen oder abrufen
      var fromStation = stationMap.putIfAbsent(
        fromStationName,
        () => Station(name: fromStationName, lines: [], coordinates: coordinates[0]),
      );
      var toStation = stationMap.putIfAbsent(
        toStationName,
        () => Station(name: toStationName, lines: [], coordinates: coordinates[coordinates.length - 1]),
      );

      // Linie in der Liste lines finden oder neue Linie erstellen
      var line = lines.firstWhere(
        (l) => l.name == lineName,
        orElse: () => Line(name: lineName, stations: [], colour: colour, geometries: {}, times: {}),
      );

      // Wenn die Linie neu ist, füge sie zu lines hinzu
      if (!lines.contains(line)) {
        lines.add(line);
      }

      // Stationen der Linie hinzufügen, falls sie noch nicht enthalten sind
      if (!line.stations.contains(fromStation)) {
        line.stations.add(fromStation);
      }
      if (!line.stations.contains(toStation)) {
        line.stations.add(toStation);
      }

      // Zeit für die Verbindung speichern
      line.times['${fromStation.name}-${toStation.name}'] = time;

      // Geometrie zwischen den beiden Stationen speichern
      line.geometries['${fromStation.name}-${toStation.name}'] = coordinates;
    }
  }
}
