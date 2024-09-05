import 'package:latlong2/latlong.dart';
import 'station.dart';

class Line {
  final String name;
  final List<Station> stations; // Reihenfolge der Stationen
  final String colour; // Farbcode der Linie
  final Map<String, List<LatLng>> geometries; // Geometrien zwischen den Stationen

  Line({
    required this.name,
    required this.stations,
    required this.colour,
    required this.geometries,
  });

  // Hole die erste Station der Linie (für Richtung Rückwärts)
  Station getFirstStation() {
    return stations.first;
  }

  // Hole die letzte Station der Linie (für Richtung Vorwärts)
  Station getLastStation() {
    return stations.last;
  }

  // Bestimme die nächste Station in einer bestimmten Richtung
  Station? getNextStation(Station currentStation, bool forward) {
    int currentIndex = stations.indexOf(currentStation);
    if (currentIndex == -1) return null;

    // Fahre vorwärts oder rückwärts, je nach Richtung
    if (forward) {
      if (currentIndex < stations.length - 1) {
        return stations[currentIndex + 1];
      }
    } else {
      if (currentIndex > 0) {
        return stations[currentIndex - 1];
      }
    }
    return null;
  }

  // Hole die Geometrie (LatLng-Punkte) zwischen zwei Stationen
  List<LatLng>? getGeometry(Station fromStation, Station toStation) {
    if (geometries['${fromStation.name}-${toStation.name}'] != null) {
      return geometries['${fromStation.name}-${toStation.name}'];
    } else {
      return geometries['${toStation.name}-${fromStation.name}'];
    }
  }

  // Überprüfe, ob eine Station Umstiegsmöglichkeiten zu anderen Linien hat
  bool hasConnectionToOtherLines(Station station, List<Line> allLines) {
    for (var line in allLines) {
      if (line != this && line.stations.contains(station)) {
        return true; // Station wird von anderen Linien bedient
      }
    }
    return false;
  }

  // Gibt zurück, ob eine bestimmte Station die Endstation ist (nützlich für Richtungsentscheidungen)
  bool isEndStation(Station station) {
    return station == getFirstStation() || station == getLastStation();
  }
}
