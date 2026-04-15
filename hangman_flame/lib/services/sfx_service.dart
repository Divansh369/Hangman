import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flame_audio/flame_audio.dart';
import 'progress_service.dart';

class SfxService {
  static final SfxService _instance = SfxService._internal();
  factory SfxService() => _instance;
  SfxService._internal();

  final ValueNotifier<bool> enabled = ValueNotifier<bool>(true);
  final ValueNotifier<double> volume = ValueNotifier<double>(1.0);
  static const String _prefKey = 'sfx_enabled';

  // assets to preload from assets/audio/
  static const List<String> _assets = ['audio/click.mp3', 'audio/unlock.mp3'];
  bool _flameReady = false;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    enabled.value = prefs.getBool(_prefKey) ?? true;
    
    // Load volume from ProgressService
    final vol = await ProgressService().getVolume();
    volume.value = vol;

    // try to preload flame audio assets (optional - files may not be present)
    try {
      await FlameAudio.audioCache.loadAll(_assets);
      _flameReady = true;
    } catch (e) {
      _flameReady = false;
      debugPrint('SfxService: failed to preload flame audio: $e');
    }
  }

  Future<void> setEnabled(bool value) async {
    enabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
  }

  Future<void> setVolume(double value) async {
    final clampedValue = value.clamp(0.0, 1.0);
    volume.value = clampedValue;
    await ProgressService().setVolume(clampedValue);
  }

  void toggle() => setEnabled(!enabled.value);

  void playClick() {
    if (!enabled.value) {
      return;
    }
    if (_flameReady) {
      FlameAudio.play('audio/click.mp3', volume: volume.value);
      return;
    }
    SystemSound.play(SystemSoundType.click);
  }

  void playUnlock() {
    if (!enabled.value) {
      return;
    }
    if (_flameReady) {
      FlameAudio.play('audio/unlock.mp3');
      return;
    }
    SystemSound.play(SystemSoundType.alert);
  }
}
