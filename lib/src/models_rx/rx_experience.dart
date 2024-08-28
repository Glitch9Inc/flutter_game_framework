import 'package:flutter_corelib/flutter_corelib.dart';

class RxExperience {
  final Map<int, int> _table;
  final RxInt _experience = 0.obs;

  RxInt level = 0.obs;
  RxInt get experience => _experience;
  RxInt experienceToNextLevel = 0.obs;
  RxInt totalExperieneRequiredThisLevel = 0.obs;
  RxDouble progressRate = 0.0.obs;

  RxExperience(this._table, {int? experience}) {
    _experience.value = experience ?? 0;

    level.value = _calculateLevel();
    experienceToNextLevel.value = _getExperienceToNextLevel();
    totalExperieneRequiredThisLevel.value = _getTableValue();
    progressRate.value = _experience.value / totalExperieneRequiredThisLevel.value;

    ever(_experience, (_) {
      level.value = _calculateLevel();
      experienceToNextLevel.value = _getExperienceToNextLevel();
      totalExperieneRequiredThisLevel.value = _getTableValue();
      progressRate.value = _experience.value / totalExperieneRequiredThisLevel.value;
    });
  }

  int _getExperienceToNextLevel() {
    return _getTableValue() - _experience.value;
  }

  int _calculateLevel() {
    if (_table.isEmpty) {
      return 0;
    }

    return _table.keys.lastWhere(
      (key) => _experience.value >= _table[key]!,
      orElse: () => _table.keys.first,
    );
  }

  int _getTableValue() {
    int index = level.isNaN ? 0 : level.value;
    if (_table.isEmpty || index < 0) {
      return 0;
    }
    if (index >= _table.length) {
      return _table.values.last;
    }
    return _table[index]!;
  }

  void gain(int points) {
    _experience.value += points;
    while (_experience.value >= experienceToNextLevel.value) {
      _experience.value -= experienceToNextLevel.value;
    }
  }
}
