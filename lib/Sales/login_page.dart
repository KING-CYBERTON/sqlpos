import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqlpos/Sales/CustomText.dart';

import '../Controllers/AuthController.dart';
import '../mysql.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // final _formKey = GlobalKey<FormState>();
  final GetAuth getAuth = Get.put(GetAuth());
  bool login = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? gender;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Center(
        child: Container(
          width: 500,
          height: 400,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.white, Colors.blue.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 10,
                offset: Offset(1, 1),
                color: Colors.purple,
              ),
            ],
            border: Border.all(
              color: Colors.teal,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(children: [
                const SizedBox(height: 20),
                Image.asset(
                    height: 80,
                    width: 500,
                    fit: BoxFit.fitWidth,
                    "assets/images/logo.png"),
                const SizedBox(height: 20),
                const Text(
                  'Login to your account',
                ),
                const SizedBox(height: 20),
                // ignore: prefer_const_constructors
                CustomText(
                  size: double.maxFinite,
                  hintText: 'Username',
                  textInputType: TextInputType.text,
                  isPass: false,
                  textController: emailController,
                ),
                const SizedBox(height: 20),
                // ignore: prefer_const_constructors
                CustomText(
                  size: double.maxFinite,
                  hintText: 'Enter your password',
                  textInputType: TextInputType.text,
                  isPass: true,
                  textController: passwordController,
                ),
                const SizedBox(height: 20),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                      onPressed: () async {
                        final dbHelper = MySQLHelper();

                        // Open the connection
                        await dbHelper.openConnection();

                        bool isUserFound = await dbHelper.fetchUser(
                            int.parse(emailController.text.trim()),
                            passwordController.text.trim());
                        if (isUserFound) {
                          print('User successfully fetched');
                        } else {
                          print('User not found');
                        }

                        dbHelper.authenticateUser(
                            int.parse(emailController.text.trim()),
                            passwordController.text.trim(),
                            context);

                        // ignore: avoid_print

                        print(getAuth.islogedin.value);
                      },
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                          backgroundColor: Colors.amberAccent),
                      child: const Text(
                        'Login',
                      )),
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
