import 'package:latlong2/latlong.dart';

import 'line.dart';

class Station {
  final String name;
  final List<Line> lines; // Liste der Linien, die an dieser Station halten
  final LatLng coordinates;

  Station({
    required this.name,
    required this.lines,
    required this.coordinates,
  });

  // Methode, um festzustellen, ob diese Station von einer bestimmten Linie bedient wird
  bool servesLine(Line line) {
    print('Station: servesLines()');
    return lines.contains(line);
  }

  // Methode, um eine neue Linie hinzuzufügen, wenn sie noch nicht existiert
  void addLine(Line line) {
    if (!lines.contains(line)) {
      lines.add(line);
    }
  }

  // Um die Linien und den Stationsnamen als String anzuzeigen
  @override
  String toString() {
    print('Station: toString()');
    String lineNames = lines.map((line) => line.name).join(', ');
    return '$name (Lines: $lineNames)';
  }

  // Überschreibe equals und hashCode, um Stationen korrekt zu vergleichen
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Station) return false;
    return name == other.name;
  }

  @override
  int get hashCode => name.hashCode;
}
