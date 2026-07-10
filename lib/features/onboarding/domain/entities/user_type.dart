enum UserType {
  student,
  searching;

  String get storageValue => name;

  static UserType? fromStorageValue(String? value) {
    for (final type in UserType.values) {
      if (type.storageValue == value) return type;
    }
    return null;
  }
}
