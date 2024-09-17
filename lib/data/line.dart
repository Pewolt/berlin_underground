import 'package:latlong2/latlong.dart';
import 'station.dart';

class Line {
  final String name;
  final List<Station> stations; // Reihenfolge der Stationen
  final String colour; // Farbcode der Linie
  final Map<String, List<LatLng>> geometries; // Geometrien zwischen den Stationen
  final Map<String, int> times;

  Line({
    required this.name,
    required this.stations,
    required this.colour,
    required this.geometries,
    required this.times,
  });

  /// Hole die erste Station der Linie (für Richtung Rückwärts)
  Station get firstStation => stations.first;

  /// Hole die letzte Station der Linie (für Richtung Vorwärts)
  Station get lastStation => stations.last;

  /// Bestimme die nächste Station in einer bestimmten Richtung
  Station? getNextStation(Station currentStation, bool forward) {
    final int currentIndex = stations.indexOf(currentStation);
    if (currentIndex == -1) return null;

    // Fahre vorwärts oder rückwärts, je nach Richtung
    if (forward && currentIndex < stations.length - 1) {
      return stations[currentIndex + 1];
    } else if (!forward && currentIndex > 0) {
      return stations[currentIndex - 1];
    }
    return null;
  }

  /// Hole die Geometrie (LatLng-Punkte) zwischen zwei Stationen
  List<LatLng>? getGeometry(Station fromStation, Station toStation) {
    return geometries['${fromStation.name}-${toStation.name}'] ??
        geometries['${toStation.name}-${fromStation.name}'];
  }

  /// Hole die Zeit zwischen zwei Stationen
  int? getTime(Station fromStation, Station toStation) {
    return times['${fromStation.name}-${toStation.name}'] ??
        times['${toStation.name}-${fromStation.name}'];
  }

  /// Überprüfe, ob eine Station Umstiegsmöglichkeiten zu anderen Linien hat
  bool hasConnectionToOtherLines(Station station, List<Line> allLines) {
    return allLines.any(
      (line) => line != this && line.stations.contains(station),
    );
  }

  /// Gibt zurück, ob eine bestimmte Station die Endstation ist
  bool isEndStation(Station station) {
    return station == firstStation || station == lastStation;
  }
}
