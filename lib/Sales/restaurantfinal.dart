import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sqlpos/Controllers/AuthController.dart';
import 'package:sqlpos/Sales/CustomText.dart';
import 'package:sqlpos/Sales/login_page.dart';
import 'package:sqlpos/mysql.dart'; // Import your MySQL helper
import 'package:sqlpos/Datamodels/product.dart'; // Import your Product model
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// Updated Customer Model with observable items
class Order {
  final int id;
  final String name;
  final int table;
  final String phone;
  final RxList<OrderItem> items; // Made this RxList for reactivity
  final String status;
  final DateTime createdAt;
  bool expanded;

  Order({
    required this.id,
    required this.name,
    required this.table,
    required this.phone,
    List<OrderItem>? items, // Made optional to initialize as RxList
    required this.status,
    required this.createdAt,
    this.expanded = false,
  }) : items = RxList<OrderItem>(items ?? []); // Initialize as RxList
}

// Order Item Model (unchanged)
class OrderItem {
  final int id;
  final String name;
  final double price;
  final String category;
  final String emoji;
  int quantity;

  OrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.emoji,
    this.quantity = 1,
  });

  // Factory constructor to create OrderItem from Product
  factory OrderItem.fromProduct(Product product,
      {String? emoji, String? category}) {
    return OrderItem(
      id: product.productId!,
      name: product.name,
      price: product.price,
      category: category ?? _getCategoryFromId(product.categoryId),
      emoji: emoji ??
          _getEmojiFromCategory(
              category ?? _getCategoryFromId(product.categoryId)),
      quantity: 1,
    );
  }

  // Helper method to map category ID to category name
  static String _getCategoryFromId(int categoryId) {
    switch (categoryId) {
      case 1:
        return 'coffee';
      case 2:
        return 'food';
      case 3:
        return 'drinks';
      case 4:
        return 'alcohol';
      case 5:
        return 'desserts';
      default:
        return 'other';
    }
  }

  // Helper method to get emoji based on category
  static String _getEmojiFromCategory(String category) {
    switch (category.toLowerCase()) {
      case 'coffee':
        return '☕';
      case 'food':
        return '🍕';
      case 'drinks':
        return '🥤';
      case 'alcohol':
        return '🍺';
      case 'desserts':
        return '🍰';
      default:
        return '🍽️';
    }
  }
}

// Updated Restaurant Controller with Payment Integration
class RestaurantController extends GetxController {
  var customerTabs = <Order>[].obs;
  var activeCustomer = Rxn<Order>();
  var currentCategory = 'all'.obs;
  var customerId = 1.obs;
  var customerCounter = 1.obs;
  var searchQuery = ''.obs;
  var customerOrderIds = <int, int>{}.obs; // Maps customer ID to order ID
  var currentStatusFilter = Rxn<String>(); // Add status filter
  var isLoadingOrders = false.obs; // Add loading state for orders

  // Database-driven menu items
  var menuItems = <OrderItem>[].obs;
  var isLoadingMenu = false.obs;
  var updateTrigger = 0.obs;

  // Payment Controllers (copied from POS)
  final TextEditingController MpesanameController = TextEditingController();
  final TextEditingController MpesacodeController = TextEditingController();
  final TextEditingController MpesaAmountController = TextEditingController();
  final TextEditingController CashAmountController = TextEditingController();
  final GlobalKey<FormState> cashkey = GlobalKey();
  final GlobalKey<FormState> mpesakey = GlobalKey();

  late double cashReceived = 0.0;
  int saleid = 0;
  final now = DateTime.now();
  final formatter = DateFormat('dd-MM-yyyy HH:mm:ss');

  @override
  void onInit() {
    super.onInit();
    loadMenuFromDatabase();
    loadOrdersFromDatabase();
    // startAutoRefresh();
  }

  @override
  void onClose() {
    stopAutoRefresh();
    MpesacodeController.dispose();
    MpesaAmountController.dispose();
    MpesanameController.dispose();
    CashAmountController.dispose();
    super.onClose();
  }

  // Generate Transaction ID (copied from POS)
  int generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return timestamp % 1000000000;
  }

  // Generate Unique Item ID
  int generateUniqueItemId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    return timestamp % 1000000000 + random;
  }

  // Calculate Change (copied from POS)
  double calculateChange() {
    cashReceived = double.tryParse(CashAmountController.text.trim()) ?? 0.0;
    double totalAmount = getTotal();
    return (cashReceived - totalAmount).clamp(0.0, double.infinity);
  }

  // Force update method
  void _triggerUpdate() {
    updateTrigger.value++;
  }

// Updated loadOrdersFromDatabase method in RestaurantController
  Future<void> loadOrdersFromDatabase() async {
    try {
      isLoadingOrders.value = true;
      final dbHelper = MySQLHelper();

      // Fetch orders and items separately

      List<Map<String, dynamic>> allOrderItems =
          await dbHelper.fetchAllOrderItems();
      allOrderItems = await dbHelper.fetchAllOrderItems();
      // Fetch orders and items separately
      List<Map<String, dynamic>> ordersInfo =
          await dbHelper.fetchAllOrdersInfo();
      ordersInfo = await dbHelper.fetchAllOrdersInfo();
      // Group items by order_id for easy lookup
      Map<int, List<Map<String, dynamic>>> itemsByOrderId = {};
      for (var item in allOrderItems) {
        int orderId = item['order_id'];
        if (!itemsByOrderId.containsKey(orderId)) {
          itemsByOrderId[orderId] = [];
        }
        itemsByOrderId[orderId]!.add(item);
      }

      // Create Order objects
      List<Order> orders = [];
      for (var orderInfo in ordersInfo) {
        int orderId = orderInfo['id'];

        // Get items for this order
        List<OrderItem> orderItems = [];
        if (itemsByOrderId.containsKey(orderId)) {
          for (var itemData in itemsByOrderId[orderId]!) {
            OrderItem orderItem = OrderItem(
              id: itemData['product_id'] as int,
              name: itemData['product_name'] as String,
              price: itemData['price'] as double,
              category: itemData['category'] as String,
              emoji: itemData['emoji'] as String,
              quantity: itemData['quantity'] as int,
            );
            orderItems.add(orderItem);
          }
        }

        // Create Order object
        Order order = Order(
          id: orderId,
          name: orderInfo['customername'] as String,
          table: orderInfo['table_location'] as int,
          phone: orderInfo['phone'] as String,
          status: orderInfo['status'] as String,
          createdAt: orderInfo['created_at'] as DateTime,
          items: orderItems,
        );

        orders.add(order);
      }

      // Update customerTabs with database orders
      customerTabs.clear();
      customerTabs.addAll(orders);

      // Update customerOrderIds mapping
      customerOrderIds.clear();
      for (Order order in orders) {
        customerOrderIds[order.id] = order.table; // Use table as order ID
      }

      // Set the highest customer ID to avoid conflicts
      if (orders.isNotEmpty) {
        customerId.value =
            orders.map((o) => o.id).reduce((a, b) => a > b ? a : b) + 1;
      }

      print(
          'Loaded ${orders.length} orders from database with ${allOrderItems.length} total items');
    } catch (e) {
      print('Error loading orders from database: $e');
    } finally {
      isLoadingOrders.value = false;
    }
  }

  Future<void> refreshOrders() async {
    await loadOrdersFromDatabase();
    Get.snackbar("Refreshed", "Orders updated from database");
  }

  List<Order> get filteredCustomerTabs {
    if (currentStatusFilter.value == null) {
      return customerTabs.toList();
    }
    return customerTabs
        .where((c) => c.status == currentStatusFilter.value)
        .toList();
  }

  int getOrderCountByStatus(String status) {
    return customerTabs.where((c) => c.status == status).length;
  }

  // Load menu from database
  Future<void> loadMenuFromDatabase() async {
    try {
      isLoadingMenu.value = true;
      final dbHelper = MySQLHelper();
      await dbHelper.openConnection();
      List<Product> products = await dbHelper.fetchAllProducts();
      products = await dbHelper.fetchAllProducts();
      menuItems.clear();
      for (Product product in products) {
        OrderItem orderItem = OrderItem.fromProduct(product);
        menuItems.add(orderItem);
      }

      await dbHelper.closeConnection();
      print('Loaded ${menuItems.length} menu items from database');
    } catch (e) {
      print('Error loading menu from database: $e');
      _loadStaticMenu();
    } finally {
      isLoadingMenu.value = false;
    }
  }

  // ============================================
