class AppItemStatus {
  const AppItemStatus._();

  static const open = 'open';
  static const done = 'done';

  static bool isDone(dynamic value) {
    return value?.toString() == done;
  }

  static bool isOpen(dynamic value) {
    final text = value?.toString();

    return text == null || text.isEmpty || text == open;
  }

  static String displayText(dynamic value) {
    if (isDone(value)) {
      return 'Done';
    }

    return 'Open';
  }
}
