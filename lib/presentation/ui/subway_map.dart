import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../state/game_provider.dart';
import '../state/game_state.dart';
import '../state/progress_provider.dart';
import '../../domain/models/connection.dart';

final _berlinBounds = LatLngBounds(
  const LatLng(52.35, 13.10), 
  const LatLng(52.65, 13.75), 
);

class SubwayMap extends ConsumerStatefulWidget {
  const SubwayMap({super.key});

  @override
  ConsumerState<SubwayMap> createState() => _SubwayMapState();
}

class _SubwayMapState extends ConsumerState<SubwayMap> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  
  late AnimationController _animController;
  Animation<double>? _progressAnimation;
  LatLng? _currentTrainPosition;
  double _trainHeading = 0.0; 

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), 
    );

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.microtask(() => ref.read(gameProvider.notifier).arriveAtStation());
      }
    });

    _animController.addListener(() {
      setState(() {
        _updateTrainPosition();
      });
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(begin: _mapController.camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(begin: _mapController.camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: _mapController.camera.zoom, end: destZoom);

    final controller = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    final Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  void _updateTrainPosition() {
    final activeConn = ref.read(gameProvider.notifier).activeConnection;
    if (activeConn == null || _progressAnimation == null) return;

    final progress = _progressAnimation!.value;
    final points = activeConn.geometry;
    
    if (points.length < 2) return;
    
    final totalSegments = points.length - 1;
    final scaledProgress = progress * totalSegments;
    final currentSegmentIndex = scaledProgress.floor().clamp(0, totalSegments - 1);
    final segmentProgress = scaledProgress - currentSegmentIndex;

    final startPoint = points[currentSegmentIndex];
    final endPoint = points[currentSegmentIndex + 1];

    final lat = startPoint.latitude + (endPoint.latitude - startPoint.latitude) * segmentProgress;
    final lng = startPoint.longitude + (endPoint.longitude - startPoint.longitude) * segmentProgress;

    _currentTrainPosition = LatLng(lat, lng);
    
    final dy = endPoint.latitude - startPoint.latitude;
    final dx = endPoint.longitude - startPoint.longitude;
    _trainHeading = math.atan2(dx, dy);
    
    _mapController.move(_currentTrainPosition!, _mapController.camera.zoom);
  }

  void _startMovement(Connection conn) {
    final isFastForwarding = ref.read(fastForwardProvider);
    _animController.duration = isFastForwarding 
        ? const Duration(milliseconds: 300) 
        : const Duration(milliseconds: 1500);

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    ));
    _animController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final repo = ref.watch(repositoryProvider);

    ref.listen(fastForwardProvider, (previous, next) {
      if (_animController.isAnimating) {
        final currentVal = _animController.value;
        _animController.duration = next 
            ? const Duration(milliseconds: 300) 
            : const Duration(milliseconds: 1500);
        _animController.forward(from: currentVal);
      }
    });

    ref.listen(gameProvider, (previous, next) {
      if (next.phase == GamePhase.moving && (previous?.phase != GamePhase.moving || previous?.currentStation != next.currentStation)) {
        final activeConn = ref.read(gameProvider.notifier).activeConnection;
        if (activeConn != null) _startMovement(activeConn);
      } 
      else if (next.phase == GamePhase.decisionPending || next.phase == GamePhase.briefing) {
         if (next.currentStation != null && previous?.phase == GamePhase.idle) {
           _currentTrainPosition = next.currentStation!.coordinates;
           _animatedMapMove(next.currentStation!.coordinates, 13.5);
         } else if (next.currentStation != null) {
           _currentTrainPosition = next.currentStation!.coordinates;
           _animatedMapMove(next.currentStation!.coordinates, 13.5);
         }
      }
    });

    final bool canInteract = gameState.phase == GamePhase.briefing || 
                             gameState.phase == GamePhase.decisionPending || 
                             gameState.phase == GamePhase.gameOver;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(52.5200, 13.4050),
        initialZoom: 12.0,
        minZoom: 11.5, 
        maxZoom: 18.0, 
        cameraConstraint: CameraConstraint.contain(
          bounds: _berlinBounds, 
        ),
        interactionOptions: InteractionOptions(
          flags: canInteract ? InteractiveFlag.all : InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.berlin_underground.app',
        ),
        
        const _StaticNetworkLayer(),
        const _StaticStationLayer(),
        
        // NEU: Der Layer, der Störungen live einzeichnet!
        if (gameState.activeDisruptions.isNotEmpty)
          const _DisruptionLayer(),
        
        if (gameState.targetStation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: gameState.targetStation!.coordinates,
                width: 40,
                height: 40,
                child: const Icon(Icons.flag, color: Colors.black, size: 40),
              )
            ],
          ),
          
        if (_currentTrainPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _currentTrainPosition!,
                width: 40, 
                height: 40,
                child: Transform.rotate(
                  angle: _trainHeading, 
                  child: Container(
                    decoration: BoxDecoration(
                      color: gameState.currentLine != null 
                        ? repo.graph.adjacencyList[gameState.currentStation?.name]?.firstWhere((c) => c.lineName == gameState.currentLine).color ?? const Color(0xFF2B2D42)
                        : const Color(0xFF2B2D42),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 4))],
                    ),
                    child: const Icon(Icons.directions_subway_rounded, color: Colors.white, size: 24),
                  ),
                ),
              )
            ],
          ),
      ],
    );
  }
}

