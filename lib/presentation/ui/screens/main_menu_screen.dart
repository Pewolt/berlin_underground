import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/screen_provider.dart';
import '../../state/progress_provider.dart';
import '../../state/audio_provider.dart';
import '../../state/game_provider.dart';
import '../../state/game_state.dart'; 
import '../../../domain/models/mission.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressState = ref.watch(progressProvider);
    final playerLevel = progressState.playerLevel;
    final totalStars = progressState.missionStars.values.fold(0, (sum, stars) => sum + stars);
    final playerCoins = progressState.coins; // NEU

    final isMusicOn = ref.watch(musicEnabledProvider);
    final isSoundOn = ref.watch(soundEnabledProvider);
    final activeDialog = ref.watch(dialogProvider);

    return Container(
      color: const Color(0xFF1E1E2C).withOpacity(0.7), 
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 24, left: 32, 
              child: GestureDetector(
                onTap: () => ref.read(dialogProvider.notifier).state = MenuDialog.levelProgress,
                child: _buildProfileBadge(playerLevel, totalStars)
              )
            ),
            Positioned(
              top: 24, right: 32,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // NEU: DIE TOKEN-ANZEIGE
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFF2B2D42), borderRadius: BorderRadius.circular(30), border: Border.all(color: const Color(0xFFFFD166), width: 2), boxShadow: const [BoxShadow(color: Colors.black45, offset: Offset(0, 4), blurRadius: 6)]),
                    child: Row(
                      children: [
                        const Icon(Icons.generating_tokens_rounded, color: Color(0xFFFFD166), size: 24),
                        const SizedBox(width: 8),
                        Text(playerCoins.toString(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 18, letterSpacing: 1)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  _RoundIconButton(icon: isMusicOn ? Icons.music_note : Icons.music_off, color: isMusicOn ? const Color(0xFF80ED99) : Colors.grey, onPressed: () => ref.read(musicEnabledProvider.notifier).state = !isMusicOn),
                  const SizedBox(width: 16),
                  _RoundIconButton(icon: isSoundOn ? Icons.volume_up : Icons.volume_off, color: isSoundOn ? const Color(0xFF3A86FF) : Colors.grey, onPressed: () => ref.read(soundEnabledProvider.notifier).state = !isSoundOn),
                  const SizedBox(width: 16),
                  _RoundIconButton(icon: Icons.settings, color: const Color(0xFF8D99AE), onPressed: () => ref.read(dialogProvider.notifier).state = MenuDialog.settings),
                ],
              ),
            ),
            Align(
              alignment: const Alignment(0, -0.15), 
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("BERLIN\nUNDERGROUND", textAlign: TextAlign.center, style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1, letterSpacing: 3, shadows: [Shadow(color: Colors.black87, offset: Offset(0, 4), blurRadius: 8)])),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () => ref.read(dialogProvider.notifier).state = MenuDialog.campaign,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF80ED99), Color(0xFF38B000)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                        borderRadius: BorderRadius.circular(40), 
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [BoxShadow(color: Color(0xFF22577A), offset: Offset(0, 6)), BoxShadow(color: Colors.black45, offset: Offset(0, 10), blurRadius: 10)],
                      ),
                      child: const Text("SPIEL STARTEN", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF2B2D42), letterSpacing: 2)),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Wrap(
                  spacing: 24,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildBottomCard(icon: Icons.map_rounded, title: "KAMPAGNE", color: const Color(0xFF3A86FF), onPressed: () => ref.read(dialogProvider.notifier).state = MenuDialog.campaign, isLocked: false),
                    _buildBottomCard(icon: Icons.shopping_cart_rounded, title: "BETRIEBSHOF", color: const Color(0xFF9B5DE5), onPressed: () => ref.read(dialogProvider.notifier).state = MenuDialog.collection, isLocked: false),
                    _buildBottomCard(icon: Icons.access_time_filled_rounded, title: "SCHICHTEN", color: const Color(0xFFFFD166), onPressed: () => ref.read(dialogProvider.notifier).state = MenuDialog.endless, isLocked: false),
                  ],
                ),
              ),
            ),
            if (activeDialog != MenuDialog.none) ...[
              GestureDetector(onTap: () => ref.read(dialogProvider.notifier).state = MenuDialog.none, child: Container(color: Colors.black87.withOpacity(0.6))),
              Center(child: _getDialogWidget(activeDialog)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _getDialogWidget(MenuDialog dialog) {
    switch (dialog) {
      case MenuDialog.campaign: return const _CampaignDialog();
      case MenuDialog.collection: return const _CollectionDialog();
      case MenuDialog.settings: return const _SettingsDialog();
      case MenuDialog.endless: return const _EndlessDialog();
      case MenuDialog.levelProgress: return const _LevelProgressDialog(); 
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildProfileBadge(int level, int stars) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFF2B2D42), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white24, width: 2), boxShadow: const [BoxShadow(color: Colors.black45, offset: Offset(0, 4), blurRadius: 6)]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(backgroundColor: const Color(0xFF80ED99), radius: 18, child: Text(level.toString(), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2B2D42), fontSize: 18))),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Praktikant", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFD166), size: 14),
                  const SizedBox(width: 4),
                  Text(stars.toString(), style: const TextStyle(color: Color(0xFFFFD166), fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCard({required IconData icon, required String title, required Color color, required VoidCallback onPressed, required bool isLocked}) {
    return GestureDetector(
      onTap: isLocked ? null : onPressed,
      child: Opacity(
        opacity: isLocked ? 0.6 : 1.0,
        child: Container(
          width: 140, padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: const Color(0xFF2B2D42), borderRadius: BorderRadius.circular(20), border: Border.all(color: color, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), offset: const Offset(0, 4), blurRadius: 6)]),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: color, size: 32), const SizedBox(height: 6), Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1))]),
              if (isLocked) Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.lock_rounded, color: Colors.white, size: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  const _RoundIconButton({required this.icon, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), offset: const Offset(0, 4), blurRadius: 4)]),
        child: Icon(icon, color: const Color(0xFF2B2D42), size: 24),
      ),
    );
  }
}

