import 'package:flutter/material.dart';

class LoginCustomInput extends StatefulWidget {
  final String hintText;
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final IconData icon;

  const LoginCustomInput({
    super.key,
    required this.hintText,
    required this.label,
    required this.controller,
    this.isPassword = false,
    required this.icon,
  });

  @override
  State<StatefulWidget> createState() => _LoginCustomInputState();
}

class _LoginCustomInputState extends State<LoginCustomInput> {
  late bool _isPasswordVisible;

  @override
  void initState() {
    super.initState();
    _isPasswordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Text(
            widget.label,
            textAlign: TextAlign.start,
          ),
          TextField(
            controller: widget.controller,
            obscureText: widget.isPassword && !_isPasswordVisible,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceBright,
              prefixIcon: Icon(widget.icon, color: Colors.grey,),
              suffixIcon: widget.isPassword ?
              IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ) : null,
              hintText: widget.hintText,
              hintStyle: const TextStyle(color: Colors.grey),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}