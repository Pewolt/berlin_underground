import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ubahn_game.dart';
import '../models/line.dart';
import '../data/data_loader.dart';
import '../widgets/flutter_map_widget.dart';
import '../widgets/game_controls.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  UbahnGame? _game;
  bool _gameStarted = false;
  String? _message;
  String? _deadEndMessage;
  double realismLevel = 0.1; // Standard-Realismusgrad
  bool soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadGame();
  }

  // Lädt die Einstellungen
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      realismLevel = prefs.getDouble('realismLevel') ?? 0.1;
      soundEnabled = prefs.getBool('soundEnabled') ?? true;
    });
  }

  // Lädt das Spiel mit den Daten
  Future<void> _loadGame() async {
    final lines = <Line>[];
    final dataLoader = DataLoader('assets/underground.geojson', lines);
    await dataLoader.loadUbahnConnections();
    setState(() {
      _game = UbahnGame(lines);
      _game!.realismLevel = realismLevel; // Setzt den Realismusgrad
    });
  }

  // Startet das Spiel
  void _startGame() {
    setState(() {
      _game!.startGame();
      _gameStarted = true;
      if (soundEnabled) {
        // Sound abspielen (Implementierung erforderlich)
      }
    });
  }

  // Zeigt eine Nachricht als modalen Dialog an
  void _showMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Information'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _message = null;
                });
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Zeigt eine Nachricht bei Sackgassen
  void _showDeadEndMessage(BuildContext context, String message) {
    setState(() {
      _deadEndMessage = message;
    });
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _deadEndMessage = null;
      });
    });
  }

  // Berechnet die durchschnittliche Geschwindigkeit
  String _calculateAverageSpeed() {
    if (_game!.traveldTime > 0) {
      double avgSpeed = _game!.totalDistance / (_game!.traveldTime / 60); // km/h
      return avgSpeed.toStringAsFixed(2);
    } else {
      return '0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _gameStarted && _game!.currentStation != null
            ? Text(
                'Zeit: ${_game!.traveldTime} min | Station: ${_game!.currentStation!.name}',
                style: const TextStyle(fontSize: 16),
              )
            : const Text('Berlin Underground Controller'),
      ),
      body: Stack(
        children: [
          // Karte
          FlutterMapWidget(game: _game, gameStarted: _gameStarted),

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

          // Spielsteuerung
          Positioned(
            bottom: 20,
            right: 20,
            child: _gameStarted
                ? _game!.gameOver
                    ? const SizedBox.shrink()
                    : GameControls(
                        game: _game!,
                        onMove: () {
                          setState(() {
                            _game!.moveToNextStation((msg) => _showMessage(context, msg));
                          });
                        },
                        onChangeLine: () {
                          setState(() {
                            _game!.changeLine((msg) => _showMessage(context, msg));
                          });
                        },
                        onChooseLineAndDirection: (line, direction) {
                          setState(() {
                            _game!.chooseLineAndDirection(line, direction);
                          });
                        },
                        showMessage: (msg) => _showMessage(context, msg),
                      )
                : ElevatedButton(
                    onPressed: _startGame,
                    child: const Text('Spiel starten'),
                  ),
          ),

          // Statistiken anzeigen
          if (_gameStarted)
            Positioned(
              top: 10,
              left: 10,
              child: Card(
                color: Colors.white.withOpacity(0.8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Statistiken:\n'
                    'Gesamtstrecke: ${_game!.totalDistance.toStringAsFixed(2)} km\n'
                    'Umstiege: ${_game!.numberOfTransfers}\n'
                    'Verspätungen: ${_game!.totalDelays} min\n'
                    'Durchschnittsgeschw.: ${_calculateAverageSpeed()} km/h',
                    style: const TextStyle(fontSize: 14),
                  ),
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
                          Text('Gesamtstrecke: ${_game!.totalDistance.toStringAsFixed(2)} km'),
                          Text('Anzahl der Umstiege: ${_game!.numberOfTransfers}'),
                          Text('Verspätungen insgesamt: ${_game!.totalDelays} min'),
                          Text('Durchschnittsgeschwindigkeit: ${_calculateAverageSpeed()} km/h'),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _game!.startGame();
                                _message = null;
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
}
