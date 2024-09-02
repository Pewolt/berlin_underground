import 'dart:convert';
import 'package:berlin_underground/ubahn_connections.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<List<UbahnConnection>> loadUbahnConnections() async {
  String data = await rootBundle.loadString('assets/underground.geojson');
  final jsonResult = json.decode(data);
  List<UbahnConnection> connections = [];

  for (var feature in jsonResult['features']) {
    connections.add(UbahnConnection.fromJson(feature));
  }

  return connections;
}
