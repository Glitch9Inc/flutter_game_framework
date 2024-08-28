import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter_game_framework/flutter_game_framework.dart';

abstract class CsvxDatabase<T extends DatabaseModelMixin> extends CsvxController with DatabaseMixin<T> {
  final CacheMap<String, T> cache = CacheMap<String, T>();

  CsvxDatabase() {
    init();
  }

  @override
  Future<void> loadDatabase() async {
    final csvData = await loadCsvTable();
    var dataList = csvData.map((data) => fromMap(data)).toList();

    for (var data in dataList) {
      cache.set(data.id, data);
    }
  }

  @override
  T fromMap(Map<String, dynamic> map);

  @override
  T get(String id) {
    if (!isInit) {
      logger.warning('Database is not initialized');
      return fromMap({});
    }

    if (cache.containsKey(id)) {
      return cache.get(id) ?? fromMap({});
    } else {
      logger.warning('Data not found: $id');
      return fromMap({});
    }
  }

  @override
  List<T?>? toList() {
    if (!isInit) {
      logger.warning('Database is not initialized');
      return null;
    }

    return cache.toList();
  }

  List<T>? toNonNullList() {
    if (!isInit) {
      logger.warning('Database is not initialized');
      return null;
    }

    return cache.toList()?.whereType<T>().toList();
  }

  List<String> getKeys() {
    return cache.cachedData.keys.toList();
  }
}
