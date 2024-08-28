import 'dart:io' as io;

import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter/services.dart';
import 'package:flutter_game_framework/flutter_game_framework.dart';
import 'package:flutter_game_framework/src/io/models/file_location.dart';
import 'package:just_audio/just_audio.dart';
import 'package:dio/dio.dart';

import 'audio_type.dart';
export 'audio_type.dart';

class AudioFile {
  static const int fileTooSmallKb = 50;
  final FileLocation location;
  final String path;
  final String? downloadUrl;
  final AudioType type;
  final AudioPlayer player;

  AudioFile({required this.location, required this.path, required this.type, this.downloadUrl})
      : player = getAudioPlayer(type);

  static AudioPlayer getAudioPlayer(AudioType type) {
    switch (type) {
      case AudioType.bgm:
        return AudioManager.bgm;
      case AudioType.sfx:
        return AudioManager.sfx;
      case AudioType.voice:
        return AudioManager.voice;
    }
  }

  Future<void> play() async {
    if (!await _exists()) throw Exception('File does not exist');
    switch (location) {
      case FileLocation.assets:
        await player.setAsset(path);
        break;
      case FileLocation.file:
        await player.setFilePath(path);
        break;
      case FileLocation.http:
        await player.setUrl(path);
    }
    await player.play();
  }

  Future<void> stop() async {
    await player.stop();
  }

  Future<bool> _exists() async {
    if (path.isEmpty) throw Exception('Path is empty');
    switch (location) {
      case FileLocation.assets:
        return await rootBundle.load(path).then((value) => true).catchError((e) => false);
      case FileLocation.file:
        bool exists = await io.File(path).exists();
        if (!exists && downloadUrl != null) {
          exists = await _downloadFile();
        }
        return exists;

      case FileLocation.http:
        // TODO: Implement network file check
        return true;
    }
  }

  Future<bool> _downloadFile() async {
    if (downloadUrl.isNullOrEmpty) return false;

    final Dio dio = Dio();

    try {
      final io.Directory persistentDataPath = await getApplicationDocumentsDirectory();
      final io.Directory downloadDir = io.Directory('${persistentDataPath.path}/$path');
      if (!downloadDir.existsSync()) {
        downloadDir.createSync(recursive: true);
      }

      final io.File file = io.File('${downloadDir.path}/$path');

      if (file.existsSync()) {
        final int fileSize = await file.length();
        if (fileSize < fileTooSmallKb) {
          file.deleteSync();
        } else {
          return true;
        }
      }

      final String filePath = '${downloadDir.path}/$path';

      final Response response = await dio.download(
        downloadUrl!,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // Progress update (optional)
            print('${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      printError(info: 'Error downloading file: $e');
    }

    return false;
  }
}
