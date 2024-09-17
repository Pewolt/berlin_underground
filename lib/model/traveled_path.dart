import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class TraveledPath {
  final List<LatLng> geometry;
  final Color color;

  TraveledPath({
    required this.geometry,
    required this.color,
  });
}
