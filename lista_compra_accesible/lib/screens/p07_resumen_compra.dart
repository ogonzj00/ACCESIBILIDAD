import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';

class P07ResumenCompraScreen extends StatelessWidget {
  const P07ResumenCompraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Resumen de compra')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 76,
                    color: AppColors.primary,
                    semanticLabel: 'Resumen de compra',
                  ),
                  const SizedBox(height: 20),
                  Text(
                    state.listName,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _SummaryRow(
                    label: 'Productos totales',
                    value: '${state.products.length}',
                  ),
                  _SummaryRow(
                    label: 'Productos comprados',
                    value: '${state.boughtCount}',
                  ),
                  _SummaryRow(
                    label: 'Productos pendientes',
                    value: '${state.pendingCount}',
                  ),
                  const Divider(height: 32),
                  Card(
                    color: AppColors.successBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text('Gasto registrado'),
                          const SizedBox(height: 8),
                          Text(
                            '${state.expense.toStringAsFixed(2)} €',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Volver a la lista',
                    icon: Icons.list_alt,
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/detalle-lista',
                      (route) => route.settings.name == '/',
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Modificar importe',
                    icon: Icons.edit_outlined,
                    outlined: true,
                    onPressed: () =>
                        Navigator.pushNamed(context, '/registrar-gasto'),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Ver todas mis listas',
                    icon: Icons.home_outlined,
                    outlined: true,
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}