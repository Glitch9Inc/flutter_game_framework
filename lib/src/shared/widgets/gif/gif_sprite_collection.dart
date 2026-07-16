import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'gif.dart';
import 'gif_controller.dart';
import 'gif_info.dart';

enum GifSpriteLoop {
  loop,
  once,
  dispose,
}

class Sprite {
  final AssetImage image;
  final GifSpriteLoop loop;
  final int fps;
  final double scale;
  final double xOffset;
  final double yOffset;

  Sprite(
    String assetPath, {
    this.fps = 6,
    this.loop = GifSpriteLoop.loop,
    this.scale = 1.0,
    this.xOffset = 0.0,
    this.yOffset = 0.0,
  }) : image = AssetImage(assetPath);

  int? width; // 자동 설정된 너비
  int? height; // 자동 설정된 높이
  bool get isLoop => loop == GifSpriteLoop.loop;

  void setSize(int width, int height) {
    this.width = width;
    this.height = height;
  }
}

/// This class only takes [AssetImage] as input.
@immutable
class GifSpriteCollection<T extends Enum> extends StatefulWidget {
  final String id;

  final Map<T, Sprite> sprites;

  /// This playback controller.
  final GifSpriteController<T> controller;

  /// Rendered when gif frames fetch is still not completed.
  final Widget Function(BuildContext context)? placeholder;

  /// Called when gif frames fetch is completed.
  final VoidCallback? onFetchCompleted;

  final Color? color;
  final BlendMode? colorBlendMode;
  final AlignmentGeometry alignment;
  final String? semanticLabel;
  final bool excludeFromSemantics;

  /// 좌우 반전 여부
  final bool flip;

  /// The current animation state of this gif.
  final T initialState;

  // Updated constructor to include animationState.
  GifSpriteCollection({
    super.key,
    required this.sprites,
    required this.controller,
    required this.initialState,
    required this.id,
    this.placeholder,
    this.onFetchCompleted,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.color,
    this.colorBlendMode,
    this.alignment = Alignment.center,
    this.flip = false,
  });

  @override
  State<GifSpriteCollection> createState() => _GifSpriteCollectionState();
}