// --- PERFORMANCE LAYERS ---

class _StaticNetworkLayer extends ConsumerWidget {
  const _StaticNetworkLayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    final unlockedLines = ref.watch(progressProvider).unlockedLines;
    
    final allPolylines = <Polyline>[];
    final addedPaths = <String>{};

    for (var station in repo.graph.adjacencyList.values) {
      for (var conn in station) {
        final pathId = "${conn.fromStation}-${conn.toStation}";
        final reversePathId = "${conn.toStation}-${conn.fromStation}";
        
        if (!addedPaths.contains(pathId) && !addedPaths.contains(reversePathId)) {
          final isUnlocked = unlockedLines.contains(conn.lineName);
          allPolylines.add(
            Polyline(
              points: conn.geometry,
              strokeWidth: isUnlocked ? 4.0 : 2.0,
              color: isUnlocked ? conn.color : Colors.grey.withOpacity(0.3),
            ),
          );
          addedPaths.add(pathId);
        }
      }
    }
    return PolylineLayer(polylines: allPolylines);
  }
}

class _StaticStationLayer extends ConsumerWidget {
  const _StaticStationLayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    final unlockedLines = ref.watch(progressProvider).unlockedLines;

    final stationMarkers = <Marker>[];
    for (var station in repo.graph.stations.values) {
      final isInterchange = station.lines.length > 1;
      final isUnlocked = station.lines.any((line) => unlockedLines.contains(line));

      stationMarkers.add(
        Marker(
          point: station.coordinates,
          width: isInterchange ? 14 : 8,
          height: isInterchange ? 14 : 8,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked ? Colors.white : Colors.grey[600],
              border: Border.all(
                color: isUnlocked ? Colors.black : Colors.grey[800]!,
                width: isInterchange ? 3 : 1.5,
              )
            ),
          ),
        )
      );
    }
    return MarkerLayer(markers: stationMarkers);
  }
}

// NEU: Der Geodaten-Layer für Störungen
class _DisruptionLayer extends ConsumerWidget {
  const _DisruptionLayer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(repositoryProvider);
    final disruptions = ref.watch(gameProvider).activeDisruptions;

    final disruptedPolylines = <Polyline>[];
    final warningMarkers = <Marker>[];

    for (var disruption in disruptions) {
      // 1. Finde die originale Kante im Graphen, um die Geometrie zu bekommen
      final connections = repo.graph.adjacencyList[disruption.fromStation] ?? [];
      final targetConn = connections.where((c) => c.toStation == disruption.toStation && c.lineName == disruption.lineName).firstOrNull;

      if (targetConn != null && targetConn.geometry.isNotEmpty) {
        // 2. Zeichne die rote Sperr-Linie drüber
        disruptedPolylines.add(
          Polyline(
            points: targetConn.geometry,
            strokeWidth: 8.0,
            color: Colors.redAccent.withOpacity(0.8),
            // flutter_map unterstützt "isDotted: true" für coole gestrichelte Linien
            isDotted: true, 
          ),
        );

        // 3. Finde den exakten Mittelpunkt der Kante für das Warnschild
        final midIndex = targetConn.geometry.length ~/ 2;
        final midPoint = targetConn.geometry[midIndex];

        warningMarkers.add(
          Marker(
            point: midPoint,
            width: 32,
            height: 32,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
            ),
          )
        );
      }
    }

    return Stack(
      children: [
        PolylineLayer(polylines: disruptedPolylines),
        MarkerLayer(markers: warningMarkers),
      ],
    );
  }
}