import 'package:flutter/material.dart';

import '../models/shopping_list.dart';
import '../models/money.dart';
import '../theme/app_theme.dart';

class VigentesCalculatorDialog extends StatefulWidget {
  const VigentesCalculatorDialog({
    required this.activeLists,
    required this.activeTotal,
    super.key,
  });

  final List<ShoppingList> activeLists;
  final double activeTotal;

  @override
  State<VigentesCalculatorDialog> createState() =>
      _VigentesCalculatorDialogState();
}

class _VigentesCalculatorDialogState extends State<VigentesCalculatorDialog> {
  late String _display;
  double? _firstOperand;
  String? _operator;
  bool _shouldResetDisplay = false;

  @override
  void initState() {
    super.initState();
    _display = _formatNumber(widget.activeTotal);
  }

  String _formatNumber(double value) {
    if (!value.isFinite) return 'Resultado fuera de rango';
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(2);
    }
    return value
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  double get _currentValue =>
      double.tryParse(_display.replaceAll(',', '.')) ?? 0.0;

  void _onDigit(String digit) {
    setState(() {
      if (_shouldResetDisplay || _display == '0.00' || _display == '0') {
        _display = digit == '.' ? '0.' : digit;
        _shouldResetDisplay = false;
      } else {
        if (digit == '.' && _display.contains('.')) return;
        _display += digit;
      }
    });
  }

  void _onOperator(String op) {
    setState(() {
      if (_firstOperand != null && _operator != null && !_shouldResetDisplay) {
        _calculate();
      }
      _firstOperand = _currentValue;
      _operator = op;
      _shouldResetDisplay = true;
    });
  }

  void _calculate() {
    if (_firstOperand == null || _operator == null) return;
    final second = _currentValue;
    double result = second;

    switch (_operator) {
      case '+':
        result = _firstOperand! + second;
        break;
      case '-':
        result = _firstOperand! - second;
        break;
      case '×':
        result = _firstOperand! * second;
        break;
      case '÷':
        if (second == 0) {
          setState(() {
            _display = 'No se puede dividir entre cero';
            _firstOperand = null;
            _operator = null;
            _shouldResetDisplay = true;
          });
          return;
        }
        result = _firstOperand! / second;
        break;
    }

    setState(() {
      _display = _formatNumber(result);
      _firstOperand = null;
      _operator = null;
      _shouldResetDisplay = true;
    });
  }

  void _clear() {
    setState(() {
      _display = '0';
      _firstOperand = null;
      _operator = null;
      _shouldResetDisplay = false;
    });
  }

  void _loadVigentesTotal() {
    setState(() {
      _display = _formatNumber(widget.activeTotal);
      _firstOperand = null;
      _operator = null;
      _shouldResetDisplay = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: const Text('Calculadora listas vigentes'),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.activeLists.isEmpty)
                const Text('No hay listas vigentes marcadas.')
              else ...[
                Text(
                  'Listas vigentes incluidas (${widget.activeLists.length}):',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                ...widget.activeLists.map(
                  (list) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            list.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            list.expenseCents == null
                                ? 'Sin gasto'
                                : '${formatExpense(list.expenseCents!)} €',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const Divider(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.successBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_operator != null && _firstOperand != null)
                      Text(
                        '${_formatNumber(_firstOperand!)} $_operator',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    Semantics(
                      liveRegion: true,
                      label: 'Resultado calculadora: $_display',
                      excludeSemantics: true,
                      child: Text(
                        _display.startsWith(RegExp(r'[-0-9]'))
                            ? '$_display €'
                            : _display,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _loadVigentesTotal,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(
                  'Total vigentes (${widget.activeTotal.toStringAsFixed(2)} €)',
                ),
              ),
              const SizedBox(height: 12),
              _buildButtonRow(['7', '8', '9', '÷']),
              const SizedBox(height: 8),
              _buildButtonRow(['4', '5', '6', '×']),
              const SizedBox(height: 8),
              _buildButtonRow(['1', '2', '3', '-']),
              const SizedBox(height: 8),
              _buildButtonRow(['C', '0', '.', '+']),
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _calculate,
                  child: const Text(
                    '=',
                    semanticsLabel: 'Calcular resultado',
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  Widget _buildButtonRow(List<String> keys) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: keys.map((key) {
        final isOp = ['+', '-', '×', '÷'].contains(key);
        final isClear = key == 'C';
        return SizedBox(
          width: 48,
          height: 56,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: isOp
                  ? AppColors.primary.withAlpha(24)
                  : isClear
                  ? AppColors.error.withAlpha(20)
                  : AppColors.surface,
              foregroundColor: isClear ? AppColors.error : AppColors.text,
            ),
            onPressed: () {
              if (isClear) {
                _clear();
              } else if (isOp) {
                _onOperator(key);
              } else {
                _onDigit(key);
              }
            },
            child: Semantics(
              excludeSemantics: true,
              label:
                  const {
                    'C': 'Borrar',
                    '+': 'Sumar',
                    '-': 'Restar',
                    '×': 'Multiplicar',
                    '÷': 'Dividir',
                    '.': 'Separador decimal',
                  }[key] ??
                  key,
              child: Text(
                key,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
