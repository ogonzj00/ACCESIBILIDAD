import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lista_compra_accesible/main.dart';
import 'package:lista_compra_accesible/state/app_state.dart';
import 'package:lista_compra_accesible/theme/app_theme.dart';
import 'package:provider/provider.dart';

Future<void> launch(
  WidgetTester tester,
  AppState state, {
  bool large = false,
}) async {
  if (large) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }
  await tester.pumpWidget(
    ChangeNotifierProvider.value(value: state, child: const ListaCompraApp()),
  );
  await tester.pumpAndSettle();
}

Future<void> touch(WidgetTester tester, Finder finder) async {
  await Scrollable.ensureVisible(tester.element(finder), alignment: .5);
  await tester.pumpAndSettle();
  expect(finder.hitTestable(), findsOneWidget);
  await tester.tap(finder);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> label(WidgetTester tester, String text) async {
  final labels = find.text(text, findRichText: true);
  if (labels.evaluate().isEmpty &&
      find.byType(Scrollable).evaluate().length == 1) {
    await tester.scrollUntilVisible(labels, 100, maxScrolls: 8);
    await tester.pumpAndSettle();
  }
  final buttonLabel = find.descendant(
    of: find.byWidgetPredicate(
      (widget) =>
          widget is ButtonStyleButton ||
          widget is PopupMenuItem ||
          widget is SnackBarAction,
    ),
    matching: labels,
  );
  await touch(
    tester,
    buttonLabel.evaluate().isEmpty ? labels.first : buttonLabel.last,
  );
}

Future<void> write(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextFormField), text);
  await tester.pumpAndSettle();
}

Future<void> openList(WidgetTester tester) => label(tester, 'Abrir');

