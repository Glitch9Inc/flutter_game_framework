import 'dart:async';
import 'package:flutter_corelib/flutter_corelib.dart';

enum LoadingState {
  none,
  loading,
  completed,
}

class LoadingController {
  final RxString message = 'Now loading...'.obs;
  final RxDouble progress = 0.0.obs;
  final Rx<LoadingState> state = LoadingState.none.obs;

  bool get isCompleted => state.value == LoadingState.completed;

  LoadingController({
    String? initialMessage,
    bool startImmediately = true,
  }) {
    if (initialMessage != null) {
      message.value = initialMessage;
    }
    if (startImmediately) {
      start();
    }
  }

  void start() {
    state.value = LoadingState.loading;
  }

  void proceed(String message) {
    this.message.value = message;
  }

  void complete() {
    state.value = LoadingState.completed;
  }
}

class CountBasedLoadingController extends LoadingController {
  final int itemCount;
  final RxInt _currentItemIndex = 0.obs; // 현재 아이템 인덱스

  CountBasedLoadingController({
    required this.itemCount,
    super.initialMessage,
    super.startImmediately,
  });

  @override
  void proceed(String message) {
    super.proceed(message);
    _currentItemIndex.value++;
    progress.value = _currentItemIndex.value / itemCount;
    if (_currentItemIndex.value >= itemCount) {
      complete();
    }
  }
}

enum TimeBasedLoadingType {
  single,
  total,
}

class TimeBasedLoadingController extends LoadingController {
  final Duration duration;
  final TimeBasedLoadingType type;
  Timer? _timer;

  TimeBasedLoadingController({
    required this.duration,
    this.type = TimeBasedLoadingType.single,
    super.initialMessage,
    super.startImmediately,
  });

  void _resetTimer(bool completeOnComplete) {
    _timer?.cancel();
    progress.value = 0.0; // 초기화

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      // 퍼센티지를 0 ~ 1 범위로 증가
      progress.value += 1 / (duration.inMilliseconds / 100);

      // 퍼센티지가 1.0 이상일 경우 타이머 취소
      if (progress.value >= 1.0) {
        _timer?.cancel();
        progress.value = 1.0; // 최대값 1.0으로 설정
        if (completeOnComplete) {
          complete();
        }
      }
    });
  }

  @override
  void start() {
    super.start();
    _resetTimer(type == TimeBasedLoadingType.total);
  }

  @override
  void proceed(String message) {
    super.proceed(message);
    if (type == TimeBasedLoadingType.single) {
      _resetTimer(false);
    }
  }
}
