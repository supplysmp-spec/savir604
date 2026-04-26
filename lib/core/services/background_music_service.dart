import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tks/core/services/services.dart';

class BackgroundMusicService extends GetxService with WidgetsBindingObserver {
  static const String _prefKey = 'background_music_enabled';
  static const String _assetPath = 'audio/ambient.mp3';

  final MyServices _services = Get.find();
  final AudioPlayer _player = AudioPlayer();
  final RxBool isEnabled = false.obs;
  bool _started = false;

  Future<BackgroundMusicService> init() async {
    WidgetsBinding.instance.addObserver(this);
    await _player.setReleaseMode(ReleaseMode.loop);
    isEnabled.value = _services.sharedPreferences.getBool(_prefKey) ?? false;

    if (isEnabled.value) {
      await _playIfEnabled();
    }

    return this;
  }

  Future<void> toggle(bool value) async {
    isEnabled.value = value;
    await _services.sharedPreferences.setBool(_prefKey, value);
    if (value) {
      await _playIfEnabled();
    } else {
      await stop();
    }
  }

  Future<void> _playIfEnabled() async {
    if (!isEnabled.value) return;
    try {
      if (!_started) {
        await _player.setVolume(0.22);
        await _player.play(AssetSource(_assetPath));
        _started = true;
      } else {
        await _player.resume();
      }
    } catch (_) {
      isEnabled.value = false;
      await _services.sharedPreferences.setBool(_prefKey, false);
      _started = false;
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _started = false;
  }

  Future<void> pause() async {
    await _player.pause();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _playIfEnabled();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      stop();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _player.dispose();
    super.onClose();
  }
}
