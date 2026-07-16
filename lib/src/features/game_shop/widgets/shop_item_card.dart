import 'package:flutter/material.dart';
import 'package:flutter_corelib_ui/flutter_corelib_ui.dart';

import '../models/shop_item.dart';
import 'price_text.dart';
import 'shop_item_image.dart';

typedef ShopItemCardBuilder = Widget Function(BuildContext context,
    ShopItem shopItem, ShopItemImage image, PriceText priceText);

class ShopItemCard extends StatelessWidget {
  static ShopItemCardBuilder kDefaultBuilder = (
    BuildContext context,
    ShopItem shopItem,
    ShopItemImage image,
    PriceText priceText,
  ) {
    return Card(
      child: Column(
        children: [
          Expanded(child: image),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  shopItem.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                priceText,
              ],
            ),
          ),
        ],
      ),
    );
  };

  final ShopItem shopItem;
  final ShopItemCardBuilder cardBuilder;
  final String timerIcon;
  final TextStyle? priceTextStyle;
  final String freePriceLabel;
  final double imageHeight;
  final double imageWidth;
  final bool imageShadow;

  ShopItemCard({
    super.key,
    required this.shopItem,
    this.imageHeight = 100,
    this.imageWidth = 100,
    this.imageShadow = true,
    ShopItemCardBuilder? cardBuilder,
    this.timerIcon = PictoIcons.timer,
    this.priceTextStyle,
    this.freePriceLabel = 'FREE',
  }) : cardBuilder = cardBuilder ?? kDefaultBuilder;

  Widget _buildDailyFreeProductAddon() {
    if (!shopItem.isDailyFree || shopItem.isAvailable) {
      return const SizedBox();
    }

    if (shopItem.resetTime == null) {
      return Text('Reset time is not set');
    }

    return Positioned.fill(
        child: Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TimerWidget(
        timerImageAsset: timerIcon,
        type: TimerType.daily,
        resetTime: shopItem.resetTime!,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => shopItem.purchase(),
      child: Stack(
        children: [
          cardBuilder(
            context,
            shopItem,
            ShopItemImage(
              shopItem: shopItem,
              height: imageHeight,
              width: imageWidth,
              hasShadow: imageShadow,
            ),
            PriceText(
              price: shopItem.price,
              style: priceTextStyle,
              freeLabel: freePriceLabel,
            ),
          ),
          _buildDailyFreeProductAddon(),
        ],
      ),
    );
  }
}
