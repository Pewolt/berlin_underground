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
    final playerCoins = progressState.coins;

    final isMusicOn = ref.watch(musicEnabledProvider);
    final isSoundOn = ref.watch(soundEnabledProvider);
    final activeDialog = ref.watch(dialogProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: const Color(0xFF1E1E2C).withOpacity(0.7), 
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 16, left: 16, 
              child: GestureDetector(
                onTap: () => ref.read(dialogProvider.notifier).state = MenuDialog.levelProgress,
                child: _buildProfileBadge(playerLevel, totalStars)
              )
            ),
            // Oben rechts: Responsiv, blendet auf sehr kleinen Bildschirmen die Token aus (oder bricht um)
            Positioned(
              top: 16, right: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (screenWidth > 350) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: const Color(0xFF2B2D42), borderRadius: BorderRadius.circular(30), border: Border.all(color: const Color(0xFFFFD166), width: 2), boxShadow: const [BoxShadow(color: Colors.black45, offset: Offset(0, 4), blurRadius: 6)]),
                      child: Row(
                        children: [
                          const Icon(Icons.generating_tokens_rounded, color: Color(0xFFFFD166), size: 20),
                          const SizedBox(width: 6),
                          Text(playerCoins.toString(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16, letterSpacing: 1)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  _RoundIconButton(icon: isMusicOn ? Icons.music_note : Icons.music_off, color: isMusicOn ? const Color(0xFF80ED99) : Colors.grey, onPressed: () => ref.read(musicEnabledProvider.notifier).state = !isMusicOn),
                  const SizedBox(width: 8),
                  _RoundIconButton(icon: isSoundOn ? Icons.volume_up : Icons.volume_off, color: isSoundOn ? const Color(0xFF3A86FF) : Colors.grey, onPressed: () => ref.read(soundEnabledProvider.notifier).state = !isSoundOn),
                  const SizedBox(width: 8),
                  _RoundIconButton(icon: Icons.settings, color: const Color(0xFF8D99AE), onPressed: () => ref.read(dialogProvider.notifier).state = MenuDialog.settings),
                ],
              ),
            ),
            Align(
              alignment: const Alignment(0, -0.2), 
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("BERLIN\nUNDERGROUND", textAlign: TextAlign.center, style: TextStyle(fontSize: screenWidth > 600 ? 42 : 32, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1, letterSpacing: 3, shadows: const [Shadow(color: Colors.black87, offset: Offset(0, 4), blurRadius: 8)])),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () => ref.read(dialogProvider.notifier).state = MenuDialog.campaign,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF80ED99), Color(0xFF38B000)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                        borderRadius: BorderRadius.circular(40), 
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [BoxShadow(color: Color(0xFF22577A), offset: Offset(0, 6)), BoxShadow(color: Colors.black45, offset: Offset(0, 10), blurRadius: 10)],
                      ),
                      child: const Text("SPIEL STARTEN", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF2B2D42), letterSpacing: 2)),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0, left: 16, right: 16),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFF2B2D42), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white24, width: 2), boxShadow: const [BoxShadow(color: Colors.black45, offset: Offset(0, 4), blurRadius: 6)]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(backgroundColor: const Color(0xFF80ED99), radius: 16, child: Text(level.toString(), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2B2D42), fontSize: 16))),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Praktikant", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFD166), size: 12),
                  const SizedBox(width: 4),
                  Text(stars.toString(), style: const TextStyle(color: Color(0xFFFFD166), fontWeight: FontWeight.bold, fontSize: 10)),
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
          width: 120, padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: const Color(0xFF2B2D42), borderRadius: BorderRadius.circular(20), border: Border.all(color: color, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), offset: const Offset(0, 4), blurRadius: 6)]),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: color, size: 28), const SizedBox(height: 6), Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1))]),
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
        width: 40, height: 40,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), offset: const Offset(0, 4), blurRadius: 4)]),
        child: Icon(icon, color: const Color(0xFF2B2D42), size: 20),
      ),
    );
  }
}

