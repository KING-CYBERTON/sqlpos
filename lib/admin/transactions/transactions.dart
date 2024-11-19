// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:responsive_framework/responsive_framework.dart';
// import 'admin_transaction_details.dart';

// class Transactions extends StatefulWidget {
//   const Transactions({super.key});

//   @override
//   TransactionsState createState() => TransactionsState();
// }

// class TransactionsState extends State<Transactions> {
//   int _currentPage = 1;
//   final int _itemsPerPage = 10;
//   bool isViewTransactonDetail = false;
//   MpesaTransaction? selectedTransaction;
//   final OrderController orderController = Get.put(OrderController());

//   List<MpesaTransaction> get _filteredAndPaginatedData {
//     final filteredData = orderController.MpesaTransactions;
//     final startIndex = (_currentPage - 1) * _itemsPerPage;
//     final endIndex = startIndex + _itemsPerPage;
//     return filteredData.sublist(startIndex,
//         endIndex > filteredData.length ? filteredData.length : endIndex);
//   }

//   // void _toggleSelection(int index, bool? value) {
//   //   setState(() {
//   //     Mpesatransactions[index]['selected'] = value ?? false;

//   //     // Update selectedTransaction
//   //     selectedTransaction = value == true ? Mpesatransactions[index] : null;
//   //   });
//   // }

//   // void _showDropdownMenu(BuildContext context) {
//   //   final selectedItems =
//   //       Mpesatransactions.where((Mtransaction) => Mtransaction.paymentStatus == "").toList();
//   //   if (selectedItems.isNotEmpty) {
//   //     showMenu(
//   //       context: context,
//   //       position: const RelativeRect.fromLTRB(100, 100, 0, 0),
//   //       items: [
//   //         PopupMenuItem(
//   //           child: const Text('Delete Selected'),
//   //           onTap: () {
//   //             setState(() {
//   //               transactionData.removeWhere((order) => order['selected']);
//   //             });
//   //           },
//   //         ),
//   //         PopupMenuItem(
//   //           child: const Text('View Transaction'),
//   //           onTap: () {
//   //             if (selectedItems.length == 1) {
//   //               setState(() {
//   //                 selectedTransaction = selectedItems.first;
//   //                 isViewTransactonDetail = true;
//   //               });
//   //             } else {
//   //               ScaffoldMessenger.of(context).showSnackBar(
//   //                 const SnackBar(
//   //                   content: Text('Please select only one transaction'),
//   //                 ),
//   //               );
//   //             }
//   //           },
//   //         ),
//   //       ],
//   //     );
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.all(ResponsiveSizes.getPadding(context)),
//       child: _buildContent(),
//     );
//   }

//   Widget _buildContent() {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           const TransactionDateRangePickerPopup(),
//           SizedBox(height: ResponsiveSizes.getSizedBoxHeight(context)),
//           isViewTransactonDetail == false
//               ? Column(
//                   children: [
//                     _buildOrderTable(),
//                     SizedBox(
//                         height: ResponsiveSizes.getSizedBoxHeight(context)),
//                     _buildPagination(),
//                   ],
//                 )
//               : selectedTransaction != null
//                   ? AdminTransactionDetails(
//                       transaction: selectedTransaction!,
//                       onBack: () =>
//                           setState(() => isViewTransactonDetail = false),
//                     )
//                   : const Center(child: Text('No transaction selected')),
//         ],
//       ),
//     );
//   }

