class AppRecipeInstructionSteps {
  const AppRecipeInstructionSteps._();

  static List<String> parse(String? value) {
    final text = value?.trim();

    if (text == null || text.isEmpty) {
      return [];
    }

    final lines = text
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map(removeStepPrefix)
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return [text];
    }

    return lines;
  }

  static String removeStepPrefix(String value) {
    return value.replaceFirst(RegExp(r'^\s*(?:\d+[\.)]|[-*•])\s*'), '').trim();
  }

  static String? buildNumberedText(List<String> steps) {
    final cleanSteps = steps.map((step) => step.trim()).where((step) {
      return step.isNotEmpty;
    }).toList();

    if (cleanSteps.isEmpty) {
      return null;
    }

    return [
      for (var index = 0; index < cleanSteps.length; index++)
        '${index + 1}. ${cleanSteps[index]}',
    ].join('\n');
  }

  static int count(String? value) {
    return parse(value).length;
  }
}
