import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Color? focusColor;
  final double? elevation;
  final Color? textColor;
  final Size? buttonSize;
  final double? fontSize;

  const MyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.focusColor,
    this.elevation,
    this.textColor,
    this.buttonSize,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: elevation,
        fixedSize: buttonSize,
        disabledBackgroundColor: focusColor ?? Theme.of(context).primaryColor,
        backgroundColor: color ?? Theme.of(context).primaryColor,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: fontSize),
      ),
    );
  }
}