// ADD: Auto-refresh functionality (Optional)
// ============================================

// Add this to RestaurantController for periodic refresh
  Timer? _refreshTimer;

  void startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      loadOrdersFromDatabase();
    });
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
  }

  // Refresh menu from database
  Future<void> refreshMenu() async {
    await loadMenuFromDatabase();
  }

  void _loadStaticMenu() {
    menuItems.value = [
      OrderItem(
          id: 1, name: "Espresso", price: 3.50, category: "coffee", emoji: "☕"),
      OrderItem(
          id: 2,
          name: "Cappuccino",
          price: 4.25,
          category: "coffee",
          emoji: "☕"),
      OrderItem(
          id: 3, name: "Latte", price: 4.75, category: "coffee", emoji: "☕"),
      OrderItem(
          id: 6, name: "Sandwich", price: 8.99, category: "food", emoji: "🥪"),
      OrderItem(
          id: 7, name: "Burger", price: 12.99, category: "food", emoji: "🍔"),
      OrderItem(
          id: 11, name: "Coke", price: 2.99, category: "drinks", emoji: "🥤"),
      OrderItem(
          id: 15, name: "Beer", price: 5.99, category: "alcohol", emoji: "🍺"),
      OrderItem(
          id: 19,
          name: "Cake Slice",
          price: 6.99,
          category: "desserts",
          emoji: "🍰"),
    ];
  }

  List<OrderItem> get filteredMenuItems {
    return menuItems.where((item) {
      final matchesCategory = currentCategory.value == 'all' ||
          item.category == currentCategory.value;
      final matchesSearch =
          item.name.toLowerCase().contains(searchQuery.value.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // ============================================
// SIMPLE WAITER RECEIPT - Copy of Payment Receipt without payment sections
// Add this method to RestaurantController
// ============================================

// Generate waiter receipt for customer while awaiting payment
  Future<void> printWaiterReceipt(Order customer) async {
    if (customer.items.isEmpty) {
      Get.snackbar("Error", "No items to print on receipt!");
      return;
    }

    try {
      final printers = await Printing.listPrinters();
      if (printers.isNotEmpty) {
        final defaultPrinter = printers.firstWhere(
          (printer) => printer.isDefault == true,
          orElse: () => printers.first,
        );

        await Printing.directPrintPdf(
          printer: defaultPrinter,
          usePrinterSettings: true,
          onLayout: (format) => _generateWaiterReceiptPdf(format, customer),
        );

        Get.snackbar("Success", "Waiter receipt printed for ${customer.name}");
      } else {
        Get.snackbar("Error", "No printers found");
      }
    } catch (e) {
      print("Error printing waiter receipt: $e");
      Get.snackbar("Error", "Failed to print receipt");
    }
  }

// Generate PDF for waiter receipt (copied from payment receipt, removed payment sections)
  Future<Uint8List> _generateWaiterReceiptPdf(
      PdfPageFormat format, Order customer) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final now = DateTime.now();
    final formatter = DateFormat('dd-MM-yyyy HH:mm:ss');
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
                      pw.Text('CALIFONIA FRIES,PIZZA AND COFFEE',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.Text('For Orders Contact: 0768671314',
                          style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Divider(),
                pw.Text('ORDER#: ${customer.table}',
                    style: const pw.TextStyle(fontSize: 8)),
                pw.Text("Time: $formattedDate",
                    style: const pw.TextStyle(fontSize: 8)),

                pw.Text('Customer: ${customer.name}',
                    style: const pw.TextStyle(fontSize: 8)),
                pw.Divider(),
                pw.SizedBox(height: 4),

                // Header row
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 1.0),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                          flex: 1,
                          child: pw.Text('CODE',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.normal,
                                  fontSize: 8))),
                      pw.Expanded(
                          flex: 2,
                          child: pw.Text('DESCRIPTION',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.normal,
                                  fontSize: 8))),
                      pw.Expanded(
                          flex: 1,
                          child: pw.Text('PRICE',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.normal,
                                  fontSize: 8))),
                      pw.Expanded(
                          flex: 1,
                          child: pw.Text('QTY',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.normal,
                                  fontSize: 8))),
                      pw.Expanded(
                          flex: 1,
                          child: pw.Text('TOTAL',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.normal,
                                  fontSize: 8))),
                    ],
                  ),
                ),
                pw.Divider(),

                // Items
                ...customer.items.map(
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
                              pw.Text(item.id.toString(),
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.normal,
                                      fontSize: 8)),
                              pw.Text(item.name,
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.normal,
                                      fontSize: 8)),
                            ]),
                        pw.Column(children: [
                          pw.Row(children: [
                            pw.Text(item.quantity.toString(),
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.normal,
                                    fontSize: 8)),
                            pw.SizedBox(width: 4),
                            pw.Text('X',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.normal,
                                    fontSize: 8)),
                            pw.SizedBox(width: 4),
                            pw.Text(item.price.toStringAsFixed(2),
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.normal,
                                    fontSize: 8)),
                          ]),
                          pw.Text(
                              (item.price * item.quantity).toStringAsFixed(2),
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.normal,
                                  fontSize: 8)),
                        ])
                      ],
                    ),
                  ),
                ),

                pw.Divider(),
                // pw.Padding(
                //   padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
                //   child: pw.Row(
                //     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                //     children: [
                //       pw.Text('VAT',
                //           style: pw.TextStyle(
                //               fontWeight: pw.FontWeight.normal, fontSize: 8)),
                //       pw.Text(getTax().toStringAsFixed(2),
                //           style: pw.TextStyle(
                //               fontWeight: pw.FontWeight.normal, fontSize: 8)),
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
                      pw.Text(getTotal().toStringAsFixed(2),
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal, fontSize: 8)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 8),

                // ** REMOVED PAYMENT SECTIONS **
                // No cash received, change, or payment method details

                pw.SizedBox(height: 8),
                pw.Divider(),
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text('PLEASE PROCEED TO CASHIER',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal, fontSize: 8)),
                      pw.Divider(thickness: 1),
                      pw.Text(
                          'RestaurantPos Ver: 1.0.0.001   contact:0706709923',
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

    return pdf.save();
  }

  // // Filter customers by status
  // List<Order> get filteredCustomerTabs {
  //   if (currentStatusFilter.value == null) {
  //     return customerTabs.toList();
  //   }
  //   return customerTabs.where((c) => c.status == currentStatusFilter.value).toList();
  // }

  // Update createCustomer method
  void createCustomer({String? name, String? table, String? phone}) async {
    final customerName = name?.trim().isNotEmpty == true
        ? name!.trim()
        : 'Customer_${customerCounter.value.toString().padLeft(3, '0')}';

    int tableId = generateUniqueItemId();

    final customer = Order(
      id: customerId.value++,
      name: customerName,
      table: tableId,
      phone: phone?.trim().isNotEmpty == true ? phone! : 'No phone',
      items: [],
      status: 'new',
      createdAt: DateTime.now(),
    );

    // Create order in database using existing function
    final dbHelper = MySQLHelper();
    int? orderId = await dbHelper.createOrder(
        customerName, customer.table, customer.phone);

    if (orderId != null) {
      // Store mapping between customer ID and order ID
      customerOrderIds[customer.id] = orderId;
      print('Created database order $orderId for customer ${customer.id}');
    }

    customerTabs.add(customer);
    activeCustomer.value = customer;

    if (name?.trim().isEmpty == true || name == null) {
      customerCounter.value++;
    }
  }

  void selectCustomer(int customerId) {
    activeCustomer.value = customerTabs.firstWhere((c) => c.id == customerId);
  }

  void closeCustomerTab(int customerId) {
    customerTabs.removeWhere((c) => c.id == customerId);
    customerOrderIds.remove(customerId);
    if (activeCustomer.value?.id == customerId) {
      activeCustomer.value =
          customerTabs.isNotEmpty ? customerTabs.first : null;
    }
  }

  // Update addToOrder method
  void addToOrder(int itemId) async {
    if (activeCustomer.value == null) return;

    final menuItem = menuItems.firstWhere((item) => item.id == itemId);
    final existingItemIndex =
        activeCustomer.value!.items.indexWhere((item) => item.id == itemId);

    // Update local state
    if (existingItemIndex != -1) {
      activeCustomer.value!.items[existingItemIndex].quantity++;
    } else {
      activeCustomer.value!.items.add(OrderItem(
        id: menuItem.id,
        name: menuItem.name,
        price: menuItem.price,
        category: menuItem.category,
        emoji: menuItem.emoji,
        quantity: 1,
      ));
    }

    // Update database using existing addToCart function
    int tableLocation = activeCustomer.value!.table;
    final dbHelper = MySQLHelper();
    await dbHelper.addToCart(tableLocation, menuItem.id, menuItem.name,
        menuItem.price, menuItem.category, menuItem.emoji);

    customerTabs.refresh();
    _triggerUpdate();
  }

  // Update updateQuantity method
  void updateQuantity(int itemId, int change) async {
    if (activeCustomer.value == null) return;

    final itemIndex =
        activeCustomer.value!.items.indexWhere((item) => item.id == itemId);
    if (itemIndex != -1) {
      int newQuantity =
          activeCustomer.value!.items[itemIndex].quantity + change;

      if (newQuantity <= 0) {
        // Remove item from local state
        activeCustomer.value!.items.removeAt(itemIndex);

        // Remove from database using existing removeFromCart function
        int tableLocation = activeCustomer.value!.table;
        final dbHelper = MySQLHelper();
        await dbHelper.removeFromCart(tableLocation, itemId);
      } else {
        // Update local quantity
        activeCustomer.value!.items[itemIndex].quantity = newQuantity;

        // Update database based on change
        int tableLocation = activeCustomer.value!.table;
        final dbHelper = MySQLHelper();
        if (change > 0) {
          // Adding quantity - use existing addToCart function
          final item = activeCustomer.value!.items[itemIndex];
          await dbHelper.addToCart(tableLocation, item.id, item.name,
              item.price, item.category, item.emoji);
        } else {
          // Removing quantity - use existing removeFromCart function
          await dbHelper.removeFromCart(tableLocation, itemId);
        }
      }

      customerTabs.refresh();
      _triggerUpdate();
    }
  }

  // Update removeItemFromOrder method
  void removeItemFromOrder(int itemId) async {
    if (activeCustomer.value == null) return;

    // Remove from local state
    activeCustomer.value!.items.removeWhere((item) => item.id == itemId);

    // Remove from database using existing removeFromCart function
    int tableLocation = activeCustomer.value!.table;
    final dbHelper = MySQLHelper();
    await dbHelper.removeFromCart(tableLocation, itemId);

    customerTabs.refresh();
    _triggerUpdate();
  }

  // ============================================
  // STATUS UPDATE METHODS
  // ============================================

  // Main status update method
  void updateCustomerOrderStatus(int customerId, String newStatus) async {
    final customerIndex = customerTabs.indexWhere((c) => c.id == customerId);
    if (customerIndex == -1) {
      print('Customer with ID $customerId not found');
      return;
    }

    final customer = customerTabs[customerIndex];
    int tableLocation = customer.table;

    // Update database using table location
    final dbHelper = MySQLHelper();
    bool success = await dbHelper.updateOrderStatus(tableLocation, newStatus);

    if (success) {
      print(
          'Updated status to $newStatus for customer $customerId (Table: $tableLocation)');

      // Refresh orders from database to get updated state
      await loadOrdersFromDatabase();

      // Update active customer if it's the same one
      if (activeCustomer.value?.id == customerId) {
        activeCustomer.value =
            customerTabs.firstWhere((c) => c.id == customerId);
      }

      customerTabs.refresh();
      _triggerUpdate();
    } else {
      print('Failed to update status for customer $customerId');
    }
  }

  // Send order to kitchen
  void sendToKitchen() {
    if (activeCustomer.value == null || activeCustomer.value!.items.isEmpty) {
      Get.snackbar("Error", "No items to send to kitchen!");
      return;
    }

    updateCustomerOrderStatus(activeCustomer.value!.id, "kitchen");
    Get.snackbar(
        "Success", "Order sent to kitchen for ${activeCustomer.value!.name}!");
  }

  // Mark order as preparing
  void markOrderPreparing() {
    if (activeCustomer.value == null) return;

    updateCustomerOrderStatus(activeCustomer.value!.id, "preparing");
    Get.snackbar("Success",
        "Order marked as preparing for ${activeCustomer.value!.name}!");
  }

  // Mark order as ready
  void markOrderReady() {
    if (activeCustomer.value == null) return;

    updateCustomerOrderStatus(activeCustomer.value!.id, "ready");
    Get.snackbar(
        "Success", "Order marked as ready for ${activeCustomer.value!.name}!");
  }

  // Mark order as served
  void markOrderServed() {
    if (activeCustomer.value == null) return;

    updateCustomerOrderStatus(activeCustomer.value!.id, "served");
    Get.snackbar(
        "Success", "Order marked as served for ${activeCustomer.value!.name}!");
  }

  double getCustomerTotal(Order customer) {
    return customer.items
        .fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double getSubtotal() {
    if (activeCustomer.value == null) return 0.0;
    return getCustomerTotal(activeCustomer.value!);
  }

  // double getTax() {
  //   return getSubtotal() * 0.16; // 16% VAT like in POS
  // }

  double getTotal() {
    return getSubtotal();
  }

  void toggleCustomerExpanded(int customerId) {
    final customerIndex = customerTabs.indexWhere((c) => c.id == customerId);
    if (customerIndex != -1) {
      customerTabs[customerIndex].expanded =
          !customerTabs[customerIndex].expanded;
      customerTabs.refresh();
    }
  }

  // Updated Process Payment - Shows dialog to choose payment method
  void processPayment(BuildContext context) {
    if (activeCustomer.value == null || activeCustomer.value!.items.isEmpty)
      return;

    Get.defaultDialog(
      title: "Choose Payment Method",
      middleText:
          "Customer: ${activeCustomer.value!.name}\nTotal: \$${getTotal().toStringAsFixed(2)}",
      content: Column(
        children: [
          Text("Customer: ${activeCustomer.value!.name}"),
          Text("Total: \$${getTotal().toStringAsFixed(2)}"),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    showF12Dialog(context); // Cash payment
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27ae60),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('💵 Cash Payment\n(F12)'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    showF11Dialog(context); // Mpesa payment
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498db),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('📱 Mpesa Payment\n(F11)'),
                ),
              ),
            ],
          ),
        ],
      ),
      confirm: Container(),
      cancel: Container(),
    );
  }

  // Update showF12Dialog method (Cash Payment)
  void showF12Dialog(BuildContext context) {
    var changeAmount = 0.0.obs;

    void updateChange() {
      cashReceived = double.tryParse(CashAmountController.text.trim()) ?? 0.0;
      double totalAmount = getTotal();
      changeAmount.value =
          (cashReceived - totalAmount).clamp(0.0, double.infinity);
    }

    Get.dialog(
      AlertDialog(
        elevation: 2.0,
        title: const Text("Cash Payment"),
        content: SizedBox(
          height: 180,
          width: Get.width * 0.4,
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
                  onChanged: (value) => updateChange(),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Please enter the cash received.";
                    if (double.tryParse(value) == null)
                      return "Please enter a valid number.";
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text("Total Amount: \$${getTotal().toStringAsFixed(2)}",
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w400)),
                Obx(() => Text(
                    "Change: \$${changeAmount.value.toStringAsFixed(2)}",
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 24))),
              ],
            ),
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () async {
                if (cashkey.currentState!.validate()) {
                  double totalAmount = getTotal();
                  updateChange();

                  if (cashReceived < totalAmount) {
                    Get.snackbar("Error",
                        "Cash received is less than the total amount.");
                    return;
                  }

                  saleid = generateTransactionId();

                  try {
                    final dbHelper = MySQLHelper();
                    await dbHelper.openConnection();

                    // Prepare cart items for upload using existing format
                    List<Map<String, dynamic>> cartItemsForUpload = [];
                    for (OrderItem item in activeCustomer.value!.items) {
                      cartItemsForUpload.add({
                        'productId': item.id,
                        'productName': item.name,
                        'quantity': item.quantity,
                        'price': item.price,
                        'total': item.price * item.quantity,
                      });
                    }
                    // Update order status to completed using existing function
                    int tableLocation = activeCustomer.value!.table;
                    await dbHelper.updateOrderStatus(
                        tableLocation, "completed");

                    // Use existing insertSaleAndItems function
                    await dbHelper.insertSaleAndItems(
                      saleid,
                      totalAmount,
                      "CASH",
                      3, // Customer ID
                      4, // Employee ID
                      cartItemsForUpload,
                    );

                    await dbHelper.closeConnection();

                    Get.snackbar("Success", "Transaction posted successfully");

                    // Print receipt
                    final printers = await Printing.listPrinters();
                    if (printers.isNotEmpty) {
                      final defaultPrinter = printers
                          .firstWhere((printer) => printer.isDefault == true);
                      await Printing.directPrintPdf(
                        printer: defaultPrinter,
                        usePrinterSettings: true,
                        onLayout: (format) =>
                            _generatePdf(format, "Sale Receipt", "CASH"),
                      );
                    }
                  } catch (e) {
                    print("Error processing payment: $e");
                  } finally {
                    // Remove customer order mapping and close tab
                    customerOrderIds.remove(activeCustomer.value!.id);
                    closeCustomerTab(activeCustomer.value!.id);
                    CashAmountController.clear();
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Complete Sale'),
            ),
          ),
        ],
      ),
    );
  }

  // Update showF11Dialog method (Mpesa Payment)
  void showF11Dialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text("Lipa Na Mpesa"),
        content: SizedBox(
          height: 280,
          width: Get.width * 0.4,
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
                      if (value == null || value.isEmpty)
                        return 'Please enter the Mpesa Code';
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
                      if (value == null || value.isEmpty)
                        return 'Please enter the Mpesa Amount';
                      if (double.tryParse(value) == null)
                        return 'Please enter a valid amount';
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
                      if (value == null || value.isEmpty)
                        return 'Please enter the Mpesa Phone Number';
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
                  saleid = generateTransactionId();
                  double totalAmount = getTotal();
                  String paymentMethod = "MPESA";

                  try {
                    double mpesaAmount =
                        double.parse(MpesaAmountController.text.trim());

                    if (mpesaAmount != totalAmount) {
                      Get.snackbar(
                          "Error", "Mpesa Amount must match the Total Amount.");
                      return;
                    }

                    int mpesaNo = int.parse(MpesanameController.text.trim());

                    final dbHelper = MySQLHelper();
                    await dbHelper.openConnection();

                    // Prepare cart items for upload using existing format
                    List<Map<String, dynamic>> cartItemsForUpload = [];
                    for (OrderItem item in activeCustomer.value!.items) {
                      cartItemsForUpload.add({
                        'productId': item.id,
                        'productName': item.name,
                        'quantity': item.quantity,
                        'price': item.price,
                        'total': item.price * item.quantity,
                      });
                    }
                    // Update order status to completed using existing function
                    int tableLocation = activeCustomer.value!.table;
                    await dbHelper.updateOrderStatus(
                        tableLocation, "completed");

                    // Use existing insertSaleAndItemsmpesa function
                    await dbHelper.insertSaleAndItemsmpesa(
                      saleid,
                      totalAmount,
                      paymentMethod,
                      3,
                      4,
                      mpesaAmount,
                      mpesaNo,
                      MpesacodeController.text.trim(),
                      cartItemsForUpload,
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
                            _generatePdf(format, "Sale Receipt", paymentMethod),
                      );
                    }
                  } catch (e) {
                    print("Error processing payment: $e");
                  }

                  // Clear and close
                  MpesacodeController.clear();
                  MpesaAmountController.clear();
                  MpesanameController.clear();
                  customerOrderIds.remove(activeCustomer.value!.id);
                  closeCustomerTab(activeCustomer.value!.id);
                  Navigator.pop(context);
                }
              },
              child: const Text('Print Receipt'),
            ),
          ),
        ],
      ),
    );
  }

  // PDF Generation (copied and adapted from POS)
  Future<Uint8List> _generatePdf(
      PdfPageFormat format, String title, String paymentMethod) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
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
                      pw.Text('CALIFONIA FRIES,PIZZA AND COFFEE',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.Text('For Orders Contact: 0768671314',
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
                pw.Text('CUSTOMER: ${activeCustomer.value?.name ?? "Walk-in"}',
                    style: const pw.TextStyle(fontSize: 8)),
                pw.Text('TABLE: ${activeCustomer.value?.table ?? "N/A"}',
                    style: const pw.TextStyle(fontSize: 8)),
                pw.Divider(),
                pw.SizedBox(height: 4),

                // Header row
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 1.0),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                          flex: 1,
                          child: pw.Text('CODE',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.normal,
                                  fontSize: 8))),
                      pw.Expanded(
                          flex: 2,
                          child: pw.Text('DESCRIPTION',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.normal,
                                  fontSize: 8))),
                      pw.Expanded(
                          flex: 1,
                          child: pw.Text('PRICE',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.normal,
                                  fontSize: 8))),
                      pw.Expanded(
                          flex: 1,
                          child: pw.Text('QTY',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.normal,
                                  fontSize: 8))),
                      pw.Expanded(
                          flex: 1,
                          child: pw.Text('TOTAL',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.normal,
                                  fontSize: 8))),
                    ],
                  ),
                ),
                pw.Divider(),

                // Items
                ...activeCustomer.value!.items.map(
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
                              pw.Text(item.id.toString(),
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.normal,
                                      fontSize: 8)),
                              pw.Text(item.name,
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.normal,
                                      fontSize: 8)),
                            ]),
                        pw.Column(children: [
                          pw.Row(children: [
                            pw.Text(item.quantity.toString(),
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.normal,
                                    fontSize: 8)),
                            pw.SizedBox(width: 4),
                            pw.Text('X',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.normal,
                                    fontSize: 8)),
                            pw.SizedBox(width: 4),
                            pw.Text(item.price.toStringAsFixed(2),
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.normal,
                                    fontSize: 8)),
                          ]),
                          pw.Text(
                              (item.price * item.quantity).toStringAsFixed(2),
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
                      pw.Text(" $paymentMethod",
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
                //       pw.Text('VAT',
                //           style: pw.TextStyle(
                //               fontWeight: pw.FontWeight.normal, fontSize: 8)),
                //       pw.Text(getTax().toStringAsFixed(2),
                //           style: pw.TextStyle(
                //               fontWeight: pw.FontWeight.normal, fontSize: 8)),
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
                      pw.Text(getTotal().toStringAsFixed(2),
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal, fontSize: 8)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 8),

                if (paymentMethod == "CASH") ...[
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
                ],

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
                      pw.Divider(thickness: 1),
                      pw.Text(
                          'RestaurantPos Ver: 1.0.0.001   contact:0706709923',
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

    return pdf.save();
  }
}

