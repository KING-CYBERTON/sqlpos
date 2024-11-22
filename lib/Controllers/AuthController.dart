import 'package:get/get.dart';

import '../Datamodels/employee.dart';

class GetAuth extends GetxController {
  static GetAuth instance = Get.find();

  // Rxn<User> fbUser = Rxn<User>();

  RxBool islogedin = true.obs;
  RxInt employee = 0.obs;
   RxString employee_name = ''.obs;

  @override
  void onReady() {
    super.onReady();

    //  ever(fbUser, _initialScreen);
  }
}
