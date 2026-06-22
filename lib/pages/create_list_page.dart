import 'package:flutter/material.dart';
import 'package:pesalistas/core/design/app_spacing.dart';
import 'package:pesalistas/core/design/list_type_style.dart';
import 'package:pesalistas/core/list_types.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/widgets/common/form_page_layout.dart';
import 'package:pesalistas/widgets/design/app_list_type_card.dart';
import 'package:pesalistas/widgets/design/app_section_header.dart';
import 'package:pesalistas/widgets/design/app_surface.dart';

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
    final style = ListTypeStyle.of(listType);

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
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.screenTop,
            AppSpacing.screenHorizontal,
            AppSpacing.screenBottom,
          ),
          children: [
            AppSurface(
              padding: EdgeInsets.zero,
              color: style.soft,
              borderColor: style.accent.withValues(alpha: 0.18),
              child: Container(
                decoration: BoxDecoration(
                  gradient: style.gradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: style.accent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(config.icon, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.createList,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: style.onSoft,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            config.description(context),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: style.onSoft.withValues(alpha: 0.78),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    const SizedBox(height: AppSpacing.md),
                    AppFormValidationMessage(message: validationMessage!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppSectionHeader(
              title: context.l10n.listType,
              subtitle: config.label(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            GridView.builder(
              itemCount: AppListTypes.all.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 0.96,
              ),
              itemBuilder: (context, index) {
                final config = AppListTypes.all[index];

                return AppListTypeCard(
                  config: config,
                  selected: listType == config.value,
                  onTap: () => selectListType(config.value),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
