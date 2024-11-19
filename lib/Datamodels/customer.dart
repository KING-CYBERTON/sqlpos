class Customer {
  int? customerId;
  String name;
  String phone;
  String? email;
  String address;

  Customer({
    this.customerId,
    required this.name,
    required this.phone,
    this.email,
    required this.address,
  });

  // Convert Customer to Map (for SQL insertion)
  Map<String, dynamic> toMap() {
    return {
      'customer_id': customerId,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
    };
  }

  // Convert Map to Customer (for SQL selection)
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      customerId: map['customer_id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
    );
  }
}
