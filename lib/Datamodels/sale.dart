class Sale {
  final int saleId;
  final DateTime saleDate;
  final double totalAmount;
  final String paymentMethod;
  final int customerId;
  final int employeeId;

  Sale({
    required this.saleId,
    required this.saleDate,
    required this.totalAmount,
    required this.paymentMethod,
    required this.customerId,
    required this.employeeId,
  });

  // Factory constructor to create a Sale instance from a Map
  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      saleId: map['sale_id'] as int,
      saleDate: map['sale_date'] as DateTime, // Ensure this is DateTime in your model
      totalAmount: map['total_amount'] as double,
      paymentMethod: map['payment_method'] as String,
      customerId: map['customer_id'] as int,
      employeeId: map['employee_id'] as int,
    );
  }

  // Method to convert Sale instance to Map (optional, if needed for database inserts)
  Map<String, dynamic> toMap() {
    return {
      'sale_id': saleId,
      'sale_date': saleDate.toIso8601String(), // Convert DateTime to String if necessary
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'customer_id': customerId,
      'employee_id': employeeId,
    };
  }
}
