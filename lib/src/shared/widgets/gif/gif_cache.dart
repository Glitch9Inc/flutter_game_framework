import 'package:flutter/material.dart';

import 'gif_info.dart';

///
/// Works as a cache system for already fetched [GifInfo].
///
@immutable
class GifCache {
  final Map<String, GifInfo> caches = {};

  /// Clears all the stored gifs from the cache.
  void clear() => caches.clear();

  /// Removes single gif from the cache.
  bool evict(Object key) => caches.remove(key) != null ? true : false;
}
