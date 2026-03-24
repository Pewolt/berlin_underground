class Mission {
  final String id;
  final String title;
  final String startStation;
  final String targetStation;
  final String description;
  final int requiredLevel; // NEU: Verhindert Softlocks durch fehlende Linien

  const Mission({
    required this.id,
    required this.title,
    required this.startStation,
    required this.targetStation,
    required this.description,
    required this.requiredLevel,
  });
}

// Der neue, an die Topologie angepasste Schichtplan
const List<Mission> campaignMissions = [
  Mission(
    id: 'm1', 
    title: 'Schicht 1: Die Jungfernfahrt', 
    startStation: 'Seestr.', 
    targetStation: 'Friedrichstr.', 
    description: 'Lerne das Anfahren und Bremsen auf der U6. Bleib auf deiner Linie.',
    requiredLevel: 1, // Nutzt nur U6
  ),
  Mission(
    id: 'm2', 
    title: 'Schicht 2: Das Kreuzberg-Kreuz', 
    startStation: 'Tempelhof', 
    targetStation: 'Gneisenaustr.', 
    description: 'Die U7 ist jetzt verfügbar! Finde den Umsteigebahnhof Mehringdamm.',
    requiredLevel: 2, // Nutzt U6 -> U7
  ),
  Mission(
    id: 'm3', 
    title: 'Schicht 3: Hochbahn-Romantik', 
    startStation: 'Gneisenaustr.', 
    targetStation: 'Kottbusser Tor', 
    description: 'Die U1 ist freigeschaltet. Nutze die U7 und steige an der Möckernbrücke um!',
    requiredLevel: 3, // Nutzt U7 -> U1
  ),
  Mission(
    id: 'm4', 
    title: 'Schicht 4: Pendler-Stress', 
    startStation: 'Warschauer Str.', 
    targetStation: 'Hallesches Tor', 
    description: 'Beweise, dass du das bestehende Netz (U6, U7, U1) beherrschst. Keine Fehler erlaubt.',
    requiredLevel: 3, // Übung
  ),
  Mission(
    id: 'm5', 
    title: 'Schicht 5: Die Magistrale', 
    startStation: 'Potsdamer Platz', 
    targetStation: 'Alexanderplatz', 
    description: 'Die historische U2 steht dir nun zur Verfügung. Ab in den Osten!',
    requiredLevel: 5, // Nutzt U2
  ),
  Mission(
    id: 'm6', 
    title: 'Schicht 6: Stadtmitte-Chaos', 
    startStation: 'Alexanderplatz', 
    targetStation: 'Seestr.', 
    description: 'Finde den besten Weg von der U2 auf die U6.',
    requiredLevel: 5, // U2 -> U6
  ),
  Mission(
    id: 'm7', 
    title: 'Schicht 7: Untergrund-Labyrinth', 
    startStation: 'Hermannplatz', 
    targetStation: 'Moritzplatz', 
    description: 'Die U8 ist online! Nutze sie als schnellen Bypass durch Kreuzberg.',
    requiredLevel: 10, // Nutzt U8
  ),
  Mission(
    id: 'm8', 
    title: 'Schicht 8: Kiez-Hopping', 
    startStation: 'Zoologischer Garten', 
    targetStation: 'Kottbusser Tor', 
    description: 'Eine lange Route. Viele Wege führen ans Ziel, aber welcher ist der schnellste?',
    requiredLevel: 10, 
  ),
  // Hier kannst du später weitere Missionen bis Level 30+ einbauen!
];