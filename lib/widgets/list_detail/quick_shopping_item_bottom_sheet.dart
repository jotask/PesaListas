import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pesalistas/core/app_units.dart';
import 'package:pesalistas/core/shopping_stores.dart';
import 'package:pesalistas/core/value_parsing.dart';
import 'package:pesalistas/l10n/l10n_extensions.dart';
import 'package:pesalistas/pages/shopping_item_form_page.dart';
import 'package:pesalistas/repositories/user_app_settings_repository.dart';
import 'package:pesalistas/widgets/common/app_number_stepper_field.dart';
import 'package:pesalistas/widgets/common/app_unit_dropdown_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<ShoppingItemFormPageResult?> showQuickShoppingItemBottomSheet({
  required BuildContext context,
}) {
  return showModalBottomSheet<ShoppingItemFormPageResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const QuickShoppingItemBottomSheet(),
  );
}

class QuickShoppingItemBottomSheet extends StatefulWidget {
  const QuickShoppingItemBottomSheet({super.key});

  @override
  State<QuickShoppingItemBottomSheet> createState() =>
      _QuickShoppingItemBottomSheetState();
}

class _QuickShoppingItemBottomSheetState
    extends State<QuickShoppingItemBottomSheet> {
  late final UserAppSettingsRepository userAppSettingsRepository;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController(
    text: '1',
  );
  final TextEditingController unitController = TextEditingController();

  String selectedStoreKey = AppShoppingStores.defaultStore;
  String? validationMessage;
  bool saving = false;

  String get selectedStoreName {
    return AppShoppingStores.label(selectedStoreKey);
  }

  @override
  void initState() {
    super.initState();

    userAppSettingsRepository = UserAppSettingsRepository(
      Supabase.instance.client,
    );

    unawaited(loadDefaultShoppingStore());
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
    super.dispose();
  }

  Future<void> loadDefaultShoppingStore() async {
    try {
      final defaultStoreKey = await userAppSettingsRepository
          .getDefaultShoppingStoreKey();

      if (!mounted || defaultStoreKey == null) {
        return;
      }

      setState(() => selectedStoreKey = defaultStoreKey);
    } catch (error, stackTrace) {
      debugPrint('QUICK ADD LOAD DEFAULT STORE FAILED: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void clearValidation() {
    if (validationMessage == null) return;

    setState(() => validationMessage = null);
  }

  Future<void> submit() async {
    if (saving) return;

    final name = nameController.text.trim();
    final quantityText = quantityController.text.trim();
    final unitText = unitController.text.trim();

    setState(() => validationMessage = null);

    if (name.isEmpty) {
      setState(() => validationMessage = context.l10n.itemNameIsRequired);
      return;
    }

    final quantity = quantityText.isEmpty
        ? 1.0
        : AppValueParsing.doubleOrNull(quantityText);

    if (quantityText.isNotEmpty && quantity == null) {
      setState(() => validationMessage = context.l10n.quantityMustBeANumber);
      return;
    }

    if (quantity != null && quantity <= 0) {
      setState(() => validationMessage = 'Quantity must be greater than 0.');
      return;
    }

    final normalizedUnit = AppUnitType.valueOrNull(unitText);

    setState(() => saving = true);

    try {
      await userAppSettingsRepository.saveDefaultShoppingStoreKey(
        selectedStoreKey,
      );
    } catch (error, stackTrace) {
      debugPrint('QUICK ADD SAVE DEFAULT STORE FAILED: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    if (!mounted) return;

    Navigator.of(context).pop(
      ShoppingItemFormPageResult(
        name: name,
        quantity: quantity,
        unit: normalizedUnit,
        storeKey: selectedStoreKey,
        storeName: selectedStoreName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.35,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.add_shopping_cart_outlined,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Quick add',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: saving
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'What do you need?',
                  hintText: 'Milk, bread, tomatoes...',
                  prefixIcon: Icon(Icons.shopping_basket_outlined),
                ),
                textInputAction: TextInputAction.next,
                onChanged: (_) => clearValidation(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppNumberStepperField(
                      controller: quantityController,
                      labelText: context.l10n.quantity,
                      hintText: '1',
                      prefixIcon: Icons.numbers_outlined,
                      min: 0.25,
                      max: 9999,
                      step: 1,
                      decimal: true,
                      enabled: !saving,
                      onChanged: clearValidation,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppUnitDropdownField(
                      controller: unitController,
                      labelText: context.l10n.unit,
                      hintText: context.l10n.pcsGMl,
                      prefixIcon: Icons.scale_outlined,
                      enabled: !saving,
                      onChanged: clearValidation,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedStoreKey,
                decoration: const InputDecoration(
                  labelText: 'Store',
                  prefixIcon: Icon(Icons.storefront_outlined),
                ),
                items: AppShoppingStores.values.map((storeKey) {
                  return DropdownMenuItem<String>(
                    value: storeKey,
                    child: Text(AppShoppingStores.label(storeKey)),
                  );
                }).toList(),
                onChanged: saving
                    ? null
                    : (value) {
                        if (value == null) return;

                        setState(() {
                          selectedStoreKey = value;
                          validationMessage = null;
                        });
                      },
              ),
              if (validationMessage != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    validationMessage!,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: saving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(context.l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: saving ? null : submit,
                      icon: saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add),
                      label: Text(context.l10n.add),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
