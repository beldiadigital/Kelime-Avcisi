import 'package:shared_preferences/shared_preferences.dart';

class DailyRewardSystem {
  static int currentStreak = 0;
  static DateTime? lastClaimDate;
  static bool canClaimToday = true;

  static final List<Map<String, int>> rewards = [
    {'coins': 10, 'gems': 0}, // Gün 1
    {'coins': 20, 'gems': 0}, // Gün 2
    {'coins': 30, 'gems': 1}, // Gün 3
    {'coins': 50, 'gems': 1}, // Gün 4
    {'coins': 75, 'gems': 2}, // Gün 5
    {'coins': 100, 'gems': 3}, // Gün 6
    {'coins': 150, 'gems': 5}, // Gün 7 (Mega Bonus!)
  ];

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    currentStreak = prefs.getInt('daily_reward_streak') ?? 0;
    final lastClaimStr = prefs.getString('daily_reward_last_claim');

    if (lastClaimStr != null) {
      lastClaimDate = DateTime.parse(lastClaimStr);
      _checkStreakValidity();
    } else {
      canClaimToday = true;
    }
  }

  static void _checkStreakValidity() {
    if (lastClaimDate == null) {
      canClaimToday = true;
      return;
    }

    final now = DateTime.now();
    final lastClaim = lastClaimDate!;

    // Aynı gün mü?
    if (_isSameDay(now, lastClaim)) {
      canClaimToday = false;
      return;
    }

    // Bir gün atlandı mı?
    final daysDifference = now.difference(lastClaim).inDays;

    if (daysDifference == 1) {
      // Ardışık gün - streak devam
      canClaimToday = true;
    } else if (daysDifference > 1) {
      // Streak kırıldı
      currentStreak = 0;
      canClaimToday = true;
    }
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static Future<Map<String, int>> claimReward() async {
    if (!canClaimToday) {
      return {'coins': 0, 'gems': 0};
    }

    // Streak'i artır (max 7)
    if (currentStreak < 7) {
      currentStreak++;
    } else {
      currentStreak = 1; // 7. günden sonra başa dön
    }

    final reward = rewards[currentStreak - 1];

    // Kaydet
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_reward_streak', currentStreak);
    await prefs.setString(
      'daily_reward_last_claim',
      DateTime.now().toIso8601String(),
    );

    lastClaimDate = DateTime.now();
    canClaimToday = false;

    return reward;
  }

  static Future<void> resetStreak() async {
    currentStreak = 0;
    lastClaimDate = null;
    canClaimToday = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('daily_reward_streak');
    await prefs.remove('daily_reward_last_claim');
  }

  static Map<String, int> getTodayReward() {
    final nextDay = currentStreak < 7 ? currentStreak : 0;
    return rewards[nextDay];
  }

  static int getDaysUntilMegaBonus() {
    return 7 - currentStreak;
  }
}
