import "package:get/get.dart";

import "../Datamodels/product.dart";

class CartController extends GetxController {
  static CartController instance = Get.find();
  // Add a dict to store the products in the cart.

  final _products = {}.obs;
  RxString paymentMethod = "Select".obs;
  RxDouble grandTotal = RxDouble(0);
  RxInt totalProductsInCart = RxInt(0);
  RxString selectedpayment = "Cash on delivery".obs;

  void addProduct(Product product) {
    print("Adding product: ${product.name}");
    if (_products.containsKey(product)) {
      _products[product] += 1;
    } else {
      _products[product] = 1;
    }
    print("Products in cart: $_products");
    totalProductsInCart.value = totalProducts;
    // Get.snackbar(
    //   "Product Added",
    //   "You have added the ${product.title} to the cart",
    //   snackPosition: SnackPosition.TOP,
    //   duration: const Duration(seconds: 2),
    // );
  }

  double totalForProduct(Product product) {
    if (_products.containsKey(product)) {
      return (product.price * _products[product]!).toDouble();
    }
    return 0.0;
  }

  //   List<OrderItem> get orderItems {
  //   return _products.entries.map((entry) {
  //     final product = entry.key;
  //     final quantity = entry.value;
  //     return OrderItem(
  //       productimage: product.Image[0], // Assuming your Product has a Pimage property
  //       productId: product.PId, // Assuming your Product has a Pid property
  //       productName: product.Pname,
  //       productPrice: product.price,
  //       quantity: quantity,
  //     );
  //   }).toList();
  // }

  void removeProduct(Product product) {
    if (_products.containsKey(product) && _products[product] == 1) {
      _products.removeWhere((key, value) => key == product);
    } else {
      _products[product] -= 1;
    }
    totalProductsInCart.value = totalProducts;
  }

  void deleteProduct(Product product) {
    _products.remove(product);
  }

  void clearCart() {
    _products.clear(); // Clear all products
    totalProductsInCart.value = 0; // Reset the total products count
    print("Cart cleared");
  }

  get products => _products;

  get productSubtotal => _products.entries
      .map((product) => product.key.price * product.value)
      .toList();
  double get paymenttotal => _products.entries
      .map((product) => product.key.price * product.value)
      .toList()
      .reduce((value, element) => value + element)
      .toDouble();

  get total => _products.entries
      .map((product) => product.key.price * product.value)
      .toList()
      .reduce((value, element) => value + element)
      .toStringAsFixed(2);


  int get totalProducts {
    return _products.values.reduce((sum, quantity) => sum + quantity);
  }
}
