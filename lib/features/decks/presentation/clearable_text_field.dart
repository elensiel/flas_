import 'package:material_ui/material_ui.dart';

String? requiredText(String? value) =>
    (value?.trim().isEmpty == true) ? 'Required' : null;

class ClearableTextField extends StatelessWidget {
  const ClearableTextField({
    super.key,
    this.fieldKey,
    required this.controller,
    required this.label,
    this.validator = requiredText,
    this.minLines,
    this.maxLines,
    this.border,
    this.textAlign = .start,
  });

  final GlobalKey<FormFieldState<String>>? fieldKey;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
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
        validator: validator,
      ),
    );
  }
}