// FIX: RESPONSIVE GAME DIALOG
// Passt sich der Bildschirmhöhe und -breite flexibel an!
class _GameDialog extends StatelessWidget {
  final String title;
  final Widget content;
  const _GameDialog({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double dialogWidth = size.width > 800 ? 700 : size.width * 0.95;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: dialogWidth, 
          constraints: BoxConstraints(maxHeight: size.height * 0.85), // Max 85% der Bildschirmhöhe
          decoration: BoxDecoration(color: const Color(0xFFEDF2F4), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white, width: 4), boxShadow: const [BoxShadow(color: Colors.black54, offset: Offset(0, 16), blurRadius: 24)]),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Nimmt nur den Platz ein, der gebraucht wird
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: const BoxDecoration(color: Color(0xFF2B2D42), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 32),
                    Expanded(child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5))),
                    Consumer(
                      builder: (context, ref, _) => GestureDetector(
                        onTap: () => ref.read(dialogProvider.notifier).state = MenuDialog.none, 
                        child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle), child: const Icon(Icons.close_rounded, color: Colors.white, size: 20)),
                      ),
                    ),
                  ],
                ),
              ),
              // Flexible übernimmt den Rest des Platzes, macht es scrollbar, wenn nötig
              Flexible(child: content),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelProgressDialog extends ConsumerWidget {
  const _LevelProgressDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerLevel = ref.watch(progressProvider).playerLevel;

    return _GameDialog(
      title: "KARRIERE",
      content: ListView.builder(
        shrinkWrap: true, // Wichtig für flexible Layouts
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
                  width: 50,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(top: 0, bottom: 0, child: Container(width: 4, color: isReached ? const Color(0xFF80ED99) : Colors.grey[300])),
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCurrent ? const Color(0xFFFFD166) : (isReached ? const Color(0xFF80ED99) : const Color(0xFFEDF2F4)),
                          border: Border.all(color: isCurrent || isReached ? const Color(0xFF2B2D42) : Colors.grey, width: 2),
                          boxShadow: isCurrent ? [const BoxShadow(color: Colors.amber, blurRadius: 8)] : [],
                        ),
                        child: Center(child: Text(level.toString(), style: TextStyle(fontWeight: FontWeight.w900, color: isCurrent || isReached ? const Color(0xFF2B2D42) : Colors.grey[500]))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0), 
                    child: Container(
                      decoration: BoxDecoration(
                        color: isReached ? Colors.white : Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isReached ? Colors.black12 : Colors.transparent, width: 2),
                        boxShadow: isReached ? const [BoxShadow(color: Colors.black12, offset: Offset(0, 4), blurRadius: 6)] : null,
                      ),
                      padding: const EdgeInsets.all(12),
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
                                    Expanded(child: Text("Lizenz frei", style: TextStyle(fontWeight: FontWeight.bold, color: isReached ? Colors.black87 : Colors.grey))),
                                  ],
                                );
                              } else if (reward.startsWith('MODUS:')) {
                                return Row(
                                  children: [
                                    Icon(Icons.gamepad_rounded, color: isReached ? const Color(0xFF3A86FF) : Colors.grey),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(reward.replaceAll('MODUS: ', ''), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: isReached ? const Color(0xFF3A86FF) : Colors.grey))),
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
                              Expanded(child: Text("Zukünftige Belohnung", style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic, fontWeight: FontWeight.bold))),
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
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        itemCount: campaignMissions.length,
        itemBuilder: (context, index) {
          final mission = campaignMissions[index];
          final stars = progressStars[mission.id] ?? 0;
          final isPreviousDone = index == 0 || (progressStars[campaignMissions[index - 1].id] ?? 0) > 0;
          final hasRequiredLevel = playerLevel >= mission.requiredLevel;
          final isUnlocked = isPreviousDone && hasRequiredLevel;

          return Card(
            margin: const EdgeInsets.only(bottom: 12), elevation: isUnlocked ? 4 : 0, color: isUnlocked ? Colors.white : Colors.grey[300], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(mission.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: isUnlocked ? const Color(0xFF2B2D42) : Colors.grey)),
              subtitle: Padding(padding: const EdgeInsets.only(top: 4.0), child: Text("${mission.startStation} ➔ ${mission.targetStation}", style: TextStyle(fontSize: 12, color: isUnlocked ? Colors.black87 : Colors.grey, fontWeight: FontWeight.bold))),
              trailing: isUnlocked 
                ? Row(mainAxisSize: MainAxisSize.min, children: [...List.generate(3, (i) => Icon(i < stars ? Icons.star_rounded : Icons.star_outline_rounded, color: const Color(0xFFFFD166), size: 16)), const SizedBox(width: 8), const Icon(Icons.play_circle_fill, color: Color(0xFF80ED99), size: 32)])
                : Row(mainAxisSize: MainAxisSize.min, children: [if (!hasRequiredLevel && isPreviousDone) Text("Lvl ${mission.requiredLevel}  ", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), const Icon(Icons.lock, color: Colors.black26, size: 28)]),
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

// FIX: RESPONSIVES LAYOUT (Desktop = Row, Mobile = Column)
class _EndlessDialog extends ConsumerWidget {
  const _EndlessDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerLevel = ref.watch(progressProvider).playerLevel;
    final isEasyUnlocked = playerLevel >= 20; 
    final isRealisticUnlocked = playerLevel >= 25; 
    
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return _GameDialog(
      title: "MODUS",
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Flex(
          direction: isDesktop ? Axis.horizontal : Axis.vertical,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              flex: isDesktop ? 1 : 0,
              child: GestureDetector(
                onTap: isEasyUnlocked ? () {
                  ref.read(dialogProvider.notifier).state = MenuDialog.none;
                  ref.read(gameProvider.notifier).startFreeplay(GameMode.freeplayEasy);
                } : null,
                child: Opacity(
                  opacity: isEasyUnlocked ? 1.0 : 0.5,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF3A86FF), width: 4),
                      boxShadow: const [BoxShadow(color: Colors.black12, offset: Offset(0, 8), blurRadius: 12)],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.coffee_rounded, size: 60, color: Color(0xFF3A86FF)),
                            const SizedBox(height: 12),
                            const Text("ENTSPANNT", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF2B2D42))),
                            const SizedBox(height: 8),
                            const Text("Zufällige Route.\nKeine Störungen.", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        if (!isEasyUnlocked)
                          Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle), child: const Icon(Icons.lock_rounded, color: Colors.white, size: 36)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: isDesktop ? 24 : 0, height: isDesktop ? 0 : 24),
            Flexible(
              flex: isDesktop ? 1 : 0,
              child: GestureDetector(
                onTap: isRealisticUnlocked ? () {
                  ref.read(dialogProvider.notifier).state = MenuDialog.none;
                  ref.read(gameProvider.notifier).startFreeplay(GameMode.freeplayRealistic);
                } : null,
                child: Opacity(
                  opacity: isRealisticUnlocked ? 1.0 : 0.5,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFFF595E), width: 4),
                      boxShadow: const [BoxShadow(color: Colors.black12, offset: Offset(0, 8), blurRadius: 12)],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 60, color: Color(0xFFFF595E)),
                            const SizedBox(height: 12),
                            const Text("REALISMUS", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF2B2D42))),
                            const SizedBox(height: 8),
                            const Text("Sperrungen.\nChaotisches Netz.", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        if (!isRealisticUnlocked)
                          Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle), child: const Icon(Icons.lock_rounded, color: Colors.white, size: 36)),
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

