import 'package:berlin_underground/ubahn_connections.dart';

class Graph {
  Map<String, List<UbahnConnection>> _adjacencyList = {};

  // Füge eine neue Kante in beide Richtungen hinzu
  void addEdge(UbahnConnection connection) {
    // Von Station zu Station
    if (_adjacencyList.containsKey(connection.fromStation)) {
      _adjacencyList[connection.fromStation]!.add(connection);
    } else {
      _adjacencyList[connection.fromStation] = [connection];
    }

    // Rückverbindung hinzufügen: Von toStation zu fromStation
    UbahnConnection reverseConnection = UbahnConnection(
      fromStation: connection.toStation,
      toStation: connection.fromStation,
      line: connection.line,
      km: connection.km,
      time: connection.time,
      colour: connection.colour,
      coordinates: connection.coordinates.reversed.toList(),
    );

    if (_adjacencyList.containsKey(reverseConnection.fromStation)) {
      _adjacencyList[reverseConnection.fromStation]!.add(reverseConnection);
    } else {
      _adjacencyList[reverseConnection.fromStation] = [reverseConnection];
    }
  }

  // Finde die Verbindungen von einer bestimmten Station
  List<UbahnConnection>? getConnections(String station) {
    return _adjacencyList[station];
  }

  // Finde den kürzesten Weg (basierend auf der Zeit) zwischen zwei Stationen
  List<UbahnConnection> shortestPath(String start, String destination) {
    // Implementiere einen Algorithmus wie Dijkstra oder A* für den kürzesten Pfad
    return []; // Dummy-Implementierung, hier sollte der Algorithmus implementiert werden
  }

  // Hilfsmethode, um den Graphen zu drucken
  void printGraph() {
    _adjacencyList.forEach((station, connections) {
      print('Station: $station');
      for (var connection in connections) {
        print('  -> ${connection.toStation} via ${connection.line} (${connection.time} min)');
      }
    });
  }
}
