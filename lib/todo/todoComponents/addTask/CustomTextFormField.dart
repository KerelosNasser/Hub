import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int? maxLines;
  final FormFieldValidator<String>? validator;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.label,
    this.maxLines,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    final screenWidth = MediaQuery.of(context).size.width;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.black,
          fontSize: screenWidth * 0.06, // Adjust font size based on screen width
        ),
        filled: true,
        fillColor: const Color(0xffedf3ff),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.08), // Adjust border radius
          borderSide: BorderSide(
            width: screenWidth * 0.01, // Adjust border width
            color: Colors.pink.shade800,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
          borderSide: BorderSide(
            width: screenWidth * 0.01,
            color: Colors.pink.shade800,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.1),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.1),
          borderSide: const BorderSide(
            width: 2,
            color: Colors.red,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03,
          vertical: screenWidth * 0.04,
        ), // Adjust padding
        hintText: 'Enter $label',
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: screenWidth * 0.05, // Adjust font size
        ),
        errorStyle: TextStyle(
          color: Colors.red,
          fontSize: screenWidth * 0.04, // Adjust font size
        ),
      ),
    );
  }
}
