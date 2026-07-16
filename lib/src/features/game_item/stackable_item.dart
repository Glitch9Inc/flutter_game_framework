import 'package:flutter_corelib/flutter_corelib.dart';

import '../game_content/mixins/expirable.dart';
import '../game_content/mixins/stackable.dart';
import 'item.dart';

class StackableItemData extends ItemData with Stackable {
  StackableItemData({
    required super.key,
    required int stackSize,
  }) {
    this.stackSize = stackSize;
  }

  StackableItemData.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    stackSize = json.getInt('stack_size');
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['stack_size'] = stackSize;
    return json;
  }

  T merge<T extends StackableItemData>(T item) {
    if (!canMerge(item)) {
      throw Exception('Cannot merge items: $key');
    }
    stackSize += item.stackSize;
    return this as T;
  }

  bool canMerge<T extends StackableItemData>(T item) {
    if (this is Expirable) {
      return key == item.key &&
          (this as Expirable).expiresAt == (item as Expirable).expiresAt;
    } else {
      return key == item.key;
    }
  }
}

abstract class StackableItem<TStackableItemData extends StackableItemData>
    extends Item<TStackableItemData> with Stackable {
  @override
  int? get maxStackSize => data?.maxStackSize;

  @override
  int get stackSize => data?.stackSize ?? 0;

  StackableItem({
    required super.key,
    required super.type,
    required super.rarity,
    super.smallImage,
    super.largeImage,
    super.data,
    int? maxStackSize,
  }) {
    if (data != null) {
      data!.maxStackSize = maxStackSize;
    }
  }
}
