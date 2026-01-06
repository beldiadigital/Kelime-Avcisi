import 'package:shared_preferences/shared_preferences.dart';

class LifeSystem {
  static const int maxLives = 10;
  static const int rechargeMinutes = 30;

  static int _currentLives = maxLives;
  static DateTime? _lastLifeLostTime;

  static int get currentLives => _currentLives;
  static bool get hasLives => _currentLives > 0;

  static Future<void> loadLives() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLives = prefs.getInt('lives') ?? maxLives;
    final lastLostStr = prefs.getString('last_life_lost');
    if (lastLostStr != null) {
      _lastLifeLostTime = DateTime.parse(lastLostStr);
      _rechargeIfNeeded();
    }
  }

  static Future<void> _rechargeIfNeeded() async {
    if (_lastLifeLostTime == null || _currentLives >= maxLives) return;

    final now = DateTime.now();
    final minutesPassed = now.difference(_lastLifeLostTime!).inMinutes;
    final livesToAdd = minutesPassed ~/ rechargeMinutes;

    if (livesToAdd > 0) {
      _currentLives = (_currentLives + livesToAdd).clamp(0, maxLives);
      _lastLifeLostTime = _lastLifeLostTime!.add(
        Duration(minutes: livesToAdd * rechargeMinutes),
      );
      await _saveLives();
    }
  }

  static Future<bool> useLife() async {
    if (_currentLives <= 0) return false;

    _currentLives--;
    if (_lastLifeLostTime == null) {
      _lastLifeLostTime = DateTime.now();
    }
    await _saveLives();
    return true;
  }

  static Future<void> addLife() async {
    _currentLives = (_currentLives + 1).clamp(0, maxLives);
    await _saveLives();
  }

  static Future<void> refillLives() async {
    _currentLives = maxLives;
    _lastLifeLostTime = null;
    await _saveLives();
  }

  static Future<void> _saveLives() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lives', _currentLives);
    if (_lastLifeLostTime != null) {
      await prefs.setString(
        'last_life_lost',
        _lastLifeLostTime!.toIso8601String(),
      );
    }
  }

  static String getNextLifeTime() {
    if (_currentLives >= maxLives || _lastLifeLostTime == null) {
      return "Dolu";
    }

    final now = DateTime.now();
    final nextLifeTime = _lastLifeLostTime!.add(
      Duration(minutes: rechargeMinutes * (maxLives - _currentLives)),
    );
    final remaining = nextLifeTime.difference(now);

    if (remaining.isNegative) {
      _rechargeIfNeeded();
      return "Dolu";
    }

    final minutes = remaining.inMinutes % 60;
    return "${minutes}dk";
  }
}
