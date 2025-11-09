import 'package:dash_rise/utils/constants/audio_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioStorage {
  static final AudioStorage _instance = AudioStorage._internal();

  factory AudioStorage() => _instance;

  AudioStorage._internal();

  SharedPreferences? _prefs;

  Future<void> _ensureInit() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<bool> getMusicEnabled() async {
    await _ensureInit();
    return _prefs!.getBool(AudioConstants.musicPrefKey) ?? true; // default ON
  }

  Future<bool> getSoundEnabled() async {
    await _ensureInit();
    return _prefs!.getBool(AudioConstants.soundPrefKey) ?? true; // default ON
  }

  Future<void> setMusicEnabled(bool value) async {
    await _ensureInit();
    await _prefs!.setBool(AudioConstants.musicPrefKey, value);
  }

  Future<void> setSoundEnabled(bool value) async {
    await _ensureInit();
    await _prefs!.setBool(AudioConstants.soundPrefKey, value);
  }
}
