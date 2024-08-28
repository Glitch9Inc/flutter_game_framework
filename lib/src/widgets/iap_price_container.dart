import 'package:flutter/material.dart';
import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_game_framework/flutter_game_framework.dart';

class IAPPriceContainer extends StatelessWidget {
  final double size;
  final double spacing;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final Product product;

  const IAPPriceContainer({
    super.key,
    required this.product,
    this.size = 20,
    this.spacing = 3,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.backgroundColor = transparentBlackW500,
  });

  Widget _buildPrice(String price) {
    double fontSize = size * 0.7;

    return StrokeText(
      price,
      style: Get.textTheme.bodyMedium!.copyWith(fontSize: fontSize),
      maxLines: 1,
      strokeStyle: StrokeStyle.blurred,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: product.getPrice(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildPrice(snapshot.data!);
          } else {
            return _buildPrice('Loading...');
          }
        });
  }
}
