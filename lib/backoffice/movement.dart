import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqlpos/mysql.dart';
import '../Datamodels/inventorylog.dart'; // Import the InventoryLog model

class InventoryLogPage extends StatefulWidget {
  const InventoryLogPage({super.key});

  @override
  State<InventoryLogPage> createState() => _InventoryLogPageState();
}

bool config = false;
List<InventoryLog> inventoryLogs = [];

class _InventoryLogPageState extends State<InventoryLogPage> {
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
                    0: FlexColumnWidth(1), // Log ID
                    1: FlexColumnWidth(2), // Product ID
                    2: FlexColumnWidth(2), // Change Type
                    3: FixedColumnWidth(80.0), // Quantity Change
                    4: FixedColumnWidth(100.0), // New Quantity
                    5: FlexColumnWidth(2), // Timestamp
                    6: FlexColumnWidth(2), // Notes
                  },
                  border: TableBorder.all(color: Colors.grey),
                  children: [
                    // Header Row
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey[300]),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Log ID',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Product ID',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Change Type',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Quantity Change',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('New Quantity',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Timestamp',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Notes',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    // Data Rows
                    ...inventoryLogs.map((entry) {
                      InventoryLog log = entry;
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(log.logId.toString()),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(log.productId.toString()),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(log.changeType),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(log.quantityChange.toString()),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(log.newQuantity.toString()),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(log.timestamp.toString()),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(log.notes ?? '-'),
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
                List<InventoryLog> logs =
                    await dbHelper.fetchAllInventoryLogs();
                      logs =
                    await dbHelper.fetchAllInventoryLogs();
                setState(() {
                  inventoryLogs = logs   .where((product) => product.productId == 2)
            .toList();
                  config = true;
                });
              },
              
              ),
            
          );
  }
}
