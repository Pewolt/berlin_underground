import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class Connection {
  final String fromStation;
  final String toStation;
  final String lineName;
  final int travelTime;
  final List<LatLng> geometry;
  final Color color; // NEU: Farbe direkt aus der GeoJSON

  Connection({
    required this.fromStation,
    required this.toStation,
    required this.lineName,
    required this.travelTime,
    required this.geometry,
    required this.color,
  });
}