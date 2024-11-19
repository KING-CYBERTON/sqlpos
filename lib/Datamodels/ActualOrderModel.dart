


class OrderModel {
  final String OId;
  final String orderId;
  final String paymentId;
  final String userId;
  final double totalPrice;
  final DateTime orderDate;
  final String paymentStatus;







  OrderModel({
    required this.OId,
    required this.orderId,
    required this.paymentId,
    required this.userId,
    required this.totalPrice,
    required this.orderDate,
    required this.paymentStatus,


   


  });


  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'OId': OId,
      'orderId': orderId,
      'paymentId': paymentId,
      'userId': userId,
      'totalPrice': totalPrice,
      'orderDate': orderDate.toIso8601String(),
      'paymentStatus': paymentStatus,


    };
  }





}

class OrderItem {
  final String productimage;
  final String productId;
  final String productName;
  final double productPrice;
  final int quantity;

  OrderItem({
    required this.productimage,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.quantity,
  });

  // From JSON
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productimage: json['productimage'],
      productId: json['productId'],
      productName: json['productName'],
      productPrice: json['productPrice'].toDouble(),
      quantity: json['quantity'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'productimage': productimage,
      'productId': productId,
      'productName': productName,
      'productPrice': productPrice,
      'quantity': quantity,
    };
  }


}



// Generate order items from the product list


// Create a list of orders with these items
List<OrderModel> orderList = [
  OrderModel(
    OId: '2',
    orderId: 'ORD001',
    paymentId: 'PAY001',
    userId: 'USR001',
    totalPrice: 700.0,
    orderDate: DateTime.now(),
    paymentStatus: 'Paid',

 

  ),
  OrderModel(
    OId: "2",
    orderId: 'ORD002',
    paymentId: 'PAY002',
    userId: 'USR002',
    totalPrice: 1500.0,
    orderDate: DateTime.now(),
    paymentStatus: 'Pending',

    
  ),
  // Add more orders as needed
];
