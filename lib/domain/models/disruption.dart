class Disruption {
  final String fromStation;
  final String toStation;
  final String lineName;
  final String description;

  const Disruption({
    required this.fromStation,
    required this.toStation,
    required this.lineName,
    required this.description,
  });

  // Hilfsfunktion, um zu prüfen, ob eine Kante betroffen ist (beide Richtungen)
  bool affects(String from, String to, String line) {
    if (lineName != line) return false;
    return (fromStation == from && toStation == to) || 
           (fromStation == to && toStation == from);
  }
}