import 'package:shared_preferences/shared_preferences.dart';

class LevelStars {
  static Map<String, int> _stars = {}; // "difficulty_level" -> stars (1-3)

  static Future<void> loadStars() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('stars_'));
    for (var key in keys) {
      _stars[key.replaceFirst('stars_', '')] = prefs.getInt(key) ?? 0;
    }
  }

  static Future<void> setStars(String difficulty, int level, int stars) async {
    final key = '${difficulty}_$level';
    final currentStars = _stars[key] ?? 0;
    
    // Sadece daha yüksek yıldız sayısı varsa güncelle
    if (stars > currentStars) {
      _stars[key] = stars;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('stars_$key', stars);
    }
  }

  static int getStars(String difficulty, int level) {
    final key = '${difficulty}_$level';
    return _stars[key] ?? 0;
  }

  static int getTotalStars(String difficulty) {
    int total = 0;
    for (int i = 1; i <= 10; i++) {
      total += getStars(difficulty, i);
    }
    return total;
  }

  static int getAllStars() {
    return getTotalStars('kolay') + getTotalStars('orta') + getTotalStars('zor');
  }

  // Seviye performansına göre yıldız hesapla
  static int calculateStars({
    required int score,
    required int targetScore,
    required int timeSpent,
    required int timeLimit,
    required int mistakes,
  }) {
    // Hedef puana ulaşmadıysa 0 yıldız
    if (score < targetScore) return 0;

    int stars = 1; // Temel 1 yıldız

    // 2. yıldız: Hedefin %150'sine ulaş
    if (score >= (targetScore * 1.5).toInt()) {
      stars = 2;
    }

    // 3. yıldız: Hedefin %200'üne ulaş VE süre limitinin %50'sinden az zamanda bitir
    if (timeLimit > 0) {
      if (score >= (targetScore * 2).toInt() && timeSpent <= (timeLimit * 0.5).toInt() && mistakes == 0) {
        stars = 3;
      }
    } else {
      // Süresiz modda sadece puan ve hata sayısına bak
      if (score >= (targetScore * 2).toInt() && mistakes == 0) {
        stars = 3;
      }
    }

    return stars;
  }
}