class _GameDialog extends StatelessWidget {
  final String title;
  final Widget content;
  const _GameDialog({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double dialogWidth = screenWidth > 800 ? 700 : screenWidth * 0.9;
    final double dialogHeight = screenHeight * 0.85;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: dialogWidth, height: dialogHeight,
        decoration: BoxDecoration(color: const Color(0xFFEDF2F4), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white, width: 4), boxShadow: const [BoxShadow(color: Colors.black54, offset: Offset(0, 16), blurRadius: 24)]),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(color: Color(0xFF2B2D42), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 32),
                  Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5)),
                  Consumer(
                    builder: (context, ref, _) => GestureDetector(
                      onTap: () => ref.read(dialogProvider.notifier).state = MenuDialog.none, 
                      child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle), child: const Icon(Icons.close_rounded, color: Colors.white, size: 24)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }
}

// --- RESTLICHE DIALOGE (Unverändert, bis auf EndlessDialog) ---
class _LevelProgressDialog extends ConsumerWidget {
  const _LevelProgressDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerLevel = ref.watch(progressProvider).playerLevel;

    return _GameDialog(
      title: "KARRIERE-FORTSCHRITT",
      content: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
        itemCount: 30, 
        itemBuilder: (context, index) {
          final level = index + 1;
          final isReached = playerLevel >= level;
          final isCurrent = playerLevel == level;
          final hasReward = levelRewards.containsKey(level);
          
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(top: 0, bottom: 0, child: Container(width: 4, color: isReached ? const Color(0xFF80ED99) : Colors.grey[300])),
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCurrent ? const Color(0xFFFFD166) : (isReached ? const Color(0xFF80ED99) : const Color(0xFFEDF2F4)),
                          border: Border.all(color: isCurrent || isReached ? const Color(0xFF2B2D42) : Colors.grey, width: 3),
                          boxShadow: isCurrent ? [const BoxShadow(color: Colors.amber, blurRadius: 8)] : [],
                        ),
                        child: Center(child: Text(level.toString(), style: TextStyle(fontWeight: FontWeight.w900, color: isCurrent || isReached ? const Color(0xFF2B2D42) : Colors.grey[500]))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0), 
                    child: Container(
                      decoration: BoxDecoration(
                        color: isReached ? Colors.white : Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isReached ? Colors.black12 : Colors.transparent, width: 2),
                        boxShadow: isReached ? const [BoxShadow(color: Colors.black12, offset: Offset(0, 4), blurRadius: 6)] : null,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: hasReward 
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: levelRewards[level]!.map((reward) {
                              if (reward.startsWith('U') && reward.length <= 2) {
                                final color = uBahnColors[reward] ?? Colors.grey;
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      margin: const EdgeInsets.only(bottom: 4),
                                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                                      child: Text(reward, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                                    ),
                                    const SizedBox(width: 8),
                                    Text("Lizenz freigeschaltet", style: TextStyle(fontWeight: FontWeight.bold, color: isReached ? Colors.black87 : Colors.grey)),
                                  ],
                                );
                              } else if (reward.startsWith('MODUS:')) {
                                return Row(
                                  children: [
                                    Icon(Icons.gamepad_rounded, color: isReached ? const Color(0xFF3A86FF) : Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(reward.replaceAll('MODUS: ', ''), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isReached ? const Color(0xFF3A86FF) : Colors.grey)),
                                  ],
                                );
                              }
                              return Text(reward, style: TextStyle(fontWeight: FontWeight.bold, color: isReached ? Colors.black87 : Colors.grey));
                            }).toList(),
                          )
                        : Row(
                            children: [
                              Icon(Icons.card_giftcard_rounded, color: Colors.grey[400]),
                              const SizedBox(width: 8),
                              Text("Zukünftige Belohnung", style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
                            ],
                          ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CampaignDialog extends ConsumerWidget {
  const _CampaignDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressState = ref.watch(progressProvider);
    final progressStars = progressState.missionStars;
    final playerLevel = progressState.playerLevel;

    return _GameDialog(
      title: "SCHICHTPLAN",
      content: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: campaignMissions.length,
        itemBuilder: (context, index) {
          final mission = campaignMissions[index];
          final stars = progressStars[mission.id] ?? 0;
          final isPreviousDone = index == 0 || (progressStars[campaignMissions[index - 1].id] ?? 0) > 0;
          final hasRequiredLevel = playerLevel >= mission.requiredLevel;
          final isUnlocked = isPreviousDone && hasRequiredLevel;

          return Card(
            margin: const EdgeInsets.only(bottom: 16), elevation: isUnlocked ? 4 : 0, color: isUnlocked ? Colors.white : Colors.grey[300], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              title: Text(mission.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isUnlocked ? const Color(0xFF2B2D42) : Colors.grey)),
              subtitle: Padding(padding: const EdgeInsets.only(top: 4.0), child: Text("${mission.startStation} ➔ ${mission.targetStation}", style: TextStyle(color: isUnlocked ? Colors.black87 : Colors.grey, fontWeight: FontWeight.bold))),
              trailing: isUnlocked 
                ? Row(mainAxisSize: MainAxisSize.min, children: [...List.generate(3, (i) => Icon(i < stars ? Icons.star_rounded : Icons.star_outline_rounded, color: const Color(0xFFFFD166), size: 24)), const SizedBox(width: 16), const Icon(Icons.play_circle_fill, color: Color(0xFF80ED99), size: 40)])
                : Row(mainAxisSize: MainAxisSize.min, children: [if (!hasRequiredLevel && isPreviousDone) Text("Benötigt Level ${mission.requiredLevel}  ", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), const Icon(Icons.lock, color: Colors.black26, size: 36)]),
              onTap: isUnlocked ? () {
                ref.read(dialogProvider.notifier).state = MenuDialog.none;
                ref.read(gameProvider.notifier).startMission(mission);
              } : null,
            ),
          );
        },
      ),
    );
  }
}

