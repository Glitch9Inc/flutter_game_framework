class Experience {
  final Map<int, int> _table;
  final int maxLvl;

  int get lvl => _calcLvl();
  int get level => lvl;
  int get untilNextLvl => _calcExpUntilNextLvl();
  int get maxExp => _getTableValue();

  int value;
  Function(Experience)? onLevelUp;

  Experience({
    this.value = 0,
    required Map<int, int> table,
    this.onLevelUp,
    int? maxLvl,
  })  : maxLvl = maxLvl ?? table.length,
        _table = table;

  void add(int exp) {
    if (onLevelUp == null) {
      value += exp;
    } else {
      final oldLvl = lvl;
      value += exp;
      final newLvl = lvl;
      if (newLvl > oldLvl) {
        onLevelUp!(this);
      }
    }
  }

  int _calcExpUntilNextLvl() {
    return _getTableValue() - value;
  }

  int _calcLvl() {
    if (_table.isEmpty) {
      return 1;
    }

    return _table.keys.lastWhere(
      (key) => value >= _table[key]!,
      orElse: () => _table.keys.first,
    );
  }

  int _getTableValue() {
    int index = lvl.isNaN ? 1 : lvl;
    if (_table.isEmpty || index < 1) {
      return _table.values.first;
    }
    if (index >= _table.length) {
      return _table.values.last;
    }
    return _table[index]!;
  }
}
