enum Priority {
  none,
  low,
  medium,
  high,
  veryHigh,
}

extension PriorityExt on Priority {
  String get title {
    switch (this) {
      case Priority.none:
        return 'None';
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
      case Priority.veryHigh:
        return 'Very High';
    }
  }

  int compareTo(Priority other) {
    return index.compareTo(other.index);
  }
}
