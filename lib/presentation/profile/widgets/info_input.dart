import 'package:flutter/material.dart';

class InfoInput extends StatelessWidget {
  final TextEditingController textController;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const InfoInput({
    super.key,
    required this.textController,
    required this.label,
    required this.validator,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceBright,
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }
}