import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

const Map<String, Color> uBahnColors = {
  'U1': Color(0xFF79B928), 'U2': Color(0xFFDF4C36), 'U3': Color(0xFF00874F),
  'U4': Color(0xFFF6D600), 'U5': Color(0xFF7A4F2A), 'U6': Color(0xFF8C6DAB),
  'U7': Color(0xFF3D91C8), 'U8': Color(0xFF005F9A), 'U9': Color(0xFFF08C00),
};

const Map<int, List<String>> levelRewards = {
  1: ['U6'], 2: ['U7'], 3: ['U1'], 5: ['U2'], 10: ['U8'], 15: ['U9'], 
  20: ['U3', 'MODUS: Entspannte Schicht'], 25: ['U4', 'MODUS: Berufsverkehr'], 30: ['U5'],
};

// ==========================================
// NEU: DAS SHOP-INVENTAR (SKINS)
// ==========================================
class TrainSkin {
  final String id;
  final String name;
  final String description;
  final int price;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;

  const TrainSkin({required this.id, required this.name, required this.description, required this.price, required this.primaryColor, required this.secondaryColor, required this.icon});
}

const List<TrainSkin> availableSkins = [
  TrainSkin(id: 'default', name: 'Baureihe F (Standard)', description: 'Ikonisch, gelb, zuverlässig.', price: 0, primaryColor: Color(0xFFF6D600), secondaryColor: Color(0xFF2B2D42), icon: Icons.directions_subway_rounded),
  TrainSkin(id: 'ddr_gi', name: 'Baureihe GI (Klassiker)', description: 'Ostalgie pur. Silber mit rotem Streifen.', price: 1500, primaryColor: Color(0xFFD00000), secondaryColor: Color(0xFFE0E0E0), icon: Icons.train_rounded),
  TrainSkin(id: 'modern_ik', name: 'Baureihe IK (Modern)', description: 'Hell, leise, geräumig.', price: 4000, primaryColor: Colors.white, secondaryColor: Colors.grey, icon: Icons.tram_rounded),
  TrainSkin(id: 'cyber', name: 'Neon-Express', description: 'Für die echten Nachtschichten.', price: 10000, primaryColor: Color(0xFF39FF14), secondaryColor: Colors.black, icon: Icons.electric_bolt_rounded),
];

class ProgressState {
  final Map<String, int> missionStars;
  final int playerLevel;
  final Set<String> unlockedLines;
  final bool isFreePlayUnlocked;
  final List<String> newlyUnlockedItems;
  
  // NEU: Economy
  final int coins;
  final List<String> purchasedSkins;
  final String activeSkin;

  ProgressState({
    required this.missionStars,
    required this.playerLevel,
    required this.unlockedLines,
    required this.isFreePlayUnlocked,
    this.newlyUnlockedItems = const [],
    required this.coins,
    required this.purchasedSkins,
    required this.activeSkin,
  });
}

final progressProvider = StateNotifierProvider<ProgressController, ProgressState>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return ProgressController(prefs);
});

class ProgressController extends StateNotifier<ProgressState> {
  final SharedPreferences _prefs;

  ProgressController(this._prefs) : super(_loadInitial(_prefs));

  static ProgressState _loadInitial(SharedPreferences prefs) {
    final Map<String, int> initialStars = {};
    int totalStars = 0;
    
    for (var key in prefs.getKeys()) {
      if (key.startsWith('mission_stars_')) {
        final missionId = key.replaceFirst('mission_stars_', '');
        final stars = prefs.getInt(key) ?? 0;
        initialStars[missionId] = stars;
        totalStars += stars;
      }
    }
    
    final level = (totalStars / 3).floor() + 1;
    
    return ProgressState(
      missionStars: initialStars,
      playerLevel: level,
      unlockedLines: _calculateUnlockedLines(level),
      isFreePlayUnlocked: level >= 20,
      coins: prefs.getInt('player_coins') ?? 0,
      purchasedSkins: prefs.getStringList('purchased_skins') ?? ['default'],
      activeSkin: prefs.getString('active_skin') ?? 'default',
    );
  }

  static Set<String> _calculateUnlockedLines(int level) {
    final Set<String> lines = {};
    levelRewards.forEach((reqLevel, rewards) {
      if (level >= reqLevel) lines.addAll(rewards.where((r) => r.startsWith('U') && r.length <= 2));
    });
    return lines;
  }

  void saveStarsAndCoins(String missionId, int stars, int earnedCoins) {
    final currentBest = state.missionStars[missionId] ?? 0;
    Map<String, int> newStars = Map.from(state.missionStars);
    int newLevel = state.playerLevel;
    List<String> unlockedJustNow = [];

    if (stars > currentBest) {
      _prefs.setInt('mission_stars_$missionId', stars);
      newStars[missionId] = stars;
      int totalStars = newStars.values.fold(0, (a, b) => a + b);
      newLevel = (totalStars / 3).floor() + 1;

      if (newLevel > state.playerLevel) {
        for (int l = state.playerLevel + 1; l <= newLevel; l++) {
          if (levelRewards.containsKey(l)) unlockedJustNow.addAll(levelRewards[l]!);
        }
      }
    }

    final newCoins = state.coins + earnedCoins;
    _prefs.setInt('player_coins', newCoins);

    state = ProgressState(
      missionStars: newStars,
      playerLevel: newLevel,
      unlockedLines: _calculateUnlockedLines(newLevel),
      isFreePlayUnlocked: newLevel >= 20,
      newlyUnlockedItems: unlockedJustNow, 
      coins: newCoins,
      purchasedSkins: state.purchasedSkins,
      activeSkin: state.activeSkin,
    );
  }

  // SHOP LOGIK
  bool buySkin(String skinId, int price) {
    if (state.coins >= price && !state.purchasedSkins.contains(skinId)) {
      final newCoins = state.coins - price;
      final newSkins = List<String>.from(state.purchasedSkins)..add(skinId);
      
      _prefs.setInt('player_coins', newCoins);
      _prefs.setStringList('purchased_skins', newSkins);
      _prefs.setString('active_skin', skinId); // Direkt ausrüsten

      state = ProgressState(
        missionStars: state.missionStars, playerLevel: state.playerLevel, unlockedLines: state.unlockedLines, isFreePlayUnlocked: state.isFreePlayUnlocked, newlyUnlockedItems: state.newlyUnlockedItems,
        coins: newCoins, purchasedSkins: newSkins, activeSkin: skinId,
      );
      return true;
    }
    return false;
  }

  void equipSkin(String skinId) {
    if (state.purchasedSkins.contains(skinId)) {
      _prefs.setString('active_skin', skinId);
      state = ProgressState(
        missionStars: state.missionStars, playerLevel: state.playerLevel, unlockedLines: state.unlockedLines, isFreePlayUnlocked: state.isFreePlayUnlocked, newlyUnlockedItems: state.newlyUnlockedItems,
        coins: state.coins, purchasedSkins: state.purchasedSkins, activeSkin: skinId,
      );
    }
  }

  void clearNewlyUnlocked() {
    if (state.newlyUnlockedItems.isNotEmpty) {
      state = ProgressState(
        missionStars: state.missionStars, playerLevel: state.playerLevel, unlockedLines: state.unlockedLines, isFreePlayUnlocked: state.isFreePlayUnlocked, newlyUnlockedItems: const [],
        coins: state.coins, purchasedSkins: state.purchasedSkins, activeSkin: state.activeSkin,
      );
    }
  }
}