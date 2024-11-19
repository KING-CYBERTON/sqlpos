import 'package:mysql1/mysql1.dart';

import '../Datamodels/sale.dart';

class DatabaseService {
  // MySQL connection details
  final String host = 'your-database-host';
  final String user = 'your-database-user';
  final String password = 'your-database-password';
  final String db = 'your-database-name';

  // Function to add a sale
  Future<int?> addSale(Sale sale) async {
    final conn = await MySqlConnection.connect(ConnectionSettings(
    host: 'localhost', // Change this to your server's IP or domain if not local
    port: 3306, // Default MySQL port
    user: 'root', // Your MySQL username
    password: '1234', // Your MySQL password
    db: 'pos_system', // Database name
    ));

    // SQL query to insert the sale into the database
    var result = await conn.query(
      'INSERT INTO sales (sale_date, total_amount, payment_method, customer_id, employee_id) VALUES (?, ?, ?, ?, ?)',
      [
        sale.saleDate.toIso8601String(),
        sale.totalAmount,
        sale.paymentMethod,
        sale.customerId,
        sale.employeeId,
      ],
    );

    // Closing the connection after operation
    await conn.close();

    // Return the inserted sale id
    return result.insertId;
  }
}
