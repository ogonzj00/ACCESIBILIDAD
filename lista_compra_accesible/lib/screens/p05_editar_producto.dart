import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/quantity_selector.dart';

class P05EditarProductoScreen extends StatefulWidget {
  const P05EditarProductoScreen({required this.productId, super.key});

  final String productId;

  @override
  State<P05EditarProductoScreen> createState() =>
      _P05EditarProductoScreenState();
}

class _P05EditarProductoScreenState extends State<P05EditarProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _quantity = 1;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final product = context.read<AppState>().productById(widget.productId);
    if (product != null) {
      _nameController.text = product.name;
      _quantity = product.quantity;
    }
    _initialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AppState>().updateProduct(
          widget.productId,
          _nameController.text,
          _quantity,
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final product = context.watch<AppState>().productById(widget.productId);
    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar producto')),
        body: const Center(child: Text('No se ha encontrado el producto.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar producto')),
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
                    AppTextField(
                      controller: _nameController,
                      label: 'Nombre del producto',
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'El nombre no puede estar vacío'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Cantidad',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: QuantitySelector(
                        quantity: _quantity,
                        onChanged: (value) => setState(() => _quantity = value),
                      ),
                    ),
                    const SizedBox(height: 28),
                    AppButton(
                      label: 'Guardar cambios',
                      icon: Icons.save_outlined,
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
