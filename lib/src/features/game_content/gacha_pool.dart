import 'package:dart_database/dart_database.dart';

import 'game_asset.dart';

class GachaEntry {
  final GameAsset reward;
  final double chance;
  bool get isRandom => chance < 100;

  GachaEntry({
    required this.reward,
    this.chance = 100,
  });
}

class GachaPool with DatabaseEntry {
  @override
  final String key;
  final List<GachaEntry> entries;

  GachaPool({
    required this.key,
    required this.entries,
  });
}
