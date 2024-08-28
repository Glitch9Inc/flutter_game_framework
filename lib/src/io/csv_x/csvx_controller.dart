import 'package:flutter/services.dart';
import 'package:flutter_corelib/flutter_corelib.dart';

abstract class CsvxController extends GetxController {
  static bool kCsvDebugMode = false;
  late Logger logger = Logger('Csvx:$path');
  String get path;

  Future<List<Map<String, Object?>>> loadCsvTable() async {
    final data = await rootBundle.loadString(path);
    final List<List<dynamic>> csvTable = const CsvToListConverter().convert(data);

    if (kCsvDebugMode) {
      logger.shout('Loaded CSV: $path');
    }

    if (csvTable.isEmpty) {
      logger.severe('Empty CSV: $path');
      return [];
    }

    final headers = csvTable.first.map((e) => _parseHeader(e.toString())).toList();
    final csvData =
        csvTable.skip(2).map((e) => Map<String, dynamic>.fromIterables(headers, e.map((e) => e.toString()))).toList();

    // isAvailable 필드가 FALSE인 데이터는 제외
    csvData.removeWhere((data) => data['isAvailable'] == 'FALSE');
    return csvData;
  }

  String _parseHeader(String header) {
    // example: id : string -> id
    // example(enum): mbtiType : Enum<MbtiType> -> mbtiType

    const space = ' ';
    String parsedHeader;

    if (header.contains(space)) {
      parsedHeader = header.split(space).first;
    } else {
      parsedHeader = header;
    }

    if (kCsvDebugMode) {
      logger.info('Parsed header: $parsedHeader');
    }

    return parsedHeader;
  }
}
