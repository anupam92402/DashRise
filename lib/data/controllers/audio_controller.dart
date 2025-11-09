import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:dash_rise/data/local_storage/audio_storage.dart';
import '../../utils/constants/audio_constants.dart';

class AudioController {
  static final AudioController _instance = AudioController._internal();
  factory AudioController() => _instance;
  AudioController._internal();

  final ValueNotifier<bool> musicEnabled = ValueNotifier(true);
  final ValueNotifier<bool> soundEnabled = ValueNotifier(true);
  bool _backgroundPlaying = false;

  Future<void> init() async {
    final storage = AudioStorage();
    musicEnabled.value = await storage.getMusicEnabled();
    soundEnabled.value = await storage.getSoundEnabled();
    // Preload assets
    await FlameAudio.audioCache.loadAll([
      AudioConstants.backgroundMusic,
      AudioConstants.scoreSfx,
    ]);
  }

  void setMusic(bool enabled) async {
    musicEnabled.value = enabled;
    await AudioStorage().setMusicEnabled(enabled);
    if (enabled) {
      playBackgroundLoop();
    } else {
      stopBackground();
    }
  }

  void setSound(bool enabled) async {
    soundEnabled.value = enabled;
    await AudioStorage().setSoundEnabled(enabled);
  }

  void playBackgroundLoop() {
    if (_backgroundPlaying || !musicEnabled.value) return;
    FlameAudio.bgm.play(AudioConstants.backgroundMusic);
    _backgroundPlaying = true;
  }

  void stopBackground() {
    if (_backgroundPlaying) {
      FlameAudio.bgm.stop();
      _backgroundPlaying = false;
    }
  }

  void playScoreSfx() {
    if (!soundEnabled.value) return;
    FlameAudio.play(AudioConstants.scoreSfx);
  }

  void dispose() {
    musicEnabled.dispose();
    soundEnabled.dispose();
    FlameAudio.bgm.stop();
  }
}
