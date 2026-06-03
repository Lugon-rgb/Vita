import 'package:flutter/material.dart';

class RoundedTextFormField extends StatelessWidget {
  final String? fieldLabel;
  final String hintText;
  final bool obscureText;
  final TextEditingController? controller;
  final Widget? iconDec;
  final String? Function(String?)? vali;
  final void Function(String?)? onSaved;

  const RoundedTextFormField({
    super.key,
    required this.hintText,
    this.fieldLabel,
    this.obscureText = false,
    this.controller,
    this.iconDec,
    this.vali,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 30,
      child: Center(
        child: Container(
          child: TextFormField(
            controller: controller,
            validator: vali,
            onSaved: onSaved,
            decoration: InputDecoration(
              suffixIcon: iconDec,
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
