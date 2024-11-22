import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:sqlpos/Controllers/CartController.dart';
import 'package:sqlpos/Datamodels/product.dart';
import 'package:sqlpos/Sales/CustomText.dart';
import 'package:sqlpos/Sales/login_page.dart';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sqlpos/mysql.dart';
import '../Controllers/AuthController.dart';
import '../mysql.dart';
import 'unfoldableseachbar.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final String title = "";
  String _message = "Press any key...";
  final FocusNode _focusNode = FocusNode();
  late String cashText = "";
  final TextEditingController MpesanameController = TextEditingController();
  final TextEditingController MpesacodeController = TextEditingController();
  final TextEditingController MpesaAmountController = TextEditingController();
  final TextEditingController CashAmountController = TextEditingController();
  late List<Product> prolist = [];
  int generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return timestamp % 1000000000; // Use only the last 9 digits
  }

  final now = DateTime.now();
  final formatter = DateFormat('dd-MM-yyyy HH:mm:ss'); // Correct format pattern
  // Format the current DateTime
  bool isExpanded = false;
  late double cashReceived;

  double calculateChange() {
    cashReceived = double.tryParse(CashAmountController.text.trim()) ?? 0.0;
    double totalAmount = cartController.paymentTotal;
    return (cashReceived - totalAmount).clamp(0.0, double.infinity);
  }

  int saleid = 0;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus(); // Request focus initially
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Dispose of the focus node to avoid memory leaks
    MpesacodeController.dispose();
    MpesaAmountController.dispose();
    MpesanameController.dispose();
    CashAmountController.dispose();
    super.dispose();
  }

  void _onKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      setState(() {
        _message = "Key pressed: ${event.logicalKey.debugName}";
      });

      // Assign functions to specific keys
      if (event.logicalKey == LogicalKeyboardKey.f12) {
        _showF12Dialog();
      } else if (event.logicalKey == LogicalKeyboardKey.f11) {
        _showF11Dialog();
      } else if (event.logicalKey == LogicalKeyboardKey.delete) {
        _ondeletePressed();
      } else if (event.logicalKey == LogicalKeyboardKey.f9) {
        _onf9Pressed();
      }
    }
  }

  // Function to handle Enter key
  void _onEnterPressed() {
    setState(() {
      _message = "Enter key action triggered!";
    });
    print("Enter key function executed.");
  }

  void _onf9Pressed() {
    getAuth.islogedin.value = false;
  }

  void _ondeletePressed() {
    cartController.cartItemsForUpload.clear();
    cartController.products.clear();
  }

  // Function to handle Arrow Up key
  void _onArrowUpPressed() {
    setState(() {
      getAuth.islogedin.value = false;
    });
    print("Arrow Up key function executed.");
  }

  final GlobalKey<FormState> cashkey = GlobalKey();
  void _showF12Dialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              elevation: 2.0,
              title: const Text("Paid Cash"),
              content: SizedBox(
                height: 180,
                width: MediaQuery.of(context).size.width * 0.4,
                child: Form(
                  key: cashkey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(
                        size: double.maxFinite,
                        hintText: 'Enter Cash Received',
                        textInputType: TextInputType.number,
                        isPass: false,
                        textController: CashAmountController,
                        onChanged: (value) {
                          // Update dialog state when the user enters cash received
                          setState(() {
                            calculateChange();
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter the cash received.";
                          }
                          if (double.tryParse(value) == null) {
                            return "Please enter a valid number.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Total Amount: ${cartController.paymentTotal}",
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w400),
                      ),
                      Text(
                        "Change: ${calculateChange()}",
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 24),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (cashkey.currentState!.validate()) {
                        double totalAmount = cartController.paymentTotal;

                        // Validate the cash received
                        if (cashReceived < totalAmount) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Cash received is less than the total amount."),
                            ),
                          );
                          return;
                        }

                        setState(() {
                          saleid = generateTransactionId();
                        });

                        try {
                          // Save the transaction in the database
                          final dbHelper = MySQLHelper();
                          await dbHelper.openConnection();
                          await dbHelper.insertSaleAndItems(
                            saleid,
                            totalAmount,
                            "CASH",
                            3, // Customer ID
                            4, // Employee ID
                            cartController.cartItemsForUpload,
                          );
                          await dbHelper.closeConnection();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Transaction posted successfully")),
                          );

                          // Printing
                          final printers = await Printing.listPrinters();
                          if (printers.isNotEmpty) {
                            final defaultPrinter = printers.firstWhere(
                              (printer) => printer.isDefault == true,
                            );
                            await Printing.directPrintPdf(
                              printer: defaultPrinter,
                              usePrinterSettings: true,
                              onLayout: (format) =>
                                  _generatePdf(format, "Sale Receipt", "CASH"),
                            );
                          } else {
                            print("No printers available.");
                          }
                        } catch (e) {
                          print("Error processing payment: $e");
                        } finally {
                          // Clear the text field and close dialog
                          cartController.cartItemsForUpload.clear();
                          cartController.products.clear();
                          Navigator.of(context).pop();
                          print(cartController.products.length);
                        }
                      }
                    },
                    child: const Text('Complete Sale'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  final GlobalKey<FormState> mpesakey = GlobalKey();
  void _showF11Dialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Lipa Na Mpesa"),
          content: SizedBox(
            height: 280,
            width: MediaQuery.of(context).size.width * 0.4,
            child: Form(
              key: mpesakey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomText(
                      size: double.maxFinite,
                      hintText: 'Mpesa Code',
                      textInputType: TextInputType.text,
                      isPass: false,
                      textController: MpesacodeController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the Mpesa Code';
                        }
                        if (value.length != 10 ||
                            !RegExp(r'^[A-Z0-9]+$').hasMatch(value)) {
                          return 'Mpesa Code must be 10 alphanumeric characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomText(
                      size: double.maxFinite,
                      hintText: 'Mpesa Amount',
                      textInputType: TextInputType.number,
                      isPass: false,
                      textController: MpesaAmountController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the Mpesa Amount';
                        }
                        // Additional validation for numeric input
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomText(
                      size: double.maxFinite,
                      hintText: 'Mpesa Phone',
                      textInputType: TextInputType.phone,
                      isPass: false,
                      textController: MpesanameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the Mpesa Phone Number';
                        }
                        // Additional validation for phone number
                        if (!RegExp(r'^(0|254)\d{9}$').hasMatch(value)) {
                          return 'Enter a valid phone number starting with 0 or 254';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (mpesakey.currentState!.validate()) {
                    setState(() {
                      saleid = generateTransactionId();
                    });

                    double totalAmount = cartController.paymentTotal;
                    String paymentMethod = "MPESA";

                    try {
                      double mpesaAmount =
                          double.parse(MpesaAmountController.text.trim());

                      // Ensure the Mpesa Amount matches the Total Amount
                      if (mpesaAmount != totalAmount) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Mpesa Amount must match the Total Amount.")),
                        );
                        return;
                      }

                      int mpesaNo = int.parse(MpesanameController.text.trim());

                      final dbHelper = MySQLHelper();
                      await dbHelper.openConnection();

                      await dbHelper.insertSaleAndItemsmpesa(
                        saleid,
                        totalAmount,
                        paymentMethod,
                        3,
                        4,
                        mpesaAmount,
                        mpesaNo,
                        MpesacodeController.text.trim(),
                        cartController.cartItemsForUpload,
                      );

                      await dbHelper.closeConnection();

                      final printers = await Printing.listPrinters();
                      if (printers.isNotEmpty) {
                        final defaultPrinter = printers
                            .firstWhere((printer) => printer.isDefault == true);
                        await Printing.directPrintPdf(
                          printer: defaultPrinter,
                          usePrinterSettings: true,
                          onLayout: (format) =>
                              _generatePdf(format, title, paymentMethod),
                        );
                      } else {
                        print("No printers available.");
                      }
                    } catch (e) {
                      print("Error processing payment: $e");
                    }
                    MpesacodeController.clear();
                    MpesaAmountController.clear();
                    MpesanameController.clear();
                    cartController.cartItemsForUpload.clear();
                    cartController.products.clear();
                    Navigator.of(context).pop();
                    print(cartController.products.length); // Exit the dialog
                  }
                },
                child: const Text('Print Receipt'),
              ),
            ),
          ],
        );
      },
    );
  }

  final GetAuth getAuth = Get.put(GetAuth());
  final CartController cartController = Get.put(CartController());
  final TextEditingController productID = TextEditingController();
  final TextEditingController FSearchController = TextEditingController();

  String search = '';
  @override
  Widget build(BuildContext context) {
    List<Product> filteredproduct = search.isEmpty
        ? prolist
        : prolist.where((product) {
            bool matchesProductId = false;
            bool matchesCategoryId = false;

            // Safely attempt to parse the search term to an integer
            try {
              int searchAsInt = int.parse(search);
              matchesProductId = product.productId == searchAsInt;
              matchesCategoryId = product.categoryId == searchAsInt;
            } catch (e) {
              // Parsing failed, so treat it as a string comparison
            }

            // Perform string comparison
            bool matchesName =
                product.name.toLowerCase().contains(search.toLowerCase());

            // Return true if any condition matches
            return matchesProductId || matchesName || matchesCategoryId;
          }).toList();
    final formattedDate = formatter.format(now);
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
    
              Image.asset(
                  height: 40,
                  width: 200,
                  fit: BoxFit.fitWidth,
                  "assets/images/logo.png"),
              const SizedBox(height: 20),
              const Text("Register: 1"),
              const VerticalDivider(
                thickness: 2,
                color: Colors.black,
              ),
              Text("Date: $formattedDate"),
            ],
          ),
          backgroundColor: Colors.grey[200],
          elevation: 0,
        ),
        body: KeyboardListener(
          focusNode: _focusNode, // Attach the focus node
          onKeyEvent: _onKey,
          child: Obx(
            () => getAuth.islogedin.value == true
                ? Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isExpanded ? 300 : 0, // Adjust sizes here

                        child: Stack(
                          children: [
                            // Sidebar content
                            Column(
                              children: [
                                SizedBox(
                                  height: 100,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: SearchBarUnfoldable(
                                          controller: FSearchController,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                search = FSearchController.text
                                                    .trim();
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors
                                                  .transparent, // Make button background transparent
                                              shadowColor: Colors
                                                  .transparent, // Remove button shadow
                                            ),
                                            icon: const Icon(Icons.search,
                                                color: Colors.blueGrey)),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    
                                    child: SingleChildScrollView(
                                        child: Table(
                                      columnWidths: const {
                                        0: FlexColumnWidth(2),
                                        1: // Item Lookup Code
                                            FlexColumnWidth(3), // Description
                                      },
                                      border: TableBorder.all(color: Colors.grey),
                                      children: [
                                        // Header Row
                                        TableRow(
                                          decoration: BoxDecoration(
                                              color: Colors.grey[300]),
                                          children: const [
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text('Item Code',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text('Description',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                    
                                        // Data Rows
                                        ...filteredproduct
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          Product product = entry
                                              .value; // The product at the current index
                                    
                                          return TableRow(
                                            children: [
                                            GestureDetector(
                                              onDoubleTap: (){
                                                   cartController
                                                    .addProduct(product);
                                                print(cartController.total);
                                              },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                      product.productId.toString()),
                                                ),
                                              ),
                                              GestureDetector(
                                                onDoubleTap: (){
                                                     cartController
                                                    .addProduct(product);
                                                print(cartController.total);
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(product.name),
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                      ],
                                    )),
                                  ),
                                ),
                              ],
                            ),
                            // Toggle button at the edge
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                                    decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5), // Shadow color
                blurRadius: 10, // Softness of shadow
                offset: Offset(0, 10), // Offset in x and y directions
              ),
            ],
          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: IconButton(
                                      onPressed: () async {
                                        final dbHelper = MySQLHelper();
                          
                                        List<Product> pro =
                                            await dbHelper.fetchAllProducts();
                                        pro = await dbHelper.fetchAllProducts();
                          
                                        setState(() {
                                          prolist = pro;
                                          isExpanded = !isExpanded;
                                        });
                                      },
                                      icon: Icon(
                                        isExpanded
                                            ? Icons.arrow_back_ios
                                            : Icons.arrow_forward_ios,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    alignment: Alignment.topRight,
                                    child: const Text(
                                      "Ayopa 1.0.01.1",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ],
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
                                      decoration:
                                          BoxDecoration(color: Colors.grey[300]),
                                      children: const [
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('NO',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Item Lookup Code',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Description',
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
                                          child: Text('Price',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Extended',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Taxable',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Rep',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                          
                                    // Data Rows
                                    ...cartController.products.entries
                                        .map((entry) {
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
                                            child: Text(
                                                product.productId.toString()),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(product.name),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('$quantity'),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                                product.price.toStringAsFixed(2)),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              cartController
                                                  .totalForProduct(product)
                                                  .toStringAsFixed(2),
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(''),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text("no"),
                                          ),
                                        ],
                                      );
                                    }),
                                  ],
                                )),
                              ),
                              Container(
                                height: 180,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 206, 124, 221),
                                      Colors.white,
                                      Color.fromARGB(255, 99, 137, 196)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
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
                                              color: const Color.fromARGB(
                                                  255, 241, 237, 237),
                                              border: Border.all(),
                                            ),
                                            child: TextField(
                                              controller: productID,
                                              focusNode: FocusNode(),
                                              onSubmitted: (value) async {
                                                // Action when Enter is pressed
                                                final dbHelper = MySQLHelper();
                                                Product? product = await dbHelper
                                                    .fetchProductById(int.parse(
                                                        productID.text.trim()));
                                                product = await dbHelper
                                                    .fetchProductById(int.parse(
                                                        productID.text.trim()));
                                                print(product!.stockQuantity);
                                                cartController
                                                    .addProduct(product);
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
                                    Obx(
                                      () => SizedBox(
                                        height: 80,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            // Calculate and display weight (you can add logic to compute it)
                                            _buildSummaryItem("Weight", ""),
                                            const VerticalDivider(
                                              thickness: 2,
                                              color: Colors.grey,
                                            ),
                                            // Sub Total from cartController
                                            _buildSummaryItem(
                                                "Sales Tax",
                                                cartController.products.isEmpty
                                                    ? "0.00"
                                                    : cartController.subtotal
                                                        .toStringAsFixed(2)),
                                            const VerticalDivider(
                                              thickness: 2,
                                              color: Colors.grey,
                                            ),
                                            // Sales Tax, assuming no tax for now
                                            _buildSummaryItem(
                                                "Sales Tax",
                                                cartController.products.isEmpty
                                                    ? "0.00"
                                                    : cartController.tax
                                                        .toStringAsFixed(2)),
                                            const VerticalDivider(
                                              thickness: 2,
                                              color: Colors.grey,
                                            ),
                                            // Totals (Grand Total from CartController)
                                            _buildSummaryItem(
                                                "Totals",
                                                cartController.products.isEmpty
                                                    ? "0.00"
                                                    : "${cartController.total ?? 0}")
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Divider(
                                      thickness: 2,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : const LoginPage(),
          ),
        ));
  }

  Future<Uint8List> _generatePdf(
      PdfPageFormat format, String title, String PAYMENT) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final font = await PdfGoogleFonts.nunitoExtraLight();
    final double change = calculateChange();
    final formattedDate = formatter.format(now);

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(1.0),
            width: 300,
            color: PdfColors.white,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.Text('SALE RECEIPT',
                          style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('CMF enterprices',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.Text('For Orders Contact: 0113618600',
                          style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Divider(),
                pw.Text('RECEIPT#: $saleid',
                    style: const pw.TextStyle(fontSize: 8)),
                pw.Text("Time: $formattedDate",
                    style: const pw.TextStyle(fontSize: 8)),
                // pw.Text('CASHIER: PRIYAL SUMARIA'),
                pw.Divider(),
                pw.SizedBox(height: 4),

                // Top row header for item description and price
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 1.0),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text('CODE',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.normal, fontSize: 8)),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text('DESCRIPTION',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.normal, fontSize: 8)),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text('PRICE',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.normal, fontSize: 8)),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text('QTY',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.normal, fontSize: 8)),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text('TOTAL',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.normal, fontSize: 8)),
                      ),
                    ],
                  ),
                ),
                pw.Divider(),

                // Loop through the items and create rows
                ...cartController.cartItemsForUpload.map(
                  (item) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(item['productId'].toString(),
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.normal,
                                      fontSize: 8)),
                              pw.Text(item['productName'].toString(),
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.normal,
                                      fontSize: 8)),
                            ]),
                        pw.Column(children: [
                          pw.Row(children: [
                            pw.Text(item['quantity'].toString(),
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.normal,
                                    fontSize: 8)),
                            pw.SizedBox(width: 4),
                            pw.Text('X',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.normal,
                                    fontSize: 8)),
                            pw.SizedBox(width: 4),
                            pw.Text(item['price'].toString(),
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.normal,
                                    fontSize: 8)),
                          ]),
                          pw.Text(item['total'].toString(),
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.normal,
                                  fontSize: 8)),
                        ])
                      ],
                    ),
                  ),
                ),

                pw.Divider(),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('PAYMENT METHOD',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal, fontSize: 8)),
                      pw.Text(" $PAYMENT",
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal, fontSize: 8)),
                    ],
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('VAT',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal, fontSize: 8)),
                      pw.Text(cartController.tax.toStringAsFixed(2),
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal, fontSize: 8)),
                    ],
                  ),
                ),

                // pw.Padding(
                //   padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
                //   child: pw.Row(
                //     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                //     children: [
                //       pw.Text('TAXABLE',
                //           style: pw.TextStyle(
                //               fontWeight: pw.FontWeight.normal, fontSize: 10)),
                //       pw.Text(cartController.subtotal.toStringAsFixed(2),
                //           style: pw.TextStyle(
                //               fontWeight: pw.FontWeight.normal, fontSize: 10)),
                //     ],
                //   ),
                // ),
                // pw.Padding(
                //   padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
                //   child: pw.Row(
                //     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                //     children: [
                //       pw.Text('VAT 16%',
                //           style: pw.TextStyle(
                //               fontWeight: pw.FontWeight.normal, fontSize: 10)),
                //       pw.Text(cartController.tax.toStringAsFixed(2),
                //           style: pw.TextStyle(
                //               fontWeight: pw.FontWeight.normal, fontSize: 10)),
                //     ],
                //   ),
                // ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('TOTAL',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal, fontSize: 8)),
                      pw.Text(cartController.total,
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal, fontSize: 8)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('CASH',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal, fontSize: 8)),
                      pw.Text(cashReceived.toStringAsFixed(2),
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal, fontSize: 8)),
                    ],
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('CHANGE',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal, fontSize: 8)),
                      pw.Text(change.toStringAsFixed(2),
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 8)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Divider(),
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text('THANK YOU',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal, fontSize: 8)),
                      pw.Text('HAVE A NICE DAY',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal, fontSize: 8)),
                      pw.Divider(
                        thickness: 1,
                      ),
                      pw.Text('AyopaPos Ver: 1.0.0.001   contact:0706709923',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal, fontSize: 8)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // pdf.addPage(
    //   pw.Page(
    //     pageFormat: format,
    //     build: (context) {
    //       return pw.Column(
    //         children: [
    //           pw.SizedBox(
    //             width: double.infinity,
    //             child: pw.FittedBox(
    //               child: pw.Text(title, style: pw.TextStyle(font: font)),
    //             ),
    //           ),
    //           pw.SizedBox(height: 20),
    //           pw.Flexible(child: pw.FlutterLogo()),
    //         ],
    //       );
    //     },
    //   ),
    // );

    return pdf.save();
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
