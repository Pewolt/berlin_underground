import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/game_provider.dart';
import '../../state/game_state.dart';
import '../../state/audio_provider.dart';
import '../../state/progress_provider.dart';
import '../../../domain/models/mission.dart';

class InGameHudScreen extends ConsumerWidget {
  const InGameHudScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final gameController = ref.read(gameProvider.notifier);
    final progressState = ref.watch(progressProvider);

    // ==========================================
    // LOGIK: Nächste Fahrt oder Neustart?
    // ==========================================
    bool canGoToNext = false;
    Mission? nextMission;
    
    if (gameState.phase == GamePhase.gameOver && gameState.currentMission != null) {
      final currentIndex = campaignMissions.indexWhere((m) => m.id == gameState.currentMission!.id);
      
      if (currentIndex != -1 && currentIndex < campaignMissions.length - 1) {
        nextMission = campaignMissions[currentIndex + 1];
        final currentStars = progressState.missionStars[gameState.currentMission!.id] ?? 0;
        
        if (gameState.isGameWon && currentStars > 0 && progressState.playerLevel >= nextMission.requiredLevel) {
          canGoToNext = true;
        }
      }
    }

    return Stack(
      children: [
        // --- HUD OBEN (ZIEL, DAISY, ZEIT) ---
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LINKS: Ziel (Wird ausgeblendet, wenn DAISY-Ticker aktiv ist, um Platz zu sparen)
                if (gameState.targetStation != null && gameState.activeDisruptions.isEmpty)
                  _buildPanel(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("ZIEL", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(gameState.targetStation!.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  )
                else 
                  const SizedBox(width: 100), // Platzhalter, damit das Layout nicht kollabiert

                // MITTE: Der DAISY-LED-Anzeiger (Nur bei Störungen!)
                if (gameState.activeDisruptions.isNotEmpty)
                  _DaisyDisplay(
                    targetStation: gameState.targetStation?.name ?? "Nicht einsteigen",
                    disruptions: gameState.activeDisruptions.map((d) => d.description).toList(),
                  ),

                // RECHTS: Zeit & Einstellungen
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPanel(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer, color: Colors.amber, size: 24),
                          const SizedBox(width: 8),
                          Text("${gameState.timeElapsed} Min", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context, 
                          barrierDismissible: false, 
                          builder: (context) => const _InGameSettingsDialog()
                        );
                      },
                      child: _buildPanel(
                        backgroundColor: const Color(0xFF8D99AE),
                        child: const Icon(Icons.settings, color: Colors.white, size: 28),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // --- GAME OVER SCREEN (SCHICHTAUSWERTUNG) ---
        if (gameState.phase == GamePhase.gameOver)
          Container(
            color: Colors.black87,
            child: Center(
              child: Container(
                width: 450,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF2F4),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: const [BoxShadow(color: Colors.black54, offset: Offset(0, 16), blurRadius: 24)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("SCHICHTAUSWERTUNG", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 2)),
                    const SizedBox(height: 8),
                    Text(
                      gameState.isGameWon ? "GUTE ARBEIT!" : "SCHICHT GESCHEITERT",
                      style: TextStyle(color: gameState.isGameWon ? const Color(0xFF38B000) : const Color(0xFFD00000), fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                    const SizedBox(height: 8),
                    Text(gameState.gameOverReason, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Color(0xFF2B2D42))),
                    
                    const SizedBox(height: 24),
                    
                    // STERNE
                    if (gameState.isGameWon)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          return Icon(index < gameState.stars ? Icons.star_rounded : Icons.star_outline_rounded, color: const Color(0xFFFFD166), size: 60);
                        }),
                      )
                    else 
                      const Icon(Icons.cancel_rounded, color: Color(0xFFD00000), size: 60),

                    // NEU: PAYOUT (MÜNZEN)
                    if (gameState.isGameWon && gameState.earnedCoins > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFFFFD166), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2B2D42), width: 2)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("PAYOUT:", style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2B2D42))),
                            const SizedBox(width: 8),
                            Text("+ ${gameState.earnedCoins}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF2B2D42))),
                            const SizedBox(width: 8),
                            const Icon(Icons.generating_tokens_rounded, color: Color(0xFF2B2D42)),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // STATISTIKEN
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black12, width: 2),
                      ),
                      child: Column(
                        children: [
                          _buildStatRow("Deine Fahrzeit", "${gameState.timeElapsed} Min", isBold: true, color: gameState.isGameWon ? const Color(0xFF38B000) : const Color(0xFFD00000)),
                          const Divider(height: 24, thickness: 2, color: Color(0xFFEDF2F4)),
                          _buildStatRow("3-Sterne Vorgabe", "${gameState.optimalTime} Min", color: Colors.grey[700]!),
                          const SizedBox(height: 8),
                          _buildStatRow("2-Sterne Limit", "${(gameState.optimalTime * 1.50).floor()} Min", color: Colors.grey[500]!, small: true),
                          _buildStatRow("1-Stern Limit", "${(gameState.optimalTime * 2.00).floor()} Min", color: Colors.grey[500]!, small: true),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // LEVEL UP BENACHRICHTIGUNG
                    if (progressState.newlyUnlockedItems.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD166),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF2B2D42), width: 3),
                          boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 4))],
                        ),
                        child: Column(
                          children: [
                            const Text("LEVEL UP! NEU FREIGESCHALTET:", style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2B2D42), fontSize: 14)),
                            const SizedBox(height: 4),
                            Text(progressState.newlyUnlockedItems.join(', '), style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF3A86FF), fontSize: 20)),
                          ],
                        ),
                      ),

                    // NAVIGATION BUTTONS (HOME & NEXT)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StylizedButton(
                          icon: Icons.home_rounded, 
                          color: const Color(0xFF8D99AE),
                          textColor: Colors.white,
                          onPressed: () {
                            ref.read(progressProvider.notifier).clearNewlyUnlocked();
                            gameController.returnToMenu();
                          },
                        ),
                        const SizedBox(width: 24), 
                        _StylizedButton(
                          icon: canGoToNext ? Icons.fast_forward_rounded : Icons.refresh_rounded, 
                          color: canGoToNext ? const Color(0xFF3A86FF) : const Color(0xFFFF9F1C),
                          textColor: Colors.white,
                          onPressed: () {
                            ref.read(progressProvider.notifier).clearNewlyUnlocked();
                            if (canGoToNext && nextMission != null) {
                              gameController.startMission(nextMission);
                            } else {
                              gameController.startMission(gameState.currentMission!);
                            }
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),

        // --- FAST FORWARD BUTTON (UNTEN LINKS) ---
        if (gameState.phase == GamePhase.moving)
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 24.0, bottom: 24.0),
              child: GestureDetector(
                onTapDown: (_) => ref.read(fastForwardProvider.notifier).state = true,
                onTapUp: (_) => ref.read(fastForwardProvider.notifier).state = false,
                onTapCancel: () => ref.read(fastForwardProvider.notifier).state = false,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ref.watch(fastForwardProvider) ? const Color(0xFF3A86FF) : const Color(0xFF2B2D42),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 4))],
                  ),
                  child: const Icon(Icons.fast_forward_rounded, color: Colors.white, size: 36),
                ),
              ),
            ),
          ),

        // --- UMSTEIGE-MENÜ (RECHTS & VERTIKAL) ---
        if (gameState.phase == GamePhase.briefing || gameState.phase == GamePhase.decisionPending)
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.only(right: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF2F4),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black12, width: 2),
                boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 8))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    gameState.phase == GamePhase.briefing ? "Routenplanung" : "Umsteigen",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2B2D42)),
                  ),
                  const SizedBox(height: 16),
                  Consumer(
                    builder: (context, ref, child) {
                      final repo = ref.read(repositoryProvider);
                      final unlockedLines = ref.read(progressProvider).unlockedLines;
                      
                      final connections = repo.graph.adjacencyList[gameState.currentStation!.name] ?? [];
                      
                      // HIER wird visuell gefiltert!
                      final validConnections = connections.where((c) {
                        if (!unlockedLines.contains(c.lineName)) return false;
                        if (gameState.phase == GamePhase.briefing) return true;
                        final prev = gameState.traveledPath.length > 1 ? gameState.traveledPath[gameState.traveledPath.length - 2] : null;
                        return c.toStation != prev;
                      }).toList();

                      // Falls das Backend gestoppt hat, aber alle Linien gesperrt sind:
                      if (validConnections.isEmpty && gameState.phase == GamePhase.decisionPending) {
                         return const Text("Keine freigeschalteten\nLinien verfügbar!", textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold));
                      }

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: validConnections.map((conn) {
                          final endpoint = repo.graph.getLineEndpoint(gameState.currentStation!.name, conn.lineName, conn.toStation);
                          final isCurrentLine = gameState.currentLine == conn.lineName;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _StylizedButton(
                              text: "${conn.lineName} ➔ $endpoint",
                              color: isCurrentLine ? conn.color : Colors.white,
                              textColor: isCurrentLine ? Colors.white : conn.color,
                              borderColor: conn.color,
                              onPressed: () => gameController.chooseLineAndMove(conn.lineName, conn.toStation),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, {bool isBold = false, Color color = const Color(0xFF2B2D42), bool small = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: small ? 2.0 : 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: small ? 14 : 16, fontWeight: isBold ? FontWeight.w900 : FontWeight.bold, color: color)),
          Text(value, style: TextStyle(fontSize: small ? 14 : 18, fontWeight: isBold ? FontWeight.w900 : FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildPanel({required Widget child, Color backgroundColor = const Color(0xFF2B2D42)}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24, width: 2), boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 4))]),
      child: child,
    );
  }
}

