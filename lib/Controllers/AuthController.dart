

import 'package:get/get.dart';

class GetAuth extends GetxController {
  static GetAuth instance = Get.find();

 // Rxn<User> fbUser = Rxn<User>();

  RxBool islogedin = true.obs;

  @override
  void onReady() {
    super.onReady();

 
  //  ever(fbUser, _initialScreen);
  }





}
