import 'package:flutter/material.dart';

///
/// Controller that wraps [AnimationController] and protects the [duration] parameter.
/// This falls into a design choice to keep the duration control to the [Gif]
/// widget.
///
class GifController extends AnimationController {
  GifController({required super.vsync});
}

class GifSpriteController<T extends Enum> extends GifController {
  T _state;
  T get state => _state;
  void Function(T state)? onStateChanged;

  GifSpriteController({
    required super.vsync,
    required T initialState,
    this.onStateChanged,
  }) : _state = initialState;

  void play(T state) {
    _state = state;
    onStateChanged?.call(state);
  }
}
