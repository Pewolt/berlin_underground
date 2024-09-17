import 'package:flutter/material.dart';
import '../models/ubahn_game.dart';
import '../models/line.dart';

class GameControls extends StatelessWidget {
  final UbahnGame game;
  final VoidCallback onMove;
  final VoidCallback onChangeLine;
  final Function(Line, bool) onChooseLineAndDirection;
  final Function(String) showMessage;

  const GameControls({
    Key? key,
    required this.game,
    required this.onMove,
    required this.onChangeLine,
    required this.onChooseLineAndDirection,
    required this.showMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wenn keine aktuelle Linie ausgewählt ist
    if (game.currentLine == null) {
      List<Line> availableLines = game.getLinesAtCurrentStation();

      if (availableLines.isEmpty) {
        return const Text('Keine Linien verfügbar.');
      } else if (availableLines.length == 1) {
        // Nur eine Linie verfügbar, Richtung wählen
        return SingleChildScrollView(
          child: Column(
            children: [
              Text('Linie ${availableLines[0].name} wählen:'),
              _buildSquareButton('Richtung ${availableLines[0].getLastStation().name}', () {
                onChooseLineAndDirection(availableLines[0], true);
              }),
              _buildSquareButton('Richtung ${availableLines[0].getFirstStation().name}', () {
                onChooseLineAndDirection(availableLines[0], false);
              }),
            ],
          ),
        );
      } else {
        // Mehrere Linien verfügbar, Linie und Richtung wählen
        return Container(
          width: 250,
          height: 350,
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
                        onChooseLineAndDirection(line, true);
                      }),
                      _buildSquareButton('Richtung ${line.getFirstStation().name}', () {
                        onChooseLineAndDirection(line, false);
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
          if (game.getAvailableLines().isNotEmpty)
            _buildSquareButton('Umsteigen', onChangeLine),
          _buildSquareButton('Weiterfahren', onMove),
        ],
      );
    }
  }

  // Hilfsmethode zur Erstellung von Buttons
  Widget _buildSquareButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(150, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}
