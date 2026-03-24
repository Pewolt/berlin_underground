import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/models/station.dart';
import '../../domain/models/connection.dart';
import '../../core/math/subway_graph.dart';

class SubwayRepository {
  final SubwayGraph graph = SubwayGraph();

  // Hilfsfunktion zum Konvertieren eines Hex-Strings (z.B. "#8C6DAB") in eine Flutter Color
  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Future<void> loadGeoJson(String assetPath) async {
    final String data = await rootBundle.loadString(assetPath);
    final Map<String, dynamic> jsonResult = json.decode(data);

    for (final feature in jsonResult['features']) {
      final properties = feature['properties'];
      
      final String lineName = properties['line']?.toString() ?? 'Unknown';
      final String fromStationName = properties['fromStation']?.toString() ?? '';
      final String toStationName = properties['toStation']?.toString() ?? '';
      final String colorHex = properties['colour']?.toString() ?? '#FFFFFF'; // NEU
      
      if (fromStationName.isEmpty || toStationName.isEmpty) continue;

      final dynamic timeRaw = properties['time'];
      final int time = timeRaw is num ? timeRaw.toInt() : int.tryParse(timeRaw.toString()) ?? 1;

      final List<LatLng> coordinates = [];
      if (feature['geometry'] != null && feature['geometry']['coordinates'] != null) {
        for (final lineString in feature['geometry']['coordinates']) {
          for (final point in lineString) {
            coordinates.add(LatLng(point[1], point[0]));
          }
        }
      }

      if (coordinates.isEmpty) continue;

      graph.addStation(Station(name: fromStationName, coordinates: coordinates.first, lines: {lineName}));
      graph.addStation(Station(name: toStationName, coordinates: coordinates.last, lines: {lineName}));

      graph.stations[fromStationName]!.lines.add(lineName);
      graph.stations[toStationName]!.lines.add(lineName);

      graph.addConnection(Connection(
        fromStation: fromStationName,
        toStation: toStationName,
        lineName: lineName,
        travelTime: time,
        geometry: coordinates,
        color: _hexToColor(colorHex), // NEU
      ));
    }
  }
}