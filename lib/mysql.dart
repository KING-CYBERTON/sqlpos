import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mysql1/mysql1.dart';
import 'package:sqlpos/Datamodels/saleitem.dart';
import 'Controllers/AuthController.dart';
import 'Datamodels/inventorylog.dart';
import 'Datamodels/product.dart';
import 'Datamodels/sale.dart';
import 'dart:math';

class MySQLHelper {
  final GetAuth getAuth = Get.put(GetAuth());
  // Define MySQL connection settings
  final ConnectionSettings settings = ConnectionSettings(
    host: '127.0.0.1', // Change this to your server's IP or domain if not local
    port: 3306, // Default MySQL port
    user: 'root', // Your MySQL username
    password: '1234', // Your MySQL password
    db: 'pos_system', // Database name
  );

  MySqlConnection? _connection;

  // Initialize and open the connection
  Future<void> openConnection() async {
    try {
      _connection = await MySqlConnection.connect(settings);
      print('Connected to MySQL database.');
    } catch (e) {
      print('Error connecting to the database: $e');
    }
  }

  // Close the connection
  Future<void> closeConnection() async {
    try {
      await _connection?.close();
      print('Database connection closed.');
    } catch (e) {
      print('Error closing the connection: $e');
    }
  }

  String generateTransactionId(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000); // Generate a random 4-digit number
    // Concatenate userId, timestamp, and random number to ensure uniqueness
    return '$userId-${(timestamp % 100000000)}-${random.toString().padLeft(4, '0')}';
  }

  Future<void> insertSaleAndItemsmpesa(
      int saleid,
      double totalAmount,
      String paymentMethod,
      int customerId,
      int employeeId,
      double mpesaAmount,
      int mpesaNo,
      String mpesacode,
      List<Map<String, dynamic>> saleItems) async {
    await openConnection();

    await _connection!.query('START TRANSACTION');

    try {
      // Step 1: Insert into `sales` table
      await _connection!.query(
          'INSERT INTO sales (sale_id, sale_date, total_amount, payment_method, customer_id, employee_id, status) '
          'VALUES ($saleid, NOW(), $totalAmount, "$paymentMethod", $customerId, $employeeId, "Completed")');

      await _connection!.query(
          'INSERT INTO mpesaTrn (sale_id, sale_time, mpesa_Amount, mpesa_No, mpesa_Code) '
          'VALUES ($saleid, NOW(), $mpesaAmount, $mpesaNo,"$mpesacode")');

      // Step 2: Insert sale items into `sales_items` table
      for (var item in saleItems) {
        await _connection!.query(
            'INSERT INTO sales_items (sale_id, product_id, product_name, quantity, price, total) '
            'VALUES ($saleid, ${item['productId']}, "${item['productName']}", ${item['quantity']}, ${item['price']}, ${item['total']})');
      }

      await _connection!.query('COMMIT');
    } catch (e) {
      print('Error: $e');
      await _connection!.query('ROLLBACK');
    } finally {
      await _connection!.close();
    }
  }

  Future<void> insertSaleAndItems(
      int saleid,
      double totalAmount,
      String paymentMethod,
      int customerId,
      int employeeId,
      List<Map<String, dynamic>> saleItems) async {
    await openConnection();

    await _connection!.query('START TRANSACTION');

    try {
      print('inserting $saleid');
      // Step 1: Insert into `sales` table
      await _connection!.query(
          'INSERT INTO sales (sale_id, sale_date, total_amount, payment_method, customer_id, employee_id, status) '
          'VALUES ($saleid, NOW(), $totalAmount, "$paymentMethod", $customerId, $employeeId, "Completed")');
      print('inserted');
      // Step 2: Insert sale items into `sales_items` table
      for (var item in saleItems) {
        await _connection!.query(
            'INSERT INTO sales_items (sale_id, product_id, product_name, quantity, price, total) '
            'VALUES ($saleid, ${item['productId']}, "${item['productName']}", ${item['quantity']}, ${item['price']}, ${item['total']})');
      }

      await _connection!.query('COMMIT');
    } catch (e) {
      print('Error: $e');
      await _connection!.query('ROLLBACK');
    } finally {
      await _connection!.close();
    }
  }

  Future<Product?> fetchProductById(int productId) async {
    // Ensure the connection is open
    if (_connection == null) {
      await openConnection();
    }

    try {
      // Query to get a single product by ID
      var results = await _connection!.query(
        'SELECT * FROM products WHERE product_id = $productId',
      );

      // Check if product exists
      if (results.isNotEmpty) {
        // Convert the first result to a Product object
        var row = results.first;
        print(row);
        return Product.fromMap(row.fields);
      } else {
        print('Product with ID $productId not found.');
        return null; // Product not found
      }
    } catch (e) {
      print('Error fetching product by ID: $e');
      return null;
    }
  }

  Future<List<InventoryLog>> fetchAllInventoryLogs() async {
    List<InventoryLog> inventoryLogs = [];
    try {
      // Open the connection if it's not already open
      if (_connection == null) await openConnection();

      // Query the database to fetch all inventory logs
      var results = await _connection?.query('SELECT * FROM inventory_log');

      // Map the query result to a list of InventoryLog objects
      for (var row in results!) {
        InventoryLog log = InventoryLog.fromMap({
          'log_id': row['log_id'],
          'product_id': row['product_id'],
          'change_type': row['change_type'],
          'quantity_change': row['quantity_change'],
          'new_quantity': row['new_quantity'],
          'timestamp':
              row['timestamp'].toString(), // Assuming `timestamp` is DateTime
          'notes': row['notes'], // notes may be null
        });
        inventoryLogs.add(log);
      }

      print(
          'Fetched ${inventoryLogs.length} inventory logs from the database.');
    } catch (e) {
      print('Error fetching inventory logs: $e');
    }

    return inventoryLogs;
  }

  Future<List<SaleItem>> fetchAllsalesItems() async {
    List<SaleItem> saleItems = [];
    try {
      // Open the connection if it's not already open
      if (_connection == null) await openConnection();

      // Query the database to fetch all products
      var results = await _connection?.query('SELECT * FROM sales_items');

      // Map the query result to a list of Product objects

      for (var row in results!) {
        SaleItem saleItem = SaleItem.fromMap({
          'sale_item_id': row['sale_item_id'] as int,
          'sale_id': row['sale_id'] as int,
          'product_id': row['product_id'] as int,
          'product_name': row['product_name'] as String,
          'quantity': row['quantity'] as int,
          'price': row['price'] as double,
          'total': row['total'] as double,
        });
        saleItems.add(saleItem);
      }

      print('Fetched ${saleItems.length} saleitems from the database.');
    } catch (e) {
      print('Error fetching saleitems: $e');
    }

    return saleItems;
  }

  Future<List<Sale>> fetchAllSales() async {
    List<Sale> sales = [];
    try {
      if (_connection == null) await openConnection();
      var results = await _connection?.query('SELECT * FROM sales');

      for (var row in results!) {
        Sale sale = Sale.fromMap({
          'sale_id': row['sale_id'],
          'sale_date':
              row['sale_date'] as DateTime, // Casting `sale_date` as DateTime
          'total_amount': row['total_amount'],
          'payment_method': row['payment_method'],
          'customer_id': row['customer_id'],
          'employee_id': row['employee_id'],
        });
        sales.add(sale);
      }
      print('Fetched ${sales.length} sales from the database.');
    } catch (e) {
      print('Error fetching sales: $e');
    }
    return sales;
  }

  // Fetch all products from the database and return them as a list of Product objects
  Future<List<Product>> fetchAllProducts() async {
    List<Product> products = [];
    try {
      // Open the connection if it's not already open
      if (_connection == null) await openConnection();

      // Query the database to fetch all products
      var results = await _connection?.query('SELECT * FROM products');

      // Map the query result to a list of Product objects
      for (var row in results!) {
        Product product = Product.fromMap({
          'product_id': row['product_id'],
          'name': row['name'],
          'description': row['description'],
          'price': row['price'],
          'cost_price': row['cost_price'],
          'stock_quantity': row['stock_quantity'],
          'category_id': row['category_id'],
        });
        products.add(product);
      }

      print('Fetched ${products.length} products from the database.');
    } catch (e) {
      print('Error fetching products: $e');
    }

    return products;
  }

  Future<bool> authenticateUser(
      int username, String password, BuildContext context) async {
    try {
      var results = await _connection!.query(
        'SELECT * FROM employees WHERE employee_id = $username AND password = "$password"',
        // [username, password],
      );
      final row = results.first; // Get the first row from the result

      // Access the 'name' field
      String name = row['name'];
      String role = row['role_name'];
      int Eid = row['employee_id'];
      getAuth.employee.value = Eid;
      getAuth.employee_name.value = name;

      if (results.isNotEmpty && (role == "Admin" || role == "Cashier")) {
        print(results);

        getAuth.islogedin.value = true;
        return true; // Authentication successful
      }
      return false; // Authentication failed
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Login failed. Please try again.'),
        backgroundColor: Colors.red, // Red color for error
        duration: Duration(seconds: 3), // Show the Snackbar for 3 seconds
      ));
      print('Error: $e');
      return false;
    } finally {
      await _connection!.close();
    }
  }

  // General method to run SELECT queries
  Future<List<Map<String, dynamic>>> fetchProducts(String sql,
      [List<dynamic>? params]) async {
    final List<Map<String, dynamic>> results = [];

    if (_connection == null) {
      print('No open connection found.');
      return results;
    }

    try {
      // Execute the query
      final queryResults = await _connection!.query(sql, params);
      // Convert results into a list of maps
      for (var row in queryResults) {
        results.add(row.fields);
        print(row.fields);
      }
    } catch (e) {
      print('Error executing query: $e');
    }

    return results;
  }

  Future<bool> fetchUser(int employeeId, String hashedPassword) async {
    bool userFound = false;

    if (_connection == null) {
      print('No open connection found.');
      return userFound;
    }

    // SQL query to fetch a user
    String sql = '''
    SELECT * FROM employees
    WHERE employee_id = $employeeId AND password = "$hashedPassword"
  ''';

    // Parameters to be passed to the query
    List<dynamic> params = []; // [employeeId, hashedPassword];

    try {
      // Execute the query
      final result = await _connection!.query(sql, params);

      print(result.fields);

      // Check if any row was returned
      if (result.isNotEmpty) {
        userFound = true; // User exists
        getAuth.islogedin.value = userFound;
        print('User found: ${result.first}');
      } else {
        print('No user found.');
      }
    } catch (e) {
      print('Error fetching user: $e');
    }

    return userFound;
  }

  // General method for INSERT, UPDATE, DELETE operations
  Future<int> execute(String sql, [List<dynamic>? params]) async {
    int affectedRows = 0;

    if (_connection == null) {
      print('No open connection found.');
      return affectedRows;
    }

    try {
      final result = await _connection!.query(sql, params);
      print(result);
      affectedRows = result.affectedRows ?? 0;
    } catch (e) {
      print('Error executing operation: $e');
    }

    return affectedRows;
  }

  // Insert method for adding a new product
  Future<int> insertProduct({required Product newProduct}) async {
    final sql = buildProductInsertSQL(newProduct);
    return await execute(sql);
  }

  // Update method for updating an existing product
  Future<int> updateProduct({required Product updatedProduct}) async {
    String sql = '''
    UPDATE products
    SET name =    "${updatedProduct.name}",, description =   "${updatedProduct.description}",, price =   ${updatedProduct.price}, cost_price =  ${updatedProduct.costPrice}, stock_quantity = ${updatedProduct.stockQuantity}, category_id = ${updatedProduct.categoryId},
    WHERE id =   ${updatedProduct.productId},
  ''';
    List<dynamic> params = [
      (updatedProduct.name),
      (updatedProduct.description),
      updatedProduct.price,
      updatedProduct.costPrice,
      updatedProduct.stockQuantity,
      updatedProduct.categoryId,
      updatedProduct.productId,
    ];

    return await execute(sql, params);
  }

  // Delete method for deleting a product by its ID
  Future<int> deleteProduct({required int productId}) async {
    String sql = 'DELETE FROM products WHERE id = ?';
    return await execute(sql, [productId]);
  }

  // Helper method to build the INSERT SQL statement for products
  String buildProductInsertSQL(Product product) {
    return '''
    INSERT INTO products (name, description, price, cost_price, stock_quantity, category_id)
    VALUES (?, ?, ?, ?, ?, ?)
  ''';
  }

  // Function to add a sale and its items
  Future<void> addSale(List<Map<String, dynamic>> saleItems) async {
    if (_connection == null) {
      print('No open connection found.');
      return;
    }

    try {
      // Start a transaction to ensure that all operations succeed or fail together
      await _connection!.query('START TRANSACTION');

      // Insert the sale record
      var result = await _connection!.query(
        'INSERT INTO sales (sale_date, customer_id, employee_id, total_amount, payment_method) VALUES (NOW(), ?, ?, ?, ?)',
        [1, 2, 100.00, 'cash'],
      );

      // Get the generated sale_id for the newly inserted sale
      int saleId = result.insertId!;

      // Insert the sale items related to this sale
      for (var item in saleItems) {
        await _connection!.query(
          'INSERT INTO sales_items (sale_id, product_id, quantity, price, total) VALUES (?, ?, ?, ?, ?)',
          [
            saleId,
            item['product_id'],
            item['quantity'],
            item['price'],
            item['total']
          ],
        );
      }

      // Commit the transaction if everything was successful
      await _connection!.query('COMMIT');
      print('Sale and sale items inserted successfully!');
    } catch (e) {
      // Rollback the transaction if any error occurs
      await _connection!.query('ROLLBACK');
      print('Error inserting sale and sale items: $e');
    }
  }

  //  Future<void> addSale({
  //   required int customerId,
  //   required int employeeId,
  //   required double totalAmount,
  //   required String paymentMethod,
  //   required List<Map<String, dynamic>> saleItems,
  // }) async {
  //   if (_connection == null) {
  //     print('No open connection found.');
  //     return;
  //   }

  //   try {
  //     // Begin transaction to ensure both sale and sale items are inserted together
  //     await _connection!.transaction((txn) async {
  //       // 1. Insert Sale record
  //       var result = await txn.query(
  //         '''
  //         INSERT INTO sales (sale_date, customer_id, employee_id, total_amount, payment_method)
  //         VALUES (NOW(), ?, ?, ?, ?)
  //         ''',
  //         [customerId, employeeId, totalAmount, paymentMethod],
  //       );

  //       // Get the generated sale_id from the insert statement
  //       int saleId = result.insertId!;

  //       // 2. Insert Sale Items
  //       for (var item in saleItems) {
  //         await txn.query(
  //           '''
  //           INSERT INTO sales_items (sale_id, product_id, quantity, price, total)
  //           VALUES (?, ?, ?, ?, ?)
  //           ''',
  //           [
  //             saleId,
  //             item['product_id'],
  //             item['quantity'],
  //             item['price'],
  //             item['total']
  //           ],
  //         );
  //       }

  //       print('Sale and sale items successfully added.');
  //     });
  //   } catch (e) {
  //     print('Error inserting sale and sale items: $e');
  //   }
  // }
}
