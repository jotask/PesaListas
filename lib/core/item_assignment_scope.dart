class AppItemAssignmentScopes {
  const AppItemAssignmentScopes._();

  static const none = 'none';
  static const specific = 'specific';
  static const all = 'all';

  static const values = [none, specific, all];

  static bool isValid(String value) {
    return values.contains(value);
  }
}
