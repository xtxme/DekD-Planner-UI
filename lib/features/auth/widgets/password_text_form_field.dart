import 'package:flutter/material.dart';
import 'package:my_first_app/shared/theme/app_colors.dart';

class PasswordTextFormField extends StatefulWidget {
  const PasswordTextFormField({
    super.key,
    this.controller,
    this.validator,
    this.hintText = 'Enter your password',
    this.iconColor = AppColors.cFFB08F7E,
    this.prefixIcon = Icons.lock,
    this.fillColor = Colors.white,
    this.borderColor = AppColors.cFFD9C6B4,
  });

  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String hintText;
  final Color iconColor;
  final IconData prefixIcon;
  final Color fillColor;
  final Color borderColor;

  @override
  State<PasswordTextFormField> createState() => _PasswordTextFormFieldState();
}

class _PasswordTextFormFieldState extends State<PasswordTextFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: _obscureText,
      enableSuggestions: false,
      autocorrect: false,
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: AppColors.cFFB8A99A),
        prefixIcon: Icon(widget.prefixIcon, color: AppColors.cFFA9998B),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: widget.iconColor,
          ),
        ),
        filled: true,
        fillColor: widget.fillColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: widget.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: widget.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.cFFD2A34A),
        ),
      ),
    );
  }
}
