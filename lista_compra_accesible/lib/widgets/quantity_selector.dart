import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class QuantitySelector extends StatefulWidget {
  const QuantitySelector({
    required this.quantity,
    required this.onChanged,
    this.min = 1,
    this.compact = false,
    this.productName,
    super.key,
  });

  final int quantity;
  final ValueChanged<int> onChanged;
  final int min;
  final bool compact;
  final String? productName;

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  String? _lastTouched; // 'minus' o 'plus'

  void _decrement() {
    if (widget.quantity <= widget.min) return;
    setState(() => _lastTouched = 'minus');
    widget.onChanged(widget.quantity - 1);
  }

  void _increment() {
    setState(() => _lastTouched = 'plus');
    widget.onChanged(widget.quantity + 1);
  }

  @override
  Widget build(BuildContext context) {
    final canDecrement = widget.quantity > widget.min;
    final buttonSize = widget.compact ? 48.0 : 52.0;

    final name = widget.productName;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      children: [
        _StepButton(
          icon: Icons.remove,
          tooltip: name == null
              ? 'Restar cantidad'
              : 'Restar cantidad de $name',
          size: buttonSize,
          enabled: canDecrement,
          highlighted: _lastTouched == 'minus',
          onTap: canDecrement ? _decrement : null,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.compact ? 14 : 20),
          child: Semantics(
            liveRegion: true,
            label: 'Cantidad: ${widget.quantity}',
            excludeSemantics: true,
            child: Text(
              '${widget.quantity}',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontSize: widget.compact ? 18 : 22),
            ),
          ),
        ),
        _StepButton(
          icon: Icons.add,
          tooltip: name == null ? 'Sumar cantidad' : 'Sumar cantidad de $name',
          size: buttonSize,
          enabled: true,
          highlighted: _lastTouched == 'plus',
          onTap: _increment,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.size,
    required this.enabled,
    required this.highlighted,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final double size;
  final bool enabled;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = !enabled
        ? AppColors.controlBorder.withAlpha(90)
        : highlighted
        ? AppColors.primary
        : AppColors.controlBorder;

    final backgroundColor = highlighted && enabled
        ? AppColors.primary.withAlpha(42)
        : AppColors.surface;

    return Semantics(
      button: true,
      enabled: enabled,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        excludeFromSemantics: true,
        child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          elevation: highlighted && enabled ? 2 : 0,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            highlightColor: AppColors.primary.withAlpha(55),
            splashColor: AppColors.primary.withAlpha(70),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: borderColor,
                  width: highlighted && enabled ? 2.5 : 1.5,
                ),
              ),
              child: Icon(
                icon,
                color: enabled
                    ? AppColors.primary
                    : AppColors.controlBorder.withAlpha(110),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
