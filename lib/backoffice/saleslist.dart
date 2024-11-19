import 'package:flutter/material.dart';
import 'package:sqlpos/Datamodels/saleitem.dart';

import '../Datamodels/sale.dart';
import '../mysql.dart';

class SalesList extends StatefulWidget {
  const SalesList({super.key});

  @override
  State<SalesList> createState() => _SalesListState();
}

class _SalesListState extends State<SalesList> {
  bool config = false;
  List<Sale> prolist = [];
  List<SaleItem> saleitemslist = [];
  @override
  Widget build(BuildContext context) {
    return config == true
        ? Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: SingleChildScrollView(
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
                        border: TableBorder.all(
                            color: Colors.grey), // Optional border
                        children: [
                          // Header Row
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey[300]),
                            children: const [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Sale Id',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Sale Date',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Total Amount',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Payment Method',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Employee Id',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          // Data Rows
                          ...prolist.map((entry) {
                            Sale sale = entry;
                            return TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(sale.saleId.toString()),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(sale.saleDate.toIso8601String()),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(sale.totalAmount.toString()),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(sale.paymentMethod.toString()),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      (sale.employeeId.toStringAsFixed(2))),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(
                thickness: 4,
              ),
              Expanded(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: SingleChildScrollView(
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
                          border: TableBorder.all(
                              color: Colors.grey), // Optional border
                          children: [
                            // Header Row
                            TableRow(
                              decoration:
                                  BoxDecoration(color: Colors.grey[300]),
                              children: const [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Sale Id',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Product Id',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(' Product Name',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('price',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Quantity',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Total',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('SaleItem_Id',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            // Data Rows
                            ...saleitemslist.map((entry) {
                              SaleItem saleitem = entry;
                              return TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(saleitem.saleId.toString()),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(saleitem.productId.toString()),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(saleitem.productName),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(saleitem.price.toString()),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text((saleitem.quantity.toString())),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text((saleitem.total.toString())),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child:
                                        Text((saleitem.saleItemId.toString())),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        : Container(
            color: Colors.amber,
            height: 200,
            width: 200,
            child: GestureDetector(
              onTap: () async {
                final dbHelper = MySQLHelper();

                List<Sale> pro = await dbHelper.fetchAllSales();
                pro = await dbHelper.fetchAllSales();

                List<SaleItem> items = await dbHelper.fetchAllsalesItems();
                items = await dbHelper.fetchAllsalesItems();

                setState(() {
                  saleitemslist = items;
                  prolist = pro;
                  config = true;
                });
              },
            ),
          );
  }
}
