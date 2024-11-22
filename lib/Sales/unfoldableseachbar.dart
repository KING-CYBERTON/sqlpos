import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../constants/colors_n_styles_constants.dart';
import '../constants/text_styles_constants.dart';



class SearchBarUnfoldable extends StatelessWidget {
  final TextEditingController controller;
  const SearchBarUnfoldable({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        width: 200,
        height: 40, // New height adjustment
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(2),
            bottomLeft: Radius.circular(2),
            bottomRight: Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.08),
              offset: Offset(0, 8),
              blurRadius: 32,
            ),
          ],
          color: Color.fromRGBO(255, 255, 255, 1),
        ),
        child: TextFormField(
          controller: controller,
          style: TextStyles.getBodyTextStyle(context), // Consistent text style
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            focusedBorder: _border(Colors.white),
            enabledBorder:
                _border(AppColorsnStylesConstants.backgroundColorLight),
            border: _border(AppColorsnStylesConstants.backgroundColorLight),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 8, // Reduced vertical padding to adjust height
              horizontal: 12,
            ),
            hintText: 'Search for products or categories...',
            hintStyle: TextStyles.getBodyTextStyle(context).copyWith(
              color: const Color.fromRGBO(118, 134, 142, 1),
            ), // Consistent hint text style
            prefixIcon: const Icon(
              Icons.search,
              color: AppColorsnStylesConstants.primaryColorLight,
            ),
          ),
          textInputAction: TextInputAction.search,
          onFieldSubmitted: _onSearchSubmitted,
        ),
      ),
    );
  }

  void _onSearchSubmitted(String value) {
    print('User searched for: $value');
    // Implement search functionality here
  }

  OutlineInputBorder _border(Color borderColor) => OutlineInputBorder(
        borderSide: BorderSide(width: 1, color: borderColor),
        borderRadius: BorderRadius.circular(12),
      );
}
