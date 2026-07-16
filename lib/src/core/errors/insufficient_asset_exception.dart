import '../localization/game_localization.dart';

class InsufficientAssetException implements Exception {
  final String assetName;
  final int requiredAmount;

  InsufficientAssetException(this.assetName, this.requiredAmount);

  @override
  String toString() {
    return GameLocalization.insufficientAsset(assetName);
  }
}
