import 'package:berlin_underground/data/station.dart';
import 'package:flutter/material.dart';

class VisitedStation {
  final Station station;
  Color color;

  VisitedStation({
    required this.station,
    required this.color,
  });
}