class _GifSpriteCollectionState<T extends Enum>
    extends State<GifSpriteCollection<T>> {
  final Map<T, List<ImageInfo>> _frameMap = {};

  late T _animationState;
  int _frameIndex = 0;

  GifSpriteController<T> get _controller => widget.controller;
  List<ImageInfo> get _frames =>
      _frameMap[_animationState] ?? _frameMap[widget.initialState] ?? [];
  ImageInfo? get _frame =>
      _frames.length > _frameIndex ? _frames[_frameIndex] : null;
  Sprite? get _sprite =>
      widget.sprites[_animationState] ?? widget.sprites[widget.initialState];
  bool get _isLoop => _sprite?.isLoop ?? true;
  bool _isGifDisposed = false; // Dispose flag to track the disposal state]

  @override
  void initState() {
    super.initState();
    _animationState = widget.initialState;
    _controller.addListener(_listener);
    _controller.onStateChanged = _changeState;
    _loadFrames().then((value) => _restartController());
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    super.dispose();
  }

  Future<void> _loadFrames() async {
    // 각 상태를 병렬로 프레임 로드하여 최적화
    await Future.wait(widget.sprites.entries.map((entry) async {
      final entryValue = entry.value.image;
      final cacheKey = '${entry.key}_${entryValue.assetName}';
      final gif = Gif.cache.caches[cacheKey] ??
          await _fetchFrames(entryValue, entry.key);
      Gif.cache.caches[cacheKey] = gif;

      setState(() {
        _frameMap[entry.key] = gif.frames;
      });
    }));

    // 초기 상태의 duration 설정
    _controller.duration = _resolveDuration();
    widget.onFetchCompleted?.call();
  }

  void _changeState(T stateKey) {
    final sameState = _animationState == stateKey;

    if (_frameMap.containsKey(stateKey)) {
      setState(() {
        _animationState = stateKey;
        _frameIndex = 0;
      });
      //print('Changing state to $stateKey, frameCount: ${_frames.length}');
      if (sameState) {
        _controller.reset();
        if (_isLoop) {
          _controller.repeat();
        } else {
          _controller.forward();
        }
      } else {
        _restartController();
      }
    } else {
      // 상태가 로드되지 않은 경우 오류 로그를 출력하여 디버깅에 도움이 되도록 합니다.
      print('Warning: No frames loaded for state $stateKey');
    }
  }

  Duration _resolveDuration() {
    final fps = widget.sprites[_animationState]?.fps ??
        widget.sprites[widget.initialState]?.fps ??
        6;
    return Duration(milliseconds: (_frames.length / fps * 1000).round());
  }

  /// Calculates the [_frameIndex] based on the [AnimationController] value.
  ///
  /// The calculation is based on the frames of the gif
  /// and the [Duration] of [AnimationController].
  void _listener() {
    if (_frames.isNotEmpty && mounted) {
      setState(() {
        _frameIndex = _frames.isEmpty
            ? 0
            : ((_frames.length - 1) * _controller.value).floor();
      });
    }
  }

  /// Modified _fetchFrames to accept AnimationState.
  Future<GifInfo> _fetchFrames(AssetImage assetImage, T stateKey) async {
    late final Uint8List bytes;

    AssetBundleImageKey key =
        await assetImage.obtainKey(const ImageConfiguration());
    bytes = (await key.bundle.load(key.name)).buffer.asUint8List();

    final buffer = await ImmutableBuffer.fromUint8List(bytes);
    Codec codec = await PaintingBinding.instance.instantiateImageCodecWithSize(
      buffer,
    );
    List<ImageInfo> infos = [];
    Duration duration = Duration();

    for (int i = 0; i < codec.frameCount; i++) {
      FrameInfo frameInfo = await codec.getNextFrame();
      infos.add(ImageInfo(image: frameInfo.image));
      duration += frameInfo.duration;

      if (i == 0 && mounted) {
        setState(() {
          if (i == 0 && mounted) {
            // 첫 번째 프레임 크기로 스프라이트 크기를 자동 설정
            widget.sprites[stateKey]
                ?.setSize(frameInfo.image.width, frameInfo.image.height);
          }
        });
      }
    }

    return GifInfo(frames: infos, duration: duration);
  }

  @override
  Widget build(BuildContext context) {
    if (_isGifDisposed) return Container(); // Return empty widget if disposed

    var spriteWidth = _frame?.image.width.toDouble() ?? 32.0;
    var spriteHeight = _frame?.image.height.toDouble() ?? 32.0;

    // Calculate the final position with offset
    double xOffset = _sprite?.xOffset ?? 0.0;
    double yOffset = _sprite?.yOffset ?? 0.0;

    RawImage image = RawImage(
      key: UniqueKey(), // 프레임 변경마다 고유 키 부여
      image: _frame?.image,
      width: spriteWidth * (_sprite?.scale ?? 1.0),
      height: spriteHeight * (_sprite?.scale ?? 1.0),
      scale: _frame?.scale ?? 1.0,
      color: widget.color,
      colorBlendMode: widget.colorBlendMode,
      fit: BoxFit.fill,
      alignment: widget.alignment,
      filterQuality: FilterQuality.none,
    );

    var flippedImage = widget.flip
        ? Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0), // X축 반전
            child: image,
          )
        : image;

    // Apply xOffset and yOffset with Transform.translate
    var translatedImage = Transform.translate(
      offset: Offset(xOffset, yOffset),
      child: flippedImage,
    );

    // Wrap in a Container to add padding for bottom-left positioning
    return Container(
      alignment: widget.alignment,
      child: widget.placeholder != null && _frame == null
          ? widget.placeholder!(context)
          : widget.excludeFromSemantics
              ? translatedImage
              : Semantics(
                  container: widget.semanticLabel != null,
                  image: true,
                  label: widget.semanticLabel ?? '',
                  child: translatedImage,
                ),
    );
  }

  void _restartController() {
    if (mounted && _frames.isNotEmpty) {
      try {
        _controller.reset();
        _controller.duration =
            _resolveDuration(); // Set the duration for the new state

        if (_isLoop) {
          _controller.repeat();
        } else {
          _controller.forward();
        }

        // Listen for completion when dispose mode is set
        if (widget.sprites[_animationState]?.loop == GifSpriteLoop.dispose) {
          _controller.addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              setState(() {
                _isGifDisposed = true; // Mark the widget as disposed
              });
            }
          });
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }
}
