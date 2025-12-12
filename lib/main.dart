import 'dart:async' as async;
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/particles.dart';
import 'package:flame/effects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform;
import 'package:confetti/confetti.dart';
import 'package:share_plus/share_plus.dart';
import 'models/achievement.dart';
import 'models/currency.dart';
import 'models/stars.dart';
import 'models/life_system.dart';
import 'models/quest.dart';
import 'models/theme.dart';
import 'models/player_level.dart';
import 'models/daily_reward.dart';
import 'models/special_balloon.dart';
import 'models/time_record.dart';
import 'models/app_rating.dart';
import 'services/sound_manager.dart';
import 'services/iap_service.dart';
import 'utils/responsive_helper.dart';

// ==========================================
// 1. VERİ YAPILARI VE KATEGORİLER
// ==========================================

// ADMOB YÖNETİMİ
class AdMobHelper {
  // Test modunu açmak için true yapın
  // PRODUCTION İÇİN FALSE YAPMAYI UNUTMAYIN!
  static const bool isTestMode = false;

  static String get bannerAdUnitId {
    if (isTestMode) {
      // Test reklamları
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111'; // Test Banner Android
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716'; // Test Banner iOS
      }
    } else {
      // Gerçek reklamlar (production)
      if (Platform.isAndroid) {
        return 'ca-app-pub-9098317866883430/5233275608';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-9098317866883430/5233275608';
      }
    }
    throw UnsupportedError('Unsupported platform');
  }

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }
}

enum GameDifficulty { kolay, orta, zor }

enum WordCategory { hayvanlar, dogal, bilim, gunluk, karisik }

class WordData {
  final String word;
  final WordCategory category;
  final GameDifficulty difficulty;

  const WordData(this.word, this.category, this.difficulty);

  // KATEGORİ BAZLI KELİMELER
  static const Map<WordCategory, List<WordData>> categoryWords = {
    WordCategory.hayvanlar: [
      WordData("ASLAN", WordCategory.hayvanlar, GameDifficulty.kolay),
      WordData("KAPLAN", WordCategory.hayvanlar, GameDifficulty.orta),
      WordData("ZEBRA", WordCategory.hayvanlar, GameDifficulty.kolay),
      WordData("PANDA", WordCategory.hayvanlar, GameDifficulty.kolay),
      WordData("KOALA", WordCategory.hayvanlar, GameDifficulty.kolay),
      WordData("FİL", WordCategory.hayvanlar, GameDifficulty.kolay),
      WordData("ZÜRAFА", WordCategory.hayvanlar, GameDifficulty.orta),
      WordData("KELEBEK", WordCategory.hayvanlar, GameDifficulty.zor),
      WordData("KÖPEK", WordCategory.hayvanlar, GameDifficulty.kolay),
      WordData("KEDİ", WordCategory.hayvanlar, GameDifficulty.kolay),
    ],
    WordCategory.dogal: [
      WordData("DENİZ", WordCategory.dogal, GameDifficulty.kolay),
      WordData("GÜNEŞ", WordCategory.dogal, GameDifficulty.kolay),
      WordData("BULUT", WordCategory.dogal, GameDifficulty.kolay),
      WordData("YILDIZ", WordCategory.dogal, GameDifficulty.orta),
      WordData("DÜNYA", WordCategory.dogal, GameDifficulty.kolay),
      WordData("DAĞ", WordCategory.dogal, GameDifficulty.kolay),
      WordData("ORMAN", WordCategory.dogal, GameDifficulty.kolay),
      WordData("GÖKYÜZÜ", WordCategory.dogal, GameDifficulty.orta),
      WordData("NEHIR", WordCategory.dogal, GameDifficulty.kolay),
      WordData("ÇİÇEK", WordCategory.dogal, GameDifficulty.kolay),
    ],
    WordCategory.bilim: [
      WordData("ROBOT", WordCategory.bilim, GameDifficulty.kolay),
      WordData("UZAY", WordCategory.bilim, GameDifficulty.kolay),
      WordData("ROKET", WordCategory.bilim, GameDifficulty.kolay),
      WordData("BİLGİ", WordCategory.bilim, GameDifficulty.kolay),
      WordData("ATOM", WordCategory.bilim, GameDifficulty.orta),
      WordData("TELESKOP", WordCategory.bilim, GameDifficulty.zor),
      WordData("DENEY", WordCategory.bilim, GameDifficulty.kolay),
      WordData("GEZEGEN", WordCategory.bilim, GameDifficulty.orta),
      WordData("UYDU", WordCategory.bilim, GameDifficulty.kolay),
    ],
    WordCategory.gunluk: [
      WordData("KİTAP", WordCategory.gunluk, GameDifficulty.kolay),
      WordData("ELMA", WordCategory.gunluk, GameDifficulty.kolay),
      WordData("SÜT", WordCategory.gunluk, GameDifficulty.kolay),
      WordData("TOP", WordCategory.gunluk, GameDifficulty.kolay),
      WordData("KALEM", WordCategory.gunluk, GameDifficulty.kolay),
      WordData("ÇANTA", WordCategory.gunluk, GameDifficulty.kolay),
      WordData("AYAKKABI", WordCategory.gunluk, GameDifficulty.orta),
      WordData("MASA", WordCategory.gunluk, GameDifficulty.kolay),
      WordData("SANDALYE", WordCategory.gunluk, GameDifficulty.orta),
    ],
  };

  static WordData getRandom([
    WordCategory? category,
    GameDifficulty? difficulty,
  ]) {
    List<WordData> pool = [];

    if (category != null) {
      pool = categoryWords[category] ?? [];
    } else {
      categoryWords.values.forEach((words) => pool.addAll(words));
    }

    if (difficulty != null) {
      pool = pool.where((w) => w.difficulty == difficulty).toList();
    }

    return pool[Random().nextInt(pool.length)];
  }
}

// SEVİYE SİSTEMİ - CANDY CRUSH TARZI (KALICI KAYIT)
class LevelProgress {
  static Map<GameDifficulty, int> completedLevels = {
    GameDifficulty.kolay: 0,
    GameDifficulty.orta: 0,
    GameDifficulty.zor: 0,
  };

  static Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    completedLevels[GameDifficulty.kolay] = prefs.getInt('level_kolay') ?? 0;
    completedLevels[GameDifficulty.orta] = prefs.getInt('level_orta') ?? 0;
    completedLevels[GameDifficulty.zor] = prefs.getInt('level_zor') ?? 0;
  }

  static Future<void> completeLevel(
    GameDifficulty difficulty,
    int level,
  ) async {
    if (level > (completedLevels[difficulty] ?? 0)) {
      completedLevels[difficulty] = level;

      // Kalıcı olarak kaydet
      final prefs = await SharedPreferences.getInstance();
      String key = difficulty == GameDifficulty.kolay
          ? 'level_kolay'
          : difficulty == GameDifficulty.orta
          ? 'level_orta'
          : 'level_zor';
      await prefs.setInt(key, level);
    }
  }

  static bool isLevelUnlocked(GameDifficulty difficulty, int level) {
    return level <= (completedLevels[difficulty] ?? 0) + 1;
  }

  static int getCompletedCount(GameDifficulty difficulty) {
    return completedLevels[difficulty] ?? 0;
  }
}

// SEVİYE TANIMI
class LevelData {
  final int level;
  final GameDifficulty difficulty;
  final String word;
  final int targetScore;
  final int timeLimit; // 0 = süresiz
  final bool hasMovingSlots;

  const LevelData({
    required this.level,
    required this.difficulty,
    required this.word,
    required this.targetScore,
    this.timeLimit = 0,
    this.hasMovingSlots = false,
  });

