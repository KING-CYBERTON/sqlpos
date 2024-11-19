

import 'package:get/get.dart';

import '../Datamodels/sale.dart';
import 'dbsevice.dart';

class SaleController extends GetxController {
  var isLoading = false.obs;
  var saleId = 0.obs;

  // Instance of DatabaseService
  final DatabaseService databaseService = DatabaseService();

  // Add sale function
  Future<void> addSale(Sale sale) async {
    try {
      isLoading(true); // Show loading indicator
      // Add the sale to the database
      var insertedId = await databaseService!.addSale(sale);
      saleId(insertedId); // Update the saleId with the inserted ID
      Get.snackbar('Success', 'Sale added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add sale: $e');
    } finally {
      isLoading(false); // Hide loading indicator
    }
  }
}