void main() {
  for (final large in [false, true]) {
    testWidgets(
      'three routes, invalid entries and cancellation (200%: $large)',
      (tester) async {
        final state = AppState();
        await launch(tester, state, large: large);
        await label(tester, 'Crear lista nueva');
        await write(tester, 'Lista cancelada');
        await touch(tester, find.byType(BackButton));
        expect(state.lists, isEmpty);
        await label(tester, 'Crear lista nueva');
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await write(tester, ' ');
        await label(tester, 'Crear lista');
        expect(find.text('Introduce un nombre para la lista'), findsOneWidget);
        await write(tester, 'Mercado');
        await label(tester, 'Crear lista');
        expect(state.listName, 'Mercado');
        expect(find.text('Mercado'), findsOneWidget);
        await label(tester, 'Añadir producto');
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await write(tester, ' ');
        await label(tester, 'Guardar producto');
        expect(find.text('Escribe el nombre del producto'), findsOneWidget);
        await write(tester, 'Cancelar este producto');
        await touch(tester, find.byType(BackButton));
        expect(state.products, isEmpty);
        await label(tester, 'Añadir producto');
        await write(tester, 'Leche');
        await label(tester, 'Guardar producto');
        expect(find.text('Leche'), findsOneWidget);
        expect(find.bySemanticsLabel('Leche'), findsWidgets);
        final checkbox = find.byType(Checkbox);
        await touch(tester, checkbox);
        expect(find.text('Comprado'), findsOneWidget);
        expect(
          tester
              .getSemantics(find.bySemanticsLabel('Leche').first)
              .flagsCollection
              .isChecked
              .name,
          'isTrue',
        );
        await touch(tester, checkbox);
        expect(find.text('Pendiente'), findsOneWidget);
        await label(tester, 'Registrar gasto');
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await write(tester, 'NaN');
        await label(tester, 'Guardar gasto');
        expect(
          find.textContaining('Introduce un importe válido'),
          findsOneWidget,
        );
        expect(find.text('NaN'), findsOneWidget);
        await write(tester, '0');
        await label(tester, 'Guardar gasto');
        expect(find.text('Resumen de compra'), findsOneWidget);
        expect(find.text('Gasto registrado'), findsOneWidget);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        expect(find.text('0,00 €'), findsOneWidget);
        await label(tester, 'Modificar importe');
        expect(find.text('0,00'), findsOneWidget);
        await write(tester, '25.07');
        await touch(tester, find.byType(BackButton));
        expect(state.expenseCents, 0);
        await label(tester, 'Modificar importe');
        await write(tester, '25,07');
        await label(tester, 'Guardar gasto');
        expect(find.text('25,07 €'), findsOneWidget);
      },
      semanticsEnabled: true,
    );
  }

  testWidgets('editing, cancelling deletion and undo in detail', (
    tester,
  ) async {
    final state = AppState()
      ..createList('Mercado')
      ..addProduct('Leche', 2);
    final id = state.products.single.id;
    await launch(tester, state, large: true);
    await openList(tester);
    expect(find.text('Mercado'), findsOneWidget);
    final menu = find.byType(PopupMenuButton<String>);
    if (menu.evaluate().isEmpty) {
      await tester.scrollUntilVisible(menu, 100, maxScrolls: 8);
    }
    await touch(tester, menu);
    await label(tester, 'Editar');
    await write(tester, 'Cambio cancelado');
    await touch(tester, find.byType(BackButton));
    expect(state.products.single.name, 'Leche');
    await touch(tester, menu);
    await label(tester, 'Editar');
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await write(tester, 'Leche entera');
    await touch(tester, find.byTooltip('Sumar cantidad'));
    await label(tester, 'Guardar cambios');
    expect(state.products.single.id, id);
    expect(state.products.single.quantity, 3);
    await touch(tester, find.byTooltip('Restar cantidad de Leche entera'));
    expect(state.products.single.quantity, 2);
    await touch(tester, find.byType(PopupMenuButton<String>));
    await label(tester, 'Eliminar');
    await label(tester, 'Cancelar');
    expect(state.products.single.id, id);
    await touch(tester, find.byType(PopupMenuButton<String>));
    await label(tester, 'Eliminar');
    await label(tester, 'Eliminar');
    expect(state.products, isEmpty);
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Deshacer'), findsOneWidget);
    await label(tester, 'Deshacer');
    expect(state.products.single.id, id);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await label(tester, 'Ver resumen');
    expect(find.text('Sin gasto registrado'), findsOneWidget);
  }, semanticsEnabled: true);

  testWidgets('list switch has context and controls meet Android tap targets', (
    tester,
  ) async {
    final state = AppState()
      ..createList('Mercado')
      ..addProduct('Leche', 2);
    state.createList('Farmacia');
    await launch(tester, state);
    expect(find.bySemanticsLabel('Vigencia de Mercado'), findsOneWidget);
    expect(find.bySemanticsLabel('Vigencia de Farmacia'), findsOneWidget);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await openList(tester);
    expect(find.text('Mercado'), findsOneWidget);
    final add = find.byTooltip('Sumar cantidad de Leche');
    expect(tester.getSize(add).shortestSide, greaterThanOrEqualTo(48));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  }, semanticsEnabled: true);
  testWidgets('amount error and save fit at 200% with an on-screen keyboard', (
    tester,
  ) async {
    final state = AppState()..createList('Mercado');
    await launch(tester, state, large: true);
    await openList(tester);
    await label(tester, 'Registrar gasto');
    await write(tester, 'Infinity');
    tester.view.viewInsets = const FakeViewPadding(bottom: 240);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await label(tester, 'Guardar gasto');
    expect(find.text('Infinity'), findsOneWidget);
    expect(find.textContaining('Introduce un importe válido'), findsOneWidget);
    await write(tester, '4,50');
    await label(tester, 'Guardar gasto');
    expect(find.text('4,50 €'), findsOneWidget);
  });

  testWidgets('calculator targets and zero division at 200%', (tester) async {
    final state = AppState()
      ..createList('Mercado')
      ..setExpense(550);
    await launch(tester, state, large: true);
    await label(tester, 'Abrir calculadora');
    final dialog = find.byType(AlertDialog);
    expect(dialog, findsOneWidget);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    for (final key in ['÷', '0', '=']) {
      final target = find
          .ancestor(
            of: find.text(key),
            matching: find.byWidgetPredicate(
              (widget) => widget is ButtonStyleButton,
            ),
          )
          .first;
      expect(tester.getSize(target).shortestSide, greaterThanOrEqualTo(48));
      await touch(tester, find.text(key));
    }
    expect(find.text('No se puede dividir entre cero'), findsOneWidget);
  }, semanticsEnabled: true);

  test('theme text and control color pairs meet contrast thresholds', () {
    double ratio(Color foreground, Color background) {
      final a = foreground.computeLuminance();
      final b = background.computeLuminance();
      return a > b ? (a + .05) / (b + .05) : (b + .05) / (a + .05);
    }

    for (final (foreground, background) in [
      (AppColors.text, AppColors.background),
      (Colors.white, AppColors.primary),
      (AppColors.success, AppColors.successBackground),
      (AppColors.secondaryText, AppColors.surface),
      (AppColors.error, AppColors.surface),
    ]) {
      expect(ratio(foreground, background), greaterThanOrEqualTo(4.5));
    }
    expect(
      ratio(AppColors.controlBorder, AppColors.surface),
      greaterThanOrEqualTo(3),
    );
  });
}
