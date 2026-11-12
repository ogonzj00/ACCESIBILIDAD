import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/p01_inicio.dart';
import 'screens/p02_crear_lista.dart';
import 'screens/p03_detalle_lista.dart';
import 'screens/p04_anadir_producto.dart';
import 'screens/p05_editar_producto.dart';
import 'screens/p06_registrar_gasto.dart';
import 'screens/p07_resumen_compra.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const ListaCompraApp(),
    ),
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
          final productId = settings.arguments as String?;
          if (productId == null) return null;
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
