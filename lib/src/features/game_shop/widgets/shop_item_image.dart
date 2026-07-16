import 'package:flutter/material.dart';
import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_corelib_ui/flutter_corelib_ui.dart';

import '../models/shop_item.dart';

class ShopItemImage extends StatelessWidget {
  final ShopItem shopItem;
  final double height;
  final double width;
  final bool hasShadow;

  const ShopItemImage({
    super.key,
    required this.shopItem,
    required this.height,
    required this.width,
    this.hasShadow = false,
  });

  double _getFontSize() {
    double smaller = height < width ? height : width;
    return smaller / 5;
  }

  Positioned _buildStackSize(int stackSize) {
    return Positioned(
      bottom: 5,
      child: DecoratedText(
        'x$stackSize',
        textStyle: Get.textTheme.bodyMedium!.copyWith(
          fontSize: _getFontSize(),
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        outlineStyle: OutlineStyle(
          color: Colors.black,
          width: 3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stackSize = shopItem.stackSize;
    final showStackSize = stackSize != null && stackSize > 1;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        if (hasShadow)
          Container(
            margin: EdgeInsets.only(top: height * 0.5, bottom: 10),
            height: height * 0.3,
            width: width * 0.9,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
        SizedBox(
          height: height,
          width: width,
          child: Image.asset(shopItem.image),
        ),
        // if the product has more than 1 quantity, display a badge
        if (showStackSize) _buildStackSize(stackSize),
      ],
    );
  }
}
