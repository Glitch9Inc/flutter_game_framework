import 'package:dart_database/dart_database.dart';
import '../unlocking/unlock_condition.dart';
import 'mixins/named_asset.dart';
import 'mixins/stackable.dart';

class GameAsset with DatabaseEntry {
  @override
  final String key;
  final String? largeImage;
  final String? smallImage;

  const GameAsset({
    required this.key,
    this.largeImage,
    this.smallImage,
  });

  String get image => smallImage ?? largeImage ?? '';

  int get stackSize {
    if (this is Stackable) {
      return (this as Stackable).stackSize;
    } else {
      return 1;
    }
  }

  String get name {
    if (this is NamedAsset) {
      return (this as NamedAsset).name;
    } else {
      return key;
    }
  }
}

class UnlockableAsset extends GameAsset with Unlockable {
  @override
  final UnlockCondition unlockCondition;

  const UnlockableAsset({
    required super.key,
    super.largeImage,
    super.smallImage,
    required this.unlockCondition,
  });
}
