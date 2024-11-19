import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:sqlpos/mysql.dart';

void main() async {
  final dbHelper = MySQLHelper();

  // Open the connection
  await dbHelper.openConnection();

  // Example: Insert a new product
// Make sure the number of placeholders (?) matches the number of parameters.
  int insertedRows = await dbHelper.execute(
    'INSERT INTO products (name, description, price, stock) VALUES ("Test Product"," A sample product for testing", 9.99, 100)',
// 4 parameters
  );

  print('Inserted $insertedRows rows.');

  await dbHelper.fetchProducts("SELECT * FROM products");

  // Close the connection
  await dbHelper.closeConnection();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
