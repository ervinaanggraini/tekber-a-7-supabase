import 'package:flutter/material.dart';
// import 'package:flutter_application/core/constants/spacings.dart';

class BaseTextField extends StatelessWidget {
  const BaseTextField({
    super.key,
    required this.labelText,
    required this.onChanged,
    required this.textInputAction,
    required this.keyboardType,
    this.helperText,
    this.errorText,
    this.obscureText = false,
  });

  final Function(String) onChanged;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final String labelText;
  final String? errorText;
  final String? helperText;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        helperText: helperText,
        errorText: errorText,
      ),
    );
  }
}
