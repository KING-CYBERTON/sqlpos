import 'package:mysql1/mysql1.dart';

class Product {
  int? productId;
  String name;
  String description;
  double price;
  double costPrice;
  int stockQuantity;
  int categoryId;

  Product({
    this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.costPrice,
    required this.stockQuantity,
    required this.categoryId,
  });

  // Convert Product to Map (for SQL insertion)
  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'name': name,
      'description': description,
      'price': price,
      'cost_price': costPrice,
      'stock_quantity': stockQuantity,
      'category_id': categoryId,
    };
  }
// Convert Map to Product (for SQL selection)
factory Product.fromMap(Map<String, dynamic> map) {
  return Product(
    productId: map['product_id'] as int?,
    name: map['name'] is Blob
        ? String.fromCharCodes((map['name'] as Blob).toBytes())
        : map['name'] as String, // Convert Blob to String if necessary
    description: map['description'] is Blob
        ? String.fromCharCodes((map['description'] as Blob).toBytes())
        : map['description'] as String, // Convert Blob to String if necessary
    price: (map['price'] as num).toDouble(),
    costPrice: (map['cost_price'] as num).toDouble(),
    stockQuantity: map['stock_quantity'] as int,
    categoryId: map['category_id'] as int,
  );
}


  // Override == and hashCode based on productId
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product && other.productId == productId;
  }

  @override
  int get hashCode => productId.hashCode;

}

List<Product> products = [
  Product(
    productId: 1,
    name: 'Laptop',
    description: 'A high performance laptop for all your computing needs.',
    price: 1200.00,
    costPrice: 900.00,
    stockQuantity: 50,
    categoryId: 101,
  ),
  Product(
    productId: 2,
    name: 'Smartphone',
    description: 'Latest model with stunning features and sleek design.',
    price: 800.00,
    costPrice: 600.00,
    stockQuantity: 150,
    categoryId: 102,
  ),
  Product(
    productId: 3,
    name: 'Wireless Headphones',
    description: 'Noise-cancelling headphones with Bluetooth connectivity.',
    price: 150.00,
    costPrice: 100.00,
    stockQuantity: 200,
    categoryId: 103,
  ),
  Product(
    productId: 4,
    name: 'Smartwatch',
    description: 'A smartwatch that tracks your fitness and notifications.',
    price: 250.00,
    costPrice: 180.00,
    stockQuantity: 80,
    categoryId: 104,
  ),
];

