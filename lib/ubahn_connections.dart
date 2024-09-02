import 'package:latlong2/latlong.dart';

class UbahnConnection {
  final String fromStation;
  final String toStation;
  final String line;
  final double km;
  final int time;
  final String colour;
  final List<LatLng> coordinates;

  UbahnConnection({
    required this.fromStation,
    required this.toStation,
    required this.line,
    required this.km,
    required this.time,
    required this.colour,
    required this.coordinates,
  });

  factory UbahnConnection.fromJson(Map<String, dynamic> json) {
    List<LatLng> coordinates = [];
    for (var lineString in json['geometry']['coordinates']) {
      for (var point in lineString) {
        coordinates.add(LatLng(point[1], point[0]));
      }
    }

    return UbahnConnection(
      fromStation: json['properties']['fromStation'],
      toStation: json['properties']['toStation'],
      line: json['properties']['line'],
      km: json['properties']['km'],
      time: json['properties']['time'],
      colour: json['properties']['colour'],
      coordinates: coordinates,
    );
  }
}
