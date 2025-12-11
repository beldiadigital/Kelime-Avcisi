import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameTheme {
  final String id;
  final String name;
  final List<Color> gradientColors;
  final Color bubbleColor1;
  final Color bubbleColor2;
  final Color bubbleColor3;
  final int unlockCost; // Coin fiyatı
  final int gemCost; // Elmas fiyatı
  final String icon;
  bool isUnlocked;

  GameTheme({
    required this.id,
    required this.name,
    required this.gradientColors,
    required this.bubbleColor1,
    required this.bubbleColor2,
    required this.bubbleColor3,
    required this.unlockCost,
    this.gemCost = 0, // Varsayılan 0
    required this.icon,
    this.isUnlocked = false,
  });
}

class ThemeManager {
  static List<GameTheme> themes = [
    GameTheme(
      id: 'default',
      name: 'Varsayılan',
      gradientColors: [Color(0xFF6DD5FA), Color(0xFFFF758C)],
      bubbleColor1: Colors.pinkAccent,
      bubbleColor2: Colors.orangeAccent,
      bubbleColor3: Colors.cyan,
      unlockCost: 0,
      gemCost: 0,
      icon: '🎨',
      isUnlocked: true,
    ),
    GameTheme(
      id: 'ocean',
      name: 'Okyanus',
      gradientColors: [Color(0xFF0052D4), Color(0xFF4364F7), Color(0xFF6FB1FC)],
      bubbleColor1: Colors.blue.shade300,
      bubbleColor2: Colors.teal.shade300,
      bubbleColor3: Colors.cyan.shade200,
      unlockCost: 500,
      gemCost: 10,
      icon: '🌊',
    ),
    GameTheme(
      id: 'space',
      name: 'Uzay',
      gradientColors: [Color(0xFF000428), Color(0xFF004e92)],
      bubbleColor1: Colors.purple.shade300,
      bubbleColor2: Colors.indigo.shade300,
      bubbleColor3: Colors.deepPurple.shade200,
      unlockCost: 750,
      gemCost: 15,
      icon: '🚀',
    ),
    GameTheme(
      id: 'forest',
      name: 'Orman',
      gradientColors: [Color(0xFF134E5E), Color(0xFF71B280)],
      bubbleColor1: Colors.green.shade300,
      bubbleColor2: Colors.lightGreen.shade300,
      bubbleColor3: Colors.lime.shade200,
      unlockCost: 1000,
      gemCost: 20,
      icon: '🌲',
    ),
    GameTheme(
      id: 'sunset',
      name: 'Gün Batımı',
      gradientColors: [Color(0xFFFF512F), Color(0xFFF09819)],
      bubbleColor1: Colors.orange.shade300,
      bubbleColor2: Colors.deepOrange.shade300,
      bubbleColor3: Colors.amber.shade200,
      unlockCost: 1250,
      gemCost: 25,
      icon: '🌅',
    ),
    GameTheme(
      id: 'night',
      name: 'Gece',
      gradientColors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
      bubbleColor1: Colors.blueGrey.shade300,
      bubbleColor2: Colors.grey.shade400,
      bubbleColor3: Colors.blueGrey.shade200,
      unlockCost: 1500,
      gemCost: 30,
      icon: '🌙',
    ),
  ];

  static String _currentThemeId = 'default';

  static GameTheme get currentTheme {
    return themes.firstWhere(
      (t) => t.id == _currentThemeId,
      orElse: () => themes[0],
    );
  }

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentThemeId = prefs.getString('current_theme') ?? 'default';
    
    // Load unlocked themes
    for (var theme in themes) {
      theme.isUnlocked = prefs.getBool('theme_${theme.id}') ?? (theme.id == 'default');
    }
  }

  static Future<bool> unlockTheme(String themeId, int coins) async {
    final theme = themes.firstWhere((t) => t.id == themeId);
    
    if (theme.isUnlocked) return false;
    if (coins < theme.unlockCost) return false;

    theme.isUnlocked = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('theme_$themeId', true);
    return true;
  }

  static Future<void> setTheme(String themeId) async {
    final theme = themes.firstWhere((t) => t.id == themeId);
    if (!theme.isUnlocked) return;

    _currentThemeId = themeId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_theme', themeId);
  }

  static int get unlockedCount => themes.where((t) => t.isUnlocked).length;
}
