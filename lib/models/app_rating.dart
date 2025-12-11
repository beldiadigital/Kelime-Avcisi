import 'package:shared_preferences/shared_preferences.dart';

class AppRatingSystem {
  static const String _keyLaunchCount = 'app_launch_count';
  static const String _keyLastRatingPrompt = 'last_rating_prompt';
  static const String _keyUserRated = 'user_rated';
  static const String _keyUserDeclined = 'user_declined';

  // Kaç oyun seansından sonra değerlendirme isteneceği
  static const int launchesUntilPrompt = 5; // İlk istem
  static const int launchesAfterDecline = 10; // Reddettikten sonra
  
  // Günlük ödül sonrası değerlendirme
  static const int daysForRating = 3; // 3 gün günlük ödül aldıktan sonra

  // Başlatma sayısını artır
  static Future<void> incrementLaunchCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_keyLaunchCount) ?? 0) + 1;
    await prefs.setInt(_keyLaunchCount, count);
  }

  // Değerlendirme isteği gösterilmeli mi?
  static Future<bool> shouldShowRatingPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Kullanıcı zaten değerlendirdi mi?
    if (prefs.getBool(_keyUserRated) ?? false) {
      return false;
    }

    final launchCount = prefs.getInt(_keyLaunchCount) ?? 0;
    final lastPrompt = prefs.getInt(_keyLastRatingPrompt) ?? 0;
    final declined = prefs.getBool(_keyUserDeclined) ?? false;

    // İlk istem - 5 açılıştan sonra
    if (!declined && launchCount >= launchesUntilPrompt) {
      return true;
    }

    // Reddettikten sonra - son istemden 10 açılış sonra
    if (declined && launchCount >= lastPrompt + launchesAfterDecline) {
      return true;
    }

    return false;
  }

  // Kullanıcı değerlendirdi
  static Future<void> userRated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUserRated, true);
    final launchCount = prefs.getInt(_keyLaunchCount) ?? 0;
    await prefs.setInt(_keyLastRatingPrompt, launchCount);
  }

  // Kullanıcı reddetti
  static Future<void> userDeclined() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUserDeclined, true);
    final launchCount = prefs.getInt(_keyLaunchCount) ?? 0;
    await prefs.setInt(_keyLastRatingPrompt, launchCount);
  }

  // Kullanıcı daha sonra dedi
  static Future<void> userPostponed() async {
    final prefs = await SharedPreferences.getInstance();
    final launchCount = prefs.getInt(_keyLaunchCount) ?? 0;
    await prefs.setInt(_keyLastRatingPrompt, launchCount);
  }

  // Debug için sıfırlama
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLaunchCount);
    await prefs.remove(_keyLastRatingPrompt);
    await prefs.remove(_keyUserRated);
    await prefs.remove(_keyUserDeclined);
  }

  // App Store'da aç
  static Future<void> openAppStore() async {
    // iOS App Store URL (App ID ile değiştirilmeli)
    // final url = 'https://apps.apple.com/app/idYOUR_APP_ID';
    // await launchUrl(Uri.parse(url));
    
    // Şimdilik sadece işaretle
    await userRated();
  }
}
