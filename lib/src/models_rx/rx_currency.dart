import 'package:flutter/material.dart';
import 'package:flutter_corelib/flutter_corelib.dart';

class RxCurrency implements Comparable {
  final String name;
  final String icon;
  final RxInt _value;

  int get value => _value.value;
  set value(int val) => _value.value = val;

  RxCurrency(int value, {required this.name, required this.icon}) : _value = value.obs;

  factory RxCurrency.fromJson(Map<String, dynamic> map) {
    return RxCurrency(map.getInt('value'), name: map.getString('name'), icon: map.getString('icon'));
  }

  factory RxCurrency.placeholderForIAP() {
    return RxCurrency(0, name: '', icon: '');
  }

  @override
  bool operator ==(Object other) => other is RxCurrency && value == other.value;
  bool operator <(RxCurrency other) => value < other.value;
  bool operator >(RxCurrency other) => value > other.value;
  bool operator <=(RxCurrency other) => value <= other.value;
  bool operator >=(RxCurrency other) => value >= other.value;

  @override
  int get hashCode => value.hashCode;

  int operator +(dynamic other) {
    if (other is RxCurrency) return value + other.value;
    if (other is int) return value + other;
    throw ArgumentError('Invalid operand type');
  }

  int operator -(dynamic other) {
    if (other is RxCurrency) return value - other.value;
    if (other is int) return value - other;
    throw ArgumentError('Invalid operand type');
  }

  int operator *(dynamic other) {
    if (other is RxCurrency) return value * other.value;
    if (other is int) return value * other;
    throw ArgumentError('Invalid operand type');
  }

  int operator /(dynamic other) {
    if (other is RxCurrency) return value ~/ other.value;
    if (other is int) return value ~/ other;
    throw ArgumentError('Invalid operand type');
  }

  @override
  int compareTo(dynamic other) {
    if (other is RxCurrency) {
      if (value < other.value) return -1;
      if (value > other.value) return 1;
      return 0;
    }
    if (other is int) {
      if (value < other) return -1;
      if (value > other) return 1;
      return 0;
    }
    throw ArgumentError('Invalid operand type');
  }
}

extension PriceExt on RxCurrency {
  Widget toWidget({
    double size = 20,
    double spacing = 3,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(20)),
    Color backgroundColor = transparentBlackW500,
  }) {
    double fontSize = size * 0.8;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          icon,
          width: size,
          height: size,
        ),
        SizedBox(
          width: spacing,
        ),
        StrokeText(
          value.toString(),
          style: Get.textTheme.bodyMedium!.copyWith(fontSize: fontSize),
          strokeStyle: StrokeStyle.blurred,
        ),
      ],
    );
  }
}