// Main Restaurant POS Screen with Keyboard Integration
class RestaurantPosScreen extends StatefulWidget {
  const RestaurantPosScreen({super.key});

  @override
  State<RestaurantPosScreen> createState() => _RestaurantPosScreenState();
}

class _RestaurantPosScreenState extends State<RestaurantPosScreen> {
  final RestaurantController controller = Get.put(RestaurantController());
  final FocusNode _focusNode = FocusNode();
  String _message =
      "Press F1: Kitchen, F2: Preparing, F3: Ready, F4: Served, F11: Mpesa, F12: Cash...";

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // Keyboard Event Handler with Status Updates
  void _onKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      setState(() {
        _message = "Key pressed: ${event.logicalKey.debugName}";
      });

      // Check if there's an active customer with items
      if (controller.activeCustomer.value == null) {
        Get.snackbar("Error", "No active customer selected");
        return;
      }

      // Status update shortcuts
      if (event.logicalKey == LogicalKeyboardKey.f1) {
        // F1 - Send to Kitchen
        controller.sendToKitchen();
      } else if (event.logicalKey == LogicalKeyboardKey.f2) {
        // F2 - Mark as Preparing
        controller.markOrderPreparing();
      } else if (event.logicalKey == LogicalKeyboardKey.f3) {
        // F3 - Mark as Ready
        controller.markOrderReady();
      } else if (event.logicalKey == LogicalKeyboardKey.f4) {
        // F4 - Mark as Served
        controller.markOrderServed();
      }
      // Payment shortcuts
      else if (event.logicalKey == LogicalKeyboardKey.f11) {
        if (controller.activeCustomer.value!.items.isNotEmpty) {
          controller.showF11Dialog(context); // Mpesa payment
        } else {
          Get.snackbar("Error", "No items to process payment");
        }
      } else if (event.logicalKey == LogicalKeyboardKey.f12) {
        if (controller.activeCustomer.value!.items.isNotEmpty) {
          controller.showF12Dialog(context); // Cash payment
        } else {
          Get.snackbar("Error", "No items to process payment");
        }
      }
      // Other shortcuts
      else if (event.logicalKey == LogicalKeyboardKey.delete) {
        _onDeletePressed();
      } else if (event.logicalKey == LogicalKeyboardKey.f9) {
        _onF9Pressed();
      }
    }
  }

  // Delete key handler - Clear current customer's order
  void _onDeletePressed() {
    if (controller.activeCustomer.value != null) {
      controller.activeCustomer.value!.items.clear();
      controller._triggerUpdate();
      Get.snackbar("Cleared", "Current customer's order cleared");
    }
  }

  // F9 key handler - Close current customer tab
  void _onF9Pressed() {
    if (controller.activeCustomer.value != null) {
      controller.closeCustomerTab(controller.activeCustomer.value!.id);
      Get.snackbar("Closed", "Customer tab closed");
    }
  }

  final GetAuth getAuth = Get.put(GetAuth());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF667eea),
      body: KeyboardListener(
          focusNode: _focusNode,
          onKeyEvent: _onKey,
          child:  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Header with keyboard shortcuts info
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'FastServe Restaurant POS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _message,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Text(
                                  'F1: Kitchen | F2: Preparing | F3: Ready | F4: Served | F11: Mpesa | F12: Cash | F9: Close | Del: Clear',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Main content
                        Expanded(
                          child: Row(
                            children: [
                              // Left Panel - Customer Tabs
                              _buildLeftPanel(),
                              // Center Panel - Menu
                              _buildCenterPanel(),
                              // Right Panel - Current Order
                              _buildRightPanel(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ),
    );
  }

  Widget _buildLeftPanel() {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Waiter Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFe74c3c), Color(0xFFc0392b)],
              ),
            ),
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // CircleAvatar(
                    //   backgroundColor: Colors.white24,
                    //   child: Text('MK',
                    //       style: TextStyle(
                    //           color: Colors.white,
                    //           fontWeight: FontWeight.bold)),
                    // ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CALIFONIA FRIES,PIZZA AND COFFEE',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        // Text('Shift: 10:00 AM - 6:00 PM',
                        //     style:
                        //         TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Refresh Orders Button
                ElevatedButton(
                  onPressed: () => controller.refreshOrders(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  ),
                  child: Obx(() => controller.isLoadingOrders.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('🔄 Refresh Orders')),
                ),
              ],
            ),
          ),

          // Enhanced Status Filter Section with Counts
          Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const Text('Filter by Status:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                Obx(() => Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: [
                        _buildStatusFilterChip(
                            'All (${controller.customerTabs.length})', null),
                        _buildStatusFilterChip(
                            'New (${controller.getOrderCountByStatus('new')})',
                            'new'),
                        _buildStatusFilterChip(
                            'Kitchen (${controller.getOrderCountByStatus('kitchen')})',
                            'kitchen'),
                        _buildStatusFilterChip(
                            'Preparing (${controller.getOrderCountByStatus('preparing')})',
                            'preparing'),
                        _buildStatusFilterChip(
                            'Ready (${controller.getOrderCountByStatus('ready')})',
                            'ready'),
                        _buildStatusFilterChip(
                            'Served (${controller.getOrderCountByStatus('served')})',
                            'served'),
                        _buildStatusFilterChip(
                            'Completed (${controller.getOrderCountByStatus('completed')})',
                            'completed'),
                      ],
                    )),
              ],
            ),
          ),

          // Add Customer Button
          Padding(
            padding: const EdgeInsets.all(15),
            child: ElevatedButton(
              onPressed: () => _showCustomerModal(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27ae60),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('New Customer',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),

          // Customer Tabs (Database Orders)
          Expanded(
            child: Obx(() {
              if (controller.isLoadingOrders.value) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('Loading orders...'),
                    ],
                  ),
                );
              }

              final customers = controller.filteredCustomerTabs;

              if (customers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people, size: 40, color: Colors.grey),
                      const SizedBox(height: 10),
                      Text(controller.currentStatusFilter.value == null
                          ? 'No orders found'
                          : 'No ${controller.currentStatusFilter.value} orders'),
                      const Text(
                          'Click "New Customer" to start or refresh orders',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return _buildCustomerTab(customer);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

// ============================================
// UPDATED: Status Filter Chip with Enhanced Colors
// ============================================
  Widget _buildStatusFilterChip(String label, String? status) {
    return Obx(() {
      final isSelected = controller.currentStatusFilter.value == status;
      final chipColor =
          status != null ? _getStatusColor(status) : const Color(0xFF3498db);

      return FilterChip(
        label: Text(label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        selected: isSelected,
        onSelected: (selected) {
          controller.currentStatusFilter.value = selected ? status : null;
        },
        backgroundColor: Colors.grey[200],
        selectedColor: chipColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      );
    });
  }

  Widget _buildCustomerTab(Order customer) {
    return Obx(() {
      controller.updateTrigger.value;

      final total = controller.getCustomerTotal(customer);
      final timeAgo = DateTime.now().difference(customer.createdAt).inMinutes;
      final isActive = controller.activeCustomer.value?.id == customer.id;

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFebf8ff) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? const Color(0xFF3498db) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => controller.selectCustomer(customer.id),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                customer.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2c3e50)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(customer.status),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  customer.status.toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('\$${total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF27ae60))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () =>
                              controller.toggleCustomerExpanded(customer.id),
                          icon: const Icon(Icons.visibility, size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF3498db),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(24, 24),
                          ),
                        ),
                        const SizedBox(width: 5),
                        IconButton(
                          onPressed: () =>
                              controller.printWaiterReceipt(customer),
                          icon: const Icon(Icons.receipt, size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF27ae60),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(24, 24),
                          ),
                          tooltip: 'Print Waiter Receipt',
                        ),
                      ],
                    ),
                  ],
                ),
                if (customer.expanded) ...[
                  const SizedBox(height: 10),
                  const Divider(),

                  // Status control buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            controller.updateCustomerOrderStatus(
                                customer.id, "kitchen");
                            Get.snackbar("Updated", "Order sent to kitchen");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFf39c12),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                          child: const Text('👨‍🍳 Kitchen',
                              style: TextStyle(fontSize: 10)),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            controller.updateCustomerOrderStatus(
                                customer.id, "preparing");
                            Get.snackbar("Updated", "Order is being prepared");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9b59b6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                          child: const Text('🔥 Preparing',
                              style: TextStyle(fontSize: 10)),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            controller.updateCustomerOrderStatus(
                                customer.id, "ready");
                            Get.snackbar("Updated", "Order is ready");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF27ae60),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                          child: const Text('✅ Ready',
                              style: TextStyle(fontSize: 10)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            controller.updateCustomerOrderStatus(
                                customer.id, "served");
                            Get.snackbar("Updated", "Order marked as served");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2c3e50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                          child: const Text('🍽️ Served',
                              style: TextStyle(fontSize: 10)),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            controller.updateCustomerOrderStatus(
                                customer.id, "completed");
                            Get.snackbar("Updated", "Order completed");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF95a5a6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                          child: const Text('✔️ Complete',
                              style: TextStyle(fontSize: 10)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Obx(() {
                    final items = customer.items;

                    if (items.isEmpty) {
                      return const Text('No items yet',
                          style: TextStyle(color: Colors.grey, fontSize: 12));
                    }

                    return Column(
                      children: [
                        ...items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${item.emoji} ${item.name}',
                                      style: const TextStyle(fontSize: 12)),
                                  Text(
                                      '${item.quantity}x \$${(item.price * item.quantity).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF27ae60))),
                                ],
                              ),
                            )),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _quickCheckout(customer),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF27ae60),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                            ),
                            child: const Text('🖨️ Print Receipt & Checkout',
                                style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCenterPanel() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
        ),
        child: Column(
          children: [
            // Quick Actions
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2c3e50), Color(0xFF34495e)],
                ),
              ),
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () => controller.refreshMenu(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Obx(() => controller.isLoadingMenu.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('🔄 Refresh Menu')),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onChanged: (value) =>
                          controller.searchQuery.value = value,
                      decoration: InputDecoration(
                        hintText: 'Search menu items...',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.7)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Obx(() => _buildQuickBtn(
                      '📋 Active: ${controller.customerTabs.where((c) => c.items.isNotEmpty).length}')),
                ],
              ),
            ),

            // Category Tabs
            Container(
              color: const Color(0xFFf8f9fa),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Obx(() => Row(
                      children: [
                        _buildCategoryTab('All', 'all'),
                        _buildCategoryTab('☕ Coffee', 'coffee'),
                        _buildCategoryTab('🍕 Food', 'food'),
                        _buildCategoryTab('🥤 Drinks', 'drinks'),
                        _buildCategoryTab('🍺 Alcohol', 'alcohol'),
                        _buildCategoryTab('🍰 Desserts', 'desserts'),
                        _buildCategoryTab('🍽️ Other', 'other'),
                      ],
                    )),
              ),
            ),

            // Menu Grid with Loading State
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Obx(() {
                  if (controller.isLoadingMenu.value) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading menu from database...'),
                        ],
                      ),
                    );
                  }

                  final items = controller.filteredMenuItems;

                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.restaurant_menu,
                              size: 40, color: Colors.grey),
                          const SizedBox(height: 10),
                          const Text('No menu items found'),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => controller.refreshMenu(),
                            child: const Text('Refresh Menu'),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildMenuItem(item);
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightPanel() {
    return Container(
      width: 400,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2c3e50), Color(0xFF34495e)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(-3, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Order Header
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: const Text(
              'Current Order',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),

          // Order Content - Wrapped in Obx for reactivity
          Expanded(
            child: Obx(() {
              controller.updateTrigger.value;

              if (controller.activeCustomer.value == null) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.note_add, size: 40, color: Colors.white54),
                      SizedBox(height: 10),
                      Text('Select a customer first',
                          style: TextStyle(color: Colors.white54)),
                      Text('Create or select a customer tab to start ordering',
                          style:
                              TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // Customer Info
                  Container(
                    margin: const EdgeInsets.all(15),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              controller.activeCustomer.value!.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _formatTime(
                                  controller.activeCustomer.value!.createdAt),
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Table ${controller.activeCustomer.value!.table} • ${controller.activeCustomer.value!.phone}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 15),
                        // Updated action buttons with status controls
                        Row(
                          children: [
                            Expanded(
                                child: _buildActionButton('🔥 Preparing', () {
                              controller.markOrderPreparing();
                            })),
                            const SizedBox(width: 8),
                            Expanded(
                                child: _buildActionButton('✅ Ready', () {
                              controller.markOrderReady();
                            })),
                            const SizedBox(width: 8),
                            Expanded(
                                child: _buildActionButton('🍽️ Served', () {
                              controller.markOrderServed();
                            })),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Order Items
                  Expanded(
                    child: Obx(() {
                      final items = controller.activeCustomer.value?.items ??
                          <OrderItem>[];

                      if (items.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart,
                                  size: 40, color: Colors.white54),
                              SizedBox(height: 10),
                              Text('No items added',
                                  style: TextStyle(color: Colors.white54)),
                              Text('Select items from the menu',
                                  style: TextStyle(
                                      color: Colors.white38, fontSize: 12)),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _buildOrderItem(item);
                        },
                      );
                    }),
                  ),

                  // Order Summary with Status and Payment Buttons
                  Obx(() {
                    final items =
                        controller.activeCustomer.value?.items ?? <OrderItem>[];

                    if (items.isEmpty) return const SizedBox.shrink();

                    return Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        border: Border(
                            top: BorderSide(
                                color: Colors.white.withOpacity(0.1))),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal:',
                                  style: TextStyle(color: Colors.white)),
                              Text(
                                  '\$${controller.getSubtotal().toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     const Text('Tax (16%):',
                          //         style: TextStyle(color: Colors.white)),
                          //     Text(
                          //         '\$${controller.getTax().toStringAsFixed(2)}',
                          //         style: const TextStyle(color: Colors.white)),
                          //   ],
                          // ),
                          const SizedBox(height: 8),
                          const Divider(color: Colors.white24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total:',
                                  style: TextStyle(
                                      color: Color(0xFFf39c12),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  '\$${controller.getTotal().toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      color: Color(0xFFf39c12),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          // Updated Send to Kitchen button with status update
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    controller.sendToKitchen();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3498db),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  child: const Text('📤 Send to Kitchen'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      controller.processPayment(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF27ae60),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  child: const Text('💳 Process Payment'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Keyboard shortcuts reminder
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Quick Keys: F1 (Kitchen) | F2 (Preparing) | F3 (Ready) | F4 (Served) | F11 (Mpesa) | F12 (Cash)',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Widget _buildQuickBtn(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child:
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
    );
  }

  Widget _buildCategoryTab(String text, String category) {
    final isActive = controller.currentCategory.value == category;
    return GestureDetector(
      onTap: () => controller.currentCategory.value = category,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFF667eea) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? const Color(0xFF495057) : const Color(0xFF6c757d),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(OrderItem item) {
    return GestureDetector(
      onTap: () => controller.addToOrder(item.id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.transparent, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item.emoji,
              style: const TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 8),
            Text(
              item.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2c3e50),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '\$${item.price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFF27ae60),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.1),
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withOpacity(0.3)),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
                Text(
                  '\$${item.price.toStringAsFixed(2)} each',
                  style:
                      const TextStyle(color: Color(0xFFbdc3c7), fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => controller.updateQuantity(item.id, -1),
                icon: const Icon(Icons.remove, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(25, 25),
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
              ),
              Container(
                width: 25,
                alignment: Alignment.center,
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
              IconButton(
                onPressed: () => controller.updateQuantity(item.id, 1),
                icon: const Icon(Icons.add, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(25, 25),
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
              ),
              const SizedBox(width: 8),
              // Delete button
              IconButton(
                onPressed: () => controller.removeItemFromOrder(item.id),
                icon: const Icon(Icons.delete, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.2),
                  foregroundColor: Colors.red[300],
                  minimumSize: const Size(25, 25),
                  side: BorderSide(color: Colors.red.withOpacity(0.3)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Enhanced status color function with all statuses
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return const Color(0xFF27ae60); // Green
      case 'kitchen':
        return const Color(0xFFf39c12); // Orange
      case 'preparing':
        return const Color(0xFF9b59b6); // Purple
      case 'ready':
        return const Color(0xFF3498db); // Blue
      case 'served':
        return const Color(0xFF2c3e50); // Dark blue
      case 'completed':
        return const Color(0xFF95a5a6); // Gray
      case 'payment':
        return const Color(0xFFe74c3c); // Red
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inMinutes;

    if (diff < 1) return 'Just now';
    if (diff < 60) return '${diff}m ago';

    final hours = diff ~/ 60;
    if (hours < 24) return '${hours}h ago';

    return DateFormat('MM/dd').format(date);
  }

  void _showCustomerModal() {
    final nameController = TextEditingController();
    final tableController = TextEditingController();
    final phoneController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'New Customer',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50)),
              ),
              const SizedBox(height: 5),
              const Text(
                'Create a new customer tab',
                style: TextStyle(color: Color(0xFF7f8c8d)),
              ),
              const SizedBox(height: 20),

              // Customer Name Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer Name (Optional)',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Color(0xFF2c3e50)),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Auto-generated if empty',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Color(0xFFe9ecef), width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Color(0xFF667eea), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Table/Location Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Table/Location (Optional)',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Color(0xFF2c3e50)),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: tableController,
                    decoration: InputDecoration(
                      hintText: 'Auto-generated unique table ID',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Color(0xFFe9ecef), width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Color(0xFF667eea), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Phone Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Phone (Optional)',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Color(0xFF2c3e50)),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      hintText: '+1 (555) 123-4567',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Color(0xFFe9ecef), width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Color(0xFF667eea), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF95a5a6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.createCustomer(
                          name: nameController.text,
                          table: tableController.text,
                          phone: phoneController.text,
                        );
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27ae60),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Create Tab',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _quickCheckout(Order customer) {
    if (customer.items.isEmpty) {
      Get.snackbar("Error", "No items to checkout!");
      return;
    }

    // Set the customer as active first
    controller.selectCustomer(customer.id);

    // Update status to payment processing
    controller.updateCustomerOrderStatus(customer.id, "payment");

    // Then show payment method dialog
    controller.processPayment(context);
  }
}

// Usage Example for main.dart integration
class RestaurantPosApp extends StatelessWidget {
  const RestaurantPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FastServe Restaurant POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Segoe UI',
      ),
      home: const RestaurantPosScreen(),
    );
  }
}

// Extensions and additional utilities
extension StringExtensions on String {
  String padRight(int width, [String padding = ' ']) {
    if (length >= width) return this;
    return this + padding * (width - length);
  }
}

// Additional Menu Category Model for enhanced functionality
class MenuCategory {
  final String id;
  final String name;
  final String icon;
  final Color color;

  MenuCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

// Payment Method Model
class PaymentMethod {
  final String id;
  final String name;
  final String icon;
  final Color color;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

// Enhanced controller extensions for additional features
extension RestaurantControllerExtensions on RestaurantController {
  List<MenuCategory> get menuCategories => [
        MenuCategory(
            id: 'all', name: 'All', icon: '📋', color: const Color(0xFF667eea)),
        MenuCategory(
            id: 'coffee',
            name: 'Coffee',
            icon: '☕',
            color: const Color(0xFF8B4513)),
        MenuCategory(
            id: 'food',
            name: 'Food',
            icon: '🍕',
            color: const Color(0xFFFF6B35)),
        MenuCategory(
            id: 'drinks',
            name: 'Drinks',
            icon: '🥤',
            color: const Color(0xFF4ECDC4)),
        MenuCategory(
            id: 'alcohol',
            name: 'Alcohol',
            icon: '🍺',
            color: const Color(0xFFFFD93D)),
        MenuCategory(
            id: 'desserts',
            name: 'Desserts',
            icon: '🍰',
            color: const Color(0xFFFF69B4)),
      ];

  List<PaymentMethod> get paymentMethods => [
        PaymentMethod(
            id: 'cash',
            name: 'Cash',
            icon: '💵',
            color: const Color(0xFF27ae60)),
        PaymentMethod(
            id: 'mpesa',
            name: 'Mpesa',
            icon: '📱',
            color: const Color(0xFF3498db)),
      ];

  int get totalActiveOrders {
    return customerTabs.where((c) => c.items.isNotEmpty).length;
  }

  // Quick access methods for keyboard shortcuts
  void handleF1KeyPress() {
    if (activeCustomer.value != null &&
        activeCustomer.value!.items.isNotEmpty) {
      sendToKitchen();
    } else {
      Get.snackbar("Error", "No active customer or items to send to kitchen");
    }
  }

  void handleF2KeyPress() {
    if (activeCustomer.value != null) {
      markOrderPreparing();
    } else {
      Get.snackbar("Error", "No active customer selected");
    }
  }

  void handleF3KeyPress() {
    if (activeCustomer.value != null) {
      markOrderReady();
    } else {
      Get.snackbar("Error", "No active customer selected");
    }
  }

  void handleF4KeyPress() {
    if (activeCustomer.value != null) {
      markOrderServed();
    } else {
      Get.snackbar("Error", "No active customer selected");
    }
  }

  void handleF11KeyPress(BuildContext context) {
    if (activeCustomer.value != null &&
        activeCustomer.value!.items.isNotEmpty) {
      showF11Dialog(context);
    } else {
      Get.snackbar(
          "Error", "No active customer or items to process with Mpesa");
    }
  }

  void handleF12KeyPress(BuildContext context) {
    if (activeCustomer.value != null &&
        activeCustomer.value!.items.isNotEmpty) {
      showF12Dialog(context);
    } else {
      Get.snackbar("Error", "No active customer or items to process with Cash");
    }
  }

  void handleDeleteKeyPress() {
    if (activeCustomer.value != null) {
      activeCustomer.value!.items.clear();
      _triggerUpdate();
      Get.snackbar("Cleared", "Current customer's order cleared");
    }
  }

  void handleF9KeyPress() {
    if (activeCustomer.value != null) {
      closeCustomerTab(activeCustomer.value!.id);
      Get.snackbar("Closed", "Customer tab closed");
    }
  }
}
