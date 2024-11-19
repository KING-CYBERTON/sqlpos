import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqlpos/Controllers/CartController.dart';
import 'package:sqlpos/Datamodels/product.dart';
import 'package:sqlpos/Sales/login_page.dart';

import '../Controllers/AuthController.dart';
import '../mysql.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  final GetAuth getAuth = Get.put(GetAuth());
  final CartController cartController = Get.put(CartController());
  final TextEditingController productID = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text("sales: 0.00"),
            const Text("Discount: 0.00%"),
            const Text("Register: 17"),
            const VerticalDivider(
              thickness: 2,
              color: Colors.black,
            ),
            Text("Date: ${DateTime.now()}"),
          ],
        ),
        backgroundColor: Colors.grey[200],
        elevation: 0,
      ),
      body: Obx(
        () => getAuth.islogedin.value == true
            ? Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.topRight,
                    child: const Text(
                      "Ayopa 2.0.1.267",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                        child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(0.5), // Num
                        1: FlexColumnWidth(2), // Item Lookup Code
                        2: FlexColumnWidth(3), // Description
                        3: FixedColumnWidth(80.0), // Quantity
                        4: FlexColumnWidth(2), // Price
                        5: FlexColumnWidth(2), // Extended
                        6: FixedColumnWidth(70.0), // Taxable
                        7: FlexColumnWidth(1), // Rep
                      },
                      border: TableBorder.all(color: Colors.grey),
                      children: [
                        // Header Row
                        TableRow(
                          decoration: BoxDecoration(color: Colors.grey[300]),
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('NO',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Item Lookup Code',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Description',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Quantity',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Price',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Extended',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Taxable',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Rep',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),

                        // Data Rows
                        ...cartController.products.entries.map((entry) {
                          Product product = entry.key;
                          int quantity = entry.value;

                          return TableRow(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(''), // Row number
                              ),
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
                                child: Text('$quantity'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(product.price.toStringAsFixed(2)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  cartController
                                      .totalForProduct(product)
                                      .toStringAsFixed(2),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(cartController.total),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("no"),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    )),
                  ),
                  Container(
                    height: 180,
                    color: Colors.lightBlue[100],
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 40,
                          child: Row(
                            children: [
                              const SizedBox(
                                  width: 100,
                                  child: Text(
                                    "Look Up Code",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  )),
                              Container(
                                width: 200,
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 241, 237, 237),
                                  border: Border.all(),
                                ),
                                child: TextField(
                                  controller: productID,
                                  focusNode: FocusNode(),
                                  onSubmitted: (value) async {
                                    // Action when Enter is pressed
                                    final dbHelper = MySQLHelper();
                                    Product? product =
                                        await dbHelper.fetchProductById(
                                            int.parse(productID.text.trim()));
                                    product = await dbHelper.fetchProductById(
                                        int.parse(productID.text.trim()));
                                    if (product != null) {
                                      cartController.addProduct(product);
                                    }
                                    print(cartController.total);
                                  },
                                  decoration: const InputDecoration(
                                      hintText: "Type something"),
                                ),
                              )
                            ],
                          ),
                        ),
                        const Divider(
                          thickness: 2,
                          color: Colors.black,
                        ),
                  Obx( ()=>      SizedBox(
                          height: 80,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Calculate and display weight (you can add logic to compute it)
                              _buildSummaryItem("Weight", "0.0"),
                              const VerticalDivider(
                                thickness: 2,
                                color: Colors.grey,
                              ),
                              // Sub Total from cartController
                              _buildSummaryItem("Sub Total",
                                  "${cartController.grandTotal.toStringAsFixed(2) ?? 0}"),
                              const VerticalDivider(
                                thickness: 2,
                                color: Colors.grey,
                              ),
                              // Sales Tax, assuming no tax for now
                              _buildSummaryItem("Sales Tax", "0.00"),
                              const VerticalDivider(
                                thickness: 2,
                                color: Colors.grey,
                              ),
                              // Totals (Grand Total from CartController)
                              _buildSummaryItem(
                                  "Totals",  "0.00")
                            ],
                          ),
                        ),),
                        const Divider(
                          thickness: 2,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  )
                ],
              )
            : const LoginPage(),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  const SummaryRow({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.put(CartController());
    final TextEditingController productID = TextEditingController();

    // Assuming you have a function to calculate total weight from the cart.
    double calculateWeight() {
      double weight = 0.0;
      cartController.products.forEach((key, value) {
        weight += value.weight *
            value.quantity; // Example, adjust based on your model
      });
      return weight;
    }

    return Container(
      height: 180,
      color: Colors.lightBlue[100],
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: Row(
              children: [
                const SizedBox(
                    width: 100,
                    child: Text(
                      "Look Up Code",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    )),
                Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 241, 237, 237),
                    border: Border.all(),
                  ),
                  child: TextField(
                    controller: productID,
                    focusNode: FocusNode(),
                    onSubmitted: (value) async {
                      // Action when Enter is pressed
                      final dbHelper = MySQLHelper();
                      Product? product = await dbHelper
                          .fetchProductById(int.parse(productID.text.trim()));
                      product = await dbHelper
                          .fetchProductById(int.parse(productID.text.trim()));
                      if (product != null) {
                        cartController.addProduct(product);
                      }
                      print(cartController.total);
                    },
                    decoration:
                        const InputDecoration(hintText: "Type something"),
                  ),
                )
              ],
            ),
          ),
          const Divider(
            thickness: 2,
            color: Colors.black,
          ),
          SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Calculate and display weight (you can add logic to compute it)
                _buildSummaryItem("Weight", "0.0"),
                const VerticalDivider(
                  thickness: 2,
                  color: Colors.grey,
                ),
                // Sub Total from cartController
                _buildSummaryItem("Sub Total",
                    "${cartController.grandTotal.toStringAsFixed(2) ?? 0}"),
                const VerticalDivider(
                  thickness: 2,
                  color: Colors.grey,
                ),
                // Sales Tax, assuming no tax for now
                _buildSummaryItem("Sales Tax", "0.00"),
                const VerticalDivider(
                  thickness: 2,
                  color: Colors.grey,
                ),
                // Totals (Grand Total from CartController)
                Obx(() => _buildSummaryItem(
                    "Totals",
                    cartController.totalProductsInCart.value == null
                        ? "${cartController.total}"
                        : "10.00"))
              ],
            ),
          ),
          const Divider(
            thickness: 2,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
