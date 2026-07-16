class Counters {
  final Map<String, int> values;

  Counters({Map<String, int>? values}) : values = values ?? {};

  int get(String key) {
    return values[key] ?? 0;
  }

  void set(String key, int value) {
    values[key] = value;
  }
}
