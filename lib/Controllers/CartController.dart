import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Datamodels/product.dart';

class CartController extends GetxController {
  static CartController instance = Get.find();

  final _products = <Product, int>{}.obs;

  RxString paymentMethod = "Select".obs;
  RxDouble grandTotal = 0.0.obs;
  RxInt totalProductsInCart = 0.obs;
  RxString selectedpayment = "Cash on delivery".obs;

  void showErrorMessage(Product product, int cartQuantity) {
  // Showing a custom Snackbar with red background at the top center
  Get.snackbar(
    "Error", // Title of the snackbar
    "Not enough stock. Available stock: ${product.stockQuantity}, Cart Quantity: $cartQuantity", // Message
    snackPosition: SnackPosition.BOTTOM, // Position it at the top
    backgroundColor: Colors.red, // Set the background color to red
    colorText: Colors.white, // Set text color to white
    borderRadius: 10, // Optional: make corners rounded
    margin: EdgeInsets.all(8), // Margin around the Snackbar
    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24), // Padding inside the Snackbar
    duration: Duration(seconds: 3), // Duration for how long the message is shown
  );
}

  // Add a product to the cart, either increasing its quantity or adding it.
  void addProduct(Product product) {
    // Fetch current quantity in the cart for this product
    int cartQuantity = _products[product] ?? 0;

    // Check if the quantity in the cart + 1 exceeds stock quantity
    if (cartQuantity + 1 <= product.stockQuantity) {
      // If stock allows, add or increase the quantity of the product in the cart
      if (_products.containsKey(product)) {
        _products[product] = _products[product]! + 1; // Increment quantity
      } else {
        _products[product] = 1; // Add new product with quantity 1
      }
    } else {
      // If adding more exceeds stock, show an error message
      print("Not enough stock. Available stock: ${product.stockQuantity}, Cart Quantity: $cartQuantity");
      // ScaffoldMessenger.of(Get.context!).showSnackBar(
      //   SnackBar(content: Text("Not enough stock. Available stock: ${product.stockQuantity}")),
      // );
        showErrorMessage(product, cartQuantity);
    }

    totalProductsInCart.value = totalProducts; // Update the total product count
  }

  // Method to prepare a consolidated list for upload
  List<Map<String, dynamic>> get cartItemsForUpload {
    return _products.entries.map((entry) {
      final product = entry.key;
      final quantity = entry.value;
      return {
        'productId': product.productId,
        'productName': product.name,
        'price': product.price,
        'quantity': quantity,
        'total': product.price * quantity,
      };
    }).toList();
  }

  // Calculate the total cost for a specific product.
  double totalForProduct(Product product) {
    if (_products.containsKey(product)) {
      return (product.price * _products[product]!).toDouble();
    }
    return 0.0;
  }

  // Remove a product from the cart by reducing its quantity or removing it entirely.
  void removeProduct(Product product) {
    if (_products.containsKey(product)) {
      if (_products[product] == 1) {
        _products.remove(product); // Remove the product entirely if quantity is 1
      } else {
        _products[product] = _products[product]! - 1; // Decrease quantity by 1
      }
    }
    totalProductsInCart.value = totalProducts; // Update the total product count
  }

  // Delete a product completely from the cart.
  void deleteProduct(Product product) {
    _products.remove(product);
    totalProductsInCart.value = totalProducts; // Update the total product count
  }

  // Clear all products from the cart.
  void clearCart() {
    _products.clear();
    totalProductsInCart.value = 0; // Reset the total products count
    print("Cart cleared");
  }

  // Getter for all products in the cart.
  Map<Product, int> get products => _products;

  // Calculate the subtotal for all products in the cart (price * quantity).
  double get productSubtotal => _products.entries
      .map((product) => product.key.price * product.value)
      .fold(0.0, (sum, element) => sum + element);

  // Calculate the total payment amount (all products' price * quantity).
  double get paymentTotal => _products.entries
      .map((product) => product.key.price * product.value)
      .fold(0.0, (sum, element) => sum + element);

  // Calculate the tax (16%) based on the total payment amount.
 // double get tax => paymentTotal * 0.16;

  // Calculate the subtotal excluding the tax.
  double get subtotal => paymentTotal;

  // Get the total amount, formatted as a fixed 2 decimal places string.
  String get total => paymentTotal.toStringAsFixed(2);

  // Get the total number of products in the cart.
  int get totalProducts {
    return _products.values.fold(0, (sum, quantity) => sum + quantity);
  }
}
