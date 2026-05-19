import 'package:flutter/material.dart';
import 'package:vita_appprojetos/uitl/my_button.dart';
import 'package:vita_appprojetos/uitl/text_form_field.dart';

class PaginaNovaSenha extends StatefulWidget {
  @override
  State<PaginaNovaSenha> createState() => _PaginaNovaSenhaState();
}

class _PaginaNovaSenhaState extends State<PaginaNovaSenha> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Redefinir Senha", style: TextStyle(fontSize: 42)),
        backgroundColor: Colors.transparent, // transparente
        elevation: 0, // remove sombra
      ),
      body: _buildUI(context),
    );
  }

  Widget _buildUI(BuildContext context) {
    void onPressed() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RedefSenha()),
      );
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
              _email(context),
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

  Widget _email(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: RoundedTextFormField(hintText: "Email associado a sua conta"),
    );
  }
}

class RedefSenha extends StatefulWidget {
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
      body: _buildUI(context),
    );
  }

  Widget _buildUI(BuildContext context) {
    void onPressed() {}
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
              _senha(context),
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

  Widget _senha(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: RoundedTextFormField(
              fieldLabel: "Nova Senha",
              hintText: "Nova Senha",
              obscureText: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: RoundedTextFormField(
              fieldLabel: "Cofirmar Senha",
              hintText: "Confirmar Senha",
              obscureText: true,
            ),
          ),
        ],
      ),
    );
  }
}
