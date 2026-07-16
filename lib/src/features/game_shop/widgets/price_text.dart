import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_corelib_ui/flutter_corelib_ui.dart';

import '../controllers/in_app_purchase_controller.dart';
import '../models/price.dart';

class PriceText extends StatefulWidget {
  final Price price;
  final TextStyle? style;
  final String freeLabel;

  PriceText({
    super.key,
    required this.price,
    this.style,
    this.freeLabel = 'Claim',
  });

  @override
  State<StatefulWidget> createState() => _PriceTextState();
}

class _PriceTextState extends State<PriceText> {
  bool get isInAppPurchase => widget.price.isInAppPurchase;
  bool get isDailyFree => widget.price.isDailyFree;
  TextStyle? get style => widget.style ?? Get.textTheme.bodyLarge;

  bool _isAvailable = false;
  String _timeLeft = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    if (isDailyFree) {
      _isAvailable =
          widget.price.isAvailable != null && widget.price.isAvailable!();
      final resetTime = widget.price.resetTime;

      if (!_isAvailable && resetTime != null) {
        _timer = Timer.periodic(Duration(seconds: 1), (timer) {
          _onDailyFreeTimerUpdate();
        });
      }
    }
  }

  void _onDailyFreeTimerUpdate() {
    final resetTime = widget.price.resetTime;
    if (resetTime == null) return;

    final now = DateTime.now();
    final timeLeft = resetTime.toDateTime().difference(now);

    if (timeLeft.isNegative) {
      _isAvailable = true;
      _timeLeft = '';
      _timer?.cancel();
    } else {
      _timeLeft = timeLeft.toString();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<String> fetchInAppProductPrice() async {
    final inAppPurchaseId = widget.price.inAppPurchaseId;

    if (inAppPurchaseId == null || inAppPurchaseId.isEmpty) {
      Debug.severe(
          'Product.fetchInAppProductPrice: inAppPurchaseId is null or empty');
      return 'error';
    }

    try {
      Get.lazyPut(() => InAppPurchaseController());
      InAppPurchaseController iapController = Get.find();
      return await iapController.getPrice(inAppPurchaseId);
    } catch (e) {
      Debug.severe('Product.fetchInAppProductPrice: $e');
      return 'error';
    }
  }

  Widget _buildText(String text) {
    return AutoSizeText(
      text,
      style: style,
      minFontSize: 8.0,
      maxLines: 1,
    );
  }

  Widget _buildIcon(String image) {
    final imageSize = style?.fontSize ?? 16.0 * 1.5;

    return Image.asset(
      image,
      width: imageSize,
      height: imageSize,
    );
  }

  Widget _buildInAppPurchasePrice() {
    return FutureBuilder<String>(
      future: fetchInAppProductPrice(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildText('...');
        }

        if (snapshot.hasError) {
          return _buildText('error');
        }

        return _buildText(snapshot.data ?? 'error');
      },
    );
  }

  Widget _buildDailyFreePrice() {
    if (_isAvailable) {
      return _buildText(widget.freeLabel);
    }

    if (widget.price.isAvailable == null || widget.price.resetTime == null) {
      return _buildText('error');
    }

    return _buildText(_timeLeft);
  }

  Widget _buildGameCurrencyPrice() {
    final String? icon = widget.price.image;
    final String? text = widget.price.currency?.stackSize.toString();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) _buildIcon(icon),
        if (icon != null) SizedBox(width: 6.0),
        if (text != null) _buildText(text),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isInAppPurchase) {
      return _buildInAppPurchasePrice();
    }

    if (isDailyFree) {
      return _buildDailyFreePrice();
    }

    return _buildGameCurrencyPrice();
  }
}
