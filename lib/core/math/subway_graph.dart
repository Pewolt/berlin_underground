import 'package:collection/collection.dart';
import '../../domain/models/station.dart';
import '../../domain/models/connection.dart';
import '../../domain/models/disruption.dart'; // NEU

class RouteResult {
  final List<String> path;
  final int totalTime;
  RouteResult(this.path, this.totalTime);
}

class SubwayGraph {
  final Map<String, Station> stations = {};
  final Map<String, List<Connection>> adjacencyList = {};

  void addStation(Station station) {
    stations.putIfAbsent(station.name, () => station);
    adjacencyList.putIfAbsent(station.name, () => []);
  }

  void addConnection(Connection connection) {
    adjacencyList[connection.fromStation]?.add(connection);
    
    adjacencyList[connection.toStation]?.add(Connection(
      fromStation: connection.toStation,
      toStation: connection.fromStation,
      lineName: connection.lineName,
      travelTime: connection.travelTime,
      geometry: connection.geometry.reversed.toList(),
      color: connection.color, 
    ));
  }

  String getLineEndpoint(String currentStation, String lineName, String nextStation) {
    String prev = currentStation;
    String curr = nextStation;
    final Set<String> visited = {prev}; 

    while (true) {
      visited.add(curr);
      final conns = adjacencyList[curr] ?? [];
      final nextConns = conns.where((c) => c.lineName == lineName && c.toStation != prev).toList();

      if (nextConns.isEmpty) return curr; 
      prev = curr;
      curr = nextConns.first.toStation; 

      if (visited.contains(curr)) return curr; 
    }
  }

  // NEU: Nimmt jetzt auch eine Liste von Störungen an!
  RouteResult findShortestPath(String startName, String targetName, {Set<String>? allowedLines, List<Disruption> disruptions = const []}) {
    if (!stations.containsKey(startName) || !stations.containsKey(targetName)) {
      return RouteResult([], 0);
    }

    final distances = <String, int>{};
    final previous = <String, String?>{};
    final pq = PriorityQueue<MapEntry<String, int>>((a, b) => a.value.compareTo(b.value));

    for (var id in stations.keys) {
      distances[id] = 999999;
      previous[id] = null;
    }

    distances[startName] = 0;
    pq.add(MapEntry(startName, 0));

    while (pq.isNotEmpty) {
      final current = pq.removeFirst().key;
      if (current == targetName) break;

      for (var connection in adjacencyList[current] ?? []) {
        if (allowedLines != null && !allowedLines.contains(connection.lineName)) continue;

        // --- DIE NEUE GEOINFORMATIK-LOGIK ---
        // Prüfe, ob genau diese Kante aktuell wegen eines Notarzteinsatzes etc. gesperrt ist.
        bool isDisrupted = disruptions.any((d) => d.affects(connection.fromStation, connection.toStation, connection.lineName));
        if (isDisrupted) continue; // Kante überspringen! Der Algorithmus muss einen Umweg finden.

        final alt = distances[current]! + connection.travelTime;

        if (alt < distances[connection.toStation]!) {
          distances[connection.toStation] = alt.toInt();
          previous[connection.toStation] = current;
          pq.add(MapEntry(connection.toStation, alt.toInt()));
        }
      }
    }

    final path = <String>[];
    String? curr = targetName;
    while (curr != null) {
      path.insert(0, curr);
      curr = previous[curr];
    }

    if (path.length <= 1 && startName != targetName) {
        return RouteResult([], 0); // Kein Weg gefunden (z.B. weil alles gesperrt ist)
    }

    return RouteResult(path, distances[targetName]!);
  }
}


        