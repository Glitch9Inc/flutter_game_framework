import 'package:flutter/material.dart';

///
/// Stores all the [ImageInfo] and duration of a gif.
///
@immutable
class GifInfo {
  final List<ImageInfo> frames;
  final Duration duration;

  GifInfo({
    required this.frames,
    required this.duration,
  });
}
