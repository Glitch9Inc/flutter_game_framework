import 'package:flutter/material.dart';

import 'item_properties.dart';

class ItemConfig {
  static const kDefaultRarityNames = {
    Rarity.none: 'None',
    Rarity.common: 'Common',
    Rarity.uncommon: 'Uncommon',
    Rarity.rare: 'Rare',
    Rarity.epic: 'Epic',
    Rarity.legendary: 'Legendary',
  };

  static const kDefaultRarityColors = {
    Rarity.none: Colors.grey,
    Rarity.common: Colors.green,
    Rarity.uncommon: Colors.green,
    Rarity.rare: Colors.blue,
    Rarity.epic: Colors.purple,
    Rarity.legendary: Colors.orange,
  };

  static const kDefaultFallbackLargeImage = 'assets/images/unknown_item.png';
  static const kDefaultFallbackSmallImage = 'assets/images/unknown_item.png';

  ItemConfig._();
}
