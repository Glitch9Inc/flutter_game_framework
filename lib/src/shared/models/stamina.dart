import 'dart:async';

import 'package:flutter_corelib/flutter_corelib.dart';

class Stamina {
  /// ~분에 1씩 회복되는지 param
  final int recoveryTimeMinute = 5;

  /// 1레벨일때 최대 스태미너
  final int startingMaxStamina = 100;

  /// 1레벨마다 증가하는 최대 스태미너 양
  final int maxStaminaIncreasePerLevel = 5;

  /// 현재 유저 레벨
  int Function() userLevel;

  /// 마지막 스테미너 값
  int lastStaminaValue;

  /// 마지막 스테미너 사용 시간
  DateTime lastStaminaUseTime;

  /// 현재 스테미너
  int _currentStamina = 0;

  Stamina({
    required this.userLevel,
    required this.lastStaminaValue,
    required this.lastStaminaUseTime,
    bool autoUpdate = true,
  }) {
    _currentStamina = _calculateStamina(); // 초기값 설정

    if (autoUpdate) {
      Timer.periodic(const Duration(minutes: 1), (timer) {
        updateStamina();
      });
    }
  }

  factory Stamina.fromJson(
      int Function() userLevel, Map<String, dynamic> json) {
    return Stamina(
      userLevel: userLevel,
      lastStaminaValue: json.getInt('last_stamina_value'),
      lastStaminaUseTime: json.getDateTime('last_stamina_use_time',
          defaultValue: DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'last_stamina_value': lastStaminaValue,
      'last_stamina_use_time': lastStaminaUseTime,
    };
  }

  int get maxValue {
    return startingMaxStamina + (userLevel() - 1) * maxStaminaIncreasePerLevel;
  }

  /// 현재 스테미너를 계산하여 반환하는 내부 메서드
  int _calculateStamina() {
    if (lastStaminaValue >= maxValue) {
      return maxValue;
    }

    final now = DateTime.now();
    final elapsedTime = now.difference(lastStaminaUseTime).inMinutes;
    final recoveredStamina = elapsedTime ~/ recoveryTimeMinute;

    return lastStaminaValue + recoveredStamina;
  }

  /// 외부에서 스테미너 값을 참조할 수 있도록 getter 제공
  int get value => _currentStamina;

  /// 스테미너 사용
  bool useStamina(int amount) {
    if (_currentStamina < amount) {
      return false;
    }
    lastStaminaValue = _currentStamina - amount;
    lastStaminaUseTime = DateTime.now();
    _currentStamina = _calculateStamina(); // 스테미너 값 업데이트
    return true;
  }

  void addStamina(int amount) {
    lastStaminaValue = _currentStamina + amount;
    lastStaminaUseTime = DateTime.now();
    _currentStamina = _calculateStamina(); // 추가 값은 max값을 넘어도 상관 없음
  }

  /// 스테미너를 수동으로 업데이트하는 메서드 (예: 시간 경과로 인한 회복)
  void updateStamina() {
    _currentStamina = _calculateStamina();
  }
}
