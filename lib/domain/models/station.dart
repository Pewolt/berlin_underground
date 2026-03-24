import 'package:latlong2/latlong.dart';

class Station {
  final String name; // Dient als eindeutige ID
  final LatLng coordinates;
  final Set<String> lines; // Set verhindert doppelte Einträge automatisch

  Station({
    required this.name,
    required this.coordinates,
    required this.lines,
  });
}