  // Her zorluk için 10 seviye - GİTTİKÇE ZORLAŞAN KELİMELER
  static List<LevelData> getLevelsForDifficulty(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.kolay:
        return [
          LevelData(
            level: 1,
            difficulty: difficulty,
            word: "AT",
            targetScore: 100,
          ),
          LevelData(
            level: 2,
            difficulty: difficulty,
            word: "EV",
            targetScore: 100,
          ),
          LevelData(
            level: 3,
            difficulty: difficulty,
            word: "TOP",
            targetScore: 100,
          ),
          LevelData(
            level: 4,
            difficulty: difficulty,
            word: "SÜT",
            targetScore: 150,
          ),
          LevelData(
            level: 5,
            difficulty: difficulty,
            word: "ELMA",
            targetScore: 150,
          ),
          LevelData(
            level: 6,
            difficulty: difficulty,
            word: "KEDI",
            targetScore: 200,
            timeLimit: 60,
          ),
          LevelData(
            level: 7,
            difficulty: difficulty,
            word: "BULUT",
            targetScore: 200,
            timeLimit: 55,
          ),
          LevelData(
            level: 8,
            difficulty: difficulty,
            word: "GÜNEŞ",
            targetScore: 250,
            timeLimit: 50,
          ),
          LevelData(
            level: 9,
            difficulty: difficulty,
            word: "YILDIZ",
            targetScore: 250,
            timeLimit: 45,
          ),
          LevelData(
            level: 10,
            difficulty: difficulty,
            word: "DÜNYA",
            targetScore: 300,
            timeLimit: 40,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 11,
            difficulty: difficulty,
            word: "KUŞLAR",
            targetScore: 300,
            timeLimit: 40,
          ),
          LevelData(
            level: 12,
            difficulty: difficulty,
            word: "ARABA",
            targetScore: 350,
            timeLimit: 38,
          ),
          LevelData(
            level: 13,
            difficulty: difficulty,
            word: "BALON",
            targetScore: 350,
            timeLimit: 38,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 14,
            difficulty: difficulty,
            word: "ÇANTA",
            targetScore: 400,
            timeLimit: 35,
          ),
          LevelData(
            level: 15,
            difficulty: difficulty,
            word: "KÖPEK",
            targetScore: 400,
            timeLimit: 35,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 16,
            difficulty: difficulty,
            word: "MASA",
            targetScore: 450,
            timeLimit: 32,
          ),
          LevelData(
            level: 17,
            difficulty: difficulty,
            word: "SANDIK",
            targetScore: 450,
            timeLimit: 32,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 18,
            difficulty: difficulty,
            word: "ORMAN",
            targetScore: 500,
            timeLimit: 30,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 19,
            difficulty: difficulty,
            word: "DENIZ",
            targetScore: 500,
            timeLimit: 30,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 20,
            difficulty: difficulty,
            word: "GÖKYÜZÜ",
            targetScore: 550,
            timeLimit: 28,
            hasMovingSlots: true,
          ),
        ];

      case GameDifficulty.orta:
        return [
          LevelData(
            level: 1,
            difficulty: difficulty,
            word: "KALEM",
            targetScore: 200,
            timeLimit: 50,
          ),
          LevelData(
            level: 2,
            difficulty: difficulty,
            word: "KITAP",
            targetScore: 200,
            timeLimit: 50,
          ),
          LevelData(
            level: 3,
            difficulty: difficulty,
            word: "ARMUT",
            targetScore: 250,
            timeLimit: 45,
          ),
          LevelData(
            level: 4,
            difficulty: difficulty,
            word: "ROBOT",
            targetScore: 250,
            timeLimit: 45,
          ),
          LevelData(
            level: 5,
            difficulty: difficulty,
            word: "ZEBRA",
            targetScore: 300,
            timeLimit: 40,
          ),
          LevelData(
            level: 6,
            difficulty: difficulty,
            word: "ORMAN",
            targetScore: 300,
            timeLimit: 40,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 7,
            difficulty: difficulty,
            word: "DENIZ",
            targetScore: 350,
            timeLimit: 35,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 8,
            difficulty: difficulty,
            word: "KAPLAN",
            targetScore: 400,
            timeLimit: 30,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 9,
            difficulty: difficulty,
            word: "GÖKYÜZÜ",
            targetScore: 450,
            timeLimit: 30,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 10,
            difficulty: difficulty,
            word: "ÇIKOLATA",
            targetScore: 500,
            timeLimit: 25,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 11,
            difficulty: difficulty,
            word: "ASLAN",
            targetScore: 550,
            timeLimit: 22,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 12,
            difficulty: difficulty,
            word: "BALIK",
            targetScore: 600,
            timeLimit: 20,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 13,
            difficulty: difficulty,
            word: "KUŞLAR",
            targetScore: 650,
            timeLimit: 20,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 14,
            difficulty: difficulty,
            word: "YATAK",
            targetScore: 700,
            timeLimit: 18,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 15,
            difficulty: difficulty,
            word: "SANDALYE",
            targetScore: 750,
            timeLimit: 18,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 16,
            difficulty: difficulty,
            word: "ÇERÇEVE",
            targetScore: 800,
            timeLimit: 16,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 17,
            difficulty: difficulty,
            word: "MASA",
            targetScore: 850,
            timeLimit: 16,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 18,
            difficulty: difficulty,
            word: "PENCERE",
            targetScore: 900,
            timeLimit: 15,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 19,
            difficulty: difficulty,
            word: "TAŞLAR",
            targetScore: 950,
            timeLimit: 15,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 20,
            difficulty: difficulty,
            word: "KÜTÜPHANE",
            targetScore: 1000,
            timeLimit: 14,
            hasMovingSlots: true,
          ),
        ];

      case GameDifficulty.zor:
        return [
          LevelData(
            level: 1,
            difficulty: difficulty,
            word: "KELEBEK",
            targetScore: 300,
            timeLimit: 45,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 2,
            difficulty: difficulty,
            word: "AYAKKABI",
            targetScore: 350,
            timeLimit: 40,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 3,
            difficulty: difficulty,
            word: "TELESKOP",
            targetScore: 400,
            timeLimit: 35,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 4,
            difficulty: difficulty,
            word: "BİLGİSAYAR",
            targetScore: 450,
            timeLimit: 35,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 5,
            difficulty: difficulty,
            word: "GÖKKUŞAĞI",
            targetScore: 500,
            timeLimit: 30,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 6,
            difficulty: difficulty,
            word: "UÇURTMA",
            targetScore: 550,
            timeLimit: 28,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 7,
            difficulty: difficulty,
            word: "KİTAPLIK",
            targetScore: 600,
            timeLimit: 25,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 8,
            difficulty: difficulty,
            word: "OYUNCAK",
            targetScore: 650,
            timeLimit: 22,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 9,
            difficulty: difficulty,
            word: "KARTOPU",
            targetScore: 700,
            timeLimit: 20,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 10,
            difficulty: difficulty,
            word: "BAHARATLIK",
            targetScore: 800,
            timeLimit: 18,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 11,
            difficulty: difficulty,
            word: "MÜHENDİS",
            targetScore: 850,
            timeLimit: 17,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 12,
            difficulty: difficulty,
            word: "DOKTORLAR",
            targetScore: 900,
            timeLimit: 16,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 13,
            difficulty: difficulty,
            word: "ÖĞRETMEN",
            targetScore: 950,
            timeLimit: 15,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 14,
            difficulty: difficulty,
            word: "HEMŞIRE",
            targetScore: 1000,
            timeLimit: 14,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 15,
            difficulty: difficulty,
            word: "ASTRONOT",
            targetScore: 1050,
            timeLimit: 13,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 16,
            difficulty: difficulty,
            word: "ÇAMAŞIR",
            targetScore: 1100,
            timeLimit: 12,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 17,
            difficulty: difficulty,
            word: "BUZDOLABI",
            targetScore: 1150,
            timeLimit: 12,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 18,
            difficulty: difficulty,
            word: "KARANLIK",
            targetScore: 1200,
            timeLimit: 11,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 19,
            difficulty: difficulty,
            word: "PAZARTESI",
            targetScore: 1250,
            timeLimit: 11,
            hasMovingSlots: true,
          ),
          LevelData(
            level: 20,
            difficulty: difficulty,
            word: "KÜTÜPHANE",
            targetScore: 1300,
            timeLimit: 10,
            hasMovingSlots: true,
          ),
        ];
    }
  }
}

// OYUNCU İSTATİSTİKLERİ
class PlayerStats {
  static int totalScore = 0;
  static int wordsCompleted = 0;
  static int highestCombo = 0;
  static int perfectGames = 0;
  static Map<String, int> achievements = {
    'first_word': 0,
    'ten_words': 0,
    'perfect_game': 0,
    'speed_master': 0,
    'combo_king': 0,
  };

  static void addScore(int points) {
    totalScore += points;
  }

  static void incrementWords() {
    wordsCompleted++;
    if (wordsCompleted == 1) achievements['first_word'] = 1;
    if (wordsCompleted >= 10) achievements['ten_words'] = 1;
  }

  static void recordCombo(int combo) {
    if (combo > highestCombo) {
      highestCombo = combo;
      if (combo >= 5) achievements['combo_king'] = 1;
    }
  }
}

// POWER-UP SİSTEMİ
enum PowerUpType { ampul, buz, miknatIs }

class PowerUp {
  final PowerUpType type;
  int count;
  final String icon;
  final String description;
  final Color color;

  PowerUp({
    required this.type,
    this.count = 3,
    required this.icon,
    required this.description,
    required this.color,
  });

  static List<PowerUp> getInitialPowerUps() {
    return [
      PowerUp(
        type: PowerUpType.ampul,
        count: 3,
        icon: "💡",
        description: "Sonraki harfi göster",
        color: Colors.amber,
      ),
      PowerUp(
        type: PowerUpType.buz,
        count: 2,
        icon: "❄️",
        description: "Balonları 5sn durdur",
        color: Colors.cyan,
      ),
      PowerUp(
        type: PowerUpType.miknatIs,
        count: 2,
        icon: "🧲",
        description: "Doğru harfi çek",
        color: Colors.purple,
      ),
    ];
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LevelProgress.loadProgress();
  await AchievementManager.loadProgress();
  await CurrencyManager.loadCurrency();
  await LevelStars.loadStars();
  await LifeSystem.loadLives();
  await QuestManager.init();
  await ThemeManager.init();
  await PlayerLevel.init();
  await DailyRewardSystem.init();
  await SoundManager().init();
  await AdMobHelper.initialize();
  await IAPService.initialize(); // In-app purchase başlat
  runApp(const DragDropApp());
}

class DragDropApp extends StatelessWidget {
  const DragDropApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kelime Avcısı',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      builder: (context, child) {
        // Responsive text scaling with max limit
        final currentScale = MediaQuery.of(context).textScaler.scale(1.0);
        final clampedScale = currentScale.clamp(0.8, 1.3);

        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(clampedScale)),
          child: child!,
        );
      },
      home: const MainMenuPage(),
    );
  }
}

