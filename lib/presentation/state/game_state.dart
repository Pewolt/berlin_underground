import '../../domain/models/station.dart';
import '../../domain/models/mission.dart';
import '../../domain/models/disruption.dart';

enum GamePhase { idle, briefing, moving, decisionPending, gameOver }
enum GameMode { campaign, freeplayEasy, freeplayRealistic }

class GameState {
  final GamePhase phase;
  final GameMode gameMode; 
  
  final Mission? currentMission; 
  final Station? startStation;
  final Station? targetStation;
  final int optimalTime; 
  
  final Station? currentStation;
  final String? currentLine;
  final int timeElapsed; 
  final List<String> traveledPath;
  final List<Disruption> activeDisruptions;

  final bool isGameWon;
  final int stars;
  final int earnedCoins; // NEU: Payout am Ende der Runde
  final String gameOverReason; 

  GameState({
    this.phase = GamePhase.idle,
    this.gameMode = GameMode.campaign,
    this.currentMission,
    this.startStation,
    this.targetStation,
    this.optimalTime = 0,
    this.currentStation,
    this.currentLine,
    this.timeElapsed = 0,
    this.traveledPath = const [],
    this.activeDisruptions = const [],
    this.isGameWon = false,
    this.stars = 0,
    this.earnedCoins = 0,
    this.gameOverReason = "",
  });

  GameState copyWith({
    GamePhase? phase, GameMode? gameMode, Mission? currentMission, Station? startStation, Station? targetStation,
    int? optimalTime, Station? currentStation, String? currentLine, int? timeElapsed, List<String>? traveledPath,
    List<Disruption>? activeDisruptions, bool? isGameWon, int? stars, int? earnedCoins, String? gameOverReason,
  }) {
    return GameState(
      phase: phase ?? this.phase, gameMode: gameMode ?? this.gameMode, currentMission: currentMission ?? this.currentMission,
      startStation: startStation ?? this.startStation, targetStation: targetStation ?? this.targetStation,
      optimalTime: optimalTime ?? this.optimalTime, currentStation: currentStation ?? this.currentStation, currentLine: currentLine ?? this.currentLine,
      timeElapsed: timeElapsed ?? this.timeElapsed, traveledPath: traveledPath ?? this.traveledPath, activeDisruptions: activeDisruptions ?? this.activeDisruptions,
      isGameWon: isGameWon ?? this.isGameWon, stars: stars ?? this.stars, earnedCoins: earnedCoins ?? this.earnedCoins, gameOverReason: gameOverReason ?? this.gameOverReason,
    );
  }
}