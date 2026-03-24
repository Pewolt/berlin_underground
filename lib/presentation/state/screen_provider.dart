import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppScreen {
  mainMenu,
  inGame,
}

enum MenuDialog {
  none,
  campaign,
  settings,
  collection,
  endless,
  levelProgress,
}

final screenProvider = StateProvider<AppScreen>((ref) => AppScreen.mainMenu);
final dialogProvider = StateProvider<MenuDialog>((ref) => MenuDialog.none);