// ==========================================
// ANA MENÜ EKRANI - CANDY CRUSH TARZI
// ==========================================
class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  late ConfettiController _confettiController;

  // Test modu için gizli sayaç
  int _levelTapCount = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _loadBannerAd();

    // Açılış kontrollerini çalıştır
    _performStartupChecks();
  }

  // Oyun açılışında yapılacak kontroller
  Future<void> _performStartupChecks() async {
    // Açılış sayısını artır
    await AppRatingSystem.incrementLaunchCount();

    // Kısa bir gecikme sonrası kontrolleri yap
    await Future.delayed(const Duration(milliseconds: 500));

    // 1. Günlük ödül kontrolü
    await _checkAndShowDailyReward();

    // 2. Rating isteği kontrolü (günlük ödülden sonra)
    await Future.delayed(const Duration(milliseconds: 500));
    await _checkAndShowRatingPrompt();
  }

  // Günlük ödül kontrolü ve gösterimi
  Future<void> _checkAndShowDailyReward() async {
    if (DailyRewardSystem.canClaimToday && mounted) {
      await Future.delayed(const Duration(milliseconds: 300));
      _showDailyReward();
    }
  }

  // Rating isteği kontrolü ve gösterimi
  Future<void> _checkAndShowRatingPrompt() async {
    final shouldShow = await AppRatingSystem.shouldShowRatingPrompt();
    if (shouldShow && mounted) {
      _showRatingDialog();
    }
  }

  void _loadBannerAd() async {
    // Reklamsız abonelik varsa reklam yükleme
    final hasSubscription = await IAPService.hasActiveNoAdsSubscription();
    if (hasSubscription) {
      setState(() {
        _isBannerAdReady = false;
      });
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: AdMobHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Banner reklam yüklenemedi: $err');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd!.load();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bannerAd?.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFF093FB),
              Color(0xFFF5576C),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Confetti
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  particleDrag: 0.05,
                  emissionFrequency: 0.05,
                  numberOfParticles: 50,
                  gravity: 0.1,
                ),
              ),

              // Arka plan parıltıları
              Positioned.fill(child: CustomPaint(painter: SparklesPainter())),

              // Ana içerik - ScrollView ile
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // ÜST BAR - Para ve Butonlar
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Ayarlar butonu
                                _buildIconButton(
                                  icon: Icons.settings,
                                  onTap: () => _showSettings(),
                                ),

                                // Para göstergeleri
                                Row(
                                  children: [
                                    _buildCurrencyDisplay(
                                      icon: "🪙",
                                      value: CurrencyManager.coins,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () => _showGemStore(),
                                      child: _buildCurrencyDisplay(
                                        icon: "💎",
                                        value: CurrencyManager.gems,
                                        color: Colors.cyan,
                                      ),
                                    ),
                                  ],
                                ),

                                // Başarımlar butonu
                                Stack(
                                  children: [
                                    _buildIconButton(
                                      icon: Icons.emoji_events,
                                      onTap: () => _showAchievements(),
                                    ),
                                    if (AchievementManager.unlockedCount > 0)
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '${AchievementManager.unlockedCount}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Can ve XP göstergesi
                            Row(
                              children: [
                                // Can göstergesi (tıklanabilir)
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _showLifeShop(),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            "❤️",
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            "${LifeSystem.currentLives}/${LifeSystem.maxLives}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          if (LifeSystem.currentLives <
                                              LifeSystem.maxLives) ...[
                                            const SizedBox(width: 5),
                                            Text(
                                              LifeSystem.getNextLifeTime(),
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.7,
                                                ),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                // XP göstergesi (Gizli test modu için tıklanabilir)
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _levelTapCount++;

                                        if (_levelTapCount >= 15) {
                                          // Test modunu aç
                                          _levelTapCount = 0;
                                          _showTestModeDialog();
                                        } else {
                                          // 3 saniye içinde 15 kez basmazsa sayacı sıfırla
                                          Future.delayed(
                                            const Duration(seconds: 3),
                                            () {
                                              if (mounted) {
                                                setState(() {
                                                  _levelTapCount = 0;
                                                });
                                              }
                                            },
                                          );
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Lv.${PlayerLevel.currentLevel}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                "${PlayerLevel.currentXP}/${PlayerLevel.xpNeeded}",
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: LinearProgressIndicator(
                                              value: PlayerLevel.progress,
                                              backgroundColor: Colors.white
                                                  .withOpacity(0.2),
                                              valueColor:
                                                  const AlwaysStoppedAnimation(
                                                    Colors.amber,
                                                  ),
                                              minHeight: 4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: context.responsive.spacing(base: 30)),

                      // Başlık - Modern Typography (Responsive)
                      Container(
                        padding: context.responsive.padding(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(
                            context.responsive.borderRadius(base: 30),
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Text(
                          "KELİME AVCISI",
                          style: TextStyle(
                            fontSize: context.responsive.fontSize(
                              small: 28,
                              medium: 36,
                              large: 44,
                            ),
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),

                      SizedBox(height: context.responsive.spacing(base: 15)),

                      // Alt başlık
                      Text(
                        "Harfleri Yakala • Kelimeleri Tamamla",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Günlük Ödül Butonu (Büyük ve Göze Çarpan)
                      if (DailyRewardSystem.canClaimToday)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: GestureDetector(
                            onTap: () => _showDailyReward(),
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFD700),
                                    Color(0xFFFF6B00),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.5),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "🎁",
                                    style: TextStyle(fontSize: 30),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "GÜNLÜK ÖDÜL!",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Text(
                                        "Gün ${DailyRewardSystem.currentStreak + 1}/7 - Al!",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 15),

                      // Özel Özellik Butonları (Görevler, Mağaza, Temalar)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildFeatureButton(
                              icon: Icons.task_alt,
                              label: "Görevler",
                              badge: QuestManager.unclaimedCount > 0
                                  ? "${QuestManager.unclaimedCount}"
                                  : null,
                              onTap: () => _showQuests(),
                            ),
                            _buildFeatureButton(
                              icon: Icons.shopping_bag,
                              label: "Mağaza",
                              badge: null,
                              onTap: () => _showShop(),
                            ),
                            _buildFeatureButton(
                              icon: Icons.palette,
                              label: "Temalar",
                              badge:
                                  "${ThemeManager.unlockedCount}/${ThemeManager.themes.length}",
                              onTap: () => _showThemes(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Zorluk Butonları - Ultra Modern Kartlar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          children: [
                            _buildModernButton(
                              context,
                              icon: "⭐",
                              title: "KOLAY",
                              subtitle:
                                  "${LevelProgress.getCompletedCount(GameDifficulty.kolay)}/10 Tamamlandı",
                              gradient: const [
                                Color(0xFF4facfe),
                                Color(0xFF00f2fe),
                              ],
                              difficulty: GameDifficulty.kolay,
                            ),
                            const SizedBox(height: 20),
                            _buildModernButton(
                              context,
                              icon: "🌟",
                              title: "ORTA",
                              subtitle:
                                  "${LevelProgress.getCompletedCount(GameDifficulty.orta)}/10 Tamamlandı",
                              gradient: const [
                                Color(0xFFfa709a),
                                Color(0xFFfee140),
                              ],
                              difficulty: GameDifficulty.orta,
                            ),
                            const SizedBox(height: 20),
                            _buildModernButton(
                              context,
                              icon: "🔥",
                              title: "ZOR",
                              subtitle:
                                  "${LevelProgress.getCompletedCount(GameDifficulty.zor)}/10 Tamamlandı",
                              gradient: const [
                                Color(0xFFf857a6),
                                Color(0xFFff5858),
                              ],
                              difficulty: GameDifficulty.zor,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Günlük ödül butonu
                      if (DailyRewardSystem.canClaimToday)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 10,
                          ),
                          child: GestureDetector(
                            onTap: _showDailyReward,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFD700),
                                    Color(0xFFFFA500),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.5),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text("🎁", style: TextStyle(fontSize: 24)),
                                  SizedBox(width: 10),
                                  Text(
                                    "GÜNLÜK ÖDÜLÜNÜ AL!",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 10),

                      // AdMob Banner Reklamı
                      if (_isBannerAdReady && _bannerAd != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          height: 55,
                          child: AdWidget(ad: _bannerAd!),
                        )
                      else
                        const SizedBox(height: 10),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        SoundManager().playClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildCurrencyDisplay({
    required String icon,
    required int value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 5),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SettingsSheet(),
    );
  }

  void _showAchievements() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AchievementsPage()),
    );
  }

  void _showDailyReward() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => DailyRewardDialog(onClaimed: () => setState(() {})),
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Text('⭐', style: TextStyle(fontSize: 50)),
            SizedBox(height: 10),
            Text(
              'Kelime Avcısı\'nı Beğendiniz mi?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Oyunumuzu değerlendirerek bize destek olabilirsiniz! Görüşleriniz bizim için çok değerli.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              AppRatingSystem.userDeclined();
              Navigator.pop(ctx);
            },
            child: const Text('Hayır, Teşekkürler'),
          ),
          TextButton(
            onPressed: () {
              AppRatingSystem.userPostponed();
              Navigator.pop(ctx);
            },
            child: const Text('Daha Sonra'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              AppRatingSystem.openAppStore();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Teşekkürler! 🌟'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Text('App Store\'da Değerlendir'),
          ),
        ],
      ),
    );
  }

  void _showLifeShop() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LifeShopPage()),
    ).then((_) {
      // Can mağazasından döndüğünde sayfayı yenile
      if (mounted) setState(() {});
    });
  }

  void _showGemStore() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GemStorePage()),
    ).then((_) {
      // Elmas mağazasından döndüğünde sayfayı yenile
      if (mounted) setState(() {});
    });
  }

  void _showTestModeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.developer_mode, color: Colors.orange),
            SizedBox(width: 8),
            Text('🔧 Test Modu'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Geliştirici test araçları',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Elmas ekle
              ElevatedButton.icon(
                onPressed: () async {
                  await CurrencyManager.addGems(1000);
                  Navigator.pop(ctx);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ 1000 elmas eklendi!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Text('💎'),
                label: const Text('1000 Elmas Ekle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              // Altın ekle
              ElevatedButton.icon(
                onPressed: () async {
                  await CurrencyManager.addCoins(10000);
                  Navigator.pop(ctx);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ 10000 altın eklendi!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Text('🪙'),
                label: const Text('10000 Altın Ekle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              // Can doldur
              ElevatedButton.icon(
                onPressed: () async {
                  LifeSystem.refillLives();
                  Navigator.pop(ctx);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Canlar dolduruldu!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Text('❤️'),
                label: const Text('Canları Doldur'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              // Tüm temaları aç
              ElevatedButton.icon(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setStringList('unlockedThemes', [
                    'ocean',
                    'space',
                    'forest',
                    'sunset',
                    'night',
                    'neon',
                  ]);
                  Navigator.pop(ctx);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Tüm temalar açıldı!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Text('🎨'),
                label: const Text('Tüm Temaları Aç'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              // XP ekle
              ElevatedButton.icon(
                onPressed: () async {
                  await PlayerLevel.addXP(500);
                  Navigator.pop(ctx);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ 500 XP eklendi!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Text('⭐'),
                label: const Text('500 XP Ekle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // İptal
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Kapat'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuests() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuestsPage()),
    ).then((_) {
      // Görevlerden döndüğünde sayfayı yenile
      if (mounted) setState(() {});
    });
  }

  void _showShop() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PowerUpShopPage()),
    ).then((_) {
      // Mağazadan döndüğünde sayfayı yenile
      if (mounted) setState(() {});
    });
  }

  void _showThemes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ThemesPage()),
    ).then((_) {
      // Temalardan döndüğünde sayfayı yenile
      if (mounted) setState(() {});
    });
  }

  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        SoundManager().playClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (badge != null)
              Positioned(
                top: -5,
                right: -5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernButton(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required GameDifficulty difficulty,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LevelSelectPage(difficulty: difficulty),
          ),
        );
      },
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              // Glassmorphism overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                  ),
                ),
              ),

              // Parlama efekti
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // İçerik
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 17,
                ),
                child: Row(
                  children: [
                    // İkon - Daha büyük ve belirgin
                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(icon, style: const TextStyle(fontSize: 32)),
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Yazılar
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.0,
                              shadows: [
                                Shadow(
                                  offset: Offset(2, 2),
                                  blurRadius: 4,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.95),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Ok ikonu
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Parıltı efekti için custom painter
class SparklesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final random = Random(42); // Sabit seed için aynı pozisyonlar

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 3 + 1;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==========================================
// SEVİYE SEÇİM EKRANI - CANDY CRUSH TARZI
// ==========================================
class LevelSelectPage extends StatelessWidget {
  final GameDifficulty difficulty;

  const LevelSelectPage({super.key, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final levels = LevelData.getLevelsForDifficulty(difficulty);
    final completedCount = LevelProgress.getCompletedCount(difficulty);

    String difficultyName = difficulty == GameDifficulty.kolay
        ? "KOLAY"
        : difficulty == GameDifficulty.orta
        ? "ORTA"
        : "ZOR";

    Color primaryColor = difficulty == GameDifficulty.kolay
        ? const Color(0xFF56CCF2)
        : difficulty == GameDifficulty.orta
        ? const Color(0xFFF093FB)
        : const Color(0xFFFA709A);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor, primaryColor.withOpacity(0.6)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Üst Bar
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            difficultyName,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "$completedCount / 10 Tamamlandı",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48), // Balance için
                  ],
                ),
              ),

              // Seviye Grid'i (Responsive)
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // iPad: 5 sütun, Büyük telefon: 4 sütun, Normal: 3 sütun, Küçük: 3 sütun
                    int crossAxisCount;
                    double childAspectRatio;

                    if (context.responsive.isTablet) {
                      crossAxisCount = 5;
                      childAspectRatio = 0.9;
                    } else if (context.responsive.isLargePhone) {
                      crossAxisCount = 4;
                      childAspectRatio = 0.85;
                    } else {
                      crossAxisCount = 3;
                      childAspectRatio = 0.8;
                    }

                    return GridView.builder(
                      padding: EdgeInsets.fromLTRB(
                        context.responsive.spacing(base: 15),
                        context.responsive.spacing(base: 10),
                        context.responsive.spacing(base: 15),
                        context.responsive.spacing(base: 15),
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: childAspectRatio,
                        crossAxisSpacing: context.responsive.spacing(base: 12),
                        mainAxisSpacing: context.responsive.spacing(base: 12),
                      ),
                      itemCount: levels.length,
                      itemBuilder: (context, index) {
                        final level = levels[index];
                        final isUnlocked = LevelProgress.isLevelUnlocked(
                          difficulty,
                          level.level,
                        );
                        final isCompleted = level.level <= completedCount;

                        return _buildLevelCard(
                          context,
                          level: level,
                          isUnlocked: isUnlocked,
                          isCompleted: isCompleted,
                          primaryColor: primaryColor,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(
    BuildContext context, {
    required LevelData level,
    required bool isUnlocked,
    required bool isCompleted,
    required Color primaryColor,
  }) {
    final difficultyName = level.difficulty == GameDifficulty.kolay
        ? 'kolay'
        : level.difficulty == GameDifficulty.orta
        ? 'orta'
        : 'zor';
    final stars = LevelStars.getStars(difficultyName, level.level);

    return GestureDetector(
      onTap: isUnlocked
          ? () {
              SoundManager().playClick();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      GamePage(difficulty: level.difficulty, levelData: level),
                ),
              );
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isUnlocked
                ? [Colors.white, Colors.white.withOpacity(0.8)]
                : [Colors.grey.shade400, Colors.grey.shade500],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isUnlocked
                  ? primaryColor.withOpacity(0.3)
                  : Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Yıldızlar (üst)
            if (isCompleted && stars > 0)
              Positioned(
                top: 5,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Icon(
                      index < stars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 14,
                    );
                  }),
                ),
              ),

            // Kilit ikonu
            if (!isUnlocked)
              const Center(
                child: Icon(Icons.lock, size: 40, color: Colors.white70),
              ),

            // Seviye bilgisi
            if (isUnlocked)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),

                      // Seviye numarası
                      Text(
                        "${level.level}",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: primaryColor,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Özellikler
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (level.timeLimit > 0)
                            const Icon(
                              Icons.timer,
                              size: 13,
                              color: Colors.orange,
                            ),
                          if (level.hasMovingSlots) const SizedBox(width: 4),
                          if (level.hasMovingSlots)
                            const Icon(Icons.waves, size: 13, color: Colors.blue),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. FLUTTER ARAYÜZ KATMANI (GELİŞMİŞ)
// ==========================================
class GamePage extends StatefulWidget {
  final GameDifficulty difficulty;
  final WordCategory? category;
  final LevelData? levelData;

  const GamePage({
    super.key,
    this.difficulty = GameDifficulty.kolay,
    this.category,
    this.levelData,
  });

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  late BubbleGame _game;
  int _score = 0;
  int _combo = 0;
  int _wordsCompleted = 0;
  int _mistakes = 0;
  int _timeSpent = 0;
  async.Timer? _gameTimer;
  List<PowerUp> _powerUps = PowerUp.getInitialPowerUps();
  bool _showCombo = false;
  late AnimationController _comboController;

  // Özel balon efektleri
  bool _isGoldActive = false; // 2x puan
  // ignore: unused_field
  bool _isSlowActive = false; // Yavaşlatma
  // ignore: unused_field
  bool _isSpeedActive = false; // Hızlandırma
  async.Timer? _goldTimer;
  async.Timer? _slowTimer;
  async.Timer? _speedTimer;

  // Banner reklam
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _comboController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _loadBannerAd();

    _game = BubbleGame(
      difficulty: widget.difficulty,
      category: widget.category,
      levelData: widget.levelData,
      onWordComplete: _handleWordComplete,
      onLetterPlaced: _handleLetterPlaced,
      onMistake: _handleMistake,
      onBubbleCaptured: _handleBubbleCaptured,
    );

    // Can kontrolü yap
    _checkLife();

    // Zamanlayıcı başlat
    _startTimer();
  }

  void _handleBubbleCaptured(String? specialType) {
    if (specialType == null) return;

    switch (specialType) {
      case 'gold':
        // 2x puan aktif et (10 saniye)
        setState(() {
          _isGoldActive = true;
        });
        _goldTimer?.cancel();
        _goldTimer = async.Timer(const Duration(seconds: 10), () {
          if (mounted) {
            setState(() {
              _isGoldActive = false;
            });
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🌟 2x Puan Aktif! (10 saniye)"),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.amber,
          ),
        );
        break;

      case 'joker':
        // Otomatik harf tamamla
        if (_game.targetIndex < _game.currentWord.length) {
          _game.targetIndex++;

          if (_game.targetIndex == _game.currentWord.length) {
            _handleWordComplete();
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🃏 Joker! Bir harf otomatik tamamlandı!"),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.purple,
          ),
        );
        break;

      case 'slow':
        // Balonları yavaşlat (5 saniye)
        setState(() {
          _isSlowActive = true;
        });
        _slowTimer?.cancel();
        _slowTimer = async.Timer(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _isSlowActive = false;
            });
          }
        });
        // Tüm balonların hızını yavaşlat
        for (var bubble in _game.children.whereType<LetterBubble>()) {
          bubble.velocity *= 0.3;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❄️ Yavaşlatma Aktif! (5 saniye)"),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.cyan,
          ),
        );
        break;

      case 'speed':
        // Daha fazla balon spawn et
        setState(() {
          _isSpeedActive = true;
        });
        _speedTimer?.cancel();
        _speedTimer = async.Timer(const Duration(seconds: 8), () {
          if (mounted) {
            setState(() {
              _isSpeedActive = false;
            });
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚡ Bonus Balonlar! (8 saniye)"),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
        break;
    }
  }

  void _checkLife() async {
    final hasLife = await LifeSystem.useLife();
    if (!hasLife) {
      // Can yok, geri dön
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "❤️ Canınız bitti! Biraz bekleyin veya reklam izleyin.",
            ),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  void _startTimer() {
    _gameTimer = async.Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeSpent++;
        });
      }
    });
  }

  void _handleMistake() {
    setState(() {
      _mistakes++;
    });
    SoundManager().playClick();
  }

  Future<void> _awardXP(int amount) async {
    final result = await PlayerLevel.addXP(amount);
    final levelsGained = result['levelsGained'] as List<int>;

    if (levelsGained.isNotEmpty && mounted) {
      final rewards = result['rewards'] as Map<String, int>;
      await CurrencyManager.addCoins(rewards['coins'] ?? 0);
      await CurrencyManager.addGems(rewards['gems'] ?? 0);

      // Level up dialogu
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("⬆️", style: TextStyle(fontSize: 60)),
                const SizedBox(height: 10),
                const Text(
                  "SEVİYE ATLADIN!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Text(
                  "Seviye ${levelsGained.last}",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      if ((rewards['coins'] ?? 0) > 0)
                        Text("🪙 ${rewards['coins']} Altın"),
                      if ((rewards['gems'] ?? 0) > 0)
                        Text("💎 ${rewards['gems']} Elmas"),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Harika!"),
              ),
            ],
          ),
        );
      });
    }
  }

  void _handleWordComplete() {
    SoundManager().playSuccess();

    setState(() {
      // Combo hesapla
      _combo++;
      int baseScore = 100;
      int comboBonus = _combo > 1 ? (_combo - 1) * 50 : 0;
      int totalPoints = baseScore + comboBonus;

      // Gold balon aktif ise 2x puan
      if (_isGoldActive) {
        totalPoints *= 2;
      }

      _score += totalPoints;
      _wordsCompleted++;

      // Para kazan (gold aktif ise 2x)
      int coinsToAdd = 50 + (_combo * 10);
      if (_isGoldActive) {
        coinsToAdd *= 2;
      }
      CurrencyManager.addCoins(coinsToAdd);

      // XP kazan
      _awardXP(20 + (_combo * 5));

      // Görev ilerletme
      QuestManager.updateProgress('daily_words_3', _wordsCompleted);
      QuestManager.updateProgress('weekly_words_25', _wordsCompleted);

      if (_combo >= 3) {
        QuestManager.updateProgress('daily_combo_3', 1);
      }

      // Başarımları güncelle
      AchievementManager.updateProgress('first_word', _wordsCompleted);
      AchievementManager.updateProgress('ten_words', _wordsCompleted);
      AchievementManager.updateProgress('fifty_words', _wordsCompleted);
      AchievementManager.updateProgress('combo_5', _combo);
      AchievementManager.updateProgress('combo_10', _combo);
      AchievementManager.updateProgress('high_score_1000', _score);

      PlayerStats.addScore(totalPoints);
      PlayerStats.incrementWords();
      PlayerStats.recordCombo(_combo);

      // Combo ses efekti
      if (_combo > 1) {
        SoundManager().playCombo();
      }

      // Seviye ilerlemesini kaydet
      if (widget.levelData != null) {
        LevelProgress.completeLevel(
          widget.levelData!.difficulty,
          widget.levelData!.level,
        );

        // Seviye tamamlandı dialogu göster
        _showLevelCompleteDialog();
      }

      // Combo animasyonu
      if (_combo > 1) {
        _showCombo = true;
        _comboController.forward(from: 0);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _showCombo = false);
        });
      }
    });
  }

  void _showLevelCompleteDialog() {
    _gameTimer?.cancel();
    SoundManager().playWin();

    final nextLevel = widget.levelData!.level + 1;
    final hasNextLevel = nextLevel <= 10;

    // Zorluk adını al
    final difficultyName = widget.levelData!.difficulty == GameDifficulty.kolay
        ? 'kolay'
        : widget.levelData!.difficulty == GameDifficulty.orta
        ? 'orta'
        : 'zor';

    // Zamana göre yıldız hesapla
    final timeStars = TimeRecord.getStars(difficultyName, _timeSpent);

    // Eski sistem ile birleştir (maksimum yıldız al)
    final scoreStars = LevelStars.calculateStars(
      score: _score,
      targetScore: widget.levelData!.targetScore,
      timeSpent: _timeSpent,
      timeLimit: widget.levelData!.timeLimit,
      mistakes: _mistakes,
    );

    final stars = max(timeStars, scoreStars);

    // En iyi zamanı kaydet
    TimeRecord.saveBestTime(difficultyName, _timeSpent);

    // Yıldızları kaydet
    LevelStars.setStars(difficultyName, widget.levelData!.level, stars);

    // Elmas kazan (yıldız sayısına göre)
    if (stars > 0) {
      CurrencyManager.addGems(stars * 2);
    }

    // Mükemmel seviye başarımı
    if (_mistakes == 0) {
      AchievementManager.checkAndUnlock('perfect_level');
    }

    // Zorluk başarımları
    if (widget.levelData!.level == 10) {
      if (widget.levelData!.difficulty == GameDifficulty.kolay) {
        AchievementManager.checkAndUnlock('all_easy');
      } else if (widget.levelData!.difficulty == GameDifficulty.orta) {
        AchievementManager.checkAndUnlock('all_medium');
      } else {
        AchievementManager.checkAndUnlock('all_hard');
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            const SizedBox(height: 15),
            const Text(
              "SEVİYE TAMAMLANDI!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),

            // Yıldızlar
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Icon(
                  index < stars ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 40,
                );
              }),
            ),

            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Puan:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "$_score",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Süre:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        TimeRecord.formatTime(_timeSpent),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  FutureBuilder<int?>(
                    future: TimeRecord.getBestTime(difficultyName),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        final bestTime = snapshot.data!;
                        final isNewRecord = _timeSpent < bestTime;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "En İyi Süre:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Text(
                                  TimeRecord.formatTime(
                                    min(_timeSpent, bestTime),
                                  ),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isNewRecord
                                        ? Colors.green
                                        : Colors.blue,
                                  ),
                                ),
                                if (isNewRecord) ...[
                                  const SizedBox(width: 5),
                                  const Icon(
                                    Icons.emoji_events,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "En Yüksek Combo:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "x$_combo",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Seviye seçimine dön
            },
            child: const Text("Seviyeler"),
          ),
          if (hasNextLevel)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                // Sonraki seviyeye geç
                final nextLevelData = LevelData.getLevelsForDifficulty(
                  widget.difficulty,
                )[nextLevel - 1];
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => GamePage(
                      difficulty: widget.difficulty,
                      levelData: nextLevelData,
                    ),
                  ),
                );
              },
              child: const Text("Sonraki Seviye"),
            ),
        ],
      ),
    );
  }

  void _handleLetterPlaced() {
    // Her harf yerleştirildiğinde çağrılır
  }

  void _usePowerUp(PowerUpType type) {
    final powerUp = _powerUps.firstWhere((p) => p.type == type);
    if (powerUp.count <= 0) return;

    setState(() {
      powerUp.count--;
    });

    _game.activatePowerUp(type);
  }

  void _showPauseMenu() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "DURAKLAT",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow("Skor", "$_score"),
            _buildStatRow("Kelime", "$_wordsCompleted"),
            _buildStatRow("En Yüksek Combo", "$_combo"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("Ana Menü"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text(
              "Devam Et",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _comboController.dispose();
    _gameTimer?.cancel();
    _goldTimer?.cancel();
    _slowTimer?.cancel();
    _speedTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() async {
    // Reklamsız abonelik varsa reklam yükleme
    final hasSubscription = await IAPService.hasActiveNoAdsSubscription();
    if (hasSubscription) {
      setState(() {
        _isBannerAdReady = false;
      });
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: AdMobHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() {
              _isBannerAdReady = true;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          print('Oyun banner reklam yüklenemedi: $err');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );
    _bannerAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // OYUN MOTORU
          GameWidget(game: _game),

          // ÜST PANEL - Skor, Pause ve Power-ups (Responsive)
          SafeArea(
            child: Padding(
              padding: context.responsive.padding(all: 15),
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // iPad için daha geniş layout, küçük telefonlar için kompakt
                      final isCompact = constraints.maxWidth < 375;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Pause butonu
                          IconButton.filled(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white24,
                              padding: context.responsive.padding(all: 12),
                            ),
                            icon: Icon(
                              Icons.pause,
                              color: Colors.white,
                              size: context.responsive.iconSize(base: 24),
                            ),
                            onPressed: _showPauseMenu,
                          ),

                          // Zamanlayıcı
                          Container(
                            padding: context.responsive.padding(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(
                                context.responsive.borderRadius(base: 20),
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.timer,
                                  color: Colors.white,
                                  size: context.responsive.iconSize(base: 20),
                                ),
                                SizedBox(
                                  width: context.responsive.spacing(base: 6),
                                ),
                                Text(
                                  TimeRecord.formatTime(_timeSpent),
                                  style: TextStyle(
                                    fontSize: context.responsive.fontSize(
                                      small: 14,
                                      medium: 18,
                                      large: 20,
                                    ),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (!isCompact) ...[
                            // Skor göstergesi (sadece büyük ekranlarda)
                            Container(
                              padding: context.responsive.padding(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(
                                  context.responsive.borderRadius(base: 25),
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: context.responsive.iconSize(base: 24),
                                  ),
                                  SizedBox(
                                    width: context.responsive.spacing(base: 8),
                                  ),
                                  Text(
                                    "$_score",
                                    style: TextStyle(
                                      fontSize: context.responsive.fontSize(
                                        small: 16,
                                        medium: 20,
                                        large: 22,
                                      ),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Kelime Sayacı
                          Container(
                            padding: context.responsive.padding(all: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(
                                context.responsive.borderRadius(base: 15),
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.greenAccent,
                                  size: context.responsive.iconSize(base: 20),
                                ),
                                Text(
                                  "$_wordsCompleted",
                                  style: TextStyle(
                                    fontSize: context.responsive.fontSize(
                                      small: 14,
                                      medium: 16,
                                      large: 18,
                                    ),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: context.responsive.spacing(base: 15)),

                  // POWER-UP PANEL (Üstte)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _powerUps
                          .map(
                            (powerUp) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              child: _buildPowerUpButton(powerUp),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // COMBO GÖSTERGESİ (Sağ üst, kelime sayacının üstünde)
          if (_showCombo && _combo > 1)
            Positioned(
              top: 20,
              right: 20,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _comboController,
                    curve: Curves.elasticOut,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.orange, Colors.deepOrange],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("🔥", style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 5),
                      Text(
                        "x$_combo",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Banner Reklam - Alt kısımda
          if (_isBannerAdReady && _bannerAd != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                color: Colors.black,
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPowerUpButton(PowerUp powerUp) {
    bool isAvailable = powerUp.count > 0;

    return GestureDetector(
      onTap: isAvailable ? () => _usePowerUp(powerUp.type) : null,
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: isAvailable
              ? powerUp.color.withOpacity(0.9)
              : Colors.grey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: isAvailable
              ? [
                  BoxShadow(
                    color: powerUp.color.withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            Center(
              child: Text(powerUp.icon, style: const TextStyle(fontSize: 24)),
            ),
            if (powerUp.count > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "${powerUp.count}",
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. FLAME OYUN MANTIĞI (GELİŞMİŞ)
// ==========================================

class BubbleGame extends FlameGame with HasCollisionDetection {
  final VoidCallback onWordComplete;
  final VoidCallback? onLetterPlaced;
  final VoidCallback? onMistake;
  final Function(String?)? onBubbleCaptured; // Özel balon yakalandığında
  final GameDifficulty difficulty;
  final WordCategory? category;
  final LevelData? levelData;

  // Oyun Durumu
  late WordData currentWordData;
  String get currentWord => currentWordData.word;
  int targetIndex = 0;

  // Power-up Durumları
  bool isFrozen = false;

  // UI Bileşenleri
  late BottomDock dock;

  BubbleGame({
    required this.onWordComplete,
    this.onLetterPlaced,
    this.onMistake,
    this.onBubbleCaptured,
    this.difficulty = GameDifficulty.kolay,
    this.category,
    this.levelData,
  });

  @override
  Future<void> onLoad() async {
    add(GradientBackground());
    add(CloudSpawner());

    dock = BottomDock();
    dock.position = Vector2(size.x / 2, size.y - 80);
    add(dock);

    _startNewLevel();
  }

  void _startNewLevel() {
    // Eski balonları temizle
    children.whereType<LetterBubble>().forEach((b) => b.removeFromParent());
    children.whereType<TargetSlot>().forEach((s) => s.removeFromParent());

    // Eğer levelData varsa onu kullan, yoksa rastgele kelime seç
    if (levelData != null) {
      currentWordData = WordData(
        levelData!.word,
        category ?? WordCategory.gunluk,
        difficulty,
      );
    } else {
      currentWordData = WordData.getRandom(category, difficulty);
    }
    targetIndex = 0;

    // Ekran genişliğine ve kelime uzunluğuna göre dinamik slot ayarları
    double maxWidth = size.x - 40; // Ekran genişliği - kenar boşlukları
    double slotSpacing;
    
    if (currentWord.length <= 5) {
      slotSpacing = difficulty == GameDifficulty.kolay ? 70 : 60;
    } else if (currentWord.length <= 7) {
      slotSpacing = 50;
    } else {
      // Çok uzun kelimeler için ekrana sığacak şekilde hesapla
      slotSpacing = maxWidth / currentWord.length;
      if (slotSpacing > 45) slotSpacing = 45;
      if (slotSpacing < 35) slotSpacing = 35;
    }
    
    double startX =
        size.x / 2 - (currentWord.length * slotSpacing) / 2 + (slotSpacing / 2);

    for (int i = 0; i < currentWord.length; i++) {
      add(
        TargetSlot(index: i, char: currentWord[i], slotSize: slotSpacing - 8)
          ..position = Vector2(startX + (i * slotSpacing), size.y - 80),
      );
    }

    _spawnBubbles();
  }

  void nextLevel() {
    _startNewLevel();
  }

  void _spawnBubbles() {
    List<String> charsToSpawn = currentWord.split('');

    // Zorluk bazlı ekstra harf sayısı
    int extra = difficulty == GameDifficulty.kolay
        ? 2
        : (difficulty == GameDifficulty.orta ? 4 : 6);
    for (int i = 0; i < extra; i++) {
      charsToSpawn.add("ABCDEFGKLMNRSTVYZ"[Random().nextInt(17)]);
    }

    charsToSpawn.shuffle();

    for (String char in charsToSpawn) {
      double x = Random().nextDouble() * (size.x - 100) + 50;
      // Balonları ekranın ortalarında başlat (y pozisyonu ekranın %30-70 arası)
      double y = (size.y * 0.3) + (Random().nextDouble() * (size.y * 0.4));

      // Özel balon olup olmayacağına karar ver
      final specialType = SpecialBalloonManager.getSpecialType();

      final bubble = LetterBubble(
        char,
        isFrozen: isFrozen,
        specialType: specialType,
      )..position = Vector2(x, y);
      bubble.initVelocity(difficulty); // Zorluk bazlı hız ayarı
      add(bubble);
    }
  }

  // POWER-UP AKTİVASYONU
  void activatePowerUp(PowerUpType type) {
    switch (type) {
      case PowerUpType.ampul:
        _showHint();
        break;
      case PowerUpType.buz:
        _freezeBubbles();
        break;
      case PowerUpType.miknatIs:
        _magnetPull();
        break;
    }
  }

  void _showHint() {
    String neededChar = currentWord[targetIndex];
    final bubbles = children
        .whereType<LetterBubble>()
        .where((b) => b.char == neededChar && !b.isLocked)
        .toList();

    if (bubbles.isEmpty) return;

    LetterBubble targetBubble = bubbles.first;
    targetBubble.add(
      ScaleEffect.by(
        Vector2.all(1.5),
        EffectController(duration: 0.5, alternate: true, repeatCount: 3),
      ),
    );
  }

  void _freezeBubbles() {
    isFrozen = true;
    children.whereType<LetterBubble>().forEach((b) => b.freeze());

    // 5 saniye sonra buzları çöz
    Future.delayed(const Duration(seconds: 5), () {
      if (!isMounted) return;
      isFrozen = false;
      children.whereType<LetterBubble>().forEach((b) => b.unfreeze());
    });
  }

  void _magnetPull() {
    String neededChar = currentWord[targetIndex];
    final bubbles = children
        .whereType<LetterBubble>()
        .where((b) => b.char == neededChar && !b.isLocked)
        .toList();

    if (bubbles.isEmpty) return;

    final slots = children
        .whereType<TargetSlot>()
        .where((s) => s.index == targetIndex)
        .toList();

    if (slots.isEmpty) return;

    LetterBubble targetBubble = bubbles.first;
    TargetSlot targetSlot = slots.first;

    targetBubble.add(
      MoveEffect.to(
        targetSlot.position,
        EffectController(duration: 0.8, curve: Curves.easeInOut),
        onComplete: () => checkDrop(targetBubble),
      ),
    );
  }

  void checkDrop(LetterBubble bubble) {
    if (bubble.char != currentWord[targetIndex]) {
      bubble.returnToFloat();
      onMistake?.call();
      return;
    }

    final slots = children.whereType<TargetSlot>().toList();
    TargetSlot? targetSlot;

    try {
      targetSlot = slots.firstWhere((s) => s.index == targetIndex);
    } catch (e) {
      return;
    }

    if (bubble.position.distanceTo(targetSlot.position) < 100) {
      SoundManager().playPop();
      bubble.snapTo(targetSlot.position);
      targetSlot.fill();
      _createConfetti(targetSlot.position);

      // Özel balon efekti uygula
      onBubbleCaptured?.call(bubble.specialType);

      targetIndex++;
      onLetterPlaced?.call();

      if (targetIndex >= currentWord.length) {
        Future.delayed(const Duration(seconds: 1), () => _startNewLevel());
        onWordComplete();
      }
    } else {
      bubble.returnToFloat();
    }
  }

  void _createConfetti(Vector2 pos) {
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 20,
          lifespan: 0.8,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 200),
            speed: Vector2(Random().nextDouble() * 200 - 100, -300),
            position: pos,
            child: CircleParticle(
              radius: 4,
              paint: Paint()..color = Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void onRemove() {
    super.onRemove();
  }
}

// ==========================================
// 4. OYUN NESNELERİ (GÖRSEL ŞÖLEN)
// ==========================================

// 🫧 SÜRÜKLENEBİLİR HARF BALONU
class LetterBubble extends PositionComponent
    with DragCallbacks, HasGameRef<BubbleGame> {
  final String char;
  final String? specialType; // Özel balon tipi

  // Fizik değişkenleri
  Vector2 velocity = Vector2.zero();
  bool isDragging = false;
  bool isLocked = false;
  bool isFrozen = false;
  final double radius = 35;

  // Görsel
  late TextComponent _text;
  late CircleComponent _bg;
  final Color _color;

  LetterBubble(this.char, {this.isFrozen = false, this.specialType})
    : _color = specialType != null
          ? _getSpecialColor(specialType)
          : _randomColor() {
    size = Vector2.all(radius * 2);
    anchor = Anchor.center;
  }

  // Özel balon renkleri
  static Color _getSpecialColor(String type) {
    switch (type) {
      case 'gold':
        return const Color(0xFFFFD700); // Altın
      case 'joker':
        return const Color(0xFF9C27B0); // Mor
      case 'slow':
        return const Color(0xFF00BCD4); // Açık mavi
      case 'speed':
        return const Color(0xFFFF5722); // Turuncu-kırmızı
      default:
        return _randomColor();
    }
  }

  // Hız zorluk seviyesine göre belirlenir
  void initVelocity(GameDifficulty difficulty) {
    double speedMultiplier;
    switch (difficulty) {
      case GameDifficulty.kolay:
        speedMultiplier = 1.0; // Normal hız
        break;
      case GameDifficulty.orta:
        speedMultiplier = 1.5; // 1.5x hız
        break;
      case GameDifficulty.zor:
        speedMultiplier = 3.0; // 3x hız - BAYA HIZLI!
        break;
    }

    velocity = Vector2(
      (Random().nextDouble() * 100 - 50) * speedMultiplier,
      (Random().nextDouble() * 100 - 50) * speedMultiplier,
    );
  }

  static Color _randomColor() => [
    Colors.pinkAccent,
    Colors.orangeAccent,
    Colors.cyan,
    Colors.purpleAccent,
    Colors.greenAccent,
  ][Random().nextInt(5)];

  @override
  Future<void> onLoad() async {
    // Parlak Balon Çizimi
    _bg = CircleComponent(
      radius: radius,
      paint: Paint()
        ..color = _color.withOpacity(0.8)
        ..style = PaintingStyle.fill,
    );

    // Özel balon için ek efekt
    if (specialType != null) {
      // Parıldayan kenar efekti
      _bg.add(
        CircleComponent(
          radius: radius - 2,
          paint: Paint()
            ..color = Colors.transparent
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        ),
      );
    }

    // Balon Parlaması (Shine effect)
    _bg.add(
      CircleComponent(
        radius: 10,
        position: Vector2(15, 15),
        paint: Paint()..color = Colors.white.withOpacity(0.4),
      ),
    );

    add(_bg);

    // Normal harf göster (özel balon bile olsa)
    _text = TextComponent(
      text: char,
      anchor: Anchor.center,
      position: size / 2,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(blurRadius: 4, color: Colors.black26)],
        ),
      ),
    );
    add(_text);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isDragging || isLocked || isFrozen)
      return; // Sürüklenirken, kilitliyken veya dondurulmuşken fizik uygulama

    // Ekran sınırlarından sekme (Bouncing)
    position += velocity * dt;
    if (position.x < radius || position.x > gameRef.size.x - radius)
      velocity.x *= -1;
    if (position.y < radius || position.y > gameRef.size.y - 150)
      velocity.y *= -1; // Aşağıya (Drop zone'a) inmesin
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (isLocked || isFrozen)
      return; // Kilitli veya dondurulmuş balonlar sürüklenemez
    isDragging = true;
    priority = 100; // Sürüklenen en öne gelsin
    scale = Vector2.all(1.2); // Büyüt
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    isDragging = false;
    scale = Vector2.all(1.0); // Küçült
    gameRef.checkDrop(this);
  }

  // Yanlış yere bırakıldıysa
  void returnToFloat() {
    add(
      MoveEffect.to(
        Vector2(position.x, position.y - 50), // Biraz yukarı fırla
        EffectController(duration: 0.5, curve: Curves.elasticOut),
      ),
    );
  }

  // Doğru yere bırakıldıysa
  void snapTo(Vector2 targetPos) {
    // Kalıcı olarak oraya git ve kilitlen
    add(
      MoveEffect.to(
        targetPos,
        EffectController(duration: 0.2, curve: Curves.easeOut),
      ),
    );
    velocity = Vector2.zero(); // Hareketi durdur
    isLocked = true; // Kilitle
    // Artık sürüklenemesin
    removeFromParent(); // Eski balonu sil
    // Yeni kilitli bir harf olarak eklenebilir ama basitlik için slotu dolduruyoruz.
  }

  // Power-up metodları
  void freeze() {
    isFrozen = true;
    _bg.paint.color = Colors.lightBlue.withOpacity(0.8); // Buzlanmış görünüm
  }

  void unfreeze() {
    isFrozen = false;
    _bg.paint.color = _color.withOpacity(0.8); // Orijinal renge dön
  }
}

// 🎯 HEDEF KUTUCUK (SLOT)
class TargetSlot extends PositionComponent {
  final int index;
  final String char;
  final double slotSize;
  bool isFilled = false;

  TargetSlot({
    required this.index,
    required this.char,
    this.slotSize = 50,
  }) {
    size = Vector2(slotSize, slotSize * 1.2);
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    // Kutucuk Çizimi
    final paint = Paint()
      ..color = isFilled ? Colors.greenAccent : Colors.white.withOpacity(0.3)
      ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 3;

    // Modern yuvarlak kare
    final rect = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(12),
    );
    canvas.drawRRect(rect, paint);

    // Eğer dolduysa harfi göster, dolmadıysa silik göster
    // Font boyutunu slot boyutuna göre ayarla
    double fontSize = slotSize * 0.64; // Slotun %64'ü kadar font boyutu
    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: isFilled ? Colors.white : Colors.white.withOpacity(0.2),
    );

    final textSpan = TextSpan(text: char, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.x - textPainter.width) / 2,
        (size.y - textPainter.height) / 2,
      ),
    );
  }

  void fill() {
    isFilled = true;
    // Dolunca zıplama efekti
    add(
      ScaleEffect.by(
        Vector2.all(1.2),
        EffectController(duration: 0.1, alternate: true),
      ),
    );
  }
}

// 🌫️ ALT PANEL (DOCK)
class BottomDock extends PositionComponent with HasGameRef {
  @override
  void render(Canvas canvas) {
    // Cam efekti panel
    final paint = Paint()..color = Colors.black.withOpacity(0.3);
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset.zero,
        width: gameRef.size.x - 40,
        height: 100,
      ),
      const Radius.circular(30),
    );
    canvas.drawRRect(rect, paint);
  }
}

// 🌈 GRADYAN ARKA PLAN
class GradientBackground extends PositionComponent with HasGameRef {
  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y);
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF6DD5FA),
          Color(0xFFFF758C),
        ], // Mavi -> Pembe gün batımı
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }
}

// ☁️ HAREKETLİ BULUT
class CloudSpawner extends Component with HasGameRef {
  double timer = 0;
  @override
  void update(double dt) {
    timer += dt;
    if (timer > 4) {
      // 4 saniyede bir bulut
      timer = 0;
      add(Cloud()..position = Vector2(-100, Random().nextDouble() * 300));
    }
  }
}

class Cloud extends PositionComponent with HasGameRef {
  double speed = 0;
  Cloud() {
    speed = Random().nextDouble() * 20 + 10;
  } // Rastgele hız

  @override
  void update(double dt) {
    x += speed * dt;
    if (x > gameRef.size.x + 100) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(const Offset(0, 0), 40, paint);
    canvas.drawCircle(const Offset(50, -10), 50, paint);
    canvas.drawCircle(const Offset(90, 10), 40, paint);
  }
}

// ==========================================
// YENİ ÖZELLİKLER - UI BÖLÜMÜ
// ==========================================

// CAN MAĞAZASI
class LifeShopPage extends StatefulWidget {
  const LifeShopPage({super.key});

  @override
  State<LifeShopPage> createState() => _LifeShopPageState();
}

class _LifeShopPageState extends State<LifeShopPage> {
  // Can paketleri (sadece elmas ile alınabilir)
  final List<Map<String, dynamic>> lifePackages = [
    {
      'lives': 1,
      'gems': 5,
      'icon': '❤️',
      'title': '1 Can',
      'description': 'Hemen oyna!',
    },
    {
      'lives': 3,
      'gems': 12,
      'icon': '❤️',
      'title': '3 Can',
      'description': 'Daha fazla oyna',
    },
    {
      'lives': 5,
      'gems': 18,
      'icon': '❤️',
      'title': '5 Can',
      'description': 'Sınırsız eğlence!',
    },
  ];

  Future<void> _buyLife(int lives, int gemCost) async {
    if (CurrencyManager.gems < gemCost) {
      _showInsufficientGemsDialog();
      return;
    }

    final success = await CurrencyManager.spendGems(gemCost);
    if (!success) {
      _showInsufficientGemsDialog();
      return;
    }

    // İstenen kadar can ekle
    for (
      int i = 0;
      i < lives && LifeSystem.currentLives < LifeSystem.maxLives;
      i++
    ) {
      await LifeSystem.addLife();
    }

    if (mounted) {
      setState(() {});
      _showSuccessDialog(lives);
    }
  }

  void _showInsufficientGemsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yetersiz Elmas'),
        content: const Text(
          'Yeterli elmasınız yok. Elmaslar sadece gerçek parayla satın alınabilir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tamam'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showGemStore();
            },
            child: const Text('Elmas Satın Al'),
          ),
        ],
      ),
    );
  }

  void _showGemStore() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('💎 Elmas Satın Al'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Elmaslar sadece gerçek parayla satın alınabilir.'),
            const SizedBox(height: 20),
            _buildGemPackage('10 Elmas', '₺9.99', 10),
            _buildGemPackage('25 Elmas', '₺19.99', 25),
            _buildGemPackage('50 Elmas', '₺34.99', 50),
            _buildGemPackage('100 Elmas', '₺59.99', 100),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildGemPackage(String title, String price, int gems) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                price,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () async {
              // Gerçek uygulama için in-app purchase
              // Şimdilik demo olarak elmas ekle
              await CurrencyManager.addGems(gems);
              if (mounted) {
                setState(() {});
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$gems elmas eklendi! (Demo)')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0097A7),
            ),
            child: const Text('Satın Al'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(int lives) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('✅ Başarılı!'),
        content: Text(
          lives == 999
              ? '24 saat boyunca sınırsız can kazandınız!'
              : '$lives can eklendi!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Harika!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '❤️ Can Mağazası',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Text('💎', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 5),
                          Text(
                            '${CurrencyManager.gems}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Mevcut canlar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Mevcut Canlarınız',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${LifeSystem.currentLives}/${LifeSystem.maxLives}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (LifeSystem.currentLives < LifeSystem.maxLives)
                      Text(
                        'Sonraki can: ${LifeSystem.getNextLifeTime()}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Can paketleri
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: lifePackages.length,
                  itemBuilder: (ctx, index) {
                    final package = lifePackages[index];
                    final isPopular = package['popular'] == true;
                    final isSpecial = package['special'] == true;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSpecial
                              ? [
                                  const Color(0xFFFFD700),
                                  const Color(0xFFFF6B00),
                                ]
                              : isPopular
                              ? [
                                  const Color(0xFF4CAF50),
                                  const Color(0xFF388E3C),
                                ]
                              : [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          if (isPopular)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  '🔥 POPÜLER',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                // Icon
                                Text(
                                  package['icon'],
                                  style: const TextStyle(fontSize: 40),
                                ),
                                const SizedBox(width: 20),

                                // Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        package['title'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        package['description'],
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Buy button
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          '💎',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          '${package['gems']}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () => _buyLife(
                                        package['lives'],
                                        package['gems'],
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: const Color(
                                          0xFF9C27B0,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 10,
                                        ),
                                      ),
                                      child: const Text(
                                        'Satın Al',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ELMAS MAĞAZASI
class GemStorePage extends StatefulWidget {
  const GemStorePage({super.key});

  @override
  State<GemStorePage> createState() => _GemStorePageState();
}

class _GemStorePageState extends State<GemStorePage> {
  // Elmas paketleri (sadece gerçek parayla alınabilir)
  final List<Map<String, dynamic>> gemPackages = [
    {
      'gems': 100,
      'price': '₺29.99',
      'priceValue': 29.99,
      'icon': '💎',
      'title': '100 Elmas',
      'description': 'Başlangıç paketi',
    },
    {
      'gems': 250,
      'price': '₺49.99',
      'priceValue': 49.99,
      'icon': '💎',
      'title': '250 Elmas',
      'description': 'Popüler seçim',
    },
    {
      'gems': 500,
      'price': '₺79.99',
      'priceValue': 79.99,
      'icon': '💎',
      'title': '500 Elmas',
      'description': 'En iyi değer',
    },
  ];

  Future<void> _purchaseGems(int gems, int bonus, double price) async {
    // Ürün ID'sini belirle
    String productId;
    if (gems == 100) {
      productId = IAPService.gems100;
    } else if (gems == 250) {
      productId = IAPService.gems250;
    } else if (gems == 500) {
      productId = IAPService.gems500;
    } else {
      return;
    }

    // In-app purchase kullanılabilir mi kontrol et
    if (!IAPService.isAvailable) {
      // Servis kullanılamıyorsa uyarı göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '❌ Satın alma servisi şu anda kullanılamıyor. Lütfen daha sonra tekrar deneyin.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Gerçek satın almayı başlat
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await IAPService.buyProduct(productId);

      if (mounted) {
        Navigator.pop(context); // Loading dialog'u kapat

        if (success) {
          _showSuccessDialog(gems, bonus);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Satın alma başlatılamadı')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Loading dialog'u kapat
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  void _showSuccessDialog(int gems, int bonus) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('✅ Satın Alma Başarılı!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💎', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 20),
            Text(
              '$gems Elmas',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Hesabınıza eklendi!',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Ana menüye dön
            },
            child: const Text('Harika!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '💎 Elmas Mağazası',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Text('💎', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 5),
                          Text(
                            '${CurrencyManager.gems}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bilgi kartı
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Text(
                      '💎 Elmaslar ile:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '• Can satın alabilirsiniz\n• Özel power-up\'lar alabilirsiniz\n• Hızlıca ilerleme sağlayabilirsiniz',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Elmas paketleri
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: gemPackages.length,
                  itemBuilder: (ctx, index) {
                    final package = gemPackages[index];
                    final isPopular = package['popular'] == true;
                    final isSpecial = package['special'] == true;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSpecial
                              ? [
                                  const Color(0xFFFFD700),
                                  const Color(0xFFFF6B00),
                                ]
                              : isPopular
                              ? [
                                  const Color(0xFF4CAF50),
                                  const Color(0xFF388E3C),
                                ]
                              : [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          if (isPopular)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  '🔥 POPÜLER',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          if (isSpecial)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  '⭐ EN İYİ DEĞER',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                // Icon
                                Text(
                                  package['icon'],
                                  style: const TextStyle(fontSize: 40),
                                ),
                                const SizedBox(width: 20),

                                // Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        package['title'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        package['description'],
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Buy button
                                Column(
                                  children: [
                                    Text(
                                      '${package['gems']} 💎',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      package['price'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () => _purchaseGems(
                                        package['gems'],
                                        0,
                                        package['priceValue'],
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: const Color(
                                          0xFF0097A7,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 10,
                                        ),
                                      ),
                                      child: const Text(
                                        'Satın Al',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Alt bilgi
              Container(
                padding: const EdgeInsets.all(20),
                child: Text(
                  '🔒 Güvenli ödeme ile App Store/Play Store üzerinden satın alınır',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// GÜNLÜK ÖDÜL DİYALOGU
// POWER-UP MAĞAZASI
class PowerUpShopPage extends StatefulWidget {
  const PowerUpShopPage({super.key});

  @override
  State<PowerUpShopPage> createState() => _PowerUpShopPageState();
}

class _PowerUpShopPageState extends State<PowerUpShopPage> {
  final List<Map<String, dynamic>> shopItems = [
    {
      'name': '💡 Ampul',
      'description': 'Bir sonraki harfi gösterir',
      'icon': '💡',
      'price': 10,
      'quantity': 1,
    },
    {
      'name': '❄️ Buz',
      'description': 'Balonları dondurur',
      'icon': '❄️',
      'price': 15,
      'quantity': 1,
    },
    {
      'name': '🧲 Mıknatıs',
      'description': 'Balonları çeker',
      'icon': '🧲',
      'price': 20,
      'quantity': 1,
    },
    {
      'name': '💡 x5 Paket',
      'description': '5 Ampul',
      'icon': '💡',
      'price': 40,
      'quantity': 5,
    },
    {
      'name': '❄️ x5 Paket',
      'description': '5 Buz',
      'icon': '❄️',
      'price': 60,
      'quantity': 5,
    },
    {
      'name': '🎁 Mega Paket',
      'description': '3 Ampul + 3 Buz + 2 Mıknatıs',
      'icon': '🎁',
      'price': 100,
      'quantity': 8,
    },
  ];

  void _purchaseItem(Map<String, dynamic> item) {
    final price = item['price'] as int;

    if (CurrencyManager.gems < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("💎 Yeterli elmasınız yok!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(item['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item['description'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("💎", style: TextStyle(fontSize: 24)),
                const SizedBox(width: 5),
                Text(
                  "$price",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () async {
              await CurrencyManager.spendGems(price);
              // TODO: Power-up'ları ekle (şu an sadece para harcıyoruz)
              setState(() {});
              Navigator.pop(ctx);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("✅ ${item['name']} satın alındı!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text("Satın Al"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        "🛍️ MAĞAZA",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Elmas göster
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          const Text("💎", style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 5),
                          Text(
                            "${CurrencyManager.gems}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Shop Items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: shopItems.length,
                  itemBuilder: (context, index) {
                    final item = shopItems[index];
                    final hasBonus = item.containsKey('bonus');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Text(
                              item['icon'],
                              style: const TextStyle(fontSize: 30),
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (hasBonus) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  item['bonus'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(item['description']),
                        trailing: ElevatedButton(
                          onPressed: () => _purchaseItem(item),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("💎 "),
                              Text("${item['price']}"),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// AYARLAR SAYFASI
class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key});

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  bool _hasNoAdsSubscription = false;

  @override
  void initState() {
    super.initState();
    _checkSubscription();
  }

  Future<void> _checkSubscription() async {
    final hasSubscription = await IAPService.hasActiveNoAdsSubscription();
    if (mounted) {
      setState(() {
        _hasNoAdsSubscription = hasSubscription;
      });
    }
  }

  Future<void> _purchaseNoAdsSubscription() async {
    if (!IAPService.isAvailable) {
      // Servis kullanılamazsa uyarı göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '❌ Satın alma servisi şu anda kullanılamıyor. Lütfen daha sonra tekrar deneyin.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Gerçek satın alma
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await IAPService.buyProduct(IAPService.subscriptionNoAds);

      if (mounted) {
        Navigator.pop(context); // Loading dialog

        if (success) {
          await _checkSubscription();
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('✅ Abonelik Başarılı!'),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.block, size: 60, color: Colors.green),
                  SizedBox(height: 20),
                  Text(
                    'Artık reklamsız oynayabilirsiniz!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Harika!'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Satın alma başlatılamadı')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: context.responsive.bottomSheetMaxHeight(),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.responsive.borderRadius(base: 30)),
        ),
      ),
      padding: context.responsive.padding(all: 25),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: context.responsive.spacing(base: 50),
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: context.responsive.spacing(base: 20)),
            Text(
              "AYARLAR",
              style: TextStyle(
                fontSize: context.responsive.fontSize(
                  small: 20,
                  medium: 24,
                  large: 28,
                ),
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: context.responsive.spacing(base: 25)),

            // Reklamsız abonelik bölümü - EN ÜSTTE (Responsive)
            if (!_hasNoAdsSubscription)
              Container(
                padding: context.responsive.padding(all: 15),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                  ),
                  borderRadius: BorderRadius.circular(
                    context.responsive.borderRadius(base: 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.block,
                          color: Colors.white,
                          size: context.responsive.iconSize(base: 28),
                        ),
                        SizedBox(width: context.responsive.spacing(base: 10)),
                        Text(
                          'Reklamsız Oyna',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.responsive.fontSize(
                              small: 18,
                              medium: 20,
                              large: 24,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tüm reklamları kaldır',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: _purchaseNoAdsSubscription,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6A1B9A),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '₺49.99/Aylık',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 28),
                    SizedBox(width: 10),
                    Text(
                      'Reklamsız Premium Aktif',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 25),

            // Ses ve müzik ayarları
            _buildSettingTile(
              icon: Icons.volume_up,
              title: "Ses Efektleri",
              value: SoundManager().soundEnabled,
              onChanged: (val) async {
                await SoundManager().toggleSound();
                setState(() {});
              },
            ),
            const SizedBox(height: 15),
            _buildSettingTile(
              icon: Icons.music_note,
              title: "Müzik",
              value: SoundManager().musicEnabled,
              onChanged: (val) async {
                await SoundManager().toggleMusic();
                setState(() {});
              },
            ),
            const SizedBox(height: 15),
            _buildStatTile(
              icon: Icons.star,
              title: "Toplam Yıldız",
              value:
                  "${LevelStars.getAllStars()}/180", // 20 levels x 3 difficulties x 3 stars
            ),
            const SizedBox(height: 15),
            _buildStatTile(
              icon: Icons.emoji_events,
              title: "Başarımlar",
              value:
                  "${AchievementManager.unlockedCount}/${AchievementManager.achievements.length}",
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                Share.share(
                  'Kelime Avcısı oyununu dene! 🎯\nHarika bir kelime oyunu!',
                  subject: 'Kelime Avcısı',
                );
              },
              icon: const Icon(Icons.share),
              label: const Text("Arkadaşlarınla Paylaş"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 15),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 30),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.deepPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber),
          const SizedBox(width: 15),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 30),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }
}

// BAŞARIMLAR SAYFASI
class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        "BAŞARIMLAR",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Achievement List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: AchievementManager.achievements.length,
                  itemBuilder: (context, index) {
                    final achievement = AchievementManager.achievements[index];
                    return _buildAchievementCard(achievement);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: achievement.isUnlocked
                ? achievement.color.withOpacity(0.3)
                : Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: achievement.isUnlocked
                  ? achievement.color.withOpacity(0.2)
                  : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                achievement.icon,
                style: TextStyle(
                  fontSize: 30,
                  color: achievement.isUnlocked ? null : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: achievement.isUnlocked ? Colors.black : Colors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: achievement.isUnlocked
                        ? Colors.grey[700]
                        : Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 8),

                // Progress bar
                if (!achievement.isUnlocked)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: achievement.progressPercentage,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation(achievement.color),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "${achievement.progress}/${achievement.target}",
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Checkmark
          if (achievement.isUnlocked)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: achievement.color,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 20),
            ),
        ],
      ),
    );
  }
}

// GÖREVLER SAYFASI
class QuestsPage extends StatefulWidget {
  const QuestsPage({super.key});

  @override
  State<QuestsPage> createState() => _QuestsPageState();
}

class _QuestsPageState extends State<QuestsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        "GÖREVLER",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTab("Günlük", QuestManager.dailyQuests),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTab("Haftalık", QuestManager.weeklyQuests),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Quest List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount:
                      QuestManager.dailyQuests.length +
                      QuestManager.weeklyQuests.length,
                  itemBuilder: (context, index) {
                    final allQuests = [
                      ...QuestManager.dailyQuests,
                      ...QuestManager.weeklyQuests,
                    ];
                    final quest = allQuests[index];
                    return _buildQuestCard(quest);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String title, List<Quest> quests) {
    final completed = quests.where((q) => q.isCompleted).length;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "$completed/${quests.length}",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestCard(Quest quest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: quest.isCompleted
                ? Colors.green.withOpacity(0.3)
                : Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: quest.isCompleted
                      ? Colors.green.withOpacity(0.2)
                      : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  quest.isCompleted ? Icons.check_circle : Icons.task_alt,
                  color: quest.isCompleted ? Colors.green : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quest.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      quest.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress bar
          if (!quest.isCompleted) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: quest.progressPercentage,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation(Colors.blue),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "${quest.progress}/${quest.target}",
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],

          const SizedBox(height: 10),

          // Reward button
          if (quest.isCompleted && !quest.isClaimed)
            ElevatedButton(
              onPressed: () async {
                final reward = await QuestManager.claimReward(quest.id);
                await CurrencyManager.addCoins(reward['coins'] ?? 0);
                await CurrencyManager.addGems(reward['gems'] ?? 0);

                setState(() {});

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "🎉 ${reward['coins']} Altın ${(reward['gems'] ?? 0) > 0 ? '+ ${reward['gems']} Elmas' : ''} Kazandın!",
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Ödülü Al: "),
                  if (quest.reward['coins']! > 0) ...[
                    const Text("🪙 "),
                    Text("${quest.reward['coins']}"),
                  ],
                  if (quest.reward['gems']! > 0) ...[
                    const SizedBox(width: 10),
                    const Text("💎 "),
                    Text("${quest.reward['gems']}"),
                  ],
                ],
              ),
            )
          else if (quest.isClaimed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "✓ Ödül Alındı",
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}

// GÜNLÜK ÖDÜL DİYALOGU
class DailyRewardDialog extends StatefulWidget {
  final VoidCallback onClaimed;

  const DailyRewardDialog({super.key, required this.onClaimed});

  @override
  State<DailyRewardDialog> createState() => _DailyRewardDialogState();
}

class _DailyRewardDialogState extends State<DailyRewardDialog> {
  bool _claimed = false;

  Future<void> _claimReward() async {
    final reward = await DailyRewardSystem.claimReward();
    await CurrencyManager.addCoins(reward['coins']!);
    await CurrencyManager.addGems(reward['gems']!);

    setState(() {
      _claimed = true;
    });

    widget.onClaimed();

    // Confetti efekti göster
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final reward = DailyRewardSystem.getTodayReward();
    final currentDay = DailyRewardSystem.currentStreak + 1;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFD700), Color(0xFFFF6B00)],
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "🎁 GÜNLÜK ÖDÜL",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Gün $currentDay / 7",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 25),

            // 7 günlük takvim
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                final day = index + 1;
                final isCompleted = day <= DailyRewardSystem.currentStreak;
                final isToday = day == currentDay;

                return Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green
                            : isToday
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: isToday ? 3 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          isCompleted ? "✓" : "$day",
                          style: TextStyle(
                            color: isCompleted || isToday
                                ? (isToday ? Colors.orange : Colors.white)
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      DailyRewardSystem.rewards[index]['gems']! > 0
                          ? "💎"
                          : "🪙",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }),
            ),

            const SizedBox(height: 25),

            // Ödül gösterimi
            if (!_claimed) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      "BUGÜNÜN ÖDÜLÜ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (reward['coins']! > 0) ...[
                          const Text("🪙", style: TextStyle(fontSize: 30)),
                          const SizedBox(width: 5),
                          Text(
                            "${reward['coins']}",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                        if (reward['gems']! > 0) ...[
                          const SizedBox(width: 15),
                          const Text("💎", style: TextStyle(fontSize: 30)),
                          const SizedBox(width: 5),
                          Text(
                            "${reward['gems']}",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.cyan,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (currentDay == 7) ...[
                      const SizedBox(height: 10),
                      const Text(
                        "⭐ MEGA BONUS! ⭐",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _claimReward,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  "ÖDÜLÜ AL!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
            ] else ...[
              const Text(
                "✓ ÖDÜL ALINDI!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Yarın tekrar gel!",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// TEMALAR SAYFASI
class ThemesPage extends StatefulWidget {
  const ThemesPage({super.key});

  @override
  State<ThemesPage> createState() => _ThemesPageState();
}

class _ThemesPageState extends State<ThemesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: ThemeManager.currentTheme.gradientColors,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        "TEMALAR",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Theme Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: ThemeManager.themes.length,
                  itemBuilder: (context, index) {
                    final theme = ThemeManager.themes[index];
                    return _buildThemeCard(theme);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCard(GameTheme theme) {
    final isSelected = ThemeManager.currentTheme.id == theme.id;

    return GestureDetector(
      onTap: () async {
        if (!theme.isUnlocked) {
          // Unlock dialog with both coin and gem options
          final choice = await showDialog<String>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text("${theme.name} Teması"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Bu temayı satın almak için seçenekler:"),
                  const SizedBox(height: 20),
                  // Coin option
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(ctx, 'coins'),
                    icon: const Text('🪙'),
                    label: Text('${theme.unlockCost} Altın'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Gem option
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(ctx, 'gems'),
                    icon: const Text('💎'),
                    label: Text('${theme.gemCost} Elmas'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("İptal"),
                ),
              ],
            ),
          );

          if (choice == 'coins') {
            if (await CurrencyManager.spendCoins(theme.unlockCost)) {
              await ThemeManager.unlockTheme(theme.id, theme.unlockCost);
              await ThemeManager.setTheme(theme.id);
              if (mounted) setState(() {});
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Yeterli altınınız yok!")),
                );
              }
            }
          } else if (choice == 'gems') {
            if (await CurrencyManager.spendGems(theme.gemCost)) {
              await ThemeManager.unlockTheme(
                theme.id,
                0,
              ); // Elmas ile alınca coin harcamıyor
              await ThemeManager.setTheme(theme.id);
              if (mounted) setState(() {});
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Yeterli elmasınız yok!")),
                );
              }
            }
          }
        } else {
          await ThemeManager.setTheme(theme.id);
          if (mounted) setState(() {});
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: Colors.white, width: 4) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Theme preview
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(theme.icon, style: const TextStyle(fontSize: 50)),
                  const SizedBox(height: 10),
                  Text(
                    theme.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!theme.isUnlocked) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "🪙 ${theme.unlockCost}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.cyan.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "💎 ${theme.gemCost}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Lock icon
            if (!theme.isUnlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.lock, color: Colors.white, size: 40),
                ),
              ),

            // Selected checkmark
            if (isSelected)
              const Positioned(
                top: 10,
                right: 10,
                child: Icon(Icons.check_circle, color: Colors.white, size: 30),
              ),
          ],
        ),
      ),
    );
  }
}
