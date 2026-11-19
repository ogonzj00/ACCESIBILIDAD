import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/money.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class P06RegistrarGastoScreen extends StatefulWidget {
  const P06RegistrarGastoScreen({super.key});

  @override
  State<P06RegistrarGastoScreen> createState() =>
      _P06RegistrarGastoScreenState();
}

class _P06RegistrarGastoScreenState extends State<P06RegistrarGastoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final currentExpense = context.read<AppState>().expenseCents;
    if (currentExpense != null) {
      _amountController.text = formatExpense(currentExpense);
    }
    _initialized = true;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final amount = parseExpense(_amountController.text);
    if (amount == null || !context.read<AppState>().hasList) return;
    context.read<AppState>().setExpense(amount);
    if (ModalRoute.of(context)?.settings.arguments == true) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, '/resumen-compra');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final currentExpense = state.expenseCents;

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar gasto')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '¿Cuánto has gastado en "${state.listName}"?',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Introduce el importe total de la compra en euros.',
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      controller: _amountController,
                      label: 'Importe (€)',
                      hint: 'Ej. 24,50',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Introduce un importe';
                        }
                        if (parseExpense(value) == null) {
                          return 'Introduce un importe válido, con hasta dos decimales y un máximo de 999999999,99 €';
                        }
                        return null;
                      },
                    ),
                    if (currentExpense != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Último importe registrado: ${formatExpense(currentExpense)} €',
                      ),
                    ],
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Guardar gasto',
                      icon: Icons.check,
                      onPressed: _save,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
