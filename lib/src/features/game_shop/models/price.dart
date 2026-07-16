import 'package:flutter/material.dart';

import '../../game_item/item_impl.dart';

enum PurchaseType {
  /// 게임 내부 재화로 컨텐츠를 구매
  gameCurrency,

  /// 실제 돈으로 컨텐츠를 구매
  inAppPurchase,

  /// 매일 무료로 받을 수 있는 컨텐츠
  dailyFree,
}

class Price {
  final PurchaseType purchaseType;
  final GameCurrency? currency;
  final String? inAppPurchaseId;
  final TimeOfDay? resetTime;
  final bool Function()? isAvailable;
  final VoidCallback? onPurchased;

  bool get isGameCurrency => purchaseType == PurchaseType.gameCurrency;
  bool get isInAppPurchase => purchaseType == PurchaseType.inAppPurchase;
  bool get isDailyFree => purchaseType == PurchaseType.dailyFree;
  String? get image => currency?.image;

  const Price.gameCurrency(this.currency)
      : purchaseType = PurchaseType.gameCurrency,
        inAppPurchaseId = null,
        resetTime = null,
        isAvailable = null,
        onPurchased = null;

  const Price.inAppPurchase(this.inAppPurchaseId)
      : purchaseType = PurchaseType.inAppPurchase,
        currency = null,
        resetTime = null,
        isAvailable = null,
        onPurchased = null;

  const Price.dailyFree({
    required this.resetTime,
    required this.isAvailable,
    required this.onPurchased,
  })  : purchaseType = PurchaseType.dailyFree,
        currency = null,
        inAppPurchaseId = null;
}
