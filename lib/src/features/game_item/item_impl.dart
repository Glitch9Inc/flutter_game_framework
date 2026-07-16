import 'item_properties.dart';
import 'item_type.dart';
import 'stackable_item.dart';

class GameCurrency extends StackableItem<StackableItemData> {
  static final none = GameCurrency(key: 'none');

  GameCurrency({
    required super.key,
    super.largeImage,
    super.smallImage,
    super.rarity = Rarity.none,
    super.data,
  }) : super(type: ItemType.currency);

  static GameCurrency create({
    required String key,
    required int stackSize,
    String? smallImage,
    String? largeImage,
    Rarity rarity = Rarity.none,
  }) {
    return GameCurrency(
      key: key,
      largeImage: largeImage,
      smallImage: smallImage,
      rarity: rarity,
      data: StackableItemData(key: key, stackSize: stackSize),
    );
  }

  @override
  GameCurrency copyWith(StackableItemData data) {
    return GameCurrency(
      key: key,
      largeImage: largeImage,
      smallImage: smallImage,
      rarity: rarity,
      data: data,
    );
  }
}

class MaterialItem extends StackableItem<StackableItemData> {
  MaterialItem({
    required super.key,
    required super.rarity,
    super.smallImage,
    super.largeImage,
    super.maxStackSize,
    super.data,
  }) : super(type: ItemType.material);

  @override
  MaterialItem copyWith(StackableItemData data) {
    return MaterialItem(
      key: key,
      rarity: rarity,
      smallImage: smallImage,
      largeImage: largeImage,
      maxStackSize: maxStackSize,
      data: data,
    );
  }
}
