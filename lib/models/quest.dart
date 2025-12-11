import 'package:shared_preferences/shared_preferences.dart';

class Quest {
  final String id;
  final String title;
  final String description;
  final String type; // daily, weekly
  final int target;
  final Map<String, int> reward; // {coins: 100, gems: 5}
  int progress;
  bool isCompleted;
  bool isClaimed;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    required this.reward,
    this.progress = 0,
    this.isCompleted = false,
    this.isClaimed = false,
  });

  double get progressPercentage => (progress / target).clamp(0.0, 1.0);
}

class QuestManager {
  static List<Quest> dailyQuests = [];
  static List<Quest> weeklyQuests = [];
  static DateTime? _lastDailyReset;
  static DateTime? _lastWeeklyReset;

  static Future<void> init() async {
    await _loadProgress();
    await _checkResets();
    if (dailyQuests.isEmpty) _generateDailyQuests();
    if (weeklyQuests.isEmpty) _generateWeeklyQuests();
  }

  static void _generateDailyQuests() {
    dailyQuests = [
      Quest(
        id: 'daily_words_3',
        title: '3 Kelime Tamamla',
        description: 'Herhangi bir seviyede 3 kelime tamamla',
        type: 'daily',
        target: 3,
        reward: {'coins': 50, 'gems': 0},
      ),
      Quest(
        id: 'daily_combo_3',
        title: '3x Kombo Yap',
        description: 'Bir oyunda 3x kombo yap',
        type: 'daily',
        target: 1,
        reward: {'coins': 75, 'gems': 1},
      ),
      Quest(
        id: 'daily_levels_2',
        title: '2 Seviye Tamamla',
        description: 'İki farklı seviyeyi bitir',
        type: 'daily',
        target: 2,
        reward: {'coins': 100, 'gems': 2},
      ),
    ];
  }

  static void _generateWeeklyQuests() {
    weeklyQuests = [
      Quest(
        id: 'weekly_words_25',
        title: '25 Kelime Tamamla',
        description: 'Hafta boyunca 25 kelime tamamla',
        type: 'weekly',
        target: 25,
        reward: {'coins': 300, 'gems': 10},
      ),
      Quest(
        id: 'weekly_levels_10',
        title: '10 Seviye Bitir',
        description: 'Hafta boyunca 10 seviye tamamla',
        type: 'weekly',
        target: 10,
        reward: {'coins': 500, 'gems': 15},
      ),
    ];
  }

  static Future<void> _checkResets() async {
    final now = DateTime.now();
    
    // Daily reset (her gün gece 00:00)
    if (_lastDailyReset == null || 
        now.day != _lastDailyReset!.day ||
        now.month != _lastDailyReset!.month) {
      dailyQuests.clear();
      _generateDailyQuests();
      _lastDailyReset = now;
      await _saveProgress();
    }

    // Weekly reset (her Pazartesi)
    if (_lastWeeklyReset == null ||
        now.difference(_lastWeeklyReset!).inDays >= 7) {
      weeklyQuests.clear();
      _generateWeeklyQuests();
      _lastWeeklyReset = now;
      await _saveProgress();
    }
  }

  static Future<void> updateProgress(String questId, int amount) async {
    final quest = [...dailyQuests, ...weeklyQuests]
        .where((q) => q.id == questId)
        .firstOrNull;
    
    if (quest == null || quest.isCompleted) return;

    quest.progress += amount;
    if (quest.progress >= quest.target) {
      quest.isCompleted = true;
    }
    await _saveProgress();
  }

  static Future<Map<String, int>> claimReward(String questId) async {
    final quest = [...dailyQuests, ...weeklyQuests]
        .where((q) => q.id == questId)
        .firstOrNull;
    
    if (quest == null || !quest.isCompleted || quest.isClaimed) {
      return {};
    }

    quest.isClaimed = true;
    await _saveProgress();
    return quest.reward;
  }

  static Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load last reset times
    final dailyStr = prefs.getString('last_daily_reset');
    if (dailyStr != null) _lastDailyReset = DateTime.parse(dailyStr);
    
    final weeklyStr = prefs.getString('last_weekly_reset');
    if (weeklyStr != null) _lastWeeklyReset = DateTime.parse(weeklyStr);

    // Load daily quests
    final dailyCount = prefs.getInt('daily_quest_count') ?? 0;
    for (int i = 0; i < dailyCount; i++) {
      final id = prefs.getString('daily_quest_${i}_id');
      if (id != null) {
        final progress = prefs.getInt('daily_quest_${i}_progress') ?? 0;
        final completed = prefs.getBool('daily_quest_${i}_completed') ?? false;
        final claimed = prefs.getBool('daily_quest_${i}_claimed') ?? false;
        
        // Find and update quest
        final quest = dailyQuests.where((q) => q.id == id).firstOrNull;
        if (quest != null) {
          quest.progress = progress;
          quest.isCompleted = completed;
          quest.isClaimed = claimed;
        }
      }
    }

    // Load weekly quests
    final weeklyCount = prefs.getInt('weekly_quest_count') ?? 0;
    for (int i = 0; i < weeklyCount; i++) {
      final id = prefs.getString('weekly_quest_${i}_id');
      if (id != null) {
        final progress = prefs.getInt('weekly_quest_${i}_progress') ?? 0;
        final completed = prefs.getBool('weekly_quest_${i}_completed') ?? false;
        final claimed = prefs.getBool('weekly_quest_${i}_claimed') ?? false;
        
        final quest = weeklyQuests.where((q) => q.id == id).firstOrNull;
        if (quest != null) {
          quest.progress = progress;
          quest.isCompleted = completed;
          quest.isClaimed = claimed;
        }
      }
    }
  }

  static Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save reset times
    if (_lastDailyReset != null) {
      await prefs.setString('last_daily_reset', _lastDailyReset!.toIso8601String());
    }
    if (_lastWeeklyReset != null) {
      await prefs.setString('last_weekly_reset', _lastWeeklyReset!.toIso8601String());
    }

    // Save daily quests
    await prefs.setInt('daily_quest_count', dailyQuests.length);
    for (int i = 0; i < dailyQuests.length; i++) {
      final quest = dailyQuests[i];
      await prefs.setString('daily_quest_${i}_id', quest.id);
      await prefs.setInt('daily_quest_${i}_progress', quest.progress);
      await prefs.setBool('daily_quest_${i}_completed', quest.isCompleted);
      await prefs.setBool('daily_quest_${i}_claimed', quest.isClaimed);
    }

    // Save weekly quests
    await prefs.setInt('weekly_quest_count', weeklyQuests.length);
    for (int i = 0; i < weeklyQuests.length; i++) {
      final quest = weeklyQuests[i];
      await prefs.setString('weekly_quest_${i}_id', quest.id);
      await prefs.setInt('weekly_quest_${i}_progress', quest.progress);
      await prefs.setBool('weekly_quest_${i}_completed', quest.isCompleted);
      await prefs.setBool('weekly_quest_${i}_claimed', quest.isClaimed);
    }
  }

  static int get unclaimedCount {
    return [...dailyQuests, ...weeklyQuests]
        .where((q) => q.isCompleted && !q.isClaimed)
        .length;
  }
}
