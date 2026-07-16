import 'package:flutter_game_framework/flutter_game_framework.dart';
import 'package:test/test.dart';

void main() {
  group('public API', () {
    test('exports shared counter model', () {
      final counters = Counters()..set('coins', 3);

      expect(counters.get('coins'), 3);
      expect(counters.get('missing'), 0);
    });

    test('exports stackable game-content behavior', () {
      final stackable = _TestStackable()
        ..stackSize = 3
        ..maxStackSize = 5;

      final result = stackable.addStack(4);

      expect(result.stackSize, 5);
      expect(result.leftOver, 2);
    });
  });
}

class _TestStackable with Stackable {
  @override
  String get key => 'test';
}
