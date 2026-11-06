import 'package:flas_/core/constants.dart';
import 'package:flas_/core/widgets/clearable_text_field.dart';
import 'package:flutter/material.dart';

class DeckInfoFields extends StatelessWidget {
  const DeckInfoFields({
    super.key,
    required this.name,
    required this.description,
  });

  final TextEditingController name;
  final TextEditingController description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .all(screenMargin),
      child: Column(
        spacing: 8,
        children: [
          ClearableTextField(controller: name, label: 'Name'),
          ClearableTextField(
            controller: description,
            label: 'Description',
            minLines: 1,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
