import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/quantity_selector.dart';

class P03DetalleListaScreen extends StatelessWidget {
  const P03DetalleListaScreen({super.key});

  Future<void> _deleteProduct(
    BuildContext context,
    AppState state,
    String id,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: const Text('¿Quieres eliminar este producto de la lista?'),
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Producto eliminado'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () => state.restoreProduct(removed),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

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
        child: Column(
          children: [
            Padding(
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
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Importe guardado: ${state.expense.toStringAsFixed(2)} €',
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
            Expanded(
              child: state.products.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Todavía no hay productos. Añade el primero para empezar.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.products.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 10,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: product.isBought,
                                      onChanged: (value) => state.toggleBought(
                                        product.id,
                                        value ?? false,
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
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : TextDecoration.none,
                                                ),
                                          ),
                                          Text(
                                            product.isBought
                                                ? 'Comprado'
                                                : 'Pendiente',
                                            style: TextStyle(
                                              color: product.isBought
                                                  ? AppColors.success
                                                  : AppColors.secondaryText,
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
            Padding(
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
          ],
        ),
      ),
    );
  }
}
