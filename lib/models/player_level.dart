import 'package:shared_preferences/shared_preferences.dart';

class PlayerLevel {
  static int _currentLevel = 1;
  static int _currentXP = 0;

  static int get currentLevel => _currentLevel;
  static int get currentXP => _currentXP;

  static int xpForNextLevel(int level) {
    return 100 + (level * 50); // Her seviye daha fazla XP gerektirir
  }

  static int get xpNeeded => xpForNextLevel(_currentLevel);
  static double get progress => (_currentXP / xpNeeded).clamp(0.0, 1.0);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLevel = prefs.getInt('player_level') ?? 1;
    _currentXP = prefs.getInt('player_xp') ?? 0;
  }

  static Future<Map<String, dynamic>> addXP(int amount) async {
    _currentXP += amount;

    List<int> levelsGained = [];
    Map<String, int> rewards = {'coins': 0, 'gems': 0};

    while (_currentXP >= xpForNextLevel(_currentLevel)) {
      _currentXP -= xpForNextLevel(_currentLevel);
      _currentLevel++;
      levelsGained.add(_currentLevel);

      // Her seviye ödülü
      rewards['coins'] = (rewards['coins'] ?? 0) + (50 + (_currentLevel * 10));

      // Her 5 seviyede elmas
      if (_currentLevel % 5 == 0) {
        rewards['gems'] = (rewards['gems'] ?? 0) + 5;
      }
    }

    await _save();

    return {'levelsGained': levelsGained, 'rewards': rewards};
  }

  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('player_level', _currentLevel);
    await prefs.setInt('player_xp', _currentXP);
  }

  static String getLevelTitle() {
    if (_currentLevel < 5) return 'Acemi';
    if (_currentLevel < 10) return 'Başlangıç';
    if (_currentLevel < 20) return 'Deneyimli';
    if (_currentLevel < 30) return 'Usta';
    if (_currentLevel < 40) return 'Uzman';
    if (_currentLevel < 50) return 'Efsane';
    return 'Tanrı';
  }
}
