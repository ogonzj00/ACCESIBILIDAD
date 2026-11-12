import 'package:flutter/foundation.dart';
import '../models/shopping_list.dart';
import '../models/shopping_product.dart';

class AppState extends ChangeNotifier {
  final List<ShoppingList> _lists = [];
  String? _currentListId;

  List<ShoppingList> get lists => List.unmodifiable(_lists);

  List<ShoppingList> get activeLists =>
      _lists.where((list) => list.isActive).toList();

  double get activeListsTotal =>
      activeLists.fold(0.0, (sum, list) => sum + list.expense);

  ShoppingList? get currentList {
    if (_currentListId == null) return null;
    for (final list in _lists) {
      if (list.id == _currentListId) return list;
    }
    return null;
  }

  bool get hasList => currentList != null;
  String get listName => currentList?.name ?? 'Mi compra';
  List<ShoppingProduct> get products => currentList?.products ?? const [];
  double get expense => currentList?.expense ?? 0.0;
  int get boughtCount => currentList?.boughtCount ?? 0;
  int get pendingCount => currentList?.pendingCount ?? 0;

  void createList(String name) {
    final cleanName = name.trim().isEmpty ? 'Mi compra' : name.trim();
    final newList = ShoppingList(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: cleanName,
    );
    _lists.insert(0, newList);
    _currentListId = newList.id;
    notifyListeners();
  }

  void selectList(String listId) {
    _currentListId = listId;
    notifyListeners();
  }

  void toggleListActive(String listId, bool isActive) {
    for (final list in _lists) {
      if (list.id == listId) {
        list.isActive = isActive;
        notifyListeners();
        return;
      }
    }
  }

  void deleteList(String listId) {
    _lists.removeWhere((list) => list.id == listId);
    if (_currentListId == listId) {
      _currentListId = _lists.isNotEmpty ? _lists.first.id : null;
    }
    notifyListeners();
  }

  void addProduct(String name, int quantity) {
    if (currentList == null) {
      createList('Mi compra');
    }
    currentList!.products.add(
      ShoppingProduct(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name.trim(),
        quantity: quantity < 1 ? 1 : quantity,
      ),
    );
    notifyListeners();
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
    notifyListeners();
  }

  void updateProductQuantity(String id, int quantity) {
    final product = productById(id);
    if (product == null) return;
    product.quantity = quantity < 1 ? 1 : quantity;
    notifyListeners();
  }

  void toggleBought(String id, bool value) {
    final product = productById(id);
    if (product == null) return;
    product.isBought = value;
    notifyListeners();
  }

  RemovedProduct? removeProduct(String id) {
    final list = currentList;
    if (list == null) return null;
    final index = list.products.indexWhere((product) => product.id == id);
    if (index < 0) return null;
    final product = list.products.removeAt(index);
    notifyListeners();
    return RemovedProduct(product: product, index: index);
  }

  void restoreProduct(RemovedProduct removed) {
    final list = currentList;
    if (list == null) return;
    final index = removed.index.clamp(0, list.products.length).toInt();
    list.products.insert(index, removed.product);
    notifyListeners();
  }

  void setExpense(double value) {
    final list = currentList;
    if (list == null) return;
    list.expense = value;
    notifyListeners();
  }
}

class RemovedProduct {
  const RemovedProduct({required this.product, required this.index});

  final ShoppingProduct product;
  final int index;
}
