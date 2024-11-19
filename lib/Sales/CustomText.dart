import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final bool isPass;
  final String hintText;
  final TextInputType textInputType;
  final TextEditingController textController;
  final double size;
  final FormFieldValidator<String>? validator;

  const CustomText({
    super.key,
    required this.isPass,
    required this.hintText,
    required this.textInputType,
    required this.textController,
    required this.size,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final inputBorder =
        OutlineInputBorder(borderSide: Divider.createBorderSide(context));
    return SizedBox(
      width: size,

      child: TextFormField(
        
        controller: textController,
        validator: validator,
        decoration: InputDecoration(
            fillColor: Colors.white,
          hintText: hintText,
          border: inputBorder,
          focusedBorder: inputBorder,
          enabledBorder: inputBorder,
          filled: true,
          contentPadding: const EdgeInsets.all(8),
        ),
        keyboardType: textInputType,
        obscureText: isPass,
      ),
    );
  }
}
