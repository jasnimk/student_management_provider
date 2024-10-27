import 'package:flutter/material.dart';

buildTextFormField({
  required TextEditingController controller,
  required String labelText,
  required String emptyValidationMessage,
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return emptyValidationMessage;
      }
      return null;
    },
  );
}
