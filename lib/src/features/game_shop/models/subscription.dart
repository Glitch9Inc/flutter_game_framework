import 'package:dart_database/dart_database.dart';
import 'package:flutter_corelib/flutter_corelib.dart';

class Subscription with DatabaseEntry {
  @override
  final String key;
  final DateTime? startDate;
  final DateTime? expirationDate;
  final bool? isPermanent;

  Subscription._({
    required this.key,
    this.startDate,
    this.expirationDate,
    this.isPermanent = false,
  });

  bool get isActive {
    if (isPermanent == true) {
      return true;
    }

    if (startDate == null || expirationDate == null) {
      return false;
    }

    final now = DateTime.now();
    return now.isAfter(startDate!) && now.isBefore(expirationDate!);
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription._(
      key: json.getString('key'),
      startDate: json.getDateTime('start_date'),
      expirationDate: json.getDateTime('expiration_date'),
      isPermanent: json.getBool('is_permanent'),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'start_date': startDate,
      'expiration_date': expirationDate,
      'is_permanent': isPermanent,
    };
  }

  /// Don't use this unless you know what you're doing.
  factory Subscription.permanent(String key) {
    return Subscription._(
      key: key,
      isPermanent: true,
    );
  }

  factory Subscription.weekly(String key) {
    final now = DateTime.now();

    return Subscription._(
      key: key,
      startDate: now,
      expirationDate: now.nextWeek,
    );
  }

  factory Subscription.monthly(String key) {
    final now = DateTime.now();

    return Subscription._(
      key: key,
      startDate: now,
      expirationDate: now.nextMonth,
    );
  }

  factory Subscription.yearly(String key) {
    final now = DateTime.now();

    return Subscription._(
      key: key,
      startDate: now,
      expirationDate: now.nextYear,
    );
  }
}
