import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_game_framework/flutter_game_framework.dart';
import 'package:flutter_game_framework/src/audio/extended_audio_player.dart';
import 'package:just_audio/just_audio.dart';

const String _defaultExtension = '.mp3';

class AudioManager extends GetxController {
  AudioManager._internal();
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  final Logger _logger = Logger('AudioManager');

  static ExtendedAudioPlayer get bgm => _instance.bgmPlayer;
  static ExtendedAudioPlayer get sfx => _instance.sfxPlayer;
  static ExtendedAudioPlayer get voice => _instance.voicePlayer;

  final sfxPlayer = ExtendedAudioPlayer('sfx', defaultLoop: false);
  final bgmPlayer = ExtendedAudioPlayer('bgm', defaultLoop: true, fadeOutOnStop: true);
  final voicePlayer = ExtendedAudioPlayer('voice', defaultLoop: false);

  static AudioPlayer getAudioPlayer(AudioType type) {
    switch (type) {
      case AudioType.bgm:
        return _instance.bgmPlayer.audioPlayer;
      case AudioType.sfx:
        return _instance.sfxPlayer.audioPlayer;
      case AudioType.voice:
        return _instance.voicePlayer.audioPlayer;
    }
  }

  ExtendedAudioPlayer getExtendedAudioPlayer(AudioType type) {
    switch (type) {
      case AudioType.bgm:
        return bgmPlayer;
      case AudioType.sfx:
        return sfxPlayer;
      case AudioType.voice:
        return voicePlayer;
    }
  }

  /// 볼륨은 0.0 ~ 1.0 사이의 값으로 설정합니다.
  /// 볼륨이 0.0이면 소리가 나지 않습니다.
  /// 볼륨이 1.0이면 최대 볼륨으로 소리가 나옵니다.
  static void setVolume(AudioType type, double volume) {
    _instance.getExtendedAudioPlayer(type).setVolume(volume);
  }

  static double getVolume(AudioType type) {
    return _instance.getExtendedAudioPlayer(type).getVolume();
  }

  /// 사운드 파일명(확장자 포함)을 인자로 받아 사운드를 재생합니다.
  static void play(FileLocation fileLocation, AudioType type, String filePath, {bool? loop}) async {
    _instance._logger.info('play: $filePath ($type)');
    if (!filePath.contains('.')) filePath += _defaultExtension;

    try {
      var extendedAudioPlayer = _instance.getExtendedAudioPlayer(type);
      extendedAudioPlayer.play(fileLocation, filePath, loop: loop);
    } catch (e) {
      _instance._logger.severe('Error playing sound: $e');
    }
  }

  static void playBgmAsset(String sound, {bool? loop}) => play(FileLocation.assets, AudioType.bgm, sound, loop: loop);
  static void playSfxAsset(String sound, {bool? loop}) => play(FileLocation.assets, AudioType.sfx, sound, loop: loop);
  static void playVoiceAsset(String sound, {bool? loop}) =>
      play(FileLocation.assets, AudioType.voice, sound, loop: loop);

  static void playBgmFile(String sound, {bool? loop}) => play(FileLocation.file, AudioType.bgm, sound, loop: loop);
  static void playSfxFile(String sound, {bool? loop}) => play(FileLocation.file, AudioType.sfx, sound, loop: loop);
  static void playVoiceFile(String sound, {bool? loop}) => play(FileLocation.file, AudioType.voice, sound, loop: loop);

  static void playBgmHttp(String sound, {bool? loop}) => play(FileLocation.http, AudioType.bgm, sound, loop: loop);
  static void playSfxHttp(String sound, {bool? loop}) => play(FileLocation.http, AudioType.sfx, sound, loop: loop);
  static void playVoiceHttp(String sound, {bool? loop}) => play(FileLocation.http, AudioType.voice, sound, loop: loop);

  static void stop(AudioType type) => _instance.getExtendedAudioPlayer(type).stop();
  static void pause(AudioType type) => _instance.getExtendedAudioPlayer(type).pause();
  static void resume(AudioType type) => _instance.getExtendedAudioPlayer(type).resume();
  static void toggle(AudioType type) => _instance.getExtendedAudioPlayer(type).toggle();
  static void playLastAudio(AudioType type) => _instance.getExtendedAudioPlayer(type).playLastAudio();

  static void stopBgm() => stop(AudioType.bgm);
  static void stopSfx() => stop(AudioType.sfx);
  static void stopVoice() => stop(AudioType.voice);

  static void pauseBgm() => pause(AudioType.bgm);
  static void pauseSfx() => pause(AudioType.sfx);
  static void pauseVoice() => pause(AudioType.voice);

  static void resumeBgm() => resume(AudioType.bgm);
  static void resumeSfx() => resume(AudioType.sfx);
  static void resumeVoice() => resume(AudioType.voice);

  static void toggleBgm() => toggle(AudioType.bgm);
  static void toggleSfx() => toggle(AudioType.sfx);
  static void toggleVoice() => toggle(AudioType.voice);

  static void playLastBgm() => playLastAudio(AudioType.bgm);
  static void playLastSfx() => playLastAudio(AudioType.sfx);
  static void playLastVoice() => playLastAudio(AudioType.voice);

  @override
  void dispose() {
    bgmPlayer.dispose();
    sfxPlayer.dispose();
    voicePlayer.dispose();
    super.dispose();
  }
}
