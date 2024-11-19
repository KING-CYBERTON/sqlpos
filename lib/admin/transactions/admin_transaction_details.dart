// import 'package:flutter/material.dart';

// import '../../DataModels/mpesadetails.dart';
// import '../../Utils/constants/sizes_constants.dart';
// import '../../Utils/constants/text_styles_constants.dart';

// class AdminTransactionDetails extends StatefulWidget {
//   final MpesaTransaction transaction;
//   final VoidCallback onBack;

//   const AdminTransactionDetails(
//       {super.key, required this.transaction, required this.onBack});

//   @override
//   AdminTransactionDetailsState createState() => AdminTransactionDetailsState();
// }

// class AdminTransactionDetailsState extends State<AdminTransactionDetails> {
//   late MpesaTransaction _editableTransaction;

//   @override
//   void initState() {
//     super.initState();
//     _editableTransaction = widget.transaction;
//   }

//   Widget _buildEditableCard(
//       String title, List<MapEntry<String, dynamic>> fields) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         color: Colors.white,
//       ),
//       margin: EdgeInsets.all(ResponsiveSizes.getPadding(context)),
//       child: Padding(
//         padding: EdgeInsets.all(ResponsiveSizes.getPadding(context)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title, style: TextStyles.getTitleStyle(context)),
//             SizedBox(height: ResponsiveSizes.getSizedBoxHeight(context)),
//             ...fields
//                 .map((entry) => _buildEditableField(entry.key, entry.value)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEditableField(String label, dynamic value) {
//     return Padding(
//       padding: EdgeInsets.symmetric(
//           vertical: ResponsiveSizes.getPadding(context) / 2),
//       child: TextFormField(
//         initialValue: value.toString(),
//         decoration: InputDecoration(
//           labelText: label,
//           border: const OutlineInputBorder(),
//         ),
//         onChanged: (newValue) {
//           setState(() {
//             label = newValue;
//           });
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: widget.onBack,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               const Icon(
//                 Icons.arrow_back_ios,
//                 size: 20,
//               ),
//               const SizedBox(
//                 width: 5,
//               ),
//               Text('Back to Transction list List',
//                   style: TextStyles.getBodyTextStyle(context)
//                       .copyWith(color: Colors.blue)),
//             ],
//           ),
//         ),
//         SizedBox(width: ResponsiveSizes.getPadding(context) * 3),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Text(
//               'Transaction Details for ID: ${_editableTransaction.orderId}',
//               style: TextStyles.getTitleStyle(context),
//             ),
//           ],
//         ),
//         SizedBox(width: ResponsiveSizes.getPadding(context) * 3),
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: _buildEditableCard('Transaction Information', [
//                 MapEntry('Order ID', _editableTransaction.orderId),
//                 MapEntry('Date', _editableTransaction.time),
//                 MapEntry('Status', _editableTransaction.paymentStatus),
//               ]),
//             ),
//             const SizedBox(
//               width: 10,
//             ),
//             Expanded(
//               child: _buildEditableCard('Customer Information', [
//                 MapEntry('Name', _editableTransaction.paymentStatus),
//                 MapEntry('Phone', _editableTransaction.phonenumber),
//               ]),
//             ),
//           ],
//         ),
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: _buildEditableCard('Payment Information', [
//                 MapEntry('Amount', _editableTransaction.amount),
//                 MapEntry('Payment Type', _editableTransaction.paymentMethod),
//                 MapEntry('ERPT No.', _editableTransaction.mpesaTrnNo),
//               ]),
//             ),
//             const SizedBox(
//               width: 10,
//             ),
//             Expanded(
//               child: _buildEditableCard('Additional Information', [
//                 MapEntry('Till', _editableTransaction.CheckoutRequestID),
//                 MapEntry('User Name', _editableTransaction.name),
//               ]),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
