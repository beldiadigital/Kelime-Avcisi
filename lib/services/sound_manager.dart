import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _effectPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  bool _soundEnabled = true;
  bool _musicEnabled = true;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    _musicEnabled = prefs.getBool('music_enabled') ?? true;
  }

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', _soundEnabled);
  }

  Future<void> toggleMusic() async {
    _musicEnabled = !_musicEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_enabled', _musicEnabled);

    if (!_musicEnabled) {
      await _musicPlayer.stop();
    }
  }

  // Efekt sesleri (URL'ler yerine asset kullanabilirsiniz)
  Future<void> playPop() async {
    if (!_soundEnabled) return;
    try {
      await _effectPlayer.play(AssetSource('sounds/pop.mp3'), volume: 0.3);
    } catch (e) {
      // Ses dosyası bulunamadı, sessizce devam et
    }
  }

  Future<void> playSuccess() async {
    if (!_soundEnabled) return;
    try {
      await _effectPlayer.play(AssetSource('sounds/success.mp3'), volume: 0.5);
    } catch (e) {
      // Ses dosyası bulunamadı, sessizce devam et
    }
  }

  Future<void> playCombo() async {
    if (!_soundEnabled) return;
    try {
      await _effectPlayer.play(AssetSource('sounds/combo.mp3'), volume: 0.4);
    } catch (e) {
      // Ses dosyası bulunamadı, sessizce devam et
    }
  }

  Future<void> playWin() async {
    if (!_soundEnabled) return;
    try {
      await _effectPlayer.play(AssetSource('sounds/win.mp3'), volume: 0.6);
    } catch (e) {
      // Ses dosyası bulunamadı, sessizce devam et
    }
  }

  Future<void> playClick() async {
    if (!_soundEnabled) return;
    try {
      await _effectPlayer.play(AssetSource('sounds/click.mp3'), volume: 0.2);
    } catch (e) {
      // Ses dosyası bulunamadı, sessizce devam et
    }
  }

  void dispose() {
    _effectPlayer.dispose();
    _musicPlayer.dispose();
  }
}
