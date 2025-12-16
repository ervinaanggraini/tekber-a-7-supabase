import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GlobalTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final TextInputType keyboardType;
  final bool enabled; // properti baru opsional

  const GlobalTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.enabled = true, // default enabled true
  });

  @override
  State<GlobalTextField> createState() => _GlobalTextFieldState();
}

class _GlobalTextFieldState extends State<GlobalTextField> {
  bool obscure = true;

  @override
  void initState() {
    super.initState();
    obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: Colors.white,
      controller: widget.controller,
      obscureText: widget.isPassword ? obscure : false,
      keyboardType: widget.keyboardType,
      enabled: widget.enabled, // pakai properti enabled
      style: TextStyle(
        color: widget.enabled ? Colors.white : Colors.white.withOpacity(0.5),
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color:
              widget.enabled
                  ? Colors.white.withOpacity(0.6)
                  : Colors.white.withOpacity(0.3),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide.none,
        ),
        suffixIcon:
            widget.isPassword
                ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color:
                        widget.enabled
                            ? Colors.white.withOpacity(0.7)
                            : Colors.white.withOpacity(0.3),
                  ),
                  onPressed:
                      widget.enabled
                          ? () {
                            setState(() {
                              obscure = !obscure;
                            });
                          }
                          : null,
                )
                : null,
      ),
    );
  }
}
