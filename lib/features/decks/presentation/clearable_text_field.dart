import 'package:flas_/core/theme/theme_context.dart';
import 'package:material_ui/material_ui.dart';

String? requiredValidator(String? value) =>
    (value?.trim().isEmpty == true) ? 'Required' : null;

class ClearableTextField extends StatelessWidget {
  const ClearableTextField({
    super.key,
    required this.controller,
    required this.label,
    this.fieldKey,
    this.validator = requiredValidator,
    this.minLines,
    this.maxLines,
    this.textAlign = .start,
    this.border,
  });

  final TextEditingController controller;
  final String label;
  final GlobalKey<FormFieldState<String>>? fieldKey;
  final FormFieldValidator<String> validator;
  final int? minLines;
  final int? maxLines;
  final TextAlign textAlign;
  final InputBorder? border;

  @override
  Widget build(BuildContext context) {
    // Rebuilds on every keystroke so the clear button appears and
    // disappears with the text.
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (_, value, _) => TextFormField(
        key: fieldKey,
        controller: controller,
        autovalidateMode: .onUserInteraction,
        decoration: InputDecoration(
          labelText: label,
          border: border,
          suffixIcon: value.text.isNotEmpty
              ? IconButton(
                  onPressed: controller.clear,
                  icon: Icon(context.icons.clear),
                )
              : null,
        ),
        validator: validator,
        minLines: minLines,
        maxLines: maxLines,
        textAlign: textAlign,
      ),
    );
  }
}
