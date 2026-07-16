class StackResult {
  final int stackSize;
  final int leftOver;

  const StackResult(
    this.stackSize,
    this.leftOver,
  );
}

mixin Stackable {
  String get key;
  int stackSize = 1;
  int? maxStackSize;

  StackResult addStack(int amount) {
    if (maxStackSize != null) {
      if (stackSize + amount > maxStackSize!) {
        int leftOver = (stackSize + amount) - maxStackSize!;
        stackSize = maxStackSize!;
        return StackResult(stackSize, leftOver);
      }
    }

    stackSize += amount;
    return StackResult(stackSize, 0);
  }

  StackResult removeStack(int amount) {
    stackSize = stackSize - amount;
    return StackResult(stackSize, 0);
  }
}
