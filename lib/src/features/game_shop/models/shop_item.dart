import 'package:flutter/material.dart';
import 'package:flutter_corelib/flutter_corelib.dart';

import '../../game_item/item_properties.dart';
import '../controllers/in_app_purchase_controller.dart';
import 'price.dart';
import 'purchase_result.dart';

typedef PurchaseCallback = Future<PurchaseResult> Function(ShopItem shopItem);

class ShopItem {
  final String id;
  final String image;
  final String name;
  final String? description;

  /// This can be used to determine the color of the widget
  final Rarity? rarity;
  final int? stackSize;

  final Price price;
  final PurchaseCallback onPurchase;

  bool get isGameCurrency => price.isGameCurrency;
  bool get isInAppPurchase => price.isInAppPurchase;
  bool get isDailyFree => price.isDailyFree;
  String? get inAppPurchaseId => price.inAppPurchaseId;
  bool get isAvailable => price.isAvailable?.call() ?? true;
  TimeOfDay? get resetTime => price.resetTime;
  String? inAppPurchasePrice;

  ShopItem({
    required this.id,
    required this.image,
    required this.name,
    required this.price,
    required this.onPurchase,
    this.description,
    this.rarity,
    this.stackSize,
  });

  Future<PurchaseResult> purchase() async {
    if (isInAppPurchase) {
      try {
        Get.lazyPut(() => InAppPurchaseController());
        final iapController = Get.find<InAppPurchaseController>();
        final result = await iapController.buyProduct(inAppPurchaseId!);
        if (result.isFailure) return result;
      } catch (e) {
        return PurchaseResult.exception(e);
      }
    }

    try {
      return await onPurchase(this);
    } catch (e) {
      return PurchaseResult.exception(e);
    }
  }
}
