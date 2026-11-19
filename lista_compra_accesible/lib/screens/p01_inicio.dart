import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/money.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/vigentes_calculator_dialog.dart';

class P01InicioScreen extends StatelessWidget {
  const P01InicioScreen({super.key});

  void _openCalculator(BuildContext context, AppState state) {
    showDialog<void>(
      context: context,
      builder: (_) => VigentesCalculatorDialog(
        activeLists: state.activeLists,
        activeTotal: state.activeListsTotal / 100,
      ),
    );
  }

  Future<void> _confirmDeleteList(
    BuildContext context,
    AppState state,
    String listId,
    String listName,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: const Text('Eliminar lista'),
        content: Text('¿Quieres eliminar "$listName" y su importe guardado?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      state.deleteList(listId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Lista de la compra')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 72,
                    color: AppColors.primary,
                    semanticLabel: 'Carrito de la compra',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Organiza tu compra fácilmente',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crea listas, añade productos y guarda el importe de todas tus compras.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Crear lista nueva',
                    icon: Icons.add,
                    onPressed: () =>
                        Navigator.pushNamed(context, '/crear-lista'),
                  ),
                  if (state.lists.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Card(
                      color: AppColors.successBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppColors.success),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.calculate_outlined,
                                  color: AppColors.success,
                                  size: 28,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Total listas vigentes (${state.activeLists.length})',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(color: AppColors.success),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${formatExpense(state.activeListsTotal)} €',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () => _openCalculator(context, state),
                              icon: const Icon(Icons.calculate),
                              label: const Text('Abrir calculadora'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Mis listas guardadas (${state.lists.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ...state.lists.map((list) {
                      void openList() {
                        state.selectList(list.id);
                        Navigator.pushNamed(context, '/detalle-lista');
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: list.isActive
                                  ? AppColors.primary
                                  : AppColors.controlBorder.withAlpha(110),
                              width: list.isActive ? 1.5 : 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: openList,
                                        excludeFromSemantics: true,
                                        canRequestFocus: false,
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            minHeight: 48,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                list.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${list.products.length} productos · ${list.expenseCents == null ? 'Sin gasto registrado' : '${formatExpense(list.expenseCents!)} €'}',
                                                style: const TextStyle(
                                                  color:
                                                      AppColors.secondaryText,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Eliminar ${list.name}',
                                      onPressed: () => _confirmDeleteList(
                                        context,
                                        state,
                                        list.id,
                                        list.name,
                                      ),
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),
                                Wrap(
                                  spacing: 12,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        MergeSemantics(
                                          child: Semantics(
                                            label: 'Vigencia de ${list.name}',
                                            child: Switch(
                                              value: list.isActive,
                                              onChanged: (value) =>
                                                  state.toggleListActive(
                                                    list.id,
                                                    value,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: ExcludeSemantics(
                                            child: Text(
                                              list.isActive
                                                  ? 'Vigente'
                                                  : 'No vigente',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: list.isActive
                                                    ? AppColors.success
                                                    : AppColors.secondaryText,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    FilledButton.tonalIcon(
                                      onPressed: openList,
                                      icon: const Icon(
                                        Icons.open_in_new,
                                        size: 18,
                                      ),
                                      label: Text(
                                        'Abrir',
                                        semanticsLabel: 'Abrir ${list.name}',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
