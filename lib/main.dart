import 'package:berlin_underground/datahandler.dart';
import 'package:berlin_underground/graph.dart';
import 'package:berlin_underground/ubahn_connections.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  // Sperre die Ausrichtung auf Querformat
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Row(
          children: [
            // Linke Seite (30% der Breite)
            Expanded(
              flex: 4,
              child: Container(
                color: Colors.grey[200], // Hintergrundfarbe der linken Hälfte
                child: Center(
                  child: Text(
                    'Hier könnte dein Inhalt stehen',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            // Rechte Seite (70% der Breite)
            Expanded(
              flex: 6,
              child: UbahnMap(),
            ),
          ],
        ),
      ),
    );
  }
}

class UbahnMap extends StatefulWidget {
  @override
  _UbahnMapState createState() => _UbahnMapState();
}

class _UbahnMapState extends State<UbahnMap> {
  List<UbahnConnection> _connections = [];
  Graph _ubahnGraph = Graph();
  double _zoom = 11.0;

  @override
  void initState() {
    super.initState();
    _loadUbahnData();
  }

  void _loadUbahnData() async {
    List<UbahnConnection> connections = await loadUbahnConnections();
    setState(() {
      _connections = connections;
      _populateGraph(_connections);
    });
  }

  void _populateGraph(List<UbahnConnection> connections) {
    for (var connection in connections) {
      _ubahnGraph.addEdge(connection); // Füge jede Verbindung in den Graphen hinzu
    }

    // Optional: Den Graphen drucken, um sicherzustellen, dass die Daten korrekt geladen wurden
    _ubahnGraph.printGraph();
  }

  List<Polyline> _createPolylines() {
    List<Polyline> polylines = [];
    double strokeWidth = _zoom;

    for (var connection in _connections) {
      Color color = _colorFromHex(connection.colour);
      polylines.add(
        Polyline(
          points: connection.coordinates,
          color: color,
          strokeWidth: strokeWidth,
        ),
      );
    }

    return polylines;
  }

  Color _colorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  void _onPositionChanged(MapPosition position, bool hasGesture) {
    setState(() {
      _zoom = position.zoom!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(52.5200, 13.4050), // Zentrum von Berlin
        zoom: _zoom,
        minZoom: 10.0,
        maxZoom: 15.0,
        interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag, // Nur Zoomen und Ziehen erlaubt
        onPositionChanged: _onPositionChanged, // Aktualisiert das Zoom-Level
      ),
      children: [
        PolylineLayer(
          polylines: _createPolylines(),
        ),
      ],
    );
  }
}
