extension MapExtension on Map<String, dynamic> {
  dynamic getOrNull(String key) => containsKey(key) ? this[key] : null;
  bool notContainsOrNull(String key) => !containsKey(key) || this[key] == null;
}
