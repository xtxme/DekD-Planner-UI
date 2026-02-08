import 'package:flutter/material.dart';

class EditProfileFormField extends StatelessWidget {
  const EditProfileFormField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.helperText,
    this.trailingIcon,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final String? helperText;
  final IconData? trailingIcon;
  final bool readOnly;
  final int maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE6DBD2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF8B6758),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          minLines: minLines,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8B6758),
          ),
          decoration: InputDecoration(
            prefixIcon: trailingIcon == null
                ? null
                : Icon(trailingIcon, size: 22, color: const Color(0xFFC4B8AE)),
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFFA48C7E),
              fontWeight: FontWeight.w500,
            ),
            
            filled: true,
            fillColor: const Color(0xFFFFFCF8),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 18,
              vertical: maxLines > 1 ? 16 : 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFDEAF5F)),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            helperText!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFFA48C7E),
            ),
          ),
        ],
      ],
    );
  }
}
