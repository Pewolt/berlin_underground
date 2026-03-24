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
    
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;

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
                // LINKS: Ziel
                if (gameState.targetStation != null && gameState.activeDisruptions.isEmpty)
                  _buildPanel(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("ZIEL", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                        Text(gameState.targetStation!.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  )
                else 
                  const SizedBox(width: 10),

                // MITTE: DAISY (Responsiv beschränkt)
                if (gameState.activeDisruptions.isNotEmpty)
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: _DaisyDisplay(
                      targetStation: gameState.targetStation?.name ?? "Nicht einsteigen",
                      disruptions: gameState.activeDisruptions.map((d) => d.description).toList(),
                    ),
                  ),

                // RECHTS: Zeit & Settings
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPanel(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text("${gameState.timeElapsed} Min", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => showDialog(context: context, barrierDismissible: false, builder: (context) => const _InGameSettingsDialog()),
                      child: _buildPanel(backgroundColor: const Color(0xFF8D99AE), child: const Icon(Icons.settings, color: Colors.white, size: 20)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // --- GAME OVER SCREEN (Responsiv mit ScrollView) ---
        if (gameState.phase == GamePhase.gameOver)
          Container(
            color: Colors.black87,
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 450, maxHeight: size.height * 0.9), // Zwingt Container in Schranken
                margin: const EdgeInsets.symmetric(horizontal: 16), // Verhindert Kanten-Kleben
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: const Color(0xFFEDF2F4), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white, width: 4), boxShadow: const [BoxShadow(color: Colors.black54, offset: Offset(0, 16), blurRadius: 24)]),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("SCHICHTAUSWERTUNG", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 2)),
                      const SizedBox(height: 8),
                      Text(gameState.isGameWon ? "GUTE ARBEIT!" : "SCHICHT GESCHEITERT", textAlign: TextAlign.center, style: TextStyle(color: gameState.isGameWon ? const Color(0xFF38B000) : const Color(0xFFD00000), fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      const SizedBox(height: 8),
                      Text(gameState.gameOverReason, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Color(0xFF2B2D42))),
                      
                      const SizedBox(height: 16),
                      
                      if (gameState.isGameWon)
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (index) => Icon(index < gameState.stars ? Icons.star_rounded : Icons.star_outline_rounded, color: const Color(0xFFFFD166), size: 50)))
                      else 
                        const Icon(Icons.cancel_rounded, color: Color(0xFFD00000), size: 50),

                      if (gameState.isGameWon && gameState.earnedCoins > 0)
                        Container(
                          margin: const EdgeInsets.only(top: 16), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: const Color(0xFFFFD166), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF2B2D42), width: 2)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("PAYOUT:", style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2B2D42))),
                              const SizedBox(width: 8),
                              Text("+ ${gameState.earnedCoins}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF2B2D42))),
                              const SizedBox(width: 8),
                              const Icon(Icons.generating_tokens_rounded, color: Color(0xFF2B2D42), size: 20),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black12, width: 2)),
                        child: Column(
                          children: [
                            _buildStatRow("Deine Fahrzeit", "${gameState.timeElapsed} Min", isBold: true, color: gameState.isGameWon ? const Color(0xFF38B000) : const Color(0xFFD00000)),
                            const Divider(height: 16, thickness: 2, color: Color(0xFFEDF2F4)),
                            _buildStatRow("3-Sterne Vorgabe", "${gameState.optimalTime} Min", color: Colors.grey[700]!),
                            const SizedBox(height: 4),
                            _buildStatRow("2-Sterne Limit", "${(gameState.optimalTime * 1.50).floor()} Min", color: Colors.grey[500]!, small: true),
                            _buildStatRow("1-Stern Limit", "${(gameState.optimalTime * 2.00).floor()} Min", color: Colors.grey[500]!, small: true),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      if (progressState.newlyUnlockedItems.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(color: const Color(0xFFFFD166), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2B2D42), width: 2), boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 4))]),
                          child: Column(
                            children: [
                              const Text("LEVEL UP! NEU LIZENZ:", style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2B2D42), fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(progressState.newlyUnlockedItems.join(', '), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF3A86FF), fontSize: 16)),
                            ],
                          ),
                        ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _StylizedButton(icon: Icons.home_rounded, color: const Color(0xFF8D99AE), textColor: Colors.white, onPressed: () { ref.read(progressProvider.notifier).clearNewlyUnlocked(); gameController.returnToMenu(); }),
                          const SizedBox(width: 16), 
                          _StylizedButton(icon: canGoToNext ? Icons.fast_forward_rounded : Icons.refresh_rounded, color: canGoToNext ? const Color(0xFF3A86FF) : const Color(0xFFFF9F1C), textColor: Colors.white, onPressed: () { ref.read(progressProvider.notifier).clearNewlyUnlocked(); if (canGoToNext && nextMission != null) { gameController.startMission(nextMission); } else { gameController.startMission(gameState.currentMission!); } }),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

        // --- FAST FORWARD BUTTON ---
        if (gameState.phase == GamePhase.moving)
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 24.0),
              child: GestureDetector(
                onTapDown: (_) => ref.read(fastForwardProvider.notifier).state = true,
                onTapUp: (_) => ref.read(fastForwardProvider.notifier).state = false,
                onTapCancel: () => ref.read(fastForwardProvider.notifier).state = false,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: ref.watch(fastForwardProvider) ? const Color(0xFF3A86FF) : const Color(0xFF2B2D42), shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 2), boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 4))]),
                  child: const Icon(Icons.fast_forward_rounded, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),

        // --- RESPONSIVES UMSTEIGE-MENÜ ---
        // Auf PC: Rechts zentriert. Auf Handy: Unten zentriert. (Damit Platz für Finger bleibt)
        if (gameState.phase == GamePhase.briefing || gameState.phase == GamePhase.decisionPending)
          Align(
            alignment: isDesktop ? Alignment.centerRight : Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(
                right: isDesktop ? 24 : 0, 
                bottom: isDesktop ? 0 : 80, // Etwas Platz nach unten lassen für den FF-Button
              ),
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 350 : size.width * 0.95, // Flexibel in der Breite
                maxHeight: size.height * 0.6, // Nie höher als 60% des Screens!
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFEDF2F4), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.black12, width: 2), boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 8))]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(gameState.phase == GamePhase.briefing ? "Routenplanung" : "Umsteigen", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF2B2D42))),
                  const SizedBox(height: 12),
                  Flexible( // Scrollbar machen, wenn es zu viele Linien gibt!
                    child: SingleChildScrollView(
                      child: Consumer(
                        builder: (context, ref, child) {
                          final repo = ref.read(repositoryProvider);
                          final unlockedLines = ref.read(progressProvider).unlockedLines;
                          final connections = repo.graph.adjacencyList[gameState.currentStation!.name] ?? [];
                          
                          final validConnections = connections.where((c) {
                            if (!unlockedLines.contains(c.lineName)) return false;
                            if (gameState.phase == GamePhase.briefing) return true;
                            final prev = gameState.traveledPath.length > 1 ? gameState.traveledPath[gameState.traveledPath.length - 2] : null;
                            return c.toStation != prev;
                          }).toList();

                          if (validConnections.isEmpty && gameState.phase == GamePhase.decisionPending) {
                             return const Padding(padding: EdgeInsets.all(16.0), child: Text("Keine freigeschalteten\nLinien verfügbar!", textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)));
                          }

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: validConnections.map((conn) {
                              final endpoint = repo.graph.getLineEndpoint(gameState.currentStation!.name, conn.lineName, conn.toStation);
                              final isCurrentLine = gameState.currentLine == conn.lineName;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: _StylizedButton(
                                  text: "${conn.lineName} ➔ $endpoint",
                                  color: isCurrentLine ? conn.color : Colors.white, textColor: isCurrentLine ? Colors.white : conn.color, borderColor: conn.color,
                                  onPressed: () => gameController.chooseLineAndMove(conn.lineName, conn.toStation),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
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
          Text(label, style: TextStyle(fontSize: small ? 12 : 14, fontWeight: isBold ? FontWeight.w900 : FontWeight.bold, color: color)),
          Text(value, style: TextStyle(fontSize: small ? 12 : 16, fontWeight: isBold ? FontWeight.w900 : FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildPanel({required Widget child, Color backgroundColor = const Color(0xFF2B2D42)}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white24, width: 2), boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 4))]),
      child: child,
    );
  }
}

// ============================================================================
// DAISY ANZEIGER (RESPONSIV)
// ============================================================================
class _DaisyDisplay extends StatelessWidget {
  final String targetStation;
  final List<String> disruptions;
  const _DaisyDisplay({required this.targetStation, required this.disruptions});

  @override
  Widget build(BuildContext context) {
    final scrollingText = "*** STÖRUNG: ${disruptions.join(' *** ')} ***";

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111), borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF444444), width: 3), 
        boxShadow: const [BoxShadow(color: Colors.black54, offset: Offset(0, 8), blurRadius: 12)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(targetStation.toUpperCase(), overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Courier', fontSize: 16, fontWeight: FontWeight.w900, color: Colors.orangeAccent, shadows: [Shadow(color: Colors.orange, blurRadius: 6)])),
              ),
              const Text("sofort", style: TextStyle(fontFamily: 'Courier', fontSize: 16, fontWeight: FontWeight.w900, color: Colors.orangeAccent, shadows: [Shadow(color: Colors.orange, blurRadius: 6)])),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white24, height: 1, thickness: 1),
          const SizedBox(height: 6),
          SizedBox(height: 18, width: double.infinity, child: _ScrollingLedText(text: scrollingText))
        ],
      ),
    );
  }
}

class _ScrollingLedText extends StatefulWidget {
  final String text;
  const _ScrollingLedText({required this.text});
  @override State<_ScrollingLedText> createState() => _ScrollingLedTextState();
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

  @override void dispose() { _animController.dispose(); _scrollController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController, scrollDirection: Axis.horizontal, physics: const NeverScrollableScrollPhysics(), 
      children: [Text("${widget.text}                    ${widget.text}", style: const TextStyle(fontFamily: 'Courier', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orangeAccent, shadows: [Shadow(color: Colors.orange, blurRadius: 4)]))],
    );
  }
}

class _InGameSettingsDialog extends ConsumerWidget {
  const _InGameSettingsDialog();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(child: Text("Hier kommt das Pause-Menü hin."));
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
        padding: isIconOnly ? const EdgeInsets.all(12) : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color, shape: isIconOnly ? BoxShape.circle : BoxShape.rectangle, borderRadius: isIconOnly ? null : BorderRadius.circular(12), 
          border: Border.all(color: borderColor ?? Colors.transparent, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), offset: const Offset(0, 4))]
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, color: textColor, size: isIconOnly ? 32 : 18), if (!isIconOnly) const SizedBox(width: 8)],
            if (!isIconOnly) Text(text!, textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}