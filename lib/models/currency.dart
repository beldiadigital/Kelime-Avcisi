import 'package:shared_preferences/shared_preferences.dart';

class CurrencyManager {
  static int _coins = 0;
  static int _gems = 0;

  static int get coins => _coins;
  static int get gems => _gems;

  static Future<void> loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _coins = prefs.getInt('coins') ?? 0;
    _gems = prefs.getInt('gems') ?? 0;
  }

  static Future<void> addCoins(int amount) async {
    _coins += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', _coins);
  }

  static Future<void> addGems(int amount) async {
    _gems += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('gems', _gems);
  }

  static Future<bool> spendCoins(int amount) async {
    if (_coins >= amount) {
      _coins -= amount;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('coins', _coins);
      return true;
    }
    return false;
  }

  static Future<bool> spendGems(int amount) async {
    if (_gems >= amount) {
      _gems -= amount;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('gems', _gems);
      return true;
    }
    return false;
  }
}

class DailyReward {
  static int _currentStreak = 0;
  static DateTime? _lastClaimDate;

  static int get currentStreak => _currentStreak;
  static bool get canClaim {
    if (_lastClaimDate == null) return true;
    final now = DateTime.now();
    final difference = now.difference(_lastClaimDate!);
    return difference.inHours >= 20; // 20 saat sonra yeni ödül
  }

  static Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _currentStreak = prefs.getInt('daily_streak') ?? 0;
    final lastClaimStr = prefs.getString('last_claim_date');
    if (lastClaimStr != null) {
      _lastClaimDate = DateTime.parse(lastClaimStr);
    }
  }

  static Future<Map<String, int>> claimReward() async {
    if (!canClaim) return {};

    final now = DateTime.now();

    // Streak kontrolü
    if (_lastClaimDate != null) {
      final hoursDiff = now.difference(_lastClaimDate!).inHours;
      if (hoursDiff > 48) {
        // 48 saatten fazla geçti, streak sıfırla
        _currentStreak = 0;
      }
    }

    _currentStreak++;
    if (_currentStreak > 7) _currentStreak = 1; // 7 günde bir reset

    _lastClaimDate = now;

    // Ödül hesapla
    int coins = 0;
    int gems = 0;

    switch (_currentStreak) {
      case 1:
        coins = 50;
        break;
      case 2:
        coins = 75;
        break;
      case 3:
        coins = 100;
        break;
      case 4:
        coins = 150;
        break;
      case 5:
        coins = 200;
        break;
      case 6:
        coins = 250;
        break;
      case 7:
        coins = 500;
        gems = 10;
        break;
    }

    await CurrencyManager.addCoins(coins);
    await CurrencyManager.addGems(gems);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_streak', _currentStreak);
    await prefs.setString('last_claim_date', now.toIso8601String());

    return {'coins': coins, 'gems': gems, 'day': _currentStreak};
  }
}
