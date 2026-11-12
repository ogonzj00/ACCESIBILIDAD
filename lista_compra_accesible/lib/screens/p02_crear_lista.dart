import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class P02CrearListaScreen extends StatefulWidget {
  const P02CrearListaScreen({super.key});

  @override
  State<P02CrearListaScreen> createState() => _P02CrearListaScreenState();
}

class _P02CrearListaScreenState extends State<P02CrearListaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Compra semanal');

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AppState>().createList(_nameController.text);
    Navigator.pushReplacementNamed(context, '/detalle-lista');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear lista')),
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
                      '¿Cómo quieres llamar a tu lista?',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      controller: _nameController,
                      label: 'Nombre de la lista',
                      hint: 'Ej. Compra semanal',
                      textInputAction: TextInputAction.done,
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Introduce un nombre para la lista'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Crear lista',
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
