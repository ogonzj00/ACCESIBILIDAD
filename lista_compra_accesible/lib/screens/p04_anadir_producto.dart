import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/quantity_selector.dart';

class P04AnadirProductoScreen extends StatefulWidget {
  const P04AnadirProductoScreen({super.key});

  @override
  State<P04AnadirProductoScreen> createState() =>
      _P04AnadirProductoScreenState();
}

class _P04AnadirProductoScreenState extends State<P04AnadirProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _quantity = 1;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AppState>().addProduct(
          _nameController.text,
          _quantity,
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir producto')),
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
                      hint: 'Ej. Leche',
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Escribe el nombre del producto'
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
                      label: 'Guardar producto',
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
