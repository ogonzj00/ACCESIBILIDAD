import 'package:flutter_test/flutter_test.dart';
import 'package:lista_compra_accesible/models/money.dart';
import 'package:lista_compra_accesible/state/app_state.dart';

void main() {
  test(
    'creates and opens distinct lists and tracks edited quantities and marks',
    () {
      final state = AppState()..createList('  Mercado  ');
      final first = state.currentList!.id;
      expect(state.listName, 'Mercado');
      state.addProduct('Pan', 2);
      final product = state.products.single.id;
      state.updateProduct(product, 'Pan integral', 3);
      state.updateProductQuantity(product, 4);
      state.updateProductQuantity(product, 0);
      state.toggleBought(product, true);
      expect(state.boughtCount, 1);
      expect(state.pendingCount, 0);
      state.toggleBought(product, false);
      expect(state.pendingCount, 1);
      expect(state.products.single.name, 'Pan integral');
      expect(state.products.single.quantity, 1);
      state.createList('Otra');
      expect(state.products, isEmpty);
      state.selectList(first);
      expect(state.products.single.id, product);
    },
  );

  test('undo restores original list, index and product once', () {
    final state = AppState()..createList('A');
    final first = state.currentList!.id;
    state.addProduct('Pan', 1);
    state.addProduct('Leche', 3);
    state.addProduct('Tomate', 2);
    final id = state.products[1].id;
    state.toggleBought(id, true);
    final removed = state.removeProduct(id)!;
    expect(state.products.map((p) => p.name), ['Pan', 'Tomate']);
    state.createList('B');
    state.addProduct('Patata', 1);
    expect(state.restoreProduct(removed), isTrue);
    expect(state.restoreProduct(removed), isFalse);
    expect(state.products.single.name, 'Patata');
    state.selectList(first);
    expect(state.products.map((p) => p.name), ['Pan', 'Leche', 'Tomate']);
    expect(state.products[1].id, id);
    expect(state.products[1].quantity, 3);
    expect(state.products[1].isBought, isTrue);
    final removedAgain = state.removeProduct(id)!;
    state.deleteList(first);
    expect(state.restoreProduct(removedAgain), isFalse);
    expect(state.products.single.name, 'Patata');
  });

  test(
    'persists snapshots in order and restores stable IDs and exact amounts',
    () async {
      String? snapshot;
      final first = AppState(writeSnapshot: (value) async => snapshot = value)
        ..createList('A');
      final listId = first.currentList!.id;
      expect(first.expenseCents, isNull);
      first.setExpense(0);
      first.toggleListActive(listId, false);
      first.addProduct('Leche', 3);
      final product = first.products.single.id;
      first.toggleBought(product, true);
      first.createList('B');
      final secondId = first.currentList!.id;
      first.setExpense(1249);
      first.createList('C');
      await first.saved;

      final restored = AppState(readSnapshot: () async => snapshot);
      await restored.load();
      expect(restored.lists.map((list) => list.name), ['C', 'B', 'A']);
      expect(restored.expenseCents, isNull);
      restored.selectList(listId);
      expect(restored.currentList!.isActive, isFalse);
      expect(restored.expenseCents, 0);
      expect(restored.products.single.id, product);
      expect(restored.products.single.quantity, 3);
      expect(restored.products.single.isBought, isTrue);
      expect(restored.activeListsTotal, 1249);
      restored.selectList(secondId);
      expect(restored.expenseCents, 1249);
      restored.addProduct('Tomate', 1);
      expect(restored.products.single.id, isNot(product));
    },
  );

  test('handles missing, corrupt and unreadable snapshots', () async {
    var writes = 0;
    final missing = AppState(readSnapshot: () async => null);
    await missing.load();
    expect(missing.lists, isEmpty);
    expect(missing.storageError, isFalse);

    final corrupt = AppState(
      readSnapshot: () async => '{"lists":[null],"lastId":1}',
      writeSnapshot: (_) async => writes++,
    );
    await corrupt.load();
    expect(corrupt.lists, isEmpty);
    expect(corrupt.storageError, isTrue);
    expect(writes, 0);
    corrupt.createList('Nueva');
    await corrupt.saved;
    expect(writes, 1);
    expect(corrupt.storageError, isFalse);

    final unreadable = AppState(
      readSnapshot: () async => throw StateError('read failed'),
      writeSnapshot: (_) async => writes++,
    );
    await unreadable.load();
    unreadable.createList('Solo en memoria');
    await unreadable.saved;
    expect(writes, 1);
    expect(unreadable.storageError, isTrue);
  });

  test(
    'write errors surface and a subsequent snapshot contains both changes',
    () async {
      var attempts = 0;
      String? snapshot;
      final state = AppState(
        writeSnapshot: (value) async {
          if (attempts++ == 0) throw StateError('write failed');
          snapshot = value;
        },
      )..createList('Lista');
      await state.saved;
      expect(state.storageError, isTrue);
      state.addProduct('Pan', 1);
      await state.saved;
      expect(state.storageError, isFalse);
      final reopened = AppState(readSnapshot: () async => snapshot);
      await reopened.load();
      expect(reopened.listName, 'Lista');
      expect(reopened.products.single.name, 'Pan');
    },
  );

  test('validates and formats money in cents', () {
    expect(parseExpense(' 24,5 '), 2450);
    expect(parseExpense('24.05'), 2405);
    expect(parseExpense('0'), 0);
    expect(parseExpense('999999999,99'), maxExpenseCents);
    expect(formatExpense(0), '0,00');
    expect(formatExpense(2405), '24,05');
    for (final value in [
      '',
      ' ',
      '-1',
      'NaN',
      'Infinity',
      '1e2',
      '1,234',
      '1.234,50',
      '1000000000',
      '2,',
      '2€',
    ]) {
      expect(parseExpense(value), isNull, reason: value);
    }
  });
}
