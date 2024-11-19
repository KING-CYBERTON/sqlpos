import 'package:mysql1/mysql1.dart';

class InventoryLog {
  final int? logId;
  final int productId;
  final String changeType;
  final int quantityChange;
  final int newQuantity;
  final DateTime timestamp;
  final String? notes;

  InventoryLog({
    this.logId,
    required this.productId,
    required this.changeType,
    required this.quantityChange,
    required this.newQuantity,
    required this.timestamp,
    this.notes,
  });

factory InventoryLog.fromMap(Map<String, dynamic> map) {
  return InventoryLog(
    logId: map['log_id'] as int?,
    productId: map['product_id'] as int,
    changeType: map['change_type'] as String,
    quantityChange: map['quantity_change'] as int,
    newQuantity: map['new_quantity'] as int,
    timestamp: DateTime.parse(map['timestamp'] as String),
    notes: map['notes'] is Blob
        ? String.fromCharCodes((map['notes'] as Blob).toBytes())
        : map['notes'] as String?,  // Handle BLOB or String
  );
}


  // Method to convert an InventoryLog instance to Map
  Map<String, dynamic> toMap() {
    return {
      'log_id': logId,
      'product_id': productId,
      'change_type': changeType,
      'quantity_change': quantityChange,
      'new_quantity': newQuantity,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }
}
