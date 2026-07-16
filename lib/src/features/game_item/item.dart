import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_corelib/flutter_corelib.dart';

import '../game_content/game_asset.dart';
import '../game_content/mixins/named_asset.dart';
import 'consumable_item.dart';
import 'item_config.dart';
import 'item_properties.dart';
import 'item_type.dart';
import 'stackable_item.dart';

export 'consumable_item.dart';
export 'item_impl.dart';
export 'stackable_item.dart';

typedef ItemLocalizer = String Function(String key);

class ItemData extends ServerModel {
  @override
  ServerModelClient get client => Item._serverClient;
  final String key;

  ItemData({
    required this.key,
    super.timestamps,
  });

  factory ItemData.create(
      {required String key, bool isStackable = false, int stackSize = 1}) {
    if (isStackable) {
      return StackableItemData(key: key, stackSize: stackSize);
    } else {
      return ItemData(key: key);
    }
  }

  @override
  ItemData.fromJson(super.json)
      : key = json.getString('key'),
        super.fromJson();

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['key'] = key;
    return json;
  }
}

class Item<TServerData extends ItemData> extends GameAsset with NamedAsset {
  static final Map<String, Item> _entries = {};
  static UnmodifiableMapView<String, Item> get entries =>
      UnmodifiableMapView(_entries);

  static Item? findItem(String key) {
    final item = _entries[key];
    if (item == null && kDebugMode) {
      Debug.severe('Item.fromKey: Item not found: $key');
    }
    return item;
  }

  static List<Item> findItemsByType(ItemType type) {
    return _entries.values.where((item) => item.type.key == type.key).toList();
  }

  static Map<Rarity, MaterialColor> _rarityColors = {};
  static Map<Rarity, String> _rarityNames = {};

  static MaterialColor getRarityColor(Rarity rarity) =>
      _rarityColors[rarity] ?? Colors.grey;
  static String getRarityName(Rarity rarity) =>
      _rarityNames[rarity] ?? 'Unknown';

  static String fallbackLargeImage = '';
  static String fallbackSmallImage = '';

  static ItemLocalizer localizeName = (id) => id;
  static ItemLocalizer localizeDescription = (id) => id;

  static late ServerModelClient _serverClient;

  /// Initialize the entire item system.
  /// You MUST call this method before using any item-related classes.
  static void init({
    required Map<String, Item> entries,
    required ItemLocalizer localizeName,
    required ItemLocalizer localizeDescription,
    required ServerModelClient serverClient,
    Map<Rarity, MaterialColor>? rarityColors,
    Map<Rarity, String>? rarityNames,
    List<ItemType>? customTypes,
    String? fallbackLargeImage,
    String? fallbackSmallImage,
  }) {
    Item._entries.clear();
    Item._entries.addAll(entries);
    Item._serverClient = serverClient;
    Item.localizeName = localizeName;
    Item.localizeDescription = localizeDescription;
    Item._rarityColors = rarityColors ?? ItemConfig.kDefaultRarityColors;
    Item._rarityNames = rarityNames ?? ItemConfig.kDefaultRarityNames;
    Item.fallbackLargeImage =
        fallbackLargeImage ?? ItemConfig.kDefaultFallbackLargeImage;
    Item.fallbackSmallImage =
        fallbackSmallImage ?? ItemConfig.kDefaultFallbackSmallImage;

    if (customTypes != null) {
      ItemType.addCustomTypes(customTypes);
    }
  }

  static final none = Item(
    key: 'none',
    rarity: Rarity.common,
    largeImage: Item.fallbackLargeImage,
    smallImage: Item.fallbackSmallImage,
    type: ItemType.unknown,
  );

  final TServerData? data;
  final Rarity rarity;
  final ItemType type;

  @override
  String get name => _name ??= Item.localizeName(key);
  String get description => _description ??= Item.localizeDescription(key);

  String? _name;
  String? _description;

  Item({
    required super.key,
    required this.type,
    required this.rarity,
    super.largeImage,
    super.smallImage,
    this.data,
  });

  /// _entries already contains items with various types,
  /// and we are copying the instances with the given data,
  /// which means we don't need to use different constructors for each type.
  static Item fromJson(Map<String, dynamic> json) {
    final key = json.getString('key');
    final fetchedItem = _entries[key];

    ItemData data;

    if (fetchedItem == null) {
      return none;
    } else {
      if (fetchedItem is ConsumableItem) {
        data = ConsumableItemData.fromJson(
          json,
          expiresIn: fetchedItem.expiresIn,
        );
      } else if (fetchedItem is StackableItem) {
        data = StackableItemData.fromJson(json);
      } else {
        data = ItemData.fromJson(json);
      }
    }

    return fetchedItem.copyWith(data);
  }

  static Item fromData(ItemData data) {
    final key = data.key;
    final fetchedItem = _entries[key] ?? none;
    return fetchedItem.copyWith(data);
  }

  static Item create({required String key, int stackSize = 1}) {
    final item = _entries[key];
    if (item == null) return none;

    final ItemData data;
    if (item is ConsumableItem) {
      data = ConsumableItemData(
        key: key,
        stackSize: stackSize,
        expiresIn: item.expiresIn,
      );
    } else {
      data = ItemData.create(
        key: key,
        isStackable: item is StackableItem,
        stackSize: stackSize,
      );
    }
    return item.copyWith(data);
  }

  Item copyWith(TServerData data) {
    return Item(
      key: key,
      type: type,
      rarity: rarity,
      largeImage: largeImage,
      smallImage: smallImage,
      data: data,
    );
  }
}

class ItemUtils {
  /// JSON에서 properties만 추출하는 함수
  static Map<String, dynamic> extractProperties(Map<String, dynamic> map) {
    final properties = Map<String, dynamic>.from(map);
    properties.remove('id');
    properties.remove('type');
    properties.remove('rarity');
    properties.remove('large_image');
    properties.remove('small_image');
    return properties;
  }

  ItemUtils._();
}
