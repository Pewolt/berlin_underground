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

  /// Methode, um festzustellen, ob diese Station von einer bestimmten Linie bedient wird
  bool servesLine(Line line) {
    return lines.contains(line);
  }

  /// Methode, um eine neue Linie hinzuzufügen, wenn sie noch nicht existiert
  void addLine(Line line) {
    if (!lines.contains(line)) {
      lines.add(line);
    }
  }

  /// Überschreibe toString, um die Linien und den Stationsnamen anzuzeigen
  @override
  String toString() {
    final String lineNames = lines.map((line) => line.name).join(', ');
    return '$name (Linien: $lineNames)';
  }

  /// Überschreibe equals und hashCode, um Stationen korrekt zu vergleichen
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Station && name == other.name);
  }

  @override
  int get hashCode => name.hashCode;
}
