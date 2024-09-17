import 'package:latlong2/latlong.dart';

// Berechnet die Distanz zwischen zwei Koordinaten
double calculateDistance(LatLng point1, LatLng point2) {
  final Distance distance = Distance();
  return distance.as(LengthUnit.Kilometer, point1, point2);
}
