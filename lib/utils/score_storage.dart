import 'package:dash_rise/utils/constants.dart' as keys;
import 'package:shared_preferences/shared_preferences.dart';

class ScoreStorage {
  static Future<void> saveLastScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keys.Constants.lastScore, score);
  }

  static Future<void> saveHighestScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHigh = prefs.getInt(keys.Constants.highScore) ?? 0;
    if (score > currentHigh) {
      await prefs.setInt(keys.Constants.highScore, score);
    }
  }

  static Future<int> getLastScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keys.Constants.lastScore) ?? 0;
  }

  static Future<int> getHighestScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keys.Constants.highScore) ?? 0;
  }
}