// ============================================================================
// DAISY ANZEIGER
// ============================================================================
class _DaisyDisplay extends StatelessWidget {
  final String targetStation;
  final List<String> disruptions;

  const _DaisyDisplay({required this.targetStation, required this.disruptions});

  @override
  Widget build(BuildContext context) {
    final scrollingText = "*** STÖRUNG: ${disruptions.join(' *** ')} ***";

    return Container(
      width: 450,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111), 
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF444444), width: 4), 
        boxShadow: const [BoxShadow(color: Colors.black54, offset: Offset(0, 8), blurRadius: 12)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                targetStation.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Courier', fontSize: 20, fontWeight: FontWeight.w900, color: Colors.orangeAccent,
                  shadows: [Shadow(color: Colors.orange, blurRadius: 6)], 
                ),
              ),
              const Text(
                "sofort",
                style: TextStyle(
                  fontFamily: 'Courier', fontSize: 20, fontWeight: FontWeight.w900, color: Colors.orangeAccent,
                  shadows: [Shadow(color: Colors.orange, blurRadius: 6)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24, height: 1, thickness: 1),
          const SizedBox(height: 8),
          SizedBox(
            height: 24,
            width: double.infinity,
            child: _ScrollingLedText(text: scrollingText),
          )
        ],
      ),
    );
  }
}

