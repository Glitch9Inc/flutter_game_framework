import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'gif.dart';
import 'gif_controller.dart';
import 'gif_info.dart';
import 'gif_sprite_collection.dart';

/// This class only takes [AssetImage] as input.
@immutable
class GifSprite extends StatefulWidget {
  final String id;

  final Sprite sprite;

  /// This playback controller.
  final GifController controller;

  /// Rendered when gif frames fetch is still not completed.
  final Widget Function(BuildContext context)? placeholder;

  /// Called when gif frames fetch is completed.
  final VoidCallback? onFetchCompleted;
  final VoidCallback? onDispose;

  final Color? color;
  final BlendMode? colorBlendMode;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Rect? centerSlice;
  final bool matchTextDirection;
  final String? semanticLabel;
  final bool excludeFromSemantics;

  /// 좌우 반전 여부
  final bool flip;

  // Updated constructor to include animationState.
  GifSprite({
    super.key,
    required this.id,
    required this.sprite,
    required this.controller,
    this.placeholder,
    this.onFetchCompleted,
    this.onDispose,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.color,
    this.colorBlendMode,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.flip = false,
  });

  @override
  State<GifSprite> createState() => _GifSpriteState();
}

class _GifSpriteState extends State<GifSprite> {
  final List<ImageInfo> _frames = [];
  int _frameIndex = 0;

  GifController get _controller => widget.controller;
  ImageInfo? get _frame =>
      _frames.length > _frameIndex ? _frames[_frameIndex] : null;
  Sprite get _sprite => widget.sprite;
  bool get _isLoop => _sprite.isLoop;
  bool _isGifDisposed = false; // Dispose flag to track the disposal state]

  @override
  void initState() {
    super.initState();
    _controller.addListener(_listener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFrames().then((value) => _restartController());
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    widget.onDispose?.call();
    super.dispose();
  }

  Future<void> _loadFrames() async {
    final cacheKey = '${widget.id}_${widget.sprite.image.assetName}';
    final gif =
        Gif.cache.caches[cacheKey] ?? await _fetchFrames(widget.sprite.image);
    Gif.cache.caches[cacheKey] = gif;

    if (mounted) {
      setState(() {
        _frames.clear();
        _frames.addAll(gif.frames);
      });
    }

    // 초기 상태의 duration 설정
    _controller.duration = _resolveDuration();
    widget.onFetchCompleted?.call();
  }

  Duration _resolveDuration() {
    final fps = _sprite.fps;
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
  Future<GifInfo> _fetchFrames(AssetImage assetImage) async {
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
            _sprite.setSize(frameInfo.image.width, frameInfo.image.height);
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
    double xOffset = _sprite.xOffset;
    double yOffset = _sprite.yOffset;

    RawImage image = RawImage(
      key: UniqueKey(), // 프레임 변경마다 고유 키 부여
      image: _frame?.image,
      width: spriteWidth * _sprite.scale,
      height: spriteHeight * _sprite.scale,
      scale: _frame?.scale ?? 1.0,
      color: widget.color,
      colorBlendMode: widget.colorBlendMode,
      fit: BoxFit.fill,
      alignment: widget.alignment,
      repeat: widget.repeat,
      centerSlice: widget.centerSlice,
      matchTextDirection: widget.matchTextDirection,
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
        if (_sprite.loop == GifSpriteLoop.dispose) {
          _controller.addStatusListener((status) {
            if (mounted && status == AnimationStatus.completed) {
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
