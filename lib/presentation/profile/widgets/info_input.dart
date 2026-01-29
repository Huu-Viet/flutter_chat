import 'package:flutter/material.dart';

class InfoInput extends StatelessWidget {
  final TextEditingController textController;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const InfoInput({
    super.key,
    required this.textController,
    required this.label,
    required this.validator,
    this.keyboardType
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textController,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.person_outline),
      ),
      validator: validator,
      keyboardType: keyboardType,
    );
  }
}