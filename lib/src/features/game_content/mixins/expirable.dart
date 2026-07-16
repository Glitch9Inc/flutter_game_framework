mixin Expirable {
  DateTime? get expiresAt;
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get canExpire => expiresAt != null;
}
