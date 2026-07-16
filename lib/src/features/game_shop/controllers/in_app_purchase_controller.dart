import 'dart:async';

import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../models/purchase_result.dart';

/// Example usage: iapController.buyProduct('crystals_1200');
class InAppPurchaseController extends GetxController {
  final Logger _logger = Logger('InAppPurchaseController');
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final InAppPurchase _iap = InAppPurchase.instance;

  final Set<String> _productIds = {
    'weekly_subscription',
    'monthly_subscription',
    'crystals_1200',
    'crystals_2400',
    'crystals_360',
    'crystals_3675',
    'crystals_720',
    'crystals_7350'
  };
  RxList<ProductDetails> products = RxList<ProductDetails>();

  InAppPurchaseController() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _iap.restorePurchases();

    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      _logger.severe('Purchase Error: $error');
    });

    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final bool available = await _iap.isAvailable();
    if (!available) {
      _logger.warning('In-app purchases are not available');
      return;
    }
    final ProductDetailsResponse response =
        await _iap.queryProductDetails(_productIds);
    if (response.notFoundIDs.isNotEmpty) {
      _logger.warning('Products not found: ${response.notFoundIDs}');
    } else {
      for (var product in response.productDetails) {
        _logger.info(
            'Product found: ${product.id}, Title: ${product.title}, Description: ${product.description}');
      }
    }
    products.addAll(response.productDetails);
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          _verifyAndDeliver(purchaseDetails);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> _verifyAndDeliver(PurchaseDetails purchaseDetails) async {
    bool valid = await _verifyPurchase(purchaseDetails);
    if (valid) {
      _deliverProduct(purchaseDetails);
    } else {
      _handleInvalidPurchase(purchaseDetails);
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // Verify the purchase here
    return true;
  }

  void _deliverProduct(PurchaseDetails purchaseDetails) {
    // Deliver the product to the user
  }

  void _handleError(IAPError error) {
    _logger.severe('Purchase Error: $error');
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    _logger.warning('Invalid Purchase: ${purchaseDetails.productID}');
  }

  void _showPendingUI() {
    // Show a pending UI to the user
  }

  Future<PurchaseResult> buyProduct(String productId) async {
    try {
      _logger.info('Attempting to buy product: $productId');

      final available = await _iap.isAvailable();
      if (!available) {
        _logger.warning('In-app purchases are not available');
        return PurchaseResult.error(
            PurchaseErrorType.paymentPlatformNotAvailable,
            productId: productId);
      }

      final response = await _iap.queryProductDetails({productId});

      if (response.notFoundIDs.isNotEmpty) {
        final arg = response.notFoundIDs.join(', ');
        _logger.warning('Product not found: $arg');
        return PurchaseResult.error(PurchaseErrorType.productIDNotFound,
            productId: productId, errorArgs: [arg]);
      }

      if (response.productDetails.isEmpty) {
        _logger.warning('No product details found for product: $productId');
        return PurchaseResult.error(PurchaseErrorType.productDetailsNotFound,
            productId: productId);
      }

      final productDetails = response.productDetails.first;
      final purchaseParam = PurchaseParam(productDetails: productDetails);

      _logger.info('Initiating purchase for product: $productId');
      final success = await _iap.buyConsumable(purchaseParam: purchaseParam);

      if (success) {
        _logger.info('Purchase completed for product: $productId');
        return PurchaseResult.success(productId: productId);
      } else {
        _logger.severe('Error during purchase for product: $productId');
        return PurchaseResult.error(PurchaseErrorType.unknown,
            productId: productId);
      }

      // // Listen for purchase updates to ensure the process completes
      // _iap.purchaseStream.listen((List<PurchaseDetails> purchaseDetailsList) {
      //   for (PurchaseDetails purchaseDetails in purchaseDetailsList) {
      //     if (purchaseDetails.productID == productId) {
      //       if (purchaseDetails.status == PurchaseStatus.purchased) {
      //         _logger.info('Purchase completed for product: $productId');
      //         // Here you might unlock the product or notify the user
      //       } else if (purchaseDetails.status == PurchaseStatus.error) {
      //         _logger.severe('Error during purchase for product: $productId: ${purchaseDetails.error}');
      //       } else if (purchaseDetails.status == PurchaseStatus.pending) {
      //         _logger.info('Purchase is pending for product: $productId');
      //       }
      //     }
      //   }
      // });
    } catch (e) {
      _logger.severe(
          'An error occurred while trying to buy the product: $productId', e);
      return PurchaseResult.exception(e, productId: productId);
    }
  }

  Future<String> getPrice(String productId) async {
    _logger.info('Getting price of $productId');
    final ProductDetailsResponse response =
        await _iap.queryProductDetails({productId}.toSet());
    if (response.notFoundIDs.isNotEmpty) {
      _logger.warning('Product not found: $productId');
      return '-';
    }
    final ProductDetails productDetails = response.productDetails.first;
    return productDetails.price;
  }
}
