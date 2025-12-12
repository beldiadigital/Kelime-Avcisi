import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final Color color;
  final int target;
  bool isUnlocked;
  int progress;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.target,
    this.isUnlocked = false,
    this.progress = 0,
  });

  double get progressPercentage => (progress / target).clamp(0.0, 1.0);
}

class AchievementManager {
  static List<Achievement> achievements = [
    Achievement(
      id: 'first_word',
      title: 'İlk Adım',
      description: 'İlk kelimeyi tamamla',
      icon: '🎯',
      color: Colors.blue,
      target: 1,
    ),
    Achievement(
      id: 'ten_words',
      title: 'Kelime Avcısı',
      description: '10 kelime tamamla',
      icon: '🏹',
      color: Colors.green,
      target: 10,
    ),
    Achievement(
      id: 'fifty_words',
      title: 'Kelime Ustası',
      description: '50 kelime tamamla',
      icon: '👑',
      color: Colors.purple,
      target: 50,
    ),
    Achievement(
      id: 'combo_5',
      title: 'Kombo Kralı',
      description: '5x kombo yap',
      icon: '🔥',
      color: Colors.orange,
      target: 5,
    ),
    Achievement(
      id: 'combo_10',
      title: 'Kombo Efsanesi',
      description: '10x kombo yap',
      icon: '⚡',
      color: Colors.red,
      target: 10,
    ),
    Achievement(
      id: 'all_easy',
      title: 'Kolay Şampiyonu',
      description: 'Tüm kolay seviyeleri tamamla',
      icon: '⭐',
      color: Colors.cyan,
      target: 10,
    ),
    Achievement(
      id: 'all_medium',
      title: 'Orta Şampiyonu',
      description: 'Tüm orta seviyeleri tamamla',
      icon: '🌟',
      color: Colors.amber,
      target: 10,
    ),
    Achievement(
      id: 'all_hard',
      title: 'Zor Şampiyonu',
      description: 'Tüm zor seviyeleri tamamla',
      icon: '💫',
      color: Colors.pink,
      target: 10,
    ),
    Achievement(
      id: 'high_score_1000',
      title: 'Puan Avcısı',
      description: '1000 puan topla',
      icon: '💎',
      color: Colors.indigo,
      target: 1000,
    ),
    Achievement(
      id: 'perfect_level',
      title: 'Mükemmel',
      description: 'Bir seviyeyi hatasız bitir',
      icon: '✨',
      color: Colors.teal,
      target: 1,
    ),
  ];

  static Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    for (var achievement in achievements) {
      achievement.isUnlocked = prefs.getBool('ach_${achievement.id}') ?? false;
      achievement.progress =
          prefs.getInt('ach_progress_${achievement.id}') ?? 0;
    }
  }

  static Future<void> updateProgress(String id, int progress) async {
    final achievement = achievements.firstWhere((a) => a.id == id);
    achievement.progress = progress;

    if (progress >= achievement.target && !achievement.isUnlocked) {
      achievement.isUnlocked = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('ach_${achievement.id}', true);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ach_progress_${achievement.id}', progress);
  }

  static Future<void> checkAndUnlock(String id) async {
    final achievement = achievements.firstWhere((a) => a.id == id);
    if (!achievement.isUnlocked) {
      achievement.isUnlocked = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('ach_${achievement.id}', true);
    }
  }

  static int get unlockedCount =>
      achievements.where((a) => a.isUnlocked).length;
}
