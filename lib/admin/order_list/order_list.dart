import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../DataModels/ActualOrderModel.dart';
import '../../constants/sizes_constants.dart';
import '../../constants/text_styles_constants.dart';
import 'admin_order_details.dart';

class OrderList extends StatefulWidget {
  const OrderList({super.key});

  @override
  OrderListState createState() => OrderListState();
}

class OrderListState extends State<OrderList> {
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  OrderModel? _selectedOrder;

  List<OrderModel> get _filteredAndPaginatedData {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return orderList.sublist(
        startIndex, endIndex > orderList.length ? orderList.length : endIndex);
  }

  // void _toggleSelectAll(bool? value) {
  //   setState(() {
  //     _selectAll = value ?? false;
  //     for (var order in orderList) {
  //  _selectAll = _selectAll;
  //     }
  //   });
  // }

  // void _toggleSelection(int index, bool? value) {
  //   setState(() {
  //     orderList[index]. = value ?? false;
  //     _selectAll = orderList.every((order) => order['selected']);
  //   });
  // }

  void _showDropdownMenu(BuildContext context) {
    final selectedItems = [12, 1, 3];
    // orderList.where((order) => order.shippingStatus).toList();
    if (selectedItems.isNotEmpty) {
      showMenu(
        context: context,
        position: const RelativeRect.fromLTRB(100, 100, 0, 0),
        items: [
          PopupMenuItem(
            child: Text('Not Started',
                style: TextStyles.getBodyTextStyle(context)),
            onTap: () {},
          ),
          PopupMenuItem(
            child:
                Text('Procesing', style: TextStyles.getBodyTextStyle(context)),
            onTap: () {
              // Implement action for selected items
            },
          ),
          PopupMenuItem(
            child:
                Text('In Transit', style: TextStyles.getBodyTextStyle(context)),
            onTap: () {
              // Implement action for selected items
            },
          ),
          PopupMenuItem(
            child: Text('Shipped', style: TextStyles.getBodyTextStyle(context)),
            onTap: () {
              // Implement action for selected items
            },
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const OrderLisDateRangePickerPopup(),
            SizedBox(height: ResponsiveSizes.getSizedBoxHeight(context)),
            if (_selectedOrder == null)
              _buildOrderTable()
            else
              AdminOrderDetailsPage(
                order: _selectedOrder!,
                onBack: () => setState(() => _selectedOrder = null),
              ),
            SizedBox(height: ResponsiveSizes.getSizedBoxHeight(context)),
            if (_selectedOrder == null) _buildPagination(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTable() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(ResponsiveSizes.getPadding(context)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Order List", style: TextStyles.getTitleStyle(context)),
                IconButton(
                  icon: const Icon(Icons.filter_2_rounded),
                  onPressed: () => _showDropdownMenu(context),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                // DataColumn(
                //   label: Checkbox(
                //     activeColor: AppColorsnStylesConstants.primaryColorLight,
                //     value: _selectAll,
                //     onChanged: _toggleSelectAll,
                //   ),
                // ),
                DataColumn(
                    label: Text('Order ID',
                        style: TextStyles.getSubtitleStyle(context))),
                DataColumn(
                    label: Text('Payment ID',
                        style: TextStyles.getSubtitleStyle(context))),
                DataColumn(
                    label: Text('Date',
                        style: TextStyles.getSubtitleStyle(context))),
                DataColumn(
                    label: Text('Total',
                        style: TextStyles.getSubtitleStyle(context))),
            

                DataColumn(
                    label: Text('Actions',
                        style: TextStyles.getSubtitleStyle(context))),
              ],
              rows: _filteredAndPaginatedData.map((order) {
                return DataRow(
                  cells: [
                    // DataCell(
                    //   Checkbox(
                    //     activeColor:
                    //         AppColorsnStylesConstants.primaryColorLight,
                    //     value: _selectedOrder,
                    //     onChanged: (value) =>
                    //         _toggleSelection(orderList.indexOf(order), value),
                    //   ),
                    // ),
                    DataCell(Text(order.orderId,
                        style: TextStyles.getBodyTextStyle(context))),
                    DataCell(Text(order.paymentId,
                        style: TextStyles.getBodyTextStyle(context))),
                    DataCell(Text(order.orderDate.toString(),
                        style: TextStyles.getBodyTextStyle(context))),
                    DataCell(Text('KSh${order.totalPrice.toStringAsFixed(2)}',
                        style: TextStyles.getBodyTextStyle(context))),
     

                    DataCell(
                      GestureDetector(
                        onTap: () {
                          setState(() => _selectedOrder = order);
                        },
                        child: Text('View Order >>',
                            style: TextStyles.getBodyTextStyle(context)
                                .copyWith(color: Colors.blue)),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    final int totalPages = (orderList.length / _itemsPerPage).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed:
              _currentPage > 1 ? () => setState(() => _currentPage--) : null,
        ),
        for (int i = 1; i <= totalPages; i++)
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: ResponsiveSizes.getPadding(context)),
            child: ElevatedButton(
              onPressed: () => setState(() => _currentPage = i),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _currentPage == i ? Colors.blue : Colors.grey[200],
              ),
              child: Text(
                i.toString(),
                style: TextStyles.getBodyTextStyle(context).copyWith(
                  color: _currentPage == i ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _currentPage < totalPages
              ? () => setState(() => _currentPage++)
              : null,
        ),
      ],
    );
  }
}

class OrderLisDateRangePickerPopup extends StatefulWidget {
  const OrderLisDateRangePickerPopup({super.key});

  @override
  OrderLisDateRangePickerPopupState createState() =>
      OrderLisDateRangePickerPopupState();
}

class OrderLisDateRangePickerPopupState
    extends State<OrderLisDateRangePickerPopup> {
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    _setDefaultDateRangeToThisWeek();
  }

  void _setDefaultDateRangeToThisWeek() {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));
    selectedDateRange =
        DateTimeRange(start: firstDayOfWeek, end: lastDayOfWeek);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order List',
              style: TextStyles.getTitleStyle(context),
            ),
            const SizedBox(height: 5),
            Text(
              'Home > Order List',
              style: TextStyles.getSubtitleStyle(context)
                  .copyWith(color: Colors.grey),
            ),
          ],
        ),
        const Spacer(),
        OutlinedButton(
          onPressed: () async {
            final DateTimeRange? picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              initialDateRange: selectedDateRange,
              builder: (BuildContext context, Widget? child) {
                return Center(
                  child: SizedBox(
                    width: ResponsiveBreakpoints.of(context).largerThan(DESKTOP)
                        ? 400
                        : 300, // Responsive width
                    height:
                        ResponsiveBreakpoints.of(context).largerThan(DESKTOP)
                            ? 500
                            : 350, // Responsive height
                    child: child,
                  ),
                );
              },
            );
            if (picked != null) {
              setState(() {
                selectedDateRange = picked;
              });
            }
          },
          child: Wrap(
            children: [
              Text(
                '${dateFormat.format(selectedDateRange!.start)} - ${dateFormat.format(selectedDateRange!.end)}',
                style: TextStyles.getSubtitleStyle(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
