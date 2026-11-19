import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/p01_inicio.dart';
import 'screens/p02_crear_lista.dart';
import 'screens/p03_detalle_lista.dart';
import 'screens/p04_anadir_producto.dart';
import 'screens/p05_editar_producto.dart';
import 'screens/p06_registrar_gasto.dart';
import 'screens/p07_resumen_compra.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = SharedPreferencesAsync();
  final state = AppState(
    readSnapshot: () => preferences.getString(AppState.storageKey),
    writeSnapshot: (snapshot) =>
        preferences.setString(AppState.storageKey, snapshot),
  );
  await state.load();
  runApp(
    ChangeNotifierProvider.value(value: state, child: const ListaCompraApp()),
  );
}

class ListaCompraApp extends StatelessWidget {
  const ListaCompraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de la compra accesible',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        final storageError = context.select<AppState, bool>(
          (state) => state.storageError,
        );
        return Column(
          children: [
            Expanded(child: child!),
            if (storageError)
              Material(
                color: AppColors.surface,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Semantics(
                      liveRegion: true,
                      child: const Text(
                        'No se han podido cargar o guardar las listas en este dispositivo.',
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      initialRoute: '/',
      routes: {
        '/': (_) => const P01InicioScreen(),
        '/crear-lista': (_) => const P02CrearListaScreen(),
        '/detalle-lista': (_) => const P03DetalleListaScreen(),
        '/anadir-producto': (_) => const P04AnadirProductoScreen(),
        '/registrar-gasto': (_) => const P06RegistrarGastoScreen(),
        '/resumen-compra': (_) => const P07ResumenCompraScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/editar-producto') {
          final productId = settings.arguments;
          if (productId is! String) return null;
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => P05EditarProductoScreen(productId: productId),
          );
        }
        return null;
      },
    );
  }
}
