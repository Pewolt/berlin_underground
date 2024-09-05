import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:berlin_underground/game/ubahn_game.dart';

class FlutterMapWidget extends StatelessWidget {
  final UbahnGame game;

  FlutterMapWidget(this.game);

  @override
  Widget build(BuildContext context) {
    print('FlutterMapWidget: build()');
    return FlutterMap(
      options: MapOptions(
        center: LatLng(52.5200, 13.4050), // Beispiel für Berlin
        zoom: 12,
        minZoom: 10.0,
        maxZoom: 15.0,
        interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        onPositionChanged: (position, hasGesture) {
          // Möglicherweise möchtest du hier auf Positionsänderungen reagieren
        },
      ),
      children: [ // Verwende 'children' statt 'layers'
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        PolylineLayer(
          polylines: game.createPolylines(), // Hier werden die Linien für die Karte erstellt
        ),
      ],
    );
  }
}
