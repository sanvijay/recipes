class ShoppingItem {
  ShoppingItem({
    required this.title,
    required this.tags,
    this.checked = false,
    required this.quantity
  });

  String title;
  List<String> tags;
  bool checked;
  String quantity;
}
