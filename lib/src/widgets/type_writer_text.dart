import 'package:flutter/material.dart';
import 'package:flutter_corelib/flutter_corelib.dart';
import '../../../../../flutter_game_framework/lib/src/audio/audio_file.dart';

class TypeWriterText extends StatefulWidget {
  /// The text to type.
  final String text;

  /// The style of the text.
  final TextStyle? style;

  /// The alignment of the text.
  final TextAlign textAlign;

  /// The speed at which the text is typed.
  final Duration speed;

  /// The sound to play when typing the text.
  final AudioFile? sound;

  /// Whether the sound is enabled.
  final bool soundEnabled;

  const TypeWriterText(
    this.text, {
    Key? key,
    this.style,
    this.speed = const Duration(milliseconds: 100),
    this.sound,
    this.textAlign = TextAlign.start,
    this.soundEnabled = true,
  }) : super(key: key);

  @override
  State<TypeWriterText> createState() => TypeWriterTextState();
}

class TypeWriterTextState extends State<TypeWriterText> {
  late String text;
  late TextStyle? textStyle;
  late Duration speed;
  AudioFile? sound;
  bool soundEnabled = true;

  // Key to force rebuild of the AnimatedTextKit
  Key animatedTextKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    text = widget.text;
    textStyle = widget.style;
    speed = widget.speed;
    sound = widget.sound;
    soundEnabled = widget.soundEnabled;
  }

  void restartAnimationWithNewText(String newText) {
    if (mounted) {
      setState(() {
        text = newText;
        animatedTextKey = UniqueKey(); // Key 변경하여 AnimatedTextKit 재시작
      });
    }
  }

  void restartAnimation() {
    if (mounted) {
      setState(() {
        animatedTextKey = UniqueKey(); // Key 변경하여 AnimatedTextKit 재시작
      });
    }
  }

  void stopAnimation() {
    // AnimatedTextKit에서 직접적으로 애니메이션을 중지하는 기능은 제공되지 않음
    // 필요 시 커스텀 솔루션 구현
  }

  void _playSound() {
    if (soundEnabled && sound != null) {
      sound!.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedTextKit(
        key: animatedTextKey, // AnimatedTextKit의 key 설정
        animatedTexts: [
          TypewriterAnimatedText(
            text,
            speed: speed,
            textStyle: textStyle ?? Get.textTheme.bodyMedium ?? const TextStyle(fontSize: 16),
            textAlign: widget.textAlign,
          ),
        ],
        onNext: (int index, bool isLast) {
          _playSound();
        },
        totalRepeatCount: 1,
        pause: const Duration(milliseconds: 1000),
        displayFullTextOnTap: true,
        stopPauseOnTap: true,
      ),
    );
  }
}
