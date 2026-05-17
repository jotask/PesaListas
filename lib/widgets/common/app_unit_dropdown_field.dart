import 'package:flutter/material.dart';
import 'package:pesalistas/core/app_units.dart';

class AppUnitDropdownField extends StatelessWidget {
  const AppUnitDropdownField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.enabled = true,
    this.onChanged,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final bool enabled;
  final VoidCallback? onChanged;

  String? get selectedValue {
    return AppUnitType.normalize(controller.text);
  }

  List<DropdownMenuItem<String>> get unitItems {
    final currentValue = selectedValue;
    final knownValues = AppUnitType.values.map((unit) => unit.value).toSet();

    final items = <DropdownMenuItem<String>>[
      const DropdownMenuItem<String>(value: '', child: Text('No unit')),
      for (final unit in AppUnitType.values)
        DropdownMenuItem<String>(
          value: unit.value,
          child: Text(AppUnitType.displayLabel(unit.value)),
        ),
    ];

    if (currentValue != null &&
        currentValue.isNotEmpty &&
        !knownValues.contains(currentValue)) {
      items.add(
        DropdownMenuItem<String>(
          value: currentValue,
          child: Text('Custom: ${AppUnitType.displayLabel(currentValue)}'),
        ),
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final value = selectedValue;

    return DropdownButtonFormField<String>(
      value: value == null || value.isEmpty ? '' : value,
      items: unitItems,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
      ),
      onChanged: enabled
          ? (newValue) {
              controller.text = newValue == null || newValue.isEmpty
                  ? ''
                  : newValue;
              onChanged?.call();
            }
          : null,
    );
  }
}
