import 'package:shared_preferences/shared_preferences.dart';

class TimeRecord {
  static const String _keyPrefix = 'best_time_';

  // Her zorluk seviyesi için hedef süreler (saniye)
  static const Map<String, int> targetTimes = {
    'kolay': 180, // 3 dakika
    'orta': 240, // 4 dakika
    'zor': 300, // 5 dakika
  };

  // Yıldız kriterleri (süreye göre)
  static int getStars(String difficulty, int seconds) {
    final target = targetTimes[difficulty] ?? 240;

    if (seconds <= target * 0.6) {
      return 3; // %60 veya daha hızlı = 3 yıldız
    } else if (seconds <= target * 0.8) {
      return 2; // %80 veya daha hızlı = 2 yıldız
    } else if (seconds <= target) {
      return 1; // Hedef süre içinde = 1 yıldız
    } else {
      return 0; // Hedef süreyi aştı = 0 yıldız
    }
  }

  // En iyi zamanı kaydet
  static Future<void> saveBestTime(String difficulty, int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$difficulty';
    final currentBest = prefs.getInt(key) ?? 999999;

    if (seconds < currentBest) {
      await prefs.setInt(key, seconds);
    }
  }

  // En iyi zamanı getir
  static Future<int?> getBestTime(String difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$difficulty';
    return prefs.getInt(key);
  }

  // Süreyi formatla (mm:ss)
  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // Zorluk adını al
  static String getDifficultyName(String difficulty) {
    switch (difficulty) {
      case 'kolay':
        return 'Kolay';
      case 'orta':
        return 'Orta';
      case 'zor':
        return 'Zor';
      default:
        return difficulty;
    }
  }
}
