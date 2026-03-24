import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/math/subway_graph.dart'; 
import '../../data/repositories/subway_repository.dart';
import '../../domain/models/connection.dart';
import '../../domain/models/mission.dart';
import '../../domain/models/disruption.dart'; 
import 'game_state.dart';
import 'progress_provider.dart';
import 'audio_provider.dart';
import 'screen_provider.dart';

final repositoryProvider = Provider<SubwayRepository>((ref) { throw UnimplementedError(); });

// Hält fest, ob der Spieler gerade die Vorspul-Taste gedrückt hält
final fastForwardProvider = StateProvider<bool>((ref) => false);

final gameProvider = StateNotifierProvider<GameController, GameState>((ref) {
  final repo = ref.watch(repositoryProvider);
  return GameController(repo, ref);
});

class GameController extends StateNotifier<GameState> {
  final SubwayRepository _repository;
  final Ref _ref;
  final Random _random = Random();

  Connection? _activeConnection;
  Connection? get activeConnection => _activeConnection;

  GameController(this._repository, this._ref) : super(GameState());

  void returnToMenu() {
    _activeConnection = null;
    state = GameState(phase: GamePhase.idle);
    _ref.read(screenProvider.notifier).state = AppScreen.mainMenu;
  }

  // ==========================================
  // KAMPAGNEN-MODUS STARTEN
  // ==========================================
  void startMission(Mission mission) {
    final start = _repository.graph.stations[mission.startStation];
    final target = _repository.graph.stations[mission.targetStation];
    if (start == null || target == null) return;
    
    final unlockedLines = _ref.read(progressProvider).unlockedLines;
    
    // Berechne die Benchmark-Zeit nur über freigeschaltete Linien
    final benchmark = _repository.graph.findShortestPath(
      mission.startStation, mission.targetStation, allowedLines: unlockedLines,
    );
    
    _ref.read(audioServiceProvider).playSfx('train_door.wav');

    state = state.copyWith(
      phase: GamePhase.briefing,
      gameMode: GameMode.campaign, 
      currentMission: mission,
      startStation: start,
      targetStation: target,
      optimalTime: benchmark.totalTime,
      currentStation: start,
      currentLine: null,
      timeElapsed: 0,
      traveledPath: [start.name],
      activeDisruptions: [], // In der Kampagne vorerst keine Zufalls-Störungen
      isGameWon: false,
      stars: 0,
      earnedCoins: 0,
      gameOverReason: "",
    );
    _ref.read(screenProvider.notifier).state = AppScreen.inGame;
  }