//   Widget _buildOrderTable() {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         color: Colors.white,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: EdgeInsets.all(ResponsiveSizes.getPadding(context)),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "Transactions",
//                   style: TextStyles.getTitleStyle(context),
//                 ),
//                 IconButton(
//                     icon: const Icon(Icons.more_vert),
//                     onPressed: () => () {} //_showDropdownMenu(context),
//                     ),
//               ],
//             ),
//           ),
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: DataTable(
//               columns: [
//                 DataColumn(
//                     label: Text('PayType',
//                         style: TextStyles.getSubtitleStyle(context))),
//                 DataColumn(
//                     label: Text('Last Update',
//                         style: TextStyles.getSubtitleStyle(context))),
//                 DataColumn(
//                     label: Text('Trn No',
//                         style: TextStyles.getSubtitleStyle(context))),
//                 DataColumn(
//                     label: Text('Trn Cell',
//                         style: TextStyles.getSubtitleStyle(context))),
//                 DataColumn(
//                     label: Text('Trn Name',
//                         style: TextStyles.getSubtitleStyle(context))),
//                 DataColumn(
//                     label: Text('Trn Amt',
//                         style: TextStyles.getSubtitleStyle(context))),
//                 DataColumn(
//                     label: Text('Trn Time',
//                         style: TextStyles.getSubtitleStyle(context))),
//                 DataColumn(
//                     label: Text('ERPT No.',
//                         style: TextStyles.getSubtitleStyle(context))),
//                 DataColumn(
//                     label: Text('Till',
//                         style: TextStyles.getSubtitleStyle(context))),
//                 DataColumn(
//                     label: Text('User Name',
//                         style: TextStyles.getSubtitleStyle(context))),
//                 DataColumn(
//                     label: Text('Status',
//                         style: TextStyles.getSubtitleStyle(context))),
//               ],
//               rows: _filteredAndPaginatedData.map((transaction) {
//                 bool isDelivered = Random().nextBool();
//                 return DataRow(
//                   color: WidgetStateProperty.all(Colors.white),
//                   // selected: transaction['selected'] ?? false,
//                   onSelectChanged: (selected) {
//                     //  _toggleSelection(
//                     //   transactionData.indexOf(transaction), selected);
//                   },
//                   cells: [
//                     DataCell(Text('MPESA',
//                         style: TextStyles.getBodyTextStyle(context))),
//                     DataCell(Text(transaction.time.toString(),
//                         style: TextStyles.getBodyTextStyle(context))),
//                     DataCell(Text(transaction.orderId,
//                         style: TextStyles.getBodyTextStyle(context))),
//                     DataCell(Text('2547${Random().nextInt(999999999)}',
//                         style: TextStyles.getBodyTextStyle(context))),
//                     DataCell(Text(transaction.name,
//                         style: TextStyles.getBodyTextStyle(context))),
//                     DataCell(Text('KSh${transaction.amount.toStringAsFixed(2)}',
//                         style: TextStyles.getBodyTextStyle(context))),
//                     DataCell(Text(transaction.phonenumber,
//                         style: TextStyles.getBodyTextStyle(context))),
//                     DataCell(Text(transaction.mpesaTrnNo,
//                         style: TextStyles.getBodyTextStyle(context))),
//                     DataCell(Text('${Random().nextInt(4) + 1}',
//                         style: TextStyles.getBodyTextStyle(context))),
//                     DataCell(Text(transaction.paymentStatus,
//                         style: TextStyles.getBodyTextStyle(context))),
//                     DataCell(
//                       Row(
//                         children: [
//                           Container(
//                             width: 10,
//                             height: 10,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: isDelivered ? Colors.green : Colors.red,
//                             ),
//                           ),
//                           SizedBox(width: ResponsiveSizes.getPadding(context)),
//                           Text(isDelivered ? 'Delivered' : 'Cancelled',
//                               style: TextStyles.getBodyTextStyle(context)),
//                         ],
//                       ),
//                     ),
//                   ],
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPagination() {
//     final int totalPages = (Mpesatransactions.length / _itemsPerPage).ceil();

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         IconButton(
//           icon: const Icon(Icons.chevron_left),
//           onPressed:
//               _currentPage > 1 ? () => setState(() => _currentPage--) : null,
//         ),
//         for (int i = 1; i <= totalPages; i++)
//           Padding(
//             padding: EdgeInsets.symmetric(
//                 horizontal: ResponsiveSizes.getPadding(context) / 2),
//             child: ElevatedButton(
//               onPressed: () => setState(() => _currentPage = i),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor:
//                     _currentPage == i ? Colors.blue : Colors.grey[200],
//               ),
//               child: Text(
//                 i.toString(),
//                 style: TextStyles.getBodyTextStyle(context).copyWith(
//                     color: _currentPage == i ? Colors.white : Colors.black),
//               ),
//             ),
//           ),
//         IconButton(
//           icon: const Icon(Icons.chevron_right),
//           onPressed: _currentPage < totalPages
//               ? () => setState(() => _currentPage++)
//               : null,
//         ),
//       ],
//     );
//   }
// }

// class TransactionDateRangePickerPopup extends StatefulWidget {
//   const TransactionDateRangePickerPopup({super.key});

//   @override
//   TransactionDateRangePickerPopupState createState() =>
//       TransactionDateRangePickerPopupState();
// }

// class TransactionDateRangePickerPopupState
//     extends State<TransactionDateRangePickerPopup> {
//   DateTimeRange? selectedDateRange;

//   @override
//   void initState() {
//     super.initState();
//     _setDefaultDateRangeToThisWeek();
//   }

//   void _setDefaultDateRangeToThisWeek() {
//     final now = DateTime.now();
//     final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
//     final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));
//     selectedDateRange =
//         DateTimeRange(start: firstDayOfWeek, end: lastDayOfWeek);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dateFormat = DateFormat('dd/MM/yyyy');

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Order List', style: TextStyles.getTitleStyle(context)),
//             const SizedBox(height: 5),
//             Text('Home > Order List',
//                 style: TextStyles.getSubtitleStyle(context)
//                     .copyWith(color: Colors.grey)),
//           ],
//         ),
//         const Spacer(),
//         OutlinedButton(
//           onPressed: () async {
//             final DateTimeRange? picked = await showDateRangePicker(
//               context: context,
//               firstDate: DateTime(2000),
//               lastDate: DateTime(2100),
//               initialDateRange: selectedDateRange,
//               builder: (BuildContext context, Widget? child) {
//                 return Center(
//                   child: SizedBox(
//                     width: ResponsiveBreakpoints.of(context).largerThan(DESKTOP)
//                         ? 400
//                         : 300, // Responsive width
//                     height:
//                         ResponsiveBreakpoints.of(context).largerThan(DESKTOP)
//                             ? 500
//                             : 350, // Responsive height
//                     child: child,
//                   ),
//                 );
//               },
//             );
//             if (picked != null) {
//               setState(() {
//                 selectedDateRange = picked;
//               });
//             }
//           },
//           child: Wrap(
//             children: [
//               Text(
//                 '${dateFormat.format(selectedDateRange!.start)} - ${dateFormat.format(selectedDateRange!.end)}',
//                 style: TextStyles.getSubtitleStyle(context),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
