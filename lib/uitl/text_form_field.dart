import 'package:flutter/material.dart';

class RoundedTextFormField extends StatelessWidget {
  final String? fieldLabel;
  final String hintText;
  final bool obscureText;
  final TextEditingController? controller;

  const RoundedTextFormField({
    super.key,
    required this.hintText,
    this.fieldLabel,
    this.obscureText = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 30,
      child: Center(
        child: Container(
          child: TextFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              labelText: fieldLabel,
              floatingLabelAlignment: FloatingLabelAlignment.start,
              hintText: hintText,
            ),
            obscureText: obscureText,
          ),
        ),
      ),
    );
  }
}
