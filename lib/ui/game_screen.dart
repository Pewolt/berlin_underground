import 'package:berlin_underground/data/data_loader.dart';
import 'package:berlin_underground/data/line.dart'; 
import 'package:berlin_underground/game/ubahn_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  UbahnGame? _game;
  bool _gameStarted = false;
  bool _directionChosen = false; // Neue Variable, um festzustellen, ob die Richtung gewählt wurde

  @override
  void initState() {
    super.initState();
    _loadGame();
  } 

  Future<void> _loadGame() async {
    final lines = <Line>[]; // Lade die Linien hier
    final dataLoader = DataLoader('assets/underground.geojson', lines);
    await dataLoader.loadUbahnConnections();
    setState(() {
      _game = UbahnGame(lines);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Berlin underground controller'),
      ),
      body: Row(
        children: [
          // Linke Seite: Zeigt aktuelle Station, Linie und Umsteigemöglichkeiten
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.grey[200],
              child: _gameStarted
                  ? _directionChosen
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Aktuelle Station: ${_game!.currentStation!.name}'),
                              Text('Aktuelle Linie: ${_game!.currentLine!.name}'),
                              Text('Richtung: ${_game!.getCurrentDirection()}'),
                              Text('Ziel: ${_game!.endStation!.name}'),
                              Text('Zeit in Minuten: ${_game!.traveldTime.toString()}'),
                              if (_game!.getAvailableLines().isNotEmpty)
                                Text(
                                  'Umsteigen möglich in Linien: ${_game!.getAvailableLines().map((line) => line.name).join(', ')}',
                                ),
                              if (_game!.gameOver)
                                ElevatedButton(
                                  onPressed: _startNewGame,
                                  child: const Text('Neue Runde beginnen'),
                                ),
                              ElevatedButton(
                                onPressed: () {
                                  if (_game!.gameOver) {
                                    _showEndGameDialog();
                                  } else {
                                    _game!.moveToNextStation(_showMessage);
                                  }
                                  setState(() {}); // Aktualisiert die UI
                                },
                                child: const Text('Weiterfahren'),
                              ),
                              if (_game!.getAvailableLines().isNotEmpty)
                                ElevatedButton(
                                  onPressed: _showLineSelectionDialog, // Dialog zur Auswahl von Linie und Richtung
                                  child: const Text('Umsteigen'),
                                ),
                            ],
                          ),
                        )
                      : _buildDirectionChoice() // Richtungsauswahl am Anfang des Spiels
                  : Center(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _game!.startGame();
                            _gameStarted = true;
                          });
                        },
                        child: const Text('Spiel starten'),
                      ),
                    ),
            ),
          ),
          // Rechte Seite: Zeigt die Karte mit den Strecken
          Expanded(
            flex: 6,
            child: FlutterMapWidget(_game, _gameStarted),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hinweis'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Zeige ein Dialogfeld, wenn das Spiel beendet ist
  void _showEndGameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Spiel beendet'),
          content: Text('Du hast die Zielstation in ${_game!.traveldTime.toString()} Minuten erreicht! /n Die optimale Zeit ist ${_game!.fastestTime.toString()}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startNewGame(); // Neue Runde starten
              },
              child: const Text('Neue Runde beginnen'),
            ),
          ],
        );
      },
    );
  }

  void _startNewGame() {
    setState(() {
      _game!.startGame();
      _directionChosen = false;
    });
  }

  // Widget zur Auswahl der Fahrtrichtung
  Widget _buildDirectionChoice() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Aktuelle Station: ${_game!.currentStation!.name}'),
          Text('Aktuelle Linie: ${_game!.currentLine!.name}'),
          Text('Ziel: ${_game!.endStation!.name}'), // Ziel dauerhaft anzeigen
          Text('Wähle die Fahrtrichtung auf der Linie ${_game!.currentLine!.name}:'),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _game!.chooseDirection(true); // Vorwärtsrichtung wählen
                _directionChosen = true;
              });
            },
            child: Text('Richtung ${_game!.currentLine!.getLastStation().name}'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _game!.chooseDirection(false); // Rückwärtsrichtung wählen
                _directionChosen = true;
              });
            },
            child: Text('Richtung ${_game!.currentLine!.getFirstStation().name}'),
          ),
        ],
      ),
    );
  }

  // Zeige ein Dialogfeld zur Auswahl der Linie und der Richtung beim Umsteigen
  Future<void> _showLineSelectionDialog() async {
    List<Line> availableLines = _game!.getAvailableLines();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Umsteigen'),
          content: SingleChildScrollView( // Scroll-Container hinzufügen
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: availableLines.map((line) {
                return Column(
                  children: [
                    Text('Linie ${line.name}'),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _game!.changeLine(line); // Linie wechseln
                          _game!.chooseDirection(true); // Vorwärtsrichtung wählen
                          Navigator.of(context).pop(); // Dialog schließen
                        });
                      },
                    child: Text('Richtung ${line.getLastStation().name}'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _game!.changeLine(line); // Linie wechseln
                          _game!.chooseDirection(false); // Rückwärtsrichtung wählen
                          Navigator.of(context).pop(); // Dialog schließen
                        });
                      },
                      child: Text('Richtung ${line.getFirstStation().name}'),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class FlutterMapWidget extends StatelessWidget {
  final UbahnGame? game;
  bool gameStarted;

  FlutterMapWidget(this.game, this.gameStarted);

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
              interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
            children: [
              PolylineLayer(
                polylines: game!.createPolylines(gameStarted),
              ),
              MarkerLayer(
                markers: game!.createMarkers(gameStarted),  // Hier fügen wir Marker hinzu
              ),
            ],
          );
  }
}

