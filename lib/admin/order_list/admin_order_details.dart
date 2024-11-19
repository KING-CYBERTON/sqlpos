import 'package:flutter/material.dart';

import '../../DataModels/ActualOrderModel.dart';
import '../../constants/colors_n_styles_constants.dart';
import '../../constants/sizes_constants.dart';
import '../../constants/text_styles_constants.dart';

class AdminOrderDetailsPage extends StatefulWidget {
  final OrderModel order;
  final VoidCallback onBack;

  const AdminOrderDetailsPage({
    super.key,
    required this.order,
    required this.onBack,
  });

  @override
  State<AdminOrderDetailsPage> createState() => _AdminOrderDetailsPageState();
}

class _AdminOrderDetailsPageState extends State<AdminOrderDetailsPage> {
  String? selectedStatus;
  Color? containerColor;
  final List items = [];

  final Map<String, Color> statusColors = {
    'Delivered': Colors.orange,
    'Processing': Colors.blue,
    'Completed': Colors.green,
    'Cancelled': Colors.red,
  };

  @override
  void initState() {
    super.initState();

    containerColor = statusColors[selectedStatus];
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: widget.onBack,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(
              Icons.arrow_back_ios,
              size: 20,
            ),
            const SizedBox(
              width: 5,
            ),
            Text('Back to Order List',
                style: TextStyles.getBodyTextStyle(context)
                    .copyWith(color: Colors.blue)),
          ],
        ),
      ),
      SizedBox(height: ResponsiveSizes.getSizedBoxHeight(context) * 2),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Orders ID: #${widget.order.orderId}',
            style: TextStyles.getTitleStyle(context),
          ),
          // Container(
          //   width: 150,
          //   height: 50,
          //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          //   decoration: BoxDecoration(
          //     color: containerColor,
          //     borderRadius: BorderRadius.circular(4),
          //   ),
          //   child: DropdownButton<String>(
          //     value: selectedStatus,
          //     items: statusColors.keys.map((String status) {
          //       return DropdownMenuItem<String>(
          //         value: status,
          //         child: Text(
          //           status,
          //           style: TextStyles.getBodyTextStyle(context).copyWith(
          //             color: Colors.white,
          //           ),
          //         ),
          //       );
          //     }).toList(),
          //     onChanged: (String? newStatus) {
          //       setState(() {
          //         selectedStatus = newStatus;
          //         containerColor = statusColors[newStatus];
          //       });
          //     },
          //     dropdownColor: Colors.grey,
          //     underline: const SizedBox.shrink(),
          //   ),
          // ),
        ],
      ),
      SizedBox(height: ResponsiveSizes.getSizedBoxHeight(context)),
      Row(
        children: [
          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text("${DateTime.now()}")
          // Text(
          //   '${DateFormat('MMM dd,yyyy').format(DateTime.parse(widget.order.orderDate))} - ${DateFormat('MMM dd,yyyy').format(DateTime.parse(widget.order['date']).add(const Duration(days: 4)))}',
          //   style: TextStyles.getBodyTextStyle(context),
          // ),
        ],
      ),
      SizedBox(height: ResponsiveSizes.getSizedBoxHeight(context)),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildInfoCard(
              context,
              Icons.person,
              'Customer',
              widget.order.orderId,
              widget.order.orderId,
              widget.order.orderId,
              'View profile',
            ),
          ),
          SizedBox(width: ResponsiveSizes.getPadding(context)),
          Expanded(
            child: _buildInfoCard(
              context,
              Icons.shopping_bag,
              'Order Info',
              'Shipping: Next express',
              'Payment Method: ${widget.order.paymentStatus}',
              'Status: "delivered',
              'Download info',
            ),
          ),
          SizedBox(width: ResponsiveSizes.getPadding(context)),
          Expanded(
            child: _buildInfoCard(
                context,
                Icons.location_on,
                'Deliver to',
                "100"
       "","",
                '',
                'View profile'),
          ),
        ],
      ),
      SizedBox(height: ResponsiveSizes.getSizedBoxHeight(context)),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildPaymentInfo(context)),
          const SizedBox(
            width: 10,
          ),
          Expanded(flex: 2, child: _buildNoteSection(context)),
        ],
      ),
      SizedBox(height: ResponsiveSizes.getSizedBoxHeight(context)),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text('Save',
                  style: TextStyles.getBodyTextStyle(context)
                      .copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
      SizedBox(height: ResponsiveSizes.getPadding(context) * 2),
      AdminOrderDetails(
      
      ),
    ]);
  }

  Widget _buildInfoCard(
    BuildContext context,
    IconData icon,
    String title,
    String line1,
    String line2,
    String line3,
    String buttonText,
  ) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveSizes.getPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: AppColorsnStylesConstants.primaryColorLight,
                    ),
                    const SizedBox(width: 8),
                    Text(title, style: TextStyles.getSubtitleStyle(context)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(line1, style: TextStyles.getBodyTextStyle(context)),
                if (line2.isNotEmpty)
                  Text(line2, style: TextStyles.getBodyTextStyle(context)),
                if (line3.isNotEmpty)
                  Text(line3, style: TextStyles.getBodyTextStyle(context)),
              ],
            ),
            ElevatedButton(
              onPressed: (){},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorsnStylesConstants.primaryColorLight,
              ),
              child: Text(buttonText,
                  style: TextStyles.getBodyTextStyle(context)
                      .copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveSizes.getPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment Info', style: TextStyles.getSubtitleStyle(context)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.credit_card, size: 24, color: Colors.green),
                const SizedBox(width: 8),
                Text('MPESA', style: TextStyles.getBodyTextStyle(context)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Business name: ${widget.order.orderId}',
                style: TextStyles.getBodyTextStyle(context)),
            Text('Phone: ${widget.order}',
                style: TextStyles.getBodyTextStyle(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteSection(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveSizes.getPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Note', style: TextStyles.getSubtitleStyle(context)),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Type some notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class $Datetime {}

// class Product {
//   final String name;
//   final String orderId;
//   final int quantity;
//   final double price;

//   Product(
//       {required this.name,
//       required this.orderId,
//       required this.quantity,
//       required this.price});

//   double get total => quantity * price;
// }

class AdminOrderDetails extends StatelessWidget {
  AdminOrderDetails({
    super.key,
  });
  final List items = [];

  double get subtotal => 5;

  double get tax => subtotal * 0.20;
  double get discount => 0;
  double get shippingRate => 0;
  double get total => subtotal + tax + shippingRate - discount;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Products',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Public Sans',
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(0.5),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
                5: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  children: [
                    const SizedBox.shrink(),
                    _buildTableHeader(
                      'Image',
                    ),
                    _buildTableHeader('Product Name'),
                    _buildTableHeader('Order ID'),
                    _buildTableHeader('Quantity'),
                    _buildTableHeader('Total', textAlign: TextAlign.right),
                  ],
                ),
                ...items.map((product) => TableRow(
                      children: [
                        Checkbox(value: false, onChanged: (_) {}),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [],
                          ),
                        ),
                        _buildTableCell(product.productName),
                        _buildTableCell(product.productId),
                        _buildTableCell(product.quantity.toString()),
                        _buildTableCell(
                            'KSh ${product.productPrice.toStringAsFixed(2)}',
                            textAlign: TextAlign.right),
                      ],
                    )),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(context, 'Subtotal', subtotal),
            _buildSummaryRow(context, 'Tax (20%)', tax),
            _buildSummaryRow(context, 'Discount', discount),
            _buildSummaryRow(context, 'Shipping Rate', shippingRate),
            const Divider(),
            _buildSummaryRow(context, 'Total', total, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text,
      {TextAlign textAlign = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        textAlign: textAlign,
      ),
    );
  }

  Widget _buildTableCell(String text, {TextAlign textAlign = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        textAlign: textAlign,
        style: const TextStyle(
          color: Colors.black,
          fontFamily: 'Public Sans',
          fontSize: 16,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, double value,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 250,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyles.getSubtitleStyle(context),
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(
                  'KSh ${value.toStringAsFixed(2)}',
                  style: TextStyles.getTitleStyle(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