// FIX: BEIDE KARTEN ZEIGEN JETZT IHREN SPERR-STATUS AN
class _EndlessDialog extends ConsumerWidget {
  const _EndlessDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerLevel = ref.watch(progressProvider).playerLevel;
    final isEasyUnlocked = playerLevel >= 20; 
    final isRealisticUnlocked = playerLevel >= 25; 

    return _GameDialog(
      title: "SCHICHT-AUSWAHL",
      content: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Row(
          children: [
            // Linke Karte: ENTSPANNT (Gesperrt bis Level 20)
            Expanded(
              child: GestureDetector(
                onTap: isEasyUnlocked ? () {
                  ref.read(dialogProvider.notifier).state = MenuDialog.none;
                  ref.read(gameProvider.notifier).startFreeplay(GameMode.freeplayEasy);
                } : null,
                child: Opacity(
                  opacity: isEasyUnlocked ? 1.0 : 0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF3A86FF), width: 4),
                      boxShadow: const [BoxShadow(color: Colors.black12, offset: Offset(0, 8), blurRadius: 12)],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.coffee_rounded, size: 80, color: Color(0xFF3A86FF)),
                            SizedBox(height: 16),
                            Text("ENTSPANNTE\nSCHICHT", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF2B2D42))),
                            SizedBox(height: 8),
                            Text("Zufällige Route.\nKeine Störungen.\nIdeal zum Netz-Lernen.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        if (!isEasyUnlocked)
                          Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle), child: const Icon(Icons.lock_rounded, color: Colors.white, size: 48)),
                        if (!isEasyUnlocked)
                          const Positioned(bottom: 24, child: Text("Wird auf Level 20 freigeschaltet", style: TextStyle(color: Color(0xFF3A86FF), fontWeight: FontWeight.w900)))
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 32),
            // Rechte Karte: REALISTISCH (Gesperrt bis Level 25)
            Expanded(
              child: GestureDetector(
                onTap: isRealisticUnlocked ? () {
                  ref.read(dialogProvider.notifier).state = MenuDialog.none;
                  ref.read(gameProvider.notifier).startFreeplay(GameMode.freeplayRealistic);
                } : null,
                child: Opacity(
                  opacity: isRealisticUnlocked ? 1.0 : 0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFFF595E), width: 4),
                      boxShadow: const [BoxShadow(color: Colors.black12, offset: Offset(0, 8), blurRadius: 12)],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning_amber_rounded, size: 80, color: Color(0xFFFF595E)),
                            SizedBox(height: 16),
                            Text("BERUFSVERKEHR\n(REALISMUS)", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF2B2D42))),
                            SizedBox(height: 8),
                            Text("Sperrungen und Chaos.\nDer Dijkstra muss umplanen.\nNur für Profis.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        if (!isRealisticUnlocked)
                          Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle), child: const Icon(Icons.lock_rounded, color: Colors.white, size: 48)),
                        if (!isRealisticUnlocked)
                          const Positioned(bottom: 24, child: Text("Wird auf Level 25 freigeschaltet", style: TextStyle(color: Color(0xFFFF595E), fontWeight: FontWeight.w900)))
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsDialog extends ConsumerWidget {
  const _SettingsDialog();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _GameDialog(
      title: "EINSTELLUNGEN",
      content: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const Icon(Icons.settings_suggest_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 24),
            const Text("Audio-Feineinstellungen und Grafik-Optionen werden in Kürze hinzugefügt.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B2D42))),
            const Spacer(),
            TextButton.icon(onPressed: () {}, icon: const Icon(Icons.delete_forever, color: Colors.red), label: const Text("Fortschritt zurücksetzen", style: TextStyle(color: Colors.red)))
          ],
        ),
      ),
    );
  }
}

