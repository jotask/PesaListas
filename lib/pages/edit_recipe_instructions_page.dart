import 'package:flutter/material.dart';
import 'package:pesalistas/core/fields/recipe_fields.dart';
import 'package:pesalistas/core/recipe_instruction_steps.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/common/form_page_layout.dart';

class EditRecipeInstructionsPageResult {
  const EditRecipeInstructionsPageResult({this.instructions});

  final String? instructions;
}

class EditRecipeInstructionsPage extends StatefulWidget {
  const EditRecipeInstructionsPage({super.key, required this.recipe});

  final Map<String, dynamic> recipe;

  @override
  State<EditRecipeInstructionsPage> createState() =>
      _EditRecipeInstructionsPageState();
}

class _EditRecipeInstructionsPageState
    extends State<EditRecipeInstructionsPage> {
  final List<TextEditingController> stepControllers = [];

  @override
  void initState() {
    super.initState();

    final existingInstructions = widget.recipe[AppRecipeFields.instructions]
        ?.toString();

    final steps = AppRecipeInstructionSteps.parse(existingInstructions);

    if (steps.isEmpty) {
      stepControllers.add(TextEditingController());
    } else {
      for (final step in steps) {
        stepControllers.add(TextEditingController(text: step));
      }
    }
  }

  @override
  void dispose() {
    for (final controller in stepControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  void addStep() {
    setState(() {
      stepControllers.add(TextEditingController());
    });
  }

  void removeStep(int index) {
    if (index < 0 || index >= stepControllers.length) return;

    final controller = stepControllers.removeAt(index);
    controller.dispose();

    if (stepControllers.isEmpty) {
      stepControllers.add(TextEditingController());
    }

    setState(() {});
  }

  void reorderStep(int oldIndex, int newIndex) {
    setState(() {
      final controller = stepControllers.removeAt(oldIndex);
      stepControllers.insert(newIndex, controller);
    });
  }

  List<String> cleanSteps() {
    return stepControllers
        .map((controller) => controller.text.trim())
        .where((step) => step.isNotEmpty)
        .toList();
  }

  String? buildInstructionsText() {
    return AppRecipeInstructionSteps.buildNumberedText(cleanSteps());
  }

  void submit() {
    Navigator.of(context).pop(
      EditRecipeInstructionsPageResult(instructions: buildInstructionsText()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.editInstructions)),
      bottomNavigationBar: AppFormBottomActions(
        cancelLabel: context.l10n.cancel,
        primaryLabel: context.l10n.save,
        primaryIcon: Icons.save_outlined,
        onCancel: () => Navigator.of(context).pop(),
        onPrimary: submit,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppFormPageHeaderCard(
              icon: Icons.menu_book_outlined,
              title: context.l10n.cookingInstructions,
              subtitle:
                  'Add each cooking instruction as a separate step. You can reorder, edit, or remove steps.',
            ),
            const SizedBox(height: 16),
            AppFormSectionCard(
              children: [
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  itemCount: stepControllers.length,
                  onReorderItem: reorderStep,
                  itemBuilder: (context, index) {
                    final controller = stepControllers[index];

                    return _InstructionStepEditor(
                      key: ValueKey(controller),
                      index: index,
                      controller: controller,
                      canRemove: stepControllers.length > 1,
                      onRemove: () => removeStep(index),
                    );
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: addStep,
                  icon: const Icon(Icons.add),
                  label: const Text('Add step'),
                ),
              ],
            ),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}

class _InstructionStepEditor extends StatelessWidget {
  const _InstructionStepEditor({
    super.key,
    required this.index,
    required this.controller,
    required this.canRemove,
    required this.onRemove,
  });

  final int index;
  final TextEditingController controller;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.35,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Step instruction',
                  hintText: 'Example: Chop the onions and garlic.',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                minLines: 2,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
              ),
            ),
            const SizedBox(width: 4),
            Column(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.drag_handle),
                    tooltip: 'Reorder step',
                  ),
                ),
                IconButton(
                  onPressed: canRemove ? onRemove : null,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remove step',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
