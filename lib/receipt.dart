import 'package:flutter/material.dart';

class ReceiptPage extends StatelessWidget {
  const ReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          width: 300,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Column(
                  children: [
                    Text('SHOP RECEIPT',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('SUPERMARKET 123'),
                    Text('PLANET EARTH'),
                    Text('Tel: +123-456-7890'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              const Text('RECEIPT #: 12345'),
              const Text('DATE: 12/12/2023'),
              const Text('CASHIER: JOHN DOE'),
              const Divider(),
              const SizedBox(height: 10),
              _buildItemRow('Lorem wheat', '€1.50'),
              _buildItemRow('Ipsum apple', '€3.75'),
              _buildItemRow('Dolor banana', '€7.30'),
              _buildItemRow('Sit meat', '€9.50'),
              _buildItemRow('Amet candy', '€0.80'),
              _buildItemRow('Consectetur coffe', '€1.20'),
              const Divider(),
              _buildItemRow('TAXABLE', '€20.45'),
              _buildItemRow('VAT 15%', '€3.60'),
              _buildItemRow('TOTAL', '€24.05', isBold: true),
              const SizedBox(height: 10),
              _buildItemRow('CASH', '€25.00'),
              _buildItemRow('CHANGE', '€0.95'),
              const SizedBox(height: 10),
              const Text('Paid with CASH'),
              const Divider(),
              const Center(
                child: Column(
                  children: [
                    Text('THANK YOU',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('HAVE A NICE DAY'),
                  ],
                ),
              ),
            ],
          ),
        ),
      
    );
  }

  Widget _buildItemRow(String item, String price, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(item,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(price,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}


