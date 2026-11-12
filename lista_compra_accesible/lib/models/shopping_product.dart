class ShoppingProduct {
  ShoppingProduct({
    required this.id,
    required this.name,
    this.quantity = 1,
    this.isBought = false,
  });

  final String id;
  String name;
  int quantity;
  bool isBought;
}
