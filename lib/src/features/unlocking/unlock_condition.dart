mixin Unlockable {
  UnlockCondition get unlockCondition;
  bool get isUnlocked => unlockCondition.isUnlocked();
}

abstract class UnlockCondition {
  static const none = AlwaysUnlocked();
  static const notImplemented = NotImplemented();

  bool isUnlocked();
}

class DynamicUnlockCondition implements UnlockCondition {
  final bool Function() condition;
  DynamicUnlockCondition(this.condition);

  @override
  bool isUnlocked() => condition();
}

mixin UnlockableMixin on UnlockCondition {
  bool isUnlockable();
}

class AlwaysUnlocked implements UnlockCondition {
  const AlwaysUnlocked();

  @override
  bool isUnlocked() => true;
}

class NotImplemented implements UnlockCondition {
  const NotImplemented();

  @override
  bool isUnlocked() => false;
}

/// 📌 숫자 기반 UnlockCondition (레벨, 스탯 등) ----------------------------------------------------
enum NumConditionType {
  greaterThan,
  lessThan,
  greaterThanOrEqual,
  lessThanOrEqual,
  equal,
}

abstract class NumCondition<T extends num> implements UnlockCondition {
  final NumConditionType type;
  final T requiredNum;
  final T Function() playerNum; // 동적 값 지원

  const NumCondition({
    required this.type,
    required this.requiredNum,
    required this.playerNum,
  });

  @override
  bool isUnlocked() {
    final currentValue = playerNum(); // 동적 평가
    switch (type) {
      case NumConditionType.greaterThan:
        return currentValue > requiredNum;
      case NumConditionType.lessThan:
        return currentValue < requiredNum;
      case NumConditionType.greaterThanOrEqual:
        return currentValue >= requiredNum;
      case NumConditionType.lessThanOrEqual:
        return currentValue <= requiredNum;
      case NumConditionType.equal:
        return currentValue == requiredNum;
    }
  }
}

/// 레벨 기반 UnlockCondition
class LevelRequirement extends NumCondition<int> {
  const LevelRequirement({
    required int requiredLevel,
    required int Function() playerLevel, // 동적 값 지원
  }) : super(
          type: NumConditionType.greaterThanOrEqual,
          requiredNum: requiredLevel,
          playerNum: playerLevel,
        );
}

/// 📌 콘텐츠 보유 기반 UnlockCondition (아이템, 퀘스트) ----------------------------------------------------
enum ContentsUnlockConditionType {
  containsAll,
  containsAny,
}

class ContentsUnlockCondition implements UnlockCondition {
  final ContentsUnlockConditionType type;
  final Set<String> requiredContents;
  final Set<String> Function() playerContents; // 동적 값 지원

  const ContentsUnlockCondition({
    required this.type,
    required this.requiredContents,
    required this.playerContents,
  });

  @override
  bool isUnlocked() {
    final currentContents = playerContents(); // 동적 평가

    switch (type) {
      case ContentsUnlockConditionType.containsAll:
        return requiredContents
            .every((element) => currentContents.contains(element));
      case ContentsUnlockConditionType.containsAny:
        return requiredContents
            .any((element) => currentContents.contains(element));
    }
  }
}

class QuestsCleared extends ContentsUnlockCondition {
  const QuestsCleared({
    required Set<String> requiredQuests,
    required Set<String> Function() playerQuests, // 동적 값 지원
  }) : super(
          type: ContentsUnlockConditionType.containsAll,
          requiredContents: requiredQuests,
          playerContents: playerQuests,
        );
}

class PurchaseCondition extends UnlockCondition with UnlockableMixin {
  final String resourceKey;
  final int requiredResource;
  final int Function() playerResource; // 동적 값 지원
  final bool Function() isPurchased;

  PurchaseCondition({
    required this.resourceKey,
    required this.requiredResource,
    required this.playerResource,
    required this.isPurchased,
  });

  @override
  bool isUnlocked() {
    return isPurchased();
  }

  @override
  bool isUnlockable() {
    final currentResources = playerResource(); // 동적 평가
    return currentResources >= requiredResource;
  }

  bool isPurchaseable() {
    return !isPurchased() && isUnlockable();
  }
}

/// 📌 복합 조건 (AND / OR)
/// 모든 조건을 만족해야 언락
class AllConditionsUnlock implements UnlockCondition {
  final List<UnlockCondition> conditions;

  const AllConditionsUnlock(this.conditions);

  @override
  bool isUnlocked() => conditions.every((condition) => condition.isUnlocked());
}

/// 하나라도 만족하면 언락
class AnyConditionUnlock implements UnlockCondition {
  final List<UnlockCondition> conditions;

  const AnyConditionUnlock(this.conditions);

  @override
  bool isUnlocked() => conditions.any((condition) => condition.isUnlocked());
}
