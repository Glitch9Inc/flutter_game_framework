import 'dart:async';

import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_game_framework/flutter_game_framework.dart';
import 'package:just_audio/just_audio.dart';

class ExtendedAudioPlayer {
  static const double _defaultVolume = 1;
  static const int _defaultMinFadeOutDurationInMillis = 2000;
  static const int _minWaitTimeInMillis = 100; // 0.1 seconds

  // Properties
  final String name;
  final bool defaultLoop;
  final bool fadeOutOnStop;
  final int fadeOutDurationInMillis;

  // Components
  final AudioPlayer audioPlayer = AudioPlayer();
  final Logger _logger;

  // Saved values
  late Prefs<double> _volume;

  // Cache values
  FileLocation? _lastFileLocation;
  FileLocation? _currentFileLocation;
  String? _lastFilePath;
  String? _currentFilePath;
  bool? _lastLoop;
  bool? _currentLoop;

  int? _lastSetTime;
  bool _isFadingOut = false;

  ExtendedAudioPlayer(
    this.name, {
    required this.defaultLoop,
    this.fadeOutOnStop = false,
    this.fadeOutDurationInMillis = _defaultMinFadeOutDurationInMillis,
  }) : _logger = Logger('$name player') {
    init();
  }

  Future<void> init() async {
    _volume = await Prefs.create<double>('${name}_volume');
    setVolume(_volume.value ?? 1);
  }

  void setVolume(double volume) {
    _volume.value = volume;
    audioPlayer.setVolume(volume);
  }

  bool get playing => audioPlayer.playing;

  double getVolume() => _volume.value ?? _defaultVolume;

  void playLastAudio() {
    if (_lastFileLocation == null || _lastFilePath == null) {
      _logger.severe('No last audio to play');
      return;
    }

    play(_lastFileLocation!, _lastFilePath!, loop: _lastLoop);
  }

  void pause() => audioPlayer.pause();

  void resume() => audioPlayer.play();

  void stop() {
    if (fadeOutOnStop) {
      fadeOutAudio();
    } else {
      audioPlayer.stop();
    }
  }

  void toggle() {
    if (playing) {
      pause();
    } else {
      resume();
    }
  }

  void dispose() => audioPlayer.dispose();

  Future<void> play(FileLocation fileLocation, String filePath, {bool? loop}) async {
    // if the audio is fading out, wait until it's done
    if (_isFadingOut) {
      Timer.periodic(const Duration(milliseconds: 50), (timer) {
        if (!_isFadingOut) {
          timer.cancel();
          play(fileLocation, filePath, loop: loop);
        }
      });
      return;
    }

    if (_lastSetTime != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final diff = now - _lastSetTime!;
      if (diff < _minWaitTimeInMillis) {
        _logger.warning('Too fast to play audio: $diff ms');
        return;
      }
      _lastSetTime = now;
    } else {
      _lastSetTime = DateTime.now().millisecondsSinceEpoch;
    }

    bool sameAudioPlaying = _currentFileLocation == fileLocation && _currentFilePath == filePath;

    // if the same audio is already playing, don't play it again
    if ((_currentLoop ?? false == true) && sameAudioPlaying) {
      _logger.warning('The same audio is already playing: $filePath');
      return;
    }

    if (audioPlayer.playing) {
      audioPlayer.stop();
    }

    if (!sameAudioPlaying) {
      _lastFileLocation = _currentFileLocation;
      _lastFilePath = _currentFilePath;
      _lastLoop = _currentLoop;

      _currentFileLocation = fileLocation;
      _currentFilePath = filePath;
      _currentLoop = loop;
    }

    switch (fileLocation) {
      case FileLocation.assets:
        audioPlayer.setAsset(filePath);
        break;
      case FileLocation.file:
        audioPlayer.setFilePath(filePath);
        break;
      case FileLocation.http:
        audioPlayer.setUrl(filePath);
    }

    audioPlayer.setLoopMode(loop ?? defaultLoop ? LoopMode.one : LoopMode.off);
    audioPlayer.play();
  }

  Future<void> fadeOutAudio() async {
    _isFadingOut = true;
    const step = Duration(milliseconds: 50); // Time step for volume changes
    final int numberOfSteps = fadeOutDurationInMillis ~/ step.inMilliseconds;
    final double volumeDecrease = audioPlayer.volume / numberOfSteps;

    Timer.periodic(step, (timer) {
      double newVolume = audioPlayer.volume - volumeDecrease;
      if (newVolume <= 0) {
        audioPlayer.setVolume(0);
        timer.cancel();
        audioPlayer.stop(); // Optionally stop the player after fading out

        _isFadingOut = false;
        audioPlayer.setVolume(getVolume()); // Reset volume to the original value
      } else {
        audioPlayer.setVolume(newVolume);
      }
    });
  }
}
