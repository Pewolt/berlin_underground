import 'package:flutter/material.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Scaffold mit AppBar und Tutorial-Text
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Willkommen zum Berlin Underground Controller!\n\n'
          'Ziel des Spiels ist es, von einer zufälligen Startstation '
          'zu einer zufälligen Zielstation zu gelangen.\n\n'
          'Wählen Sie die Linie und die Fahrtrichtung, um sich fortzubewegen. '
          'Sie können an Stationen umsteigen und müssen versuchen, '
          'die kürzeste Route zu finden.\n\n'
          'Achten Sie auf Störungen und passen Sie Ihre Route entsprechend an.\n\n'
          'Viel Spaß beim Spielen!',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
