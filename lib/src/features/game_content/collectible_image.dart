import 'package:dart_database/dart_database.dart';
import 'package:flutter_corelib/flutter_corelib.dart';

class CollectibleImage with DatabaseEntry {
  @override
  final String key;
  final String image;
  final bool isUnlocked; // or isCollected
  final DateTime? unlockedAt;

  const CollectibleImage({
    required this.key,
    required this.image,
    required this.isUnlocked,
    this.unlockedAt,
  });

  CollectibleImage.fromJson(Map<String, dynamic> json)
      : key = json.getString('id'),
        image = json.getString('image'),
        isUnlocked = json.getBool('isUnlocked'),
        unlockedAt = json.getDateTimeOrNull('unlockedAt');

  CollectibleImage unlock() {
    return CollectibleImage(
      key: key,
      image: image,
      isUnlocked: true,
      unlockedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': key,
      'image': image,
      'isUnlocked': isUnlocked,
    };
    if (unlockedAt != null) {
      json['unlockedAt'] = unlockedAt!.toIso8601String();
    }
    return json;
  }

  @override
  String toString() {
    return 'CollectibleImage{id: $key, image: $image, isUnlocked: $isUnlocked, unlockedAt: $unlockedAt}';
  }

  @override
  operator ==(Object other) {
    return other is CollectibleImage && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;
}
