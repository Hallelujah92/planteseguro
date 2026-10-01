import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.placeholder,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String? placeholder;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}
