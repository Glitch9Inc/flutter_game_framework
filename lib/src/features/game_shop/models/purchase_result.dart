enum PurchaseErrorType {
  unknown,

  exception,

  /// iap payment platform is not ready or not available
  paymentPlatformNotAvailable,

  /// iap product ID is not found in the store
  productIDNotFound,

  /// iap product details are not found in the store
  productDetailsNotFound,
}

class PurchaseResult {
  final bool isSuccess;
  final Object? error;
  final PurchaseErrorType? errorType;
  final String? productId;
  final List<String>? errorArgs;

  bool get isFailure => !isSuccess;

  PurchaseResult(
    this.isSuccess, {
    this.productId,
    this.error,
    this.errorType,
    this.errorArgs,
  });

  factory PurchaseResult.success({String? productId}) {
    return PurchaseResult(
      true,
      productId: productId,
    );
  }

  factory PurchaseResult.error(
    PurchaseErrorType errorType, {
    String? productId,
    List<String>? errorArgs,
  }) {
    return PurchaseResult(
      false,
      productId: productId,
      errorType: errorType,
      errorArgs: errorArgs,
    );
  }

  factory PurchaseResult.exception(Object error, {String? productId}) {
    return PurchaseResult(
      false,
      productId: productId,
      error: error,
      errorType: PurchaseErrorType.exception,
    );
  }
}
