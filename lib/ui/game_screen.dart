import 'package:berlin_underground/data/data_loader.dart';
import 'package:berlin_underground/data/line.dart';
import 'package:berlin_underground/game/ubahn_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  UbahnGame? _game;
  bool _gameStarted = false;
  String? _deadEndMessage;

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  Future<void> _loadGame() async {
    final lines = <Line>[]; // Lade die Linien hier
    final dataLoader = DataLoader('assets/underground.geojson', lines); // Beispielpfad
    await dataLoader.loadUbahnConnections();
    setState(() {
      _game = UbahnGame(lines);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _gameStarted && _game!.currentStation != null
            ? Text(
                'Zeit: ${_game!.traveldTime} min | Aktuelle Station: ${_game!.currentStation!.name} | Ziel: ${_game!.endStation!.name}',
                style: const TextStyle(fontSize: 16),
              )
            : const Text('Berlin underground controller'),
      ),
      body: Stack(
        children: [
          // Die Karte nimmt den gesamten Bildschirm ein
          FlutterMapWidget(_game, _gameStarted),
          // Die Buttons unten rechts in der Ecke
          Positioned(
            bottom: 20,
            right: 20,
            child: _gameStarted
                ? _game!.gameOver
                    ? const SizedBox.shrink()
                    : _buildGameControls()
                : _buildSquareButton('Spiel starten', () {
                    setState(() {
                      _game!.startGame();
                      _gameStarted = true;
                    });
                  }),
          ),
          // Nachricht bei Sackgasse
          if (_deadEndMessage != null)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.redAccent,
                child: Text(
                  _deadEndMessage!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          // Endbildschirm
          if (_gameStarted && _game!.gameOver)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Card(
                    margin: const EdgeInsets.all(20),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Spiel beendet!', style: TextStyle(fontSize: 24)),
                          const SizedBox(height: 20),
                          Text('Gefahrene Zeit: ${_game!.traveldTime} min'),
                          Text('Bestmögliche Zeit: ${_game!.fastestTime} min'),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _game!.startGame();
                                _deadEndMessage = null;
                              });
                            },
                            child: const Text('Neustarten'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Widget zum Anzeigen der Spielsteuerung
  Widget _buildGameControls() {
    // Wenn keine aktuelle Linie ausgewählt ist
    if (_game!.currentLine == null) {
      List<Line> availableLines = _game!.getLinesAtCurrentStation();

      if (availableLines.isEmpty) {
        return const Text('Keine Linien verfügbar.');
      } else if (availableLines.length == 1) {
        // Nur eine Linie verfügbar, Richtung wählen
        return SingleChildScrollView(
          child: Column(
            children: [
              Text('Linie ${availableLines[0].name} wählen:'),
              _buildSquareButton('Richtung ${availableLines[0].getLastStation().name}', () {
                setState(() {
                  _game!.chooseLineAndDirection(availableLines[0], true);
                });
              }),
              _buildSquareButton('Richtung ${availableLines[0].getFirstStation().name}', () {
                setState(() {
                  _game!.chooseLineAndDirection(availableLines[0], false);
                });
              }),
            ],
          ),
        );
      } else {
        // Mehrere Linien verfügbar, Linie und Richtung wählen
        return Container(
          width: 250, // Breite der Auswahlbox (anpassen nach Bedarf)
          height: 350, // Höhe der Auswahlbox (anpassen nach Bedarf)
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text('Linie und Richtung wählen:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                for (var line in availableLines)
                  Column(
                    children: [
                      Text('Linie ${line.name}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      _buildSquareButton('Richtung ${line.getLastStation().name}', () {
                        setState(() {
                          _game!.chooseLineAndDirection(line, true);
                        });
                      }),
                      _buildSquareButton('Richtung ${line.getFirstStation().name}', () {
                        setState(() {
                          _game!.chooseLineAndDirection(line, false);
                        });
                      }),
                      const Divider(),
                    ],
                  ),
              ],
            ),
          ),
        );
      }
    } else {
      // Linie ist ausgewählt, normale Steuerung anzeigen
      return Column(
        children: [
          if (_game!.getAvailableLines().isNotEmpty)
            _buildSquareButton('Umsteigen', () {
              _showLineSelectionDialog();
            }),
          _buildSquareButton('Weiterfahren', () {
            setState(() {
              _game!.moveToNextStation(() => _showMessage(context, "Sackgasse! Drehe um."));
            });
          }),
        ],
      );
    }
  }

  // Funktion zur Erstellung von quadratischen Buttons mit runden Ecken
  Widget _buildSquareButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Geringerer Abstand zwischen den Buttons
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(150, 50), // Angepasste Größe
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Runde Ecken
          ),
        ),
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }

  // Zeige das Dialogfeld für den Linienwechsel
  Future<void> _showLineSelectionDialog() async {
    List<Line> availableLines = _game!.getAvailableLines();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Umsteigen'),
          content: SingleChildScrollView(
            child: Column(
              children: availableLines.map((line) {
                return Column(
                  children: [
                    Text('Linie ${line.name}'),
                    _buildSquareButton('Richtung ${line.getLastStation().name}', () {
                      setState(() {
                        _game!.changeLine(line); // Linie wechseln
                        _game!.chooseDirection(true); // Vorwärtsrichtung wählen
                        Navigator.of(context).pop(); // Dialog schließen
                      });
                    }),
                    _buildSquareButton('Richtung ${line.getFirstStation().name}', () {
                      setState(() {
                        _game!.changeLine(line); // Linie wechseln
                        _game!.chooseDirection(false); // Rückwärtsrichtung wählen
                        Navigator.of(context).pop(); // Dialog schließen
                      });
                    }),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // Methode zur Anzeige von Nachrichten
  void _showMessage(BuildContext context, String message) {
    setState(() {
      _deadEndMessage = message;
    });
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _deadEndMessage = null;
      });
    });
  }
}

// ignore: must_be_immutable
class FlutterMapWidget extends StatelessWidget {
  final UbahnGame? game;
  bool gameStarted;

  FlutterMapWidget(this.game, this.gameStarted, {super.key});

  @override
  Widget build(BuildContext context) {
    return game == null
        ? const Center(child: CircularProgressIndicator())
        : FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(52.508, 13.4050),
              initialZoom: 10.5,
              minZoom: 10.0,
              maxZoom: 13.0,
              // ignore: deprecated_member_use
              interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
            children: [
              PolylineLayer(
                polylines: game!.createPolylines(gameStarted),
              ),
              MarkerLayer(
                markers: game!.createMarkers(gameStarted), // Hier fügen wir die angepassten Marker hinzu
              ),
            ],
          );
  }
}
