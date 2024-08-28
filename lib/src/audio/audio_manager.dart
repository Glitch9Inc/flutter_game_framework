import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:just_audio/just_audio.dart';

const String _defaultExtension = '.mp3';
const double _defaultVolume = 1;

class AudioManager extends GetxController {
  AudioManager._internal();
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  static AudioPlayer get bgm => _instance.bgmPlayer;
  static AudioPlayer get sfx => _instance.sfxPlayer;
  static AudioPlayer get voice => _instance.voicePlayer;

  final sfxPlayer = AudioPlayer();
  final bgmPlayer = AudioPlayer();
  final voicePlayer = AudioPlayer();
  final Logger _logger = Logger('SoundManager');

  late Prefs<double> _bgmVolume;
  late Prefs<double> _sfxVolume;
  late Prefs<double> _voiceVolume;

  String? currentBgm;
  String? currentSfx;
  String? currentVoice;

  final RxBool _isBgmSession = false.obs;
  final RxBool _isBgmPlaying = false.obs;
  static RxBool get isBgmSession => _instance._isBgmSession;
  static RxBool get isBgmPlaying => _instance._isBgmPlaying;

  static Future<void> init() async {
    _instance._bgmVolume = await Prefs.create<double>('bgmVolume');
    _instance._sfxVolume = await Prefs.create<double>('sfxVolume');
    _instance._voiceVolume = await Prefs.create<double>('voiceVolume');

    setVolume(AudioType.bgm, _instance._bgmVolume.value ?? _defaultVolume);
    setVolume(AudioType.sfx, _instance._sfxVolume.value ?? _defaultVolume);
    setVolume(AudioType.voice, _instance._voiceVolume.value ?? _defaultVolume);
  }

  AudioPlayer getPlayer(AudioType type) {
    switch (type) {
      case AudioType.bgm:
        return bgmPlayer;
      case AudioType.sfx:
        return sfxPlayer;
      case AudioType.voice:
        return voicePlayer;
    }
  }

  Prefs<double> getVolumePrefs(AudioType type) {
    switch (type) {
      case AudioType.bgm:
        return _bgmVolume;
      case AudioType.sfx:
        return _sfxVolume;
      case AudioType.voice:
        return _voiceVolume;
    }
  }

  /// 배경음 볼륨을 설정합니다.
  /// 볼륨은 0.0 ~ 1.0 사이의 값으로 설정합니다.
  /// 볼륨이 0.0이면 소리가 나지 않습니다.
  /// 볼륨이 1.0이면 최대 볼륨으로 소리가 나옵니다.
  static void setVolume(AudioType type, double volume) {
    _instance.getVolumePrefs(type).value = volume;
    _instance.getPlayer(type).setVolume(volume);
  }

  /// 배경음 볼륨을 가져옵니다.
  static double getVolume(AudioType type) {
    return _instance.getVolumePrefs(type).value ?? _defaultVolume;
  }

  /// 사운드 파일명(확장자 포함)을 인자로 받아 사운드를 재생합니다.
  static void play(FileLocation location, AudioType type, String sound, {bool startBgmSession = false}) async {
    _instance._logger.info('SoundManager.play: $sound ($type)');
    if (!sound.contains('.')) sound += _defaultExtension;

    bool forceLoop = false;

    switch (type) {
      case AudioType.bgm:
        _instance.currentBgm = sound;
        forceLoop = true;
        isBgmSession.value = startBgmSession;
        isBgmPlaying.value = true;
        break;
      case AudioType.sfx:
        _instance.currentSfx = sound;
        break;
      case AudioType.voice:
        _instance.currentVoice = sound;
        break;
    }

    try {
      if (location == FileLocation.file) {
        await _instance.getPlayer(type).setFilePath(sound);
      } else if (location == FileLocation.http) {
        await _instance.getPlayer(type).setUrl(sound);
      } else {
        await _instance.getPlayer(type).setAsset(sound);
      }
      _instance.getPlayer(type).setLoopMode(forceLoop ? LoopMode.one : LoopMode.off);
      _instance.getPlayer(type).play();
    } catch (e) {
      _instance._logger.severe('Error playing sound: $e');
      isBgmSession.value = false;
    }
  }

  static void playBgmAsset(String sound, {bool startBgmSession = true}) =>
      play(FileLocation.assets, AudioType.bgm, sound, startBgmSession: startBgmSession);
  static void playSfxAsset(String sound) => play(FileLocation.assets, AudioType.sfx, sound);
  static void playVoiceAsset(String sound) => play(FileLocation.assets, AudioType.voice, sound);

  static void playBgmFile(String sound) => play(FileLocation.file, AudioType.bgm, sound);
  static void playSfxFile(String sound) => play(FileLocation.file, AudioType.sfx, sound);
  static void playVoiceFile(String sound) => play(FileLocation.file, AudioType.voice, sound);

  static void playBgmHttp(String sound) => play(FileLocation.http, AudioType.bgm, sound);
  static void playSfxHttp(String sound) => play(FileLocation.http, AudioType.sfx, sound);
  static void playVoiceHttp(String sound) => play(FileLocation.http, AudioType.voice, sound);

  static void stop(AudioType type, {bool reset = true}) {
    _instance.getPlayer(type).stop();
    isBgmPlaying.value = false;
    if (reset) {
      isBgmSession.value = false;
    }
  }

  static void stopBgm({bool reset = true}) => stop(AudioType.bgm, reset: reset);
  static void pauseBgm() => _instance.bgmPlayer.pause();
  static void resumeBgm() => _instance.bgmPlayer.play();
  static void stopSfx() => stop(AudioType.sfx);
  static void stopVoice() => stop(AudioType.voice);

  static void toggleBgm() {
    bool playing = _instance.bgmPlayer.playing;
    if (playing) {
      stopBgm(reset: false);
    } else {
      if (_instance.currentBgm != null) {
        playBgmAsset(_instance.currentBgm!);
      } else {
        _instance._logger.warning('Current BGM is null');
      }
    }
  }

  @override
  void dispose() {
    bgmPlayer.dispose();
    sfxPlayer.dispose();
    voicePlayer.dispose();
    super.dispose();
  }
}