class _ScrollingLedText extends StatefulWidget {
  final String text;
  const _ScrollingLedText({required this.text});

  @override
  State<_ScrollingLedText> createState() => _ScrollingLedTextState();
}

class _ScrollingLedTextState extends State<_ScrollingLedText> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    final durationSeconds = (widget.text.length * 0.15).toInt().clamp(5, 30);
    _animController = AnimationController(vsync: this, duration: Duration(seconds: durationSeconds));
    
    _animController.addListener(() {
      if (_scrollController.hasClients) {
        final maxExtent = _scrollController.position.maxScrollExtent;
        final currentPosition = _animController.value * maxExtent;
        _scrollController.jumpTo(currentPosition);
      }
    });
    _animController.repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(), 
      children: [
        Text(
          "${widget.text}                    ${widget.text}",
          style: const TextStyle(
            fontFamily: 'Courier', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orangeAccent,
            shadows: [Shadow(color: Colors.orange, blurRadius: 4)],
          ),
        ),
      ],
    );
  }
}

class _InGameSettingsDialog extends ConsumerWidget {
  const _InGameSettingsDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMusicOn = ref.watch(musicEnabledProvider);
    final isSoundOn = ref.watch(soundEnabledProvider);
    final gameState = ref.watch(gameProvider);
    final gameController = ref.read(gameProvider.notifier);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: const Color(0xFFEDF2F4),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: const [BoxShadow(color: Colors.black54, offset: Offset(0, 16), blurRadius: 24)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(color: Color(0xFF2B2D42), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              child: const Text("PAUSE", textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5)),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildToggleRow(icon: isMusicOn ? Icons.music_note : Icons.music_off, title: "Musik", value: isMusicOn, onChanged: (val) => ref.read(musicEnabledProvider.notifier).state = val),
                  const SizedBox(height: 12),
                  _buildToggleRow(icon: isSoundOn ? Icons.volume_up : Icons.volume_off, title: "Soundeffekte", value: isSoundOn, onChanged: (val) => ref.read(soundEnabledProvider.notifier).state = val),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 24.0), child: Divider(color: Colors.black12, thickness: 2)),
                  SizedBox(width: double.infinity, child: _StylizedButton(text: "WEITERFAHREN", color: const Color(0xFF80ED99), textColor: const Color(0xFF2B2D42), onPressed: () => Navigator.of(context).pop())),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: _StylizedButton(text: "SCHICHT NEUSTARTEN", color: const Color(0xFF3A86FF), textColor: Colors.white, onPressed: () { Navigator.of(context).pop(); if (gameState.currentMission != null) gameController.startMission(gameState.currentMission!); })),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: _StylizedButton(text: "ABBRECHEN", color: const Color(0xFFFF595E), textColor: Colors.white, onPressed: () { Navigator.of(context).pop(); gameController.returnToMenu(); })),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({required IconData icon, required String title, required bool value, required Function(bool) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black12, width: 2)),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2B2D42), size: 28),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B2D42)))),
          Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF80ED99), activeTrackColor: const Color(0xFF2B2D42)),
        ],
      ),
    );
  }
}

class _StylizedButton extends StatelessWidget {
  final String? text;
  final Color color;
  final Color textColor;
  final Color? borderColor;
  final IconData? icon;
  final VoidCallback onPressed;

  const _StylizedButton({this.text, required this.color, required this.textColor, this.borderColor, this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isIconOnly = text == null;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: isIconOnly ? const EdgeInsets.all(16) : const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: color, 
          shape: isIconOnly ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isIconOnly ? null : BorderRadius.circular(16), 
          border: Border.all(color: borderColor ?? Colors.transparent, width: 3), 
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), offset: const Offset(0, 4))]
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: isIconOnly ? 36 : 20),
              if (!isIconOnly) const SizedBox(width: 8),
            ],
            if (!isIconOnly)
              Text(text!, textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}