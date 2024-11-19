import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sqlpos/Datamodels/product.dart';
import 'package:sqlpos/mysql.dart';
import 'package:sqlpos/print.dart';

import 'Sales/pos.dart';
import 'admin/dashboard/dashboard.dart';
import 'backoffice/Appbar.dart';
import 'backoffice/Productlist.dart';
import 'backoffice/movement.dart';
import 'backoffice/saleslist.dart';

void main() async {
  final dbHelper = MySQLHelper();

  // Open the connection
  await dbHelper.openConnection();

  final Product newproduct = Product(
      productId: 5,
      name: "nitohz",
      description: " A sample product for testing",
      price: 10.00,
      costPrice: 900.00,
      stockQuantity: 50,
      categoryId: 3);

  // Example: Insert a new product
// Make sure the number of placeholders (?) matches the number of parameters.
  int insertedRows = await dbHelper.execute(
    'INSERT INTO products (name, description, price, cost_price, stock_quantity, category_id) VALUES ("${newproduct.name}","${newproduct.description}", ${newproduct.price},${newproduct.costPrice},${newproduct.stockQuantity}, ${newproduct.categoryId})',
  );

  //// this update works
  int ppo = await dbHelper.execute(
    '''UPDATE products
    SET name = 'ikosawa', price =30
    WHERE product_id = 5''');


  //

  await dbHelper.fetchAllProducts();
  await dbHelper.fetchAllProducts();
  // await dbHelper.fetchProductById(2);
  // await dbHelper.fetchProductById(2);
  //await dbHelper.fetchProducts("SELECT * FROM products");

  // List<Map<String, dynamic>> saleItems = [
  //   {'product_id': 1, 'quantity': 2, 'price': 50.00, 'total': 100.00},
  //   {'product_id': 2, 'quantity': 1, 'price': 30.00, 'total': 30.00},
  // ];





  // await dbHelper.addSale(
  //     customerId: 2,
  //     employeeId: 1,
  //     totalAmount: 1000.00,
  //     paymentMethod: "cash",
  //     saleItems: saleItems);

  // await dbHelper.insertProduct(newProduct: newproduct);

   //await dbHelper.updateProduct(updatedProduct: newproduct);

  // print('Inserted $insertedRows rows.');

  // await dbHelper.fetchProducts("SELECT * FROM products");

  // Close the connection

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
            // Initializing responsive_framework here.
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1200, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
      home: Scaffold(


        
        body: adminAppBar(),

        //   Center(
        //       child: ElevatedButton(
        //           onPressed: () async {
        //             final dbHelper = MySQLHelper();
        //             await dbHelper.openConnection();

        //             List<Map<String, dynamic>> saleItems = [
        //               {
        //                 'product_id': 1,
        //                 'quantity': 2,
        //                 'price': 50.00,
        //                 'total': 100.00
        //               },
        //               {
        //                 'product_id': 2,
        //                 'quantity': 1,
        //                 'price': 30.00,
        //                 'total': 30.00
        //               },
        //             ];

        //             await dbHelper.execute(
        //                 ' INSERT INTO sales (sale_id,sale_date, customer_id, employee_id, total_amount, payment_method)  VALUES (124,NOW(), 1,2, 100.00, "cash")');
        //             for (var item in saleItems) {
        //               await dbHelper.execute(
        //                 '   INSERT INTO sales_items (sale_id, product_id, quantity, price, total) VALUES (124, ${item['product_id']}, ${item['quantity']},  ${item['price']}, ${item['total']})   ',
        //               );
        //             }

        //             await dbHelper.closeConnection();

        //           },
        //           child: const Text('data'))),
      ),
    );
  }
}
