import 'package:mysql1/mysql1.dart';

class SaleItem {
  final int? saleItemId;  // saleItemId can remain nullable if it's auto-generated
  final int saleId;  // saleId is now non-nullable
  final int productId;  // productId is now non-nullable
  final String productName;
  final int quantity;
  final double price;
  final double total;

  SaleItem({
   this.saleItemId,   // Default value for saleItemId if not provided
    required this.saleId,  // saleId is required
    required this.productId,  // productId is required
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
  });

  // Factory constructor for creating a new SaleItem instance from a Map
  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      saleItemId: map['sale_item_id'] as int,  // Default to 0 if not provided
      saleId: map['sale_id'] as int,  // Non-nullable saleId
      productId: map['product_id'] as int,  // Non-nullable productId
      productName: map['product_name'] is Blob
          ? String.fromCharCodes((map['product_name'] as Blob).toBytes())
          : map['product_name'] as String? ?? '',  // Handle Blob to String conversion
      quantity: map['quantity'] as int? ?? 0,
      price: map['price'] as double? ?? 0.0,
      total: map['total'] as double? ?? 0.0,
    );
  }

  // Method to convert SaleItem instance to Map
  Map<String, dynamic> toMap() {
    return {
      'sale_item_id': saleItemId,
      'sale_id': saleId,  // Ensure saleId is always present
      'product_id': productId,  // Ensure productId is always present
      'product_name': productName,  // Ensure productName is not null
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }
}
