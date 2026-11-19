import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/money.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/quantity_selector.dart';

class P03DetalleListaScreen extends StatelessWidget {
  const P03DetalleListaScreen({super.key});

  Future<void> _deleteProduct(
    BuildContext context,
    AppState state,
    String id,
    String name,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: const Text('Eliminar producto'),
        content: Text('¿Quieres eliminar $name de la lista?'),
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

    if (confirm != true) return;
    final removed = state.removeProduct(id);
    if (removed == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        content: Text('$name eliminado'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {
            final restored = state.restoreProduct(removed);
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  restored ? '$name recuperado' : 'No se puede recuperar $name',
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final expense = state.expenseCents;

    return Scaffold(
      appBar: AppBar(
        title: Text(state.listName),
        actions: [
          IconButton(
            tooltip: 'Inicio',
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (route) => false,
            ),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Semantics(
                            liveRegion: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${state.pendingCount} pendientes · ${state.boughtCount} comprados',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  expense == null
                                      ? 'Sin gasto registrado'
                                      : 'Importe guardado: ${formatExpense(expense)} €',
                                  style: const TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Icon(Icons.shopping_basket_outlined, size: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (state.products.isEmpty)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Todavía no hay productos. Añade el primero para empezar.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.builder(
                  itemCount: state.products.length,
                  itemBuilder: (context, index) {
                    final product = state.products[index];
                    return Card(
                      key: ValueKey(product.id),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                MergeSemantics(
                                  child: Semantics(
                                    label: product.name,
                                    child: Checkbox(
                                      value: product.isBought,
                                      onChanged: (value) => state.toggleBought(
                                        product.id,
                                        value ?? false,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              decoration: product.isBought
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                            ),
                                      ),
                                      Semantics(
                                        liveRegion: true,
                                        excludeSemantics: true,
                                        label:
                                            '${product.name}: ${product.isBought ? 'Comprado' : 'Pendiente'}',
                                        child: Text(
                                          product.isBought
                                              ? 'Comprado'
                                              : 'Pendiente',
                                          style: TextStyle(
                                            color: product.isBought
                                                ? AppColors.success
                                                : AppColors.secondaryText,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  tooltip: 'Opciones de ${product.name}',
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      Navigator.pushNamed(
                                        context,
                                        '/editar-producto',
                                        arguments: product.id,
                                      );
                                    } else if (value == 'delete') {
                                      _deleteProduct(
                                        context,
                                        state,
                                        product.id,
                                        product.name,
                                      );
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Editar'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 12),
                                  child: Text(
                                    'Cantidad:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                QuantitySelector(
                                  quantity: product.quantity,
                                  productName: product.name,
                                  compact: true,
                                  onChanged: (newQty) =>
                                      state.updateProductQuantity(
                                        product.id,
                                        newQty,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    AppButton(
                      label: 'Añadir producto',
                      icon: Icons.add,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/anadir-producto'),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      label: 'Registrar gasto',
                      icon: Icons.euro,
                      outlined: true,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/registrar-gasto'),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      label: 'Ver resumen',
                      icon: Icons.receipt_long_outlined,
                      outlined: true,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/resumen-compra'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
