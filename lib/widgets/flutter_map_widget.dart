import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/ubahn_game.dart';

class FlutterMapWidget extends StatelessWidget {
  final UbahnGame? game;
  final bool gameStarted;

  const FlutterMapWidget({Key? key, required this.game, required this.gameStarted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wenn das Spiel nicht geladen ist, zeige einen Ladeindikator
    if (game == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Erstelle die Karte mit Polylinien und Markern
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(52.508, 13.4050),
        initialZoom: 10.5,
        minZoom: 10.0,
        maxZoom: 13.0,
        interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag, // Aktiviert Zoomen und Ziehen
      ),
      children: [
        PolylineLayer(
          polylines: game!.createPolylines(gameStarted),
        ),
        MarkerLayer(
          markers: game!.createMarkers(gameStarted),
        ),
      ]
    );
  }
}
