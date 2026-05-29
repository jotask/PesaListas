import 'package:flutter/material.dart';

class AppNumberStepperField extends StatelessWidget {
  const AppNumberStepperField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.onChanged,
    this.hintText = '1',
    this.prefixIcon,
    this.step = 1,
    this.min = 0,
    this.max = 9999,
    this.decimal = true,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String labelText;
  final VoidCallback onChanged;
  final String hintText;
  final IconData? prefixIcon;
  final double step;
  final double min;
  final double max;
  final bool decimal;
  final bool enabled;

  double _currentValue() {
    final text = controller.text.trim().replaceAll(',', '.');
    final parsed = double.tryParse(text);

    if (parsed == null) {
      return min <= 1 && max >= 1 ? 1 : min;
    }

    return parsed.clamp(min, max).toDouble();
  }

  String _formatValue(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  void _changeValue(double delta) {
    final current = _currentValue();
    final next = (current + delta).clamp(min, max).toDouble();

    controller.text = _formatValue(next);
    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );

    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        enabled: enabled,
      ),
      child: Row(
        children: [
          _StepperIconButton(
            icon: Icons.remove,
            enabled: enabled,
            onPressed: () => _changeValue(-step),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.numberWithOptions(decimal: decimal),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: hintText,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              onChanged: (_) => onChanged(),
            ),
          ),
          _StepperIconButton(
            icon: Icons.add,
            enabled: enabled,
            onPressed: () => _changeValue(step),
          ),
        ],
      ),
    );
  }
}

class _StepperIconButton extends StatelessWidget {
  const _StepperIconButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkResponse(
      onTap: enabled ? onPressed : null,
      radius: 22,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: enabled
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.45,
                ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}