  // ==========================================
  // ENDLOS-MODUS STARTEN (INKL. STÖRUNGEN)
  // ==========================================
  void startFreeplay(GameMode mode) {
    final unlockedLines = _ref.read(progressProvider).unlockedLines;
    
    // 1. Hole alle Verbindungen, die der Spieler befahren darf
    List<Connection> validConnections = [];
    _repository.graph.adjacencyList.values.forEach((connections) {
      validConnections.addAll(connections.where((c) => unlockedLines.contains(c.lineName)));
    });

    if (validConnections.isEmpty) return;

    String startName = validConnections[_random.nextInt(validConnections.length)].fromStation;
    String targetName = "";
    RouteResult benchmark = RouteResult([], 0);
    
    // 2. Suche ein Ziel, das mindestens 10 Minuten entfernt ist
    int attempts = 0;
    while (benchmark.totalTime < 10 && attempts < 50) {
      targetName = validConnections[_random.nextInt(validConnections.length)].toStation;
      if (startName != targetName) {
        benchmark = _repository.graph.findShortestPath(startName, targetName, allowedLines: unlockedLines);
      }
      attempts++;
    }

    // 3. Störungen generieren (nur im realistischen Modus)
    List<Disruption> disruptions = [];
    if (mode == GameMode.freeplayRealistic) {
      int disruptionCount = _random.nextInt(2) + 1; 
      for (int i = 0; i < disruptionCount; i++) {
        // Platziere die Störung gemeinerweise direkt auf dem idealen Pfad!
        if (benchmark.path.length > 2) {
          int edgeIndex = _random.nextInt(benchmark.path.length - 1);
          String dFrom = benchmark.path[edgeIndex];
          String dTo = benchmark.path[edgeIndex + 1];
          final edgeLine = _repository.graph.adjacencyList[dFrom]?.firstWhere((c) => c.toStation == dTo).lineName ?? "";
          
          disruptions.add(Disruption(
            fromStation: dFrom, 
            toStation: dTo, 
            lineName: edgeLine, 
            description: "Notarzteinsatz zw. $dFrom und $dTo!"
          ));
        }
      }
      // Benchmark MIT den Störungen neu berechnen (Dijkstra plant Umleitung)
      benchmark = _repository.graph.findShortestPath(startName, targetName, allowedLines: unlockedLines, disruptions: disruptions);
    }

    final freeplayMission = Mission(
      id: 'freeplay_${DateTime.now().millisecondsSinceEpoch}',
      title: mode == GameMode.freeplayRealistic ? "Berufsverkehr" : "Entspannte Schicht",
      startStation: startName,
      targetStation: targetName,
      description: "Zufällig generierte Route.",
      requiredLevel: 0,
    );

    _ref.read(audioServiceProvider).playSfx('train_door.wav');

    state = state.copyWith(
      phase: GamePhase.briefing,
      gameMode: mode,
      currentMission: freeplayMission,
      startStation: _repository.graph.stations[startName],
      targetStation: _repository.graph.stations[targetName],
      optimalTime: benchmark.totalTime,
      currentStation: _repository.graph.stations[startName],
      currentLine: null,
      timeElapsed: 0,
      traveledPath: [startName],
      activeDisruptions: disruptions,
      isGameWon: false,
      stars: 0,
      earnedCoins: 0,
      gameOverReason: "",
    );
    
    _ref.read(screenProvider.notifier).state = AppScreen.inGame;
  }

  // ==========================================
  // FAHR-LOGIK & KANTEN-PRÜFUNG
  // ==========================================
  void chooseLineAndMove(String lineName, String nextStationName) {
    // SECURITY CHECK: Ist die Strecke gesperrt?
    bool isBlocked = state.activeDisruptions.any((d) => d.affects(state.currentStation!.name, nextStationName, lineName));
    if (isBlocked) {
      _ref.read(audioServiceProvider).playSfx('fail.wav');
      return; 
    }

    final connections = _repository.graph.adjacencyList[state.currentStation!.name] ?? [];
    Connection? selectedConnection;
    for (var conn in connections) {
      if (conn.toStation == nextStationName && conn.lineName == lineName) {
        selectedConnection = conn;
        break;
      }
    }
    if (selectedConnection == null) return;

    _activeConnection = selectedConnection;
    state = state.copyWith(phase: GamePhase.moving, currentLine: lineName);
  }

