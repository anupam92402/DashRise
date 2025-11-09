import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/constants/constants_keys.dart';

class ScoreStorage {
  static Future<void> saveLastScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(ConstantsKeys.lastScore, score);
  }

  static Future<void> saveHighestScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHigh = prefs.getInt(ConstantsKeys.highScore) ?? 0;
    if (score > currentHigh) {
      await prefs.setInt(ConstantsKeys.highScore, score);
    }
  }

  static Future<int> getLastScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(ConstantsKeys.lastScore) ?? 0;
  }

  static Future<int> getHighestScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(ConstantsKeys.highScore) ?? 0;
  }
}
