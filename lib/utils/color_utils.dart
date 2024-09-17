import 'package:flutter/material.dart';

// Konvertiert einen Hex-Farbcode in ein Color-Objekt
Color colorFromHex(String hexColor) {
  hexColor = hexColor.replaceAll('#', '');
  return Color(int.parse('FF$hexColor', radix: 16));
}
