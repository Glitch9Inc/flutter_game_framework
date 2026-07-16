import 'package:flutter/material.dart';

import 'item.dart';

enum Rarity {
  none,
  common,
  uncommon,
  rare,
  epic,
  legendary,
}

extension RarityExt on Rarity {
  String get name => Item.getRarityName(this);
  MaterialColor get color => Item.getRarityColor(this);
}
