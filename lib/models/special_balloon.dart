import 'dart:math';

class SpecialBalloon {
  final String type; // 'gold', 'joker', 'slow'
  final String icon;
  final String description;

  SpecialBalloon({
    required this.type,
    required this.icon,
    required this.description,
  });
}

class SpecialBalloonManager {
  static final Random _random = Random();

  // Özel balon tipleri
  static final Map<String, SpecialBalloon> specialTypes = {
    'gold': SpecialBalloon(
      type: 'gold',
      icon: '🌟',
      description: '2x Puan Kazanırsın!',
    ),
    'joker': SpecialBalloon(
      type: 'joker',
      icon: '🃏',
      description: 'Eksik Harfi Tamamlar!',
    ),
    'slow': SpecialBalloon(
      type: 'slow',
      icon: '❄️',
      description: '5 Saniye Yavaşlatır!',
    ),
    'speed': SpecialBalloon(
      type: 'speed',
      icon: '⚡',
      description: 'Daha Fazla Balon!',
    ),
  };

  // Özel balon spawn şansları (%)
  static const double goldChance = 0.10; // %10
  static const double jokerChance = 0.05; // %5
  static const double slowChance = 0.08; // %8
  static const double speedChance = 0.07; // %7

  /// Normal balon mu yoksa özel balon mu spawn edilecek?
  static String? getSpecialType() {
    final roll = _random.nextDouble();

    if (roll < goldChance) {
      return 'gold';
    } else if (roll < goldChance + jokerChance) {
      return 'joker';
    } else if (roll < goldChance + jokerChance + slowChance) {
      return 'slow';
    } else if (roll < goldChance + jokerChance + slowChance + speedChance) {
      return 'speed';
    }

    return null; // Normal balon
  }

  /// Özel balon efekti uygulanacak mı?
  static bool shouldSpawnSpecial() {
    return _random.nextDouble() <
        (goldChance + jokerChance + slowChance + speedChance);
  }

  /// Rastgele bir özel balon tipi seç
  static String getRandomSpecialType() {
    final types = ['gold', 'joker', 'slow', 'speed'];
    return types[_random.nextInt(types.length)];
  }
}
