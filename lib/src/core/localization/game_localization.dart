import 'dart:ui';

import 'package:flutter_corelib/flutter_corelib.dart';

class GameLocalization {
  static Locale get locale => Get.locale ?? const Locale('en', 'US');

  static String insufficientAsset(String currencyName) {
    if (locale.languageCode == 'ko') {
      return '$currencyName이(가) 부족합니다';
    } else if (locale.languageCode == 'ja') {
      return '$currencyNameが不足しています';
    } else if (locale.languageCode == 'zh') {
      return '不足$currencyName';
    } else {
      return 'Not enough $currencyName';
    }
  }

  GameLocalization._();
}