  // ==========================================
  // ANKUNFT AM BAHNHOF & PAYOUT
  // ==========================================
  void arriveAtStation() {
    if (_activeConnection == null || state.phase != GamePhase.moving) return;

    final connection = _activeConnection!;
    _activeConnection = null;

    final arrivedStation = _repository.graph.stations[connection.toStation]!;
    final newPath = List<String>.from(state.traveledPath)..add(arrivedStation.name);
    final newTime = state.timeElapsed + connection.travelTime;

    // 1. ZIEL ERREICHT? -> PAYOUT BERECHNEN
    if (arrivedStation.name == state.targetStation!.name) {
      int earnedStars = 0;
      if (newTime <= state.optimalTime) {
        earnedStars = 3;
      } else if (newTime <= state.optimalTime * 1.50) {
        earnedStars = 2;
      } else if (newTime <= state.optimalTime * 2.00) {
        earnedStars = 1;
      }

      if (earnedStars > 0) {
        int payout = 0;
        
        if (state.gameMode == GameMode.campaign) {
          final previousBest = _ref.read(progressProvider).missionStars[state.currentMission!.id] ?? 0;
          if (earnedStars > previousBest) {
            payout = (earnedStars - previousBest) * 250; // Belohnung für Fortschritt
          } else {
            payout = 50; // Grind-Trostpreis
          }
        } else if (state.gameMode == GameMode.freeplayEasy) {
          payout = 150; 
        } else if (state.gameMode == GameMode.freeplayRealistic) {
          payout = 500; // High Risk, High Reward!
        }

        if (state.gameMode == GameMode.campaign) {
          _ref.read(progressProvider.notifier).saveStarsAndCoins(state.currentMission!.id, earnedStars, payout);
        } else {
          // Im Freeplay speichern wir keine Sterne, nur Coins!
          _ref.read(progressProvider.notifier).saveStarsAndCoins('dummy', 0, payout);
        }
        
        _ref.read(audioServiceProvider).playSfx('success.wav');
        state = state.copyWith(phase: GamePhase.gameOver, currentStation: arrivedStation, timeElapsed: newTime, traveledPath: newPath, isGameWon: true, stars: earnedStars, earnedCoins: payout, gameOverReason: "Ziel erreicht! Tolle Leistung.");
      } else {
        _ref.read(audioServiceProvider).playSfx('fail.wav');
        state = state.copyWith(phase: GamePhase.gameOver, currentStation: arrivedStation, timeElapsed: newTime, traveledPath: newPath, isGameWon: false, stars: 0, earnedCoins: 0, gameOverReason: "Du warst viel zu langsam!");
      }
      return;
    }

    // 2. ZEITLIMIT GERISSEN?
    if (newTime > state.optimalTime * 2.00) {
      _ref.read(audioServiceProvider).playSfx('fail.wav');
      state = state.copyWith(phase: GamePhase.gameOver, currentStation: arrivedStation, timeElapsed: newTime, traveledPath: newPath, isGameWon: false, stars: 0, earnedCoins: 0, gameOverReason: "Zeitlimit massiv überschritten. Schicht abgebrochen.");
      return;
    }

    // 3. WEITERFAHREN ODER UMSTEIGEN? (DER AUTO-CONTINUE FIX)
    final availableConnections = _repository.graph.adjacencyList[arrivedStation.name] ?? [];
    String previousStationName = state.currentStation!.name;
    
    // Checke NUR Linien, die der Spieler auch freigeschaltet hat!
    final unlockedLines = _ref.read(progressProvider).unlockedLines;
    final forwardConnections = availableConnections.where((c) => 
        c.toStation != previousStationName && 
        unlockedLines.contains(c.lineName)
    ).toList();

    bool canStayOnCurrentLine = forwardConnections.any((c) => c.lineName == state.currentLine);
    bool hasOtherLines = forwardConnections.any((c) => c.lineName != state.currentLine);

    // Echte Sackgasse erreicht
    if (!canStayOnCurrentLine && !hasOtherLines) {
      _ref.read(audioServiceProvider).playSfx('fail.wav');
      state = state.copyWith(phase: GamePhase.gameOver, currentStation: arrivedStation, timeElapsed: newTime, traveledPath: newPath, isGameWon: false, stars: 0, earnedCoins: 0, gameOverReason: "SACKGASSE!");
      return;
    }

    // Wir MÜSSEN oder KÖNNEN umsteigen -> Menü öffnen
    if (hasOtherLines || !canStayOnCurrentLine) {
      _ref.read(audioServiceProvider).playSfx('train_door.wav');
      state = state.copyWith(phase: GamePhase.decisionPending, currentStation: arrivedStation, timeElapsed: newTime, traveledPath: newPath);
    } 
    // AUTO-CONTINUE: Es gibt nur die aktuelle Linie -> Fahr einfach durch!
    else {
      Connection? nextConn;
      for (var conn in forwardConnections) {
        if (conn.lineName == state.currentLine) {
          nextConn = conn;
          break;
        }
      }
      if (nextConn != null) {
        _activeConnection = nextConn;
        state = state.copyWith(currentStation: arrivedStation, timeElapsed: newTime, traveledPath: newPath, phase: GamePhase.moving);
      }
    }
  }
}