class SaleItem {
  final int? saleItemId;
  final int? saleId;
  final int? productId;
  final String productName;
  final int quantity;
  final double price;
  final double total;

  SaleItem({
    this.saleItemId,
    this.saleId,
    this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
  });

  // Factory constructor for creating a new SaleItem instance from a Map
  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      saleItemId: map['sale_item_id'] as int?,
      saleId: map['sale_id'] as int?,
      productId: map['product_id'] as int?,
      productName: map['product_name'] as String? ?? '',
      quantity: map['quantity'] as int? ?? 0,
      price: map['price'] as double? ?? 0.0,
      total: map['total'] as double? ?? 0.0,
    );
  }

  // Method to convert SaleItem instance to Map
  Map<String, dynamic> toMap() {
    return {
      'sale_item_id': saleItemId,
      'sale_id': saleId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }
}
