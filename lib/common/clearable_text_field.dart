import 'package:flutter/material.dart';

String? validator(String? value) =>
    (value == null || value.trim().isEmpty) ? 'Required' : null;

class ClearableTextField extends StatelessWidget {
  const ClearableTextField({
    super.key,
    required this.controller,
    required this.label,
    this.minLines,
    this.maxLines,
    this.border,
    this.textAlign = .start,
  });

  final TextEditingController controller;
  final String label;
  final int? minLines;
  final int? maxLines;
  final InputBorder? border;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (BuildContext context, value, _) => TextFormField(
        controller: controller,
        validator: validator,
        minLines: minLines,
        maxLines: maxLines,
        textAlign: textAlign,
        decoration: InputDecoration(
          labelText: label,
          border: border,
          suffixIcon: value.text.isNotEmpty
              ? IconButton(
                  onPressed: controller.clear,
                  icon: const Icon(Icons.clear),
                )
              : null,
        ),
      ),
    );
  }
}
