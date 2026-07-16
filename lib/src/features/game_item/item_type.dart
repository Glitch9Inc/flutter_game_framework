class ItemType {
  static final values = [
    unknown,
    currency,
    material,
    consumable,
  ];

  static void addCustomTypes(List<ItemType> customTypes) {
    values.addAll(customTypes);
  }

  static const ItemType unknown = ItemType('unknown');
  static const ItemType currency = ItemType('currency');
  static const ItemType material = ItemType('material');
  static const ItemType consumable = ItemType('consumable');

  final String key;

  const ItemType(this.key);

  @override
  String toString() => key;

  @override
  bool operator ==(Object other) {
    if (other is ItemType) {
      return key == other.key;
    }
    return false;
  }

  @override
  int get hashCode => key.hashCode;
}
