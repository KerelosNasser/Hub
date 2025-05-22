import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final int maxLines;
  final String? Function(String?)? validator;
  final bool showCounter;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.maxLines = 1,
    this.validator,
    this.showCounter = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon, color: Colors.pink.shade800),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        fillColor: const Color(0xffedf3ff),
        counterText: showCounter ? null : '',
      ),
      style: const TextStyle(color: Colors.black),
    );
  }
}