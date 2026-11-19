import 'shopping_product.dart';

class ShoppingList {
  ShoppingList({
    required this.id,
    required this.name,
    List<ShoppingProduct>? products,
    this.expenseCents,
    this.isActive = true,
  }) : products = products ?? [];

  final String id;
  String name;
  final List<ShoppingProduct> products;
  int? expenseCents;
  bool isActive; // true = lista vigente

  int get boughtCount => products.where((product) => product.isBought).length;
  int get pendingCount => products.length - boughtCount;
}
