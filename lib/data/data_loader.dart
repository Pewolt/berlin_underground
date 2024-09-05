import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'line.dart';
import 'station.dart';

class DataLoader {
  final String geoJsonPath;
  final List<Line> lines;

  DataLoader(this.geoJsonPath, this.lines);

  Future<void> loadUbahnConnections() async {
    String data = await rootBundle.loadString(geoJsonPath);
    final jsonResult = json.decode(data);
    _parseGeoJson(jsonResult);
  }

  void _parseGeoJson(Map<String, dynamic> json) {
    Map<String, Station> stationMap = {};
    for (var feature in json['features']) {
      var properties = feature['properties'];
      var lineName = properties['line'];
      var fromStationName = properties['fromStation'];
      var toStationName = properties['toStation'];
      var colour = properties['colour'];

      List<LatLng> coordinates = [];
      for (var lineString in feature['geometry']['coordinates']) {
        for (var point in lineString) {
          coordinates.add(LatLng(point[1], point[0]));
        }
      }

      var fromStation = stationMap.putIfAbsent(
        fromStationName,
        () => Station(name: fromStationName, lines: []),
      );
      var toStation = stationMap.putIfAbsent(
        toStationName,
        () => Station(name: toStationName, lines: []),
      );

      var line = lines.firstWhere(
        (l) => l.name == lineName,
        orElse: () => Line(name: lineName, stations: [], colour: colour, geometries: {}),
      );

      if (!lines.contains(line)) {
        lines.add(line);
      }

      if (!line.stations.contains(fromStation)) {
        line.stations.add(fromStation);
      }
      if (!line.stations.contains(toStation)) {
        line.stations.add(toStation);
      }

      line.geometries['${fromStation.name}-${toStation.name}'] = coordinates;
    }
  }
}
