import 'package:flutter/material.dart';
import 'package:pesalistas/core/list_types.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/common/form_page_layout.dart';

class CreateListPageResult {
  const CreateListPageResult({required this.name, required this.listType});

  final String name;
  final String listType;
}

class CreateListPage extends StatefulWidget {
  const CreateListPage({super.key});

  @override
  State<CreateListPage> createState() => _CreateListPageState();
}

class _CreateListPageState extends State<CreateListPage> {
  final TextEditingController nameController = TextEditingController();

  String listType = AppListTypes.generic.value;
  String? validationMessage;

  AppListTypeConfig get selectedConfig => AppListTypes.fromValue(listType);

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void clearValidation() {
    if (validationMessage == null) return;

    setState(() => validationMessage = null);
  }

  void selectListType(String value) {
    setState(() => listType = value);
  }

  void submit() {
    final name = nameController.text.trim();

    setState(() => validationMessage = null);

    if (name.isEmpty) {
      setState(() => validationMessage = context.l10n.listNameIsRequired);
      return;
    }

    Navigator.of(
      context,
    ).pop(CreateListPageResult(name: name, listType: listType));
  }

  @override
  Widget build(BuildContext context) {
    final config = selectedConfig;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.createList)),
      bottomNavigationBar: AppFormBottomActions(
        cancelLabel: context.l10n.cancel,
        primaryLabel: context.l10n.create,
        primaryIcon: Icons.add,
        onCancel: () => Navigator.of(context).pop(),
        onPrimary: submit,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppFormPageHeaderCard(
              icon: config.icon,
              title: context.l10n.createList,
              subtitle: config.description(context),
            ),
            const SizedBox(height: 16),
            AppFormSectionCard(
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.listName,
                    hintText: context.l10n.moviesToWatch,
                    prefixIcon: const Icon(Icons.list_alt_outlined),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => submit(),
                  onChanged: (_) => clearValidation(),
                ),
                if (validationMessage != null) ...[
                  const SizedBox(height: 16),
                  AppFormValidationMessage(message: validationMessage!),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.listType,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            for (final config in AppListTypes.all)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ListTypeOptionCard(
                  config: config,
                  selected: listType == config.value,
                  onTap: () => selectListType(config.value),
                ),
              ),
            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }
}

class _ListTypeOptionCard extends StatelessWidget {
  const _ListTypeOptionCard({
    required this.config,
    required this.selected,
    required this.onTap,
  });

  final AppListTypeConfig config;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor = selected
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surface;

    final foregroundColor = selected
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurface;

    final borderColor = selected
        ? theme.colorScheme.primary
        : theme.dividerColor.withValues(alpha: 0.45);

    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  config.icon,
                  color: selected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.label(context),
                      style: TextStyle(
                        color: foregroundColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      config.description(context),
                      style: TextStyle(
                        color: foregroundColor.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
