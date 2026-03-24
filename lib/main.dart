import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/repositories/subway_repository.dart';
import 'presentation/state/game_provider.dart';
import 'presentation/state/progress_provider.dart';
import 'presentation/state/screen_provider.dart';
import 'presentation/state/audio_provider.dart'; // Der neue Audio-Provider
import 'presentation/ui/subway_map.dart';
import 'presentation/ui/screens/main_menu_screen.dart';
import 'presentation/ui/screens/ingame_hud_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final repository = SubwayRepository();
  
  // Lädt die Vektordaten (deine GeoJSON)
  await repository.loadGeoJson('assets/underground.geojson');

  // Lock auf Landscape für das Arcade-Feeling
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(
      ProviderScope(
        overrides: [
          repositoryProvider.overrideWithValue(repository),
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
        child: const BerlinUndergroundApp(),
      ),
    );
  });
}

// App-Klasse ist jetzt ein ConsumerWidget, um globale Provider zu initialisieren
class BerlinUndergroundApp extends ConsumerWidget {
  const BerlinUndergroundApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FEUER FREI: Initialisiert den Audio-Service direkt beim Start, damit die Musik läuft
    ref.read(audioServiceProvider);

    return MaterialApp(
      title: 'Berlin Underground',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      home: const Scaffold(
        body: Stack(
          children: [
            // Die Vektor-Karte liegt permanent unten
            SubwayMap(),
            
            // Der Router legt die UI darüber
            SafeArea(
              child: AppScreenRouter(),
            ),
          ],
        ),
      ),
    );
  }
}

class AppScreenRouter extends ConsumerWidget {
  const AppScreenRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Horcht nur noch auf die verbleibenden validen Screens
    final currentScreen = ref.watch(screenProvider);

    Widget activeWidget;
    switch (currentScreen) {
      case AppScreen.mainMenu:
        activeWidget = const MainMenuScreen();
        break;
      case AppScreen.inGame:
        activeWidget = const InGameHudScreen();
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: activeWidget,
    );
  }
}