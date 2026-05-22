import 'package:flutter_test/flutter_test.dart';
import 'package:pesalistas/core/recipe_instruction_steps.dart';

void main() {
  group('AppRecipeInstructionSteps.parse', () {
    test('returns an empty list for null or blank text', () {
      expect(AppRecipeInstructionSteps.parse(null), isEmpty);
      expect(AppRecipeInstructionSteps.parse(''), isEmpty);
      expect(AppRecipeInstructionSteps.parse('   '), isEmpty);
    });

    test('parses numbered instruction lines', () {
      final result = AppRecipeInstructionSteps.parse(
        '1. Chop onions\n2. Heat oil\n3. Serve',
      );

      expect(result, ['Chop onions', 'Heat oil', 'Serve']);
    });

    test('parses bullet instruction lines', () {
      final result = AppRecipeInstructionSteps.parse(
        '- Chop onions\n* Heat oil\n• Serve',
      );

      expect(result, ['Chop onions', 'Heat oil', 'Serve']);
    });

    test('removes empty lines', () {
      final result = AppRecipeInstructionSteps.parse(
        '1. Chop onions\n\n2. Heat oil\n   \n3. Serve',
      );

      expect(result, ['Chop onions', 'Heat oil', 'Serve']);
    });
  });

  group('AppRecipeInstructionSteps.removeStepPrefix', () {
    test('removes supported step prefixes', () {
      expect(AppRecipeInstructionSteps.removeStepPrefix('1. Chop'), 'Chop');
      expect(AppRecipeInstructionSteps.removeStepPrefix('2) Heat'), 'Heat');
      expect(AppRecipeInstructionSteps.removeStepPrefix('- Serve'), 'Serve');
      expect(AppRecipeInstructionSteps.removeStepPrefix('* Serve'), 'Serve');
      expect(AppRecipeInstructionSteps.removeStepPrefix('• Serve'), 'Serve');
    });

    test('keeps text without a prefix', () {
      expect(
        AppRecipeInstructionSteps.removeStepPrefix('Mix everything'),
        'Mix everything',
      );
    });
  });

  group('AppRecipeInstructionSteps.buildNumberedText', () {
    test('returns null for no clean steps', () {
      expect(AppRecipeInstructionSteps.buildNumberedText([]), null);
      expect(AppRecipeInstructionSteps.buildNumberedText(['', '   ']), null);
    });

    test('builds numbered text from clean steps', () {
      final result = AppRecipeInstructionSteps.buildNumberedText([
        ' Chop onions ',
        'Heat oil',
        '',
        ' Serve ',
      ]);

      expect(result, '1. Chop onions\n2. Heat oil\n3. Serve');
    });
  });

  group('AppRecipeInstructionSteps.count', () {
    test('counts parsed steps', () {
      expect(AppRecipeInstructionSteps.count('1. Chop\n2. Heat'), 2);
      expect(AppRecipeInstructionSteps.count(null), 0);
    });
  });
}
