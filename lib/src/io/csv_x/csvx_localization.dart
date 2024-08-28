import 'package:flutter/services.dart';
import 'package:flutter_corelib/flutter_corelib.dart';
import 'package:flutter/material.dart';

class CsvxLocalization {
  static ValueNotifier<Locale> currentLocale = ValueNotifier(const Locale('en', 'US'));
  static List<String> supportedLocaleCodes = ['ar', 'ko', 'ja', 'en', 'zh', 'es', 'fr', 'de'];

  static final Map<String, Map<String, String>> _localizations = {};
  static final List<String> _cachedLocales = [];
  static bool _cacheAllLocales = false;
  static String _csvDir = 'assets/csv/localization';
  static final Logger _logger = Logger('CsvLocalization');
  static bool _isInit = false;
  static const String _emptyValue = '-';

  static Future<void> init({
    String? csvDir,
    Locale? defaultLocale,
    String? defaultTable,
    bool? cacheAllLocales,
    List<String>? supportedLocaleCodes,
    List<Locale>? supportedLocales,
  }) async {
    if (_isInit) {
      _logger.warning('CsvLocalization is already initialized');
      return;
    }

    if (supportedLocaleCodes != null && supportedLocales != null) {
      _logger.severe('supportedLocaleCodes and supportedLocales cannot be used at the same time');
      return;
    }

    if (supportedLocaleCodes != null) {
      CsvxLocalization.supportedLocaleCodes = supportedLocaleCodes;
    } else if (supportedLocales != null) {
      CsvxLocalization.supportedLocaleCodes = supportedLocales.map((e) => e.languageCode).toList();
    }

    _logger.info('Initializing CsvLocalization...');

    _isInit = true;
    if (csvDir != null) _csvDir = csvDir;
    if (defaultLocale != null) currentLocale.value = defaultLocale;
    if (defaultTable != null) await load(defaultTable);
    if (cacheAllLocales != null) _cacheAllLocales = cacheAllLocales;

    _logger.info('CsvLocalization initialized. Locale: ${currentLocale.value}');
  }

  static String _buildPath(String tableName) {
    return '$_csvDir/$tableName.csv';
  }

  static Future<void> load(String tableName, {Locale? loadLocale, bool? cacheAllLocales}) async {
    if (loadLocale != null && cacheAllLocales != null) {
      _logger.severe('loadLocale and cacheAllLocales cannot be used at the same time');
      return;
    }

    try {
      final data = await rootBundle.loadString(_buildPath(tableName));
      final List<List<dynamic>> csvTable = const CsvToListConverter().convert(data);

      final headers = csvTable.first.map((e) => e.toString()).toList();
      final csvData = csvTable
          .skip(1)
          .map((e) => Map<String, dynamic>.fromIterables(headers, e.map((e) => e?.toString() ?? '')))
          .toList();

      for (var row in csvData) {
        final key = row['key'] as String;
        //_logger.info('Loading localization key: $key');

        if (!_localizations.containsKey(key)) {
          _localizations[key] = {};
          //_logger.info('Adding new localization key: $key');
        }

        if (loadLocale != null) {
          if (row[loadLocale.languageCode] == null) {
            _logger.warning('Value not found: $key - ${loadLocale.languageCode}');
          }
          _localizations[key]![loadLocale.languageCode] = row[loadLocale.languageCode] ?? _emptyValue;
          continue;
        }

        for (var locale
            in (cacheAllLocales ?? _cacheAllLocales ? [currentLocale.value.languageCode] : supportedLocaleCodes)) {
          if (row[locale] == null) {
            _logger.warning('Value not found: $key - $locale');
          }

          _localizations[key]![locale] = row[locale] ?? _emptyValue;
        }
      }

      _cachedLocales.addAll(
          (cacheAllLocales ?? _cacheAllLocales ? [currentLocale.value.languageCode] : supportedLocaleCodes)
              .where((locale) => !_cachedLocales.contains(locale))
              .toList());
    } catch (e) {
      _logger.severe('Failed to load CSV table: $e');
    }
  }

  static void _loadLocaleIfNeededSync(Locale locale) {
    if (!_cachedLocales.contains(locale.languageCode)) {
      _logger.info('Locale ${locale.languageCode} not cached. Loading...');
      loadSync('localization', loadLocale: locale);
    }
  }

  static void loadSync(String tableName, {Locale? loadLocale}) {
    if (loadLocale != null && _cacheAllLocales) {
      _logger.severe('loadLocale and cacheAllLocales cannot be used at the same time');
      return;
    }

    try {
      rootBundle.loadString(_buildPath(tableName)).then((data) {
        final List<List<dynamic>> csvTable = const CsvToListConverter().convert(data);

        final headers = csvTable.first.map((e) => e.toString()).toList();
        final csvData = csvTable
            .skip(1)
            .map((e) => Map<String, dynamic>.fromIterables(headers, e.map((e) => e?.toString() ?? _emptyValue)))
            .toList();

        for (var row in csvData) {
          final key = row['key'] as String;
          if (!_localizations.containsKey(key)) {
            _localizations[key] = {};
          }

          if (loadLocale != null) {
            _localizations[key]![loadLocale.languageCode] = row[loadLocale.languageCode] ?? _emptyValue;
            continue;
          }

          for (var locale in (_cacheAllLocales ? headers.sublist(1) : supportedLocaleCodes)) {
            _localizations[key]![locale] = row[locale] ?? _emptyValue;
          }
        }

        _cachedLocales.addAll((_cacheAllLocales ? headers.sublist(1) : supportedLocaleCodes)
            .where((locale) => !_cachedLocales.contains(locale))
            .toList());
      });
    } catch (e) {
      _logger.severe('Failed to load CSV table: $e');
    }
  }

  static String get(String key) {
    //_logger.info('Getting localization for key: $key with locale: ${currentLocale.value.languageCode}');
    _loadLocaleIfNeededSync(currentLocale.value);

    if (!_localizations.containsKey(key)) {
      _logger.warning('Key not found: $key');
      return key;
    }

    if (!_localizations[key]!.containsKey(currentLocale.value.languageCode)) {
      _logger.warning('Locale not found: ${currentLocale.value}');
      return key;
    }

    if (_localizations[key]![currentLocale.value.languageCode] == null) {
      _logger.warning('Value not found: $key');
      return key;
    }

    return _localizations[key]?[currentLocale.value.languageCode] ?? key;
  }

  static String getWithAutoFormatKey<T>({required TextType type, required String id}) {
    final modelName = T.runtimeType.toString().toLowerCase();
    final key = '$modelName.${type.name}.$id';

    return get(key);
  }

  static String getWithLocale(String key, Locale locale) {
    _loadLocaleIfNeededSync(locale);

    if (!_localizations.containsKey(key)) {
      _logger.warning('Key not found: $key');
      return key;
    }

    return _localizations[key]?[locale.languageCode] ?? key;
  }

  static void changeLocale(Locale locale) {
    if (!supportedLocaleCodes.contains(locale.languageCode)) {
      _logger.warning('Unsupported locale: $locale');
      return;
    }

    _loadLocaleIfNeededSync(locale);
    currentLocale.value = locale;
  }
}
