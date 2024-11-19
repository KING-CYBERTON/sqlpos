import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqlpos/mysql.dart';

import '../Datamodels/product.dart'; // Make sure to import the Product model

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

bool config = false;
List<Product> prolist = [];

class _ProductListState extends State<ProductList> {
  @override
  Widget build(BuildContext context) {
    return config == true
        ? SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(0.5), // Item Lookup Code
                    1: FlexColumnWidth(3), // Description
                    2: FixedColumnWidth(80.0), // Quantity
                    3: FlexColumnWidth(2), // Price
                    4: FlexColumnWidth(2), // Extended
                    5: FixedColumnWidth(70.0), // Taxable
                    6: FlexColumnWidth(1), // Rep
                  },
                  border: TableBorder.all(color: Colors.grey), // Optional border
                  children: [
                    // Header Row
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey[300]),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Item Lookup Code',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Description',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Name',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('quantity',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('cost_price',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('price',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('category',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    // Data Rows
                    ...prolist.map((entry) {
                      Product product = entry;
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(product.productId.toString()),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(product.description),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(product.name.toString()),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(product.stockQuantity.toString()),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text((product.costPrice.toStringAsFixed(2))),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(product.price.toStringAsFixed(
                                2)), // Hardcoded or dynamic taxable status
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(product.categoryId
                                .toString()), // Hardcoded or dynamic rep info
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
        )
        : Container(
          color: Colors.amber,
            height: 200,
            width: 200,
            child: GestureDetector(
              onTap: () async {
                final dbHelper = MySQLHelper();

                List<Product> pro = await dbHelper.fetchAllProducts();
                pro = await dbHelper.fetchAllProducts();
                setState(() {
                  prolist = pro;
                  config = true;
                });
              },
            ),
          );
  }
}
