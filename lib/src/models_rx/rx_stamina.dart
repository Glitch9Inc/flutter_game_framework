import 'dart:async';

import 'package:get/get.dart';

class RxStamina {
  /// ~분에 1씩 회복되는지 param
  final int recoveryTimeMinute = 5;

  /// 1레벨일때 최대 스태미너
  final int startingMaxStamina = 100;

  /// 1레벨마다 증가하는 최대 스태미너 양
  final int maxStaminaIncreasePerLevel = 5;

  /// 현재 유저 레벨
  final int userLevel; // 최소 레벨

  /// 마지막 스테미너 값
  int lastStaminaValue;

  /// 마지막 스테미너 사용 시간
  DateTime lastStaminaUseTime;

  /// 현재 스테미너 (RxInt로 변경)
  final RxInt _currentStamina = 0.obs;

  RxStamina({
    required this.userLevel,
    required this.lastStaminaValue,
    required this.lastStaminaUseTime,
    bool autoUpdate = true,
  }) {
    _currentStamina.value = _calculateStamina(); // 초기값 설정

    if (autoUpdate) {
      Timer.periodic(const Duration(minutes: 1), (timer) {
        updateStamina();
      });
    }
  }

  int get maxValue {
    return startingMaxStamina + (userLevel - 1) * maxStaminaIncreasePerLevel;
  }

  /// 현재 스테미너를 계산하여 반환하는 내부 메서드
  int _calculateStamina() {
    final now = DateTime.now();
    final elapsedTime = now.difference(lastStaminaUseTime).inMinutes;
    final recoveredStamina = elapsedTime ~/ recoveryTimeMinute;
    final currentStamina = lastStaminaValue + recoveredStamina;
    return currentStamina.clamp(0, maxValue);
  }

  /// 외부에서 스테미너 값을 참조할 수 있도록 getter 제공
  RxInt get value => _currentStamina;

  /// 스테미너 사용
  void useStamina(int amount) {
    lastStaminaValue = _currentStamina.value - amount;
    lastStaminaUseTime = DateTime.now();
    _currentStamina.value = _calculateStamina(); // 스테미너 값 업데이트
  }

  /// 스테미너를 수동으로 업데이트하는 메서드 (예: 시간 경과로 인한 회복)
  void updateStamina() {
    _currentStamina.value = _calculateStamina();
  }
}
