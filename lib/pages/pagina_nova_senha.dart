// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:vita_appprojetos/uitl/auth_util.dart';
import 'package:vita_appprojetos/uitl/my_button.dart';
import 'package:vita_appprojetos/uitl/text_form_field.dart';

final _emailUser = TextEditingController();

class PaginaNovaSenha extends StatefulWidget {
  const PaginaNovaSenha({super.key});

  @override
  State<PaginaNovaSenha> createState() => _PaginaNovaSenhaState();
}

class _PaginaNovaSenhaState extends State<PaginaNovaSenha> {
  final AuthUtil _auth = AuthUtil();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Redefinir Senha", style: TextStyle(fontSize: 42)),
        backgroundColor: Colors.transparent, // transparente
        elevation: 0, // remove sombra
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    void onPressed() async {
      final _email = _emailUser.text.trim();
      await _auth.emailRedefSenha(_email);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RedefSenha()),
        );
      }
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.75,
      child: Form(
        child: Padding(
          padding: const EdgeInsetsGeometry.symmetric(
            horizontal: 20,
            vertical: 25,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _email(),
              SizedBox(
                child: MyButton(
                  text: "Confirmar",
                  onPressed: onPressed,
                  color: Colors.blue,
                  elevation: 0,
                  textColor: Colors.white,
                  buttonSize: Size(450, 52),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _email() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: RoundedTextFormField(
        controller: _emailUser,
        hintText: "Email associado a sua conta",
      ),
    );
  }
}

class RedefSenha extends StatefulWidget {
  const RedefSenha({super.key});

  @override
  State<RedefSenha> createState() => _RedefSenhaState();
}

class _RedefSenhaState extends State<RedefSenha> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nova Senha", style: TextStyle(fontSize: 42)),
        backgroundColor: Colors.transparent, // transparente
        elevation: 0, // remove sombra
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    void _logIn() {
      Navigator.pop(context); // Close RedefSenha
      Navigator.pop(context); // Close PaginaNovaSenha
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.75,
      child: Form(
        child: Padding(
          padding: const EdgeInsetsGeometry.symmetric(
            horizontal: 20,
            vertical: 25,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Email enviado",
                    style: TextStyle(fontSize: 38, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Um email de redefinição de senha foi enviado para ${_emailUser.text.trim()}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
              MyButton(
                text: "Login",
                fontSize: 30,
                onPressed: _logIn,
                color: Colors.blue,
                elevation: 0,
                textColor: Colors.white,
                buttonSize: Size(450, 52),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