class _CollectionDialog extends ConsumerWidget {
  const _CollectionDialog();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressState = ref.watch(progressProvider);
    final unlockedLines = progressState.unlockedLines;
    final purchasedSkins = progressState.purchasedSkins;
    final activeSkin = progressState.activeSkin;
    final playerCoins = progressState.coins;
    final allLines = uBahnColors.keys.toList()..sort();
    
    return _GameDialog(
      title: "BETRIEBSHOF",
      content: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("LIZENZEN & LINIEN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2B2D42))),
            const SizedBox(height: 12),
            Expanded(
              flex: 2,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, childAspectRatio: 2.0, crossAxisSpacing: 12, mainAxisSpacing: 12),
                itemCount: allLines.length,
                itemBuilder: (context, index) {
                  final line = allLines[index];
                  final isUnlocked = unlockedLines.contains(line);
                  final trueColor = uBahnColors[line]!;
                  final displayColor = isUnlocked ? trueColor : trueColor.withOpacity(0.15);
                  return Container(
                    decoration: BoxDecoration(color: displayColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: isUnlocked ? Colors.white : trueColor.withOpacity(0.3), width: 2)),
                    alignment: Alignment.center,
                    child: Text(line, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: isUnlocked ? Colors.white : trueColor.withOpacity(0.6))),
                  );
                },
              ),
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("FUHRPARK (SHOP)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2B2D42))),
                Row(
                  children: [
                    const Icon(Icons.generating_tokens_rounded, color: Color(0xFFFFD166)),
                    const SizedBox(width: 4),
                    Text(playerCoins.toString(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF2B2D42))),
                  ],
                )
              ],
            ),
            const SizedBox(height: 12),
            // SHOP-LISTE
            Expanded(
              flex: 3,
              child: ListView.builder(
                itemCount: availableSkins.length,
                itemBuilder: (context, index) {
                  final skin = availableSkins[index];
                  final isOwned = purchasedSkins.contains(skin.id);
                  final isEquipped = activeSkin == skin.id;
                  final canAfford = playerCoins >= skin.price;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isEquipped ? const Color(0xFFE8F5E9) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isEquipped ? const Color(0xFF80ED99) : Colors.black12, width: isEquipped ? 3 : 2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: skin.primaryColor, shape: BoxShape.circle, border: Border.all(color: skin.secondaryColor, width: 2)),
                          child: Icon(skin.icon, color: skin.secondaryColor, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(skin.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF2B2D42))),
                              Text(skin.description, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        // DER ACTION BUTTON (KAUFEN Oder AUSRÜSTEN)
                        if (isEquipped)
                          const Icon(Icons.check_circle, color: Color(0xFF80ED99), size: 36)
                        else if (isOwned)
                          ElevatedButton(
                            onPressed: () => ref.read(progressProvider.notifier).equipSkin(skin.id),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3A86FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                            child: const Text("AUSRÜSTEN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          )
                        else
                          ElevatedButton.icon(
                            onPressed: canAfford ? () => ref.read(progressProvider.notifier).buySkin(skin.id, skin.price) : null,
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD166), disabledBackgroundColor: Colors.grey[300], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                            icon: Icon(Icons.shopping_cart, size: 16, color: canAfford ? const Color(0xFF2B2D42) : Colors.grey),
                            label: Text("${skin.price}", style: TextStyle(fontWeight: FontWeight.w900, color: canAfford ? const Color(0xFF2B2D42) : Colors.grey)),
                          )
                      ],
                    ),
                  );
                }
              ),
            )
          ],
        ),
      ),
    );
  }
}