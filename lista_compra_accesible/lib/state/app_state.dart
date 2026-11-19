import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/money.dart';
import '../models/shopping_list.dart';
import '../models/shopping_product.dart';

class AppState extends ChangeNotifier {
  AppState({this.readSnapshot, this.writeSnapshot});

  static const storageKey = 'shopping_lists_v1';
  final Future<String?> Function()? readSnapshot;
  final Future<void> Function(String)? writeSnapshot;
  Future<void> _write = Future.value();
  Future<void> get saved => _write;
  bool storageError = false;
  bool _readFailed = false;
  bool _disposed = false;
  int _lastId = 0;
  final List<ShoppingList> _lists = [];

  Future<void> load() async {
    final String? raw;
    try {
      raw = await readSnapshot?.call();
    } catch (_) {
      storageError = true;
      _readFailed = true;
      return;
    }
    if (raw == null) return;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final lastId = data['lastId'] as int;
      final active = data['currentListId'] as String?;
      final ids = <String>{};
      String readId(Object? value) {
        final id = value as String;
        final number = int.tryParse(id);
        if (number == null || number < 1 || number > lastId || !ids.add(id)) {
          throw const FormatException('Invalid identifier');
        }
        return id;
      }

      final restored = [
        for (final list in (data['lists'] as List).cast<Map<String, dynamic>>())
          ShoppingList(
            id: readId(list['id']),
            name: list['name'] as String,
            isActive: list['isActive'] as bool,
            expenseCents: _readExpense(list['expenseCents']),
            products: [
              for (final product
                  in (list['products'] as List).cast<Map<String, dynamic>>())
                ShoppingProduct(
                  id: readId(product['id']),
                  name: product['name'] as String,
                  isBought: product['isBought'] as bool,
                  quantity: _readQuantity(product['quantity']),
                ),
            ],
          ),
      ];
      if (lastId < 0 ||
          (active != null && !restored.any((l) => l.id == active))) {
        throw const FormatException('Invalid list selection');
      }
      _lists.addAll(restored);
      _lastId = lastId;
      _currentListId = active;
    } on FormatException {
      storageError = true;
    } on TypeError {
      storageError = true;
    }
  }

  int? _readExpense(Object? value) {
    final cents = value as int?;
    if (cents != null && (cents < 0 || cents > maxExpenseCents)) {
      throw const FormatException('Invalid expense');
    }
    return cents;
  }

  int _readQuantity(Object? value) {
    final quantity = value as int;
    if (quantity < 1) throw const FormatException('Invalid quantity');
    return quantity;
  }

  void _changed() {
    final writeSnapshot = this.writeSnapshot;
    if (writeSnapshot != null && !_readFailed) {
      final snapshot = jsonEncode({
        'lastId': _lastId,
        'currentListId': _currentListId,
        'lists': [
          for (final list in _lists)
            {
              'id': list.id,
              'name': list.name,
              'isActive': list.isActive,
              'expenseCents': list.expenseCents,
              'products': [
                for (final product in list.products)
                  {
                    'id': product.id,
                    'name': product.name,
                    'quantity': product.quantity,
                    'isBought': product.isBought,
                  },
              ],
            },
        ],
      });
      _write = _write.then((_) async {
        var failed = false;
        try {
          await writeSnapshot(snapshot);
        } catch (_) {
          failed = true;
        }
        if (storageError != failed) {
          storageError = failed;
          if (!_disposed) notifyListeners();
        }
      });
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  ShoppingList? _listById(String? id) {
    for (final list in _lists) {
      if (list.id == id) return list;
    }
    return null;
  }

  String? _currentListId;

  List<ShoppingList> get lists => List.unmodifiable(_lists);

  List<ShoppingList> get activeLists =>
      _lists.where((list) => list.isActive).toList();

  int get activeListsTotal =>
      activeLists.fold(0, (sum, list) => sum + (list.expenseCents ?? 0));

  ShoppingList? get currentList => _listById(_currentListId);

  bool get hasList => currentList != null;
  String get listName => currentList?.name ?? 'Mi compra';
  List<ShoppingProduct> get products => currentList?.products ?? const [];
  int? get expenseCents => currentList?.expenseCents;
  int get boughtCount => currentList?.boughtCount ?? 0;
  int get pendingCount => currentList?.pendingCount ?? 0;

  void createList(String name) {
    final cleanName = name.trim().isEmpty ? 'Mi compra' : name.trim();
    final newList = ShoppingList(id: (++_lastId).toString(), name: cleanName);
    _lists.insert(0, newList);
    _currentListId = newList.id;
    _changed();
  }

  void selectList(String listId) {
    if (_listById(listId) == null) return;
    _currentListId = listId;
    _changed();
  }

  void toggleListActive(String listId, bool isActive) {
    for (final list in _lists) {
      if (list.id == listId) {
        list.isActive = isActive;
        _changed();
        return;
      }
    }
  }

  void deleteList(String listId) {
    _lists.removeWhere((list) => list.id == listId);
    if (_currentListId == listId) {
      _currentListId = _lists.isNotEmpty ? _lists.first.id : null;
    }
    _changed();
  }

  void addProduct(String name, int quantity) {
    final list = currentList;
    if (list == null) return;
    list.products.add(
      ShoppingProduct(
        id: (++_lastId).toString(),
        name: name.trim(),
        quantity: quantity < 1 ? 1 : quantity,
      ),
    );
    _changed();
  }

  ShoppingProduct? productById(String id) {
    final list = currentList;
    if (list == null) return null;
    for (final product in list.products) {
      if (product.id == id) return product;
    }
    return null;
  }

  void updateProduct(String id, String name, int quantity) {
    final product = productById(id);
    if (product == null) return;
    product
      ..name = name.trim()
      ..quantity = quantity < 1 ? 1 : quantity;
    _changed();
  }

  void updateProductQuantity(String id, int quantity) {
    final product = productById(id);
    if (product == null) return;
    product.quantity = quantity < 1 ? 1 : quantity;
    _changed();
  }

  void toggleBought(String id, bool value) {
    final product = productById(id);
    if (product == null) return;
    product.isBought = value;
    _changed();
  }

  RemovedProduct? removeProduct(String id) {
    final list = currentList;
    if (list == null) return null;
    final index = list.products.indexWhere((product) => product.id == id);
    if (index < 0) return null;
    final product = list.products.removeAt(index);
    _changed();
    return RemovedProduct(listId: list.id, product: product, index: index);
  }

  bool restoreProduct(RemovedProduct removed) {
    final list = _listById(removed.listId);
    if (list == null || list.products.any((p) => p.id == removed.product.id)) {
      return false;
    }
    final index = removed.index.clamp(0, list.products.length).toInt();
    list.products.insert(index, removed.product);
    _changed();
    return true;
  }

  void setExpense(int cents) {
    final list = currentList;
    if (list == null || cents < 0 || cents > maxExpenseCents) return;
    list.expenseCents = cents;
    _changed();
  }
}

class RemovedProduct {
  const RemovedProduct({
    required this.listId,
    required this.product,
    required this.index,
  });

  final String listId;

  final ShoppingProduct product;
  final int index;
}
