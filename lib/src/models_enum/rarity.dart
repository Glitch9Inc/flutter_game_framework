import 'package:flutter/material.dart';

enum Rarity {
  common,
  rare,
  epic,
  legendary,
}

extension RarityExt on Rarity {
  double get chance {
    switch (this) {
      case Rarity.common:
        return 0.6;
      case Rarity.rare:
        return 0.3;
      case Rarity.epic:
        return 0.08;
      case Rarity.legendary:
        return 0.02;
    }
  }

  Color get color {
    switch (this) {
      case Rarity.common:
        return Colors.grey;
      case Rarity.rare:
        return Colors.blue;
      case Rarity.epic:
        return Colors.purple;
      case Rarity.legendary:
        return Colors.orange;
    }
  }
}
