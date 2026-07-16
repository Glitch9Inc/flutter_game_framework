import 'package:flutter_corelib/flutter_corelib.dart';
import '../game_content/mixins/expirable.dart';

import 'item_script.dart';
import 'item_type.dart';
import 'stackable_item.dart';

class ConsumableItemData extends StackableItemData with Expirable {
  final Duration? expiresIn;

  ConsumableItemData({
    required super.key,
    required super.stackSize,
    this.expiresIn,
  });

  ConsumableItemData.fromJson(
    super.json, {
    this.expiresIn,
  }) : super.fromJson();

  @override
  DateTime? get expiresAt =>
      expiresIn != null ? createdAt.add(expiresIn!) : null;

  @override
  bool get canExpire => expiresIn != null;
}

/// 소모품.
/// 소모품은 사용하면 소멸되는 아이템이다.
/// 기능은 딱 세가지 밖에 없다.
/// 1. 스테미나 n회복
/// 2. 랜덤 상자 (n개의 아이템 중 랜덤한 아이템을 획득)
/// 3. 선택 상자 (n개의 아이템 중 선택한 아이템을 획득)
///
/// * 획득 방법
/// 1. 이벤트 챌린지 보상 (이벤트 퀘스트 완료)
/// 2. 7일 패스 구매 (7일간 매일 고가의 아이템을 획득)
/// 3. 트위터를 통해 공개된 코드 입력 (코드 입력시 랜덤한 아이템을 획득)
/// 4. 유료 상품 구매 (소모품 패키지 구매)
class ConsumableItem extends StackableItem<ConsumableItemData> {
  final List<ItemScript> scripts;
  final Duration? expiresIn;

  ConsumableItem({
    required super.key,
    required super.rarity,
    required this.scripts,
    super.smallImage,
    super.largeImage,
    super.data,
    super.maxStackSize,
    this.expiresIn,
  }) : super(type: ItemType.consumable);

  // factory ConsumableItem.fromJson(Map<String, dynamic> json) {
  //   return ConsumableItem(
  //     id: json.getString('id'),
  //     rarity: json.getEnum('rarity', Rarity.values),
  //     largeImage: json.getStringOrNull('large_image'),
  //     smallImage: json.getStringOrNull('small_image'),
  //     properties: ItemUtils.extractProperties(json),
  //     attributes: ConsumeItemEvent.fromJson(json),
  //   );
  // }

  void use() {
    var attribute = getAttribute(ItemScript.kExpiresIn);
    if (attribute == null) {
      throw Exception('Use script not found for consumable: $key');
    }

    switch (attribute.key) {
      case ItemScript.kStamina:
        // parse argument to int and recover stamina
        final stamina = attribute.getValue<int>();
        if (stamina == 0) {
          throw Exception('Stamina value is not set for consumable: $key');
        }
        //Routina.gainStamina(stamina);
        break;
      case ItemScript.kRandomBox:
        //  use argument as item pool id and get random item
        final poolId = attribute.getValue<String>();
        if (poolId.isEmpty) {
          throw Exception('Item pool id is not set for consumable: $key');
        }
        //final pulledItem = Routina.itemPool.getRandomItem(poolId);
        //Routina.inventory.getPulledItem(pulledItem.item, pulledItem.stackSize);
        break;
      case ItemScript.kSelectBox:
        // use argument as item pool id and let user select item
        final poolId = attribute.getValue<String>();
        if (poolId.isEmpty) {
          throw Exception('Item pool id is not set for consumable: $key');
        }
        // TODO: 아이템을 고를 수 있는 팝업을 띄운다. (아직 안만듦)
        //AppDialog.notYetImplemented();
        break;
      default:
        throw Exception('Unknown consumable type: $attribute');
    }
  }

  bool hasAttribute(String key) =>
      scripts.any((attribute) => attribute.key == key);
  ItemScript? getAttribute(String key) =>
      scripts.firstWhereOrNull((attribute) => attribute.key == key);
  T? getAttributeValue<T>(String key) => getAttribute(key)?.getValue<T>();

  @override
  ConsumableItem copyWith(ConsumableItemData data) {
    return ConsumableItem(
      key: key,
      rarity: rarity,
      scripts: scripts,
      smallImage: smallImage,
      largeImage: largeImage,
      maxStackSize: maxStackSize,
      expiresIn: expiresIn,
      data: data,
    );
  }
}
