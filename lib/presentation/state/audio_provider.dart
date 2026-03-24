import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Die Toggle-Status
final musicEnabledProvider = StateProvider<bool>((ref) => true);
final soundEnabledProvider = StateProvider<bool>((ref) => true);

// Der Service-Provider, der beim ersten Aufruf initialisiert wird
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService(ref);
  service.init();
  return service;
});

class AudioService {
  final Ref _ref;
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  AudioService(this._ref) {
    // Hört auf Änderungen des Musik-Toggles
    _ref.listen(musicEnabledProvider, (prev, isEnabled) {
      if (isEnabled) {
        playMusic();
      } else {
        _musicPlayer.pause();
      }
    });
  }

  Future<void> init() async {
    // Musik soll unendlich loopen
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playMusic() async {
    if (!_ref.read(musicEnabledProvider)) return;
    // Spiele Hintergrundmusik (Pfade an deine Assets anpassen!)
    await _musicPlayer.play(AssetSource('audio/bg_music.mp3'), volume: 0.3);
  }

  Future<void> playSfx(String fileName) async {
    if (!_ref.read(soundEnabledProvider)) return;
    
    // SFXPlayer feuert den Sound ab und ist direkt bereit für den nächsten
    await _sfxPlayer.play(AssetSource('audio/$fileName'), volume: 0.8);
  }

  void dispose() {
    _musicPlayer.dispose();
    _sfxPlayer.dispose();
  }
}