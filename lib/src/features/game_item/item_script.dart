import 'package:flutter_corelib/flutter_corelib.dart';

enum ConsumableType {
  unknown,
  stamina,
  randomBox,
  selectBox,
}

class ItemScript {
  static const kExp = 'EXP';
  static const kExpiresIn = 'EXPIRES_IN';
  static const kStamina = 'STAMINA';
  static const kRandomBox = 'RANDOM_BOX';
  static const kSelectBox = 'SELECT_BOX';

  // 키, 값을 나누는 세퍼레이터는 다음 세가지:
  // 1. [:] 뒤의 값은 공식이 불필요한 값
  // 2. [+] 뒤의 값은 경험치나 스태미나의 회복값이나 아이템에 붙은 스텟증가 값
  // 3. [-] 뒤의 값은 아이템에 붙은 스텟 감소 값

  // 값은 다음과 같이 구분:
  // 1. 수치 - 숫자 (장비 스텟의 경우 뒤에 %가 붙으면 Multiplicative Bonus, 그렇지 않으면 Additive Bonus)
  // 2. ID - 문자열

  // 예시:
  // STAMINA+50 (사용시 50의 스태미나 회복)
  // INT+5 (장비 착용시 INT스텟이 5만큼 증가)
  // EXPIRES_IN:1 (아이템이 1일 후 소멸)

  final String key;
  final dynamic value;
  final bool isPercentage;

  ItemScript._(this.key, this.value, this.isPercentage);

  // stamina factory
  factory ItemScript.getStamina(int value) {
    return ItemScript._(kStamina, value, false);
  }

  // expiresIn factory
  factory ItemScript.expiresIn(int value) {
    return ItemScript._(kExpiresIn, value, false);
  }

  // randomBox factory
  factory ItemScript.randomBox(String value) {
    return ItemScript._(kRandomBox, value, false);
  }

  static List<ItemScript> fromJson(Map<String, dynamic> json) {
    const itemSeparator = ',';
    final attributesAsString = json.getString('item_attributes');

    if (attributesAsString.isEmpty) {
      return [];
    }

    final attributes = <ItemScript>[];

    final attributeList = attributesAsString.split(itemSeparator);

    for (final attribute in attributeList) {
      // split with :, + or -
      // but if it's [-], the following value has to be negative
      final isNegative = attribute.contains('-');
      final parts = attribute.split(RegExp(r'[:+-]'));
      if (parts.length < 2) {
        throw Exception('Invalid attribute: $attribute');
      }

      final key = parts[0];
      var value = parts[1];
      if (isNegative) value = '-$value';
      final isPercentage = value.endsWith('%');
      final realValue =
          isPercentage ? value.substring(0, value.length - 1) : value;

      attributes.add(ItemScript._(key, realValue, isPercentage));
    }

    return attributes;
  }

  T getValue<T>() {
    if (T == int) {
      return int.parse(value) as T;
    } else if (T == double) {
      return double.parse(value) as T;
    } else if (T == String) {
      return value as T;
    } else {
      throw Exception('Unsupported type: $T');
    }
  }
}
