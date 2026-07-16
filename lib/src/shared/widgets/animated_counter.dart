import 'package:flutter/material.dart';

class AnimatedCounter extends StatefulWidget {
  final int targetValue; // 목표 값
  final TextStyle? style; // 텍스트 스타일

  const AnimatedCounter({super.key, required this.targetValue, this.style});

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  int _currentValue = 0; // 현재 표시되는 값

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1), // 애니메이션 지속 시간 (1초)
    );

    // Tween을 이용해 0에서 target value까지 애니메이션 설정
    _animation =
        IntTween(begin: 0, end: widget.targetValue).animate(_controller)
          ..addListener(() {
            setState(() {
              _currentValue = _animation.value; // 애니메이션 값에 맞춰 숫자를 업데이트
            });
          });

    _controller.forward(); // 애니메이션 시작
  }

  @override
  void dispose() {
    _controller.dispose(); // 애니메이션 컨트롤러 해제
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 만약 목표 값이 업데이트되었다면 새로운 값으로 애니메이션 재설정
    if (oldWidget.targetValue != widget.targetValue) {
      _animation = IntTween(begin: _currentValue, end: widget.targetValue)
          .animate(_controller);
      _controller.forward(from: 0); // 새로운 애니메이션 시작
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$_currentValue', // 현재 값 표시
      style: widget.style,
    );
  }
}
