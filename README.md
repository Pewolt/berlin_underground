# Berlin Underground Controller

![Startbildschirm](https://cloud.bht-berlin.de/index.php/apps/files_sharing/publicpreview/6GXxKEQH4TX8saA?file=/&fileId=49995263&x=2892&y=1526&a=true&etag=fcae04eafa60b3fe6653ea3748163a66)

## App Idee und Zielsetzung
Das Berliner Ubahn Netz ist das größte in Deutschland. Es ist mit 9 Linien und 175 Bahnhöfen sehr komplex. Für neue Einwohner oder Studenten die nach Berlin ziehen ist es eine Herausforderung sich zu orientieren. Die verschiedenen Stationen und Umsteigebahnhöfe sind sehr vielseitig in verschiedene Richtungen nutzbar. Eine Methode das U-Bahnnetz zu lernen ist es dieses interaktiv und spielerisch zu erfassen. Wir haben mit dieser Idee eine spielerische Lernapp verfolgt, in welcher der Nutzer die optimale Verbindung selbst versucht zu erfahren. Das Kernelement dabei ist die gefahrene Zeit.

Aktuell gibt es keine App die diesen spielerischen Ansatz verfolgt. Es gibt sehr viele Apps mit Übersichtsplänen, Karten sowie Routing welche einem die optimale Verbindung vorgeben. Oftmals ist man im Alltag des Berliner ÖPNV jedoch angewiesen „outside-the-box“ zu denken da es jederzeit zu Störungen, Ausfällen oder Baumaßnahmen kommen kann. Dabei hilft eine umfangreiche Kenntnis über das Streckennetz. Obwohl das Kernelement die Zeit ist, gibt es in einem Netzwerk keine falsche Verbindung.

## Zielgruppe
Die Zielgruppe ist definiert als berlinfremde Personen im Alter von +18 Jahren. Dies hat den Grund, dass Erwachsene ab 18 Jahren, vor allem in Städten, U-Bahn-Systeme oft täglich für den Weg zur Arbeit, zur Universität oder für Freizeitaktivitäten nutzen. Die App kann dazu beitragen, die Navigation in einer komplexen Stadtlandschaft zu verbessern. Das Wissen über optimale Verbindungen spart Zeit und Stress im Alltag und hilft durch den Gameification Aspekt schneller ein räumliches Vorstellungsvermögen über die Stadt Berlin zu erwerben.

## Ausblick auf mögliche Verbesserungen oder Features

Das U-Bahnnetz lässt sich mit dem S-Bahn und Tram-Netz erweitern und würde für einen höheren Schwierigkeitsgrad sorgen.
Ranglisten würden ebenfalls den Wettbewerb gegen sich selbst und andere fördern und einen Anreiz zu Nutzung geben. 
Bestimmte Ziele innerhalb Berlins oder entlang eines Weges können ebenfalls dazu beitragen den Spielspaß zu verlängern sowie den Schwierigkeitsgrad erhöhen.
Ein realistischer Modus bei den Störungen auf der Stecke vorkommen.

---

## Überblick

**Berlin Underground Controller** ist ein interaktives Simulationsspiel, das es Spielern ermöglicht, das Berliner U-Bahn-Netz zu navigieren. Ziel ist es, von einer zufällig zugewiesenen Startstation zu einer zufälligen Zielstation in der kürzest möglichen Zeit zu gelangen, wobei realistische Reisebedingungen und Einschränkungen simuliert werden.

Das Spiel wurde mit Flutter entwickelt und verwendet geografische Daten, um das U-Bahn-Netzwerk genau darzustellen, einschließlich Stationen, Linien und Fahrzeiten zwischen den Stationen. Es bietet eine unterhaltsame Möglichkeit, das Berliner U-Bahn-Netz zu erkunden und gleichzeitig die optimale Route zu finden.

![Spielverlauf](https://cloud.bht-berlin.de/index.php/apps/files_sharing/publicpreview/eTy38JCSdrdQrKb?file=/&fileId=49995261&x=2892&y=1526&a=true&etag=f36e3956371fa884c8d3db2f1f9c0da4)

## Features

- **Interaktive Karte**: Visuelle Darstellung des Berliner U-Bahn-Netzes mit Flutter Map.
- **Zufällige Start- und Zielstation**: Jede Spielsitzung beginnt mit einer zufälligen Start- und Zielstation.
- **Realistische Reisesimulation**:
  - Genaue Fahrzeiten zwischen den Stationen.
  - Notwendigkeit von Linienwechseln und Richtungsentscheidungen wie im echten U-Bahn-System.
- **Benutzeroberfläche**:
  - Anzeige der aktuellen Fahrzeit, der aktuellen Station und des Ziels.
  - Buttons zum Weiterfahren, Umsteigen und Wählen der Richtung.
- **Endbildschirm**:
  - Zeigt die insgesamt benötigte Zeit.
  - Zeigt die bestmögliche Zeit basierend auf dem kürzesten Weg.
  - Möglichkeit, das Spiel neu zu starten.
- **Mehrsprachigkeit**: Das Spiel ist derzeit auf Deutsch verfügbar.

## Installation und Start

### Voraussetzungen

Um das Spiel auszuführen, benötigen Sie Folgendes auf Ihrem Entwicklungssystem:

- **Flutter SDK**: [Flutter installieren](https://flutter.dev/docs/get-started/install) für Ihr Betriebssystem.
- **Dart SDK**: Wird mit Flutter installiert.
- **Git**: Zum Klonen des Repositorys.

### Installation

1. **Repository klonen**

   ```bash
   git clone https://github.com/yourusername/berlin-underground-controller.git
   cd berlin-underground-controller
   ```

2. **Flutter-Pakete beziehen**

   Navigieren Sie zum Projektverzeichnis und führen Sie aus:

   ```bash
   flutter pub get
   ```

### Spiel starten

Sie können das Spiel auf verschiedenen Plattformen ausführen:

#### Android

1. **Android-Gerät oder Emulator einrichten**

   - Für physische Geräte: USB-Debugging aktivieren.
   - Für Emulatoren: Einen Emulator über den AVD-Manager in Android Studio erstellen.

2. **App ausführen**

   ```bash
   flutter run
   ```

#### iOS

1. **iOS-Gerät oder Simulator einrichten**

   - Für physische Geräte: Geräteprovisionierung einrichten.
   - Für Simulatoren: Simulator-App in Xcode verwenden.

2. **App ausführen**

   ```bash
   flutter run
   ```

   *Hinweis: Nur auf macOS.*

#### Web

1. **Web-Unterstützung aktivieren**

   ```bash
   flutter channel stable
   flutter upgrade
   flutter config --enable-web
   ```

2. **App im Webbrowser ausführen**

   ```bash
   flutter run -d chrome
   ```

#### Desktop (Windows, macOS, Linux)

1. **Desktop-Unterstützung aktivieren**

   ```bash
   flutter config --enable-windows-desktop
   flutter config --enable-macos-desktop
   flutter config --enable-linux-desktop
   ```

2. **App ausführen**

   ```bash
   flutter run -d windows
   # oder für macOS
   flutter run -d macos
   # oder für Linux
   flutter run -d linux
   ```

### Release-Versionen bauen

Für bessere Performance bauen Sie eine Release-Version:

```bash
flutter build apk --release
# oder für iOS
flutter build ios --release
```

*Hinweis: Für iOS-Builds ist ein Mac mit installiertem Xcode erforderlich.*

## Projektstruktur

Die Projektstruktur ist wie folgt organisiert:

```
- assets/
  - analyse.py           # Erstellung von times.json
  - times.json
  - underground.geojson
- lib/
  - main.dart
  - data/
    - data_loader.dart
    - line.dart
    - station.dart
    - times_loader.dart
  - game/
    - ubahn_game.dart
  - model/
    - traveled_path.dart
    - visited_station.dart
  - ui/
    - game_screen.dart
```

- **assets/**: Enthält GeoJSON-Daten, Fahrzeitdaten und das Python-Skript zur Generierung von `times.json`.
  - `analyse.py`: Python-Skript zur Erstellung von `times.json` basierend auf Netzwerkdaten.
  - `times.json`: Enthält die berechneten kürzesten Fahrzeiten zwischen den Stationen.
  - `underground.geojson`: GeoJSON-Datei mit den U-Bahn-Netzwerkdaten.
- **lib/**: Enthält den Dart-Quellcode der Anwendung.
  - **main.dart**: Einstiegspunkt der Anwendung.
  - **data/**: Datenmodelle und Loader für Stationen, Linien und Fahrzeiten.
    - `data_loader.dart`: Lädt und parst die GeoJSON-Daten.
    - `line.dart`: Definiert die `Line`-Klasse.
    - `station.dart`: Definiert die `Station`-Klasse.
    - `times_loader.dart`: Lädt die Fahrzeitdaten aus `times.json`.
  - **game/**: Spiel-Logik und Zustandsverwaltung.
    - `ubahn_game.dart`: Hauptklasse für die Spielmechanik.
  - **model/**: Modelle für die Darstellung der zurückgelegten Pfade und besuchten Stationen.
    - `traveled_path.dart`: Definiert die `TraveledPath`-Klasse.
    - `visited_station.dart`: Definiert die `VisitedStation`-Klasse.
  - **ui/**: Benutzeroberflächen-Bildschirme für die App.
    - `game_screen.dart`: Hauptbildschirm des Spiels.

## Spielanleitung

1. **Spiel starten**

   - Klicken Sie auf den Button "Spiel starten".

2. **Linie und Richtung wählen**

   - Wenn mehrere Linien an der Startstation verfügbar sind, wählen Sie eine Linie und die Richtung.
   - Wenn nur eine Linie verfügbar ist, wählen Sie die Richtung.

3. **Navigieren**

   - Nutzen Sie den Button "Weiterfahren", um zur nächsten Station zu gelangen.
   - Mit "Umsteigen" können Sie an der aktuellen Station die Linie wechseln.
   - Wenn Sie in einer Sackgasse ankommen, erscheint eine Nachricht, die Sie auffordert, umzudrehen.

4. **Ziel**

   - Erreichen Sie die Zielstation in der kürzest möglichen Zeit.
   - Am Ende zeigt das Spiel die benötigte Zeit und die bestmögliche Zeit an.

5. **Endbildschirm**

   - Nach Erreichen des Ziels erscheint ein Endbildschirm.
   - Sie können Ihre Gesamtzeit und die optimale Zeit einsehen.
   - Option, das Spiel neu zu starten.

*[Gameplay-Video](https://cloud.bht-berlin.de/index.php/s/G368xeqEcZm5Tg4)*

## Datenquellen und Genauigkeit

- **GeoJSON-Daten**: Die U-Bahn-Netzwerkdaten wurden auf Basis von OpenStreetMap-Daten nachmodelliert.
- **Fahrzeiten**: Basieren auf offiziellen Daten.
- **times.json**: Basiert auf Shortest-Path Berechnungen in der analyse.py. Als Umsteigezeit wurde immer 2 Minuten festgelegt.
- **Genauigkeit**: Obwohl wir uns bemüht haben, die Daten so genau wie möglich zu halten, können aufgrund von Vereinfachungen einige Abweichungen auftreten.

## Entwicklungshinweise

- **Sprache**: Das Spiel wurde auf Deutsch entwickelt. Kommentare und Dokumentation sind hauptsächlich in Deutsch.
- **Zustandsverwaltung**: Verwendet `StatefulWidget` für die Zustandsverwaltung innerhalb des Spiels.
- **Kartenanzeige**: Nutzt die Pakete `flutter_map` und `latlong2` für die Kartendarstellung und geografische Berechnungen.
- **Benutzeroberfläche**: Erstellt mit standardmäßigen Flutter-Widgets und benutzerdefinierten Stilen für Buttons und Dialoge.

## Abhängigkeiten

Wichtige Abhängigkeiten im Projekt:

- `flutter_map`: Für die interaktive Karte.
- `latlong2`: Für geografische Berechnungen.
- **Python-Pakete** (für `analyse.py`):
  - `geopandas`
  - `networkx`
  - `pandas`
- `provider` oder andere State-Management-Pakete können für eine bessere Zustandsverwaltung integriert werden (derzeit nicht implementiert).

## Installation der Abhängigkeiten

Alle Flutter-Abhängigkeiten sind in der `pubspec.yaml` aufgeführt. Führen Sie `flutter pub get` aus, um sie zu installieren.

Für das Python-Skript `analyse.py` (falls Sie `times.json` neu generieren müssen):

```bash
pip install geopandas networkx pandas
```

*Hinweis: Python 3.x ist für das Skript `analyse.py` erforderlich.*

## Beitrag leisten

Beiträge sind willkommen! Bitte folgen Sie diesen Schritten:

1. Forken Sie das Repository.
2. Erstellen Sie einen neuen Branch für Ihr Feature oder Ihren Bugfix.
3. Committen Sie Ihre Änderungen mit klaren Nachrichten.
4. Pushen Sie zu Ihrem Fork und erstellen Sie einen Pull Request.

## Lizenz

Dieses Projekt dient Bildungszwecken und ist Teil einer Universitätsaufgabe. Bitte kontaktieren Sie den Autor für Fragen zur Lizenzierung.