// FIX: AUTO-ADAPTIVES GRID & SCROLLBAR
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
      content: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("LIZENZEN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF2B2D42))),
                  const SizedBox(height: 12),
                  // NEU: maxCrossAxisExtent sorgt dafür, dass sich die Kacheln dynamisch der Breite anpassen!
                  GridView.builder(
                    shrinkWrap: true, // Wichtig in ScrollViews
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 80, // Maximale Breite einer Kachel
                      childAspectRatio: 2.0, 
                      crossAxisSpacing: 8, 
                      mainAxisSpacing: 8
                    ),
                    itemCount: allLines.length,
                    itemBuilder: (context, index) {
                      final line = allLines[index];
                      final isUnlocked = unlockedLines.contains(line);
                      final trueColor = uBahnColors[line]!;
                      final displayColor = isUnlocked ? trueColor : trueColor.withOpacity(0.15);
                      return Container(
                        decoration: BoxDecoration(color: displayColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: isUnlocked ? Colors.white : trueColor.withOpacity(0.3), width: 2)),
                        alignment: Alignment.center,
                        child: Text(line, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: isUnlocked ? Colors.white : trueColor.withOpacity(0.6))),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Divider(thickness: 2),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("FUHRPARK", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF2B2D42))),
                      Row(
                        children: [
                          const Icon(Icons.generating_tokens_rounded, color: Color(0xFFFFD166), size: 20),
                          const SizedBox(width: 4),
                          Text(playerCoins.toString(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF2B2D42))),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  // SHOP-LISTE (Jetzt flexibel)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: availableSkins.length,
                    itemBuilder: (context, index) {
                      final skin = availableSkins[index];
                      final isOwned = purchasedSkins.contains(skin.id);
                      final isEquipped = activeSkin == skin.id;
                      final canAfford = playerCoins >= skin.price;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isEquipped ? const Color(0xFFE8F5E9) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isEquipped ? const Color(0xFF80ED99) : Colors.black12, width: isEquipped ? 3 : 2),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: skin.primaryColor, shape: BoxShape.circle, border: Border.all(color: skin.secondaryColor, width: 2)),
                              child: Icon(skin.icon, color: skin.secondaryColor, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(skin.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF2B2D42))),
                                  Text(skin.description, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isEquipped)
                              const Icon(Icons.check_circle, color: Color(0xFF80ED99), size: 32)
                            else if (isOwned)
                              ElevatedButton(
                                onPressed: () => ref.read(progressProvider.notifier).equipSkin(skin.id),
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3A86FF), padding: const EdgeInsets.symmetric(horizontal: 12), minimumSize: Size.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                child: const Text("GO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                              )
                            else
                              ElevatedButton.icon(
                                onPressed: canAfford ? () => ref.read(progressProvider.notifier).buySkin(skin.id, skin.price) : null,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD166), disabledBackgroundColor: Colors.grey[300], padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: Size.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                icon: Icon(Icons.shopping_cart, size: 14, color: canAfford ? const Color(0xFF2B2D42) : Colors.grey),
                                label: Text("${skin.price}", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: canAfford ? const Color(0xFF2B2D42) : Colors.grey)),
                              )
                          ],
                        ),
                      );
                    }
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsDialog extends ConsumerWidget {
  const _SettingsDialog();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _GameDialog(title: "EINSTELLUNGEN", content: const Center(child: Text("...")));
  }
}