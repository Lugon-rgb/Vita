import 'package:flutter/material.dart';
import 'package:vita_appprojetos/uitl/text_form_field.dart';

// ignore: must_be_immutable
class ReAuthDialogBox extends StatefulWidget {
  final TextEditingController email;
  final TextEditingController senha;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const ReAuthDialogBox({
    super.key,
    required this.email,
    required this.senha,
    this.onConfirm,
    this.onCancel,
  });

  @override
  State<ReAuthDialogBox> createState() => _ReAuthDialogBoxState();
}

class _ReAuthDialogBoxState extends State<ReAuthDialogBox> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(child: Text("Confirme suas credenciais")),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      content: SingleChildScrollView(
        child: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: RoundedTextFormField(
                  fieldLabel: "Email",
                  hintText: "seu@email.com",
                  controller: widget.email,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: RoundedTextFormField(
                  fieldLabel: "Senha",
                  hintText: "Senha",
                  obscureText: _isObscured,
                  controller: widget.senha,
                  iconDec: IconButton(
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                    icon: Icon(
                      _isObscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    iconSize: 35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: widget.onCancel ?? () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: widget.onConfirm ?? () => Navigator.pop(context),
          child: const Text("Confirmar"),
        ),
      ],
    );
  }
}
