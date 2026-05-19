import 'package:flutter/material.dart';
import 'package:vita_appprojetos/pages/pagina_nova_senha.dart';
import 'package:vita_appprojetos/uitl/my_button.dart';
import 'package:vita_appprojetos/uitl/text_form_field.dart';
import 'package:image_input/image_input.dart';

class PaginaLogin extends StatefulWidget {
  @override
  State<PaginaLogin> createState() => _PaginaLoginState();
}

class _PaginaLoginState extends State<PaginaLogin> {
  bool _isLoginMode = true;

  void onPressed() {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Vita", style: TextStyle(fontSize: 42)),
        backgroundColor: Colors.transparent, // transparente
        elevation: 0, // remove sombra
      ),
      body: _buildUI(context),
    );
  }

  Widget _buildUI(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: AlignmentGeometry.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: _baraSelecao(context),
          ),
        ),
        _isLoginMode ? _buildLogin(context) : _buildRegister(context),
      ],
    );
  }

  Widget _baraSelecao(BuildContext context) {
    void _login() {
      setState(() {
        _isLoginMode = true;
      });
    }

    void _register() {
      setState(() {
        _isLoginMode = false;
      });
    }

    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width - 30,
      height: 50.0,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 42, 42, 42),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 50.0,
        children: [
          MyButton(
            text: "Login",
            onPressed: _login,
            color: _isLoginMode ? Colors.blue : Color.fromARGB(255, 42, 42, 42),
            focusColor: Colors.blue,
            elevation: 0,
            textColor: Colors.white,
            buttonSize: Size(175, 41),
          ),
          MyButton(
            text: "Criar Conta",
            onPressed: _register,
            color: !_isLoginMode
                ? Colors.blue
                : Color.fromARGB(255, 42, 42, 42),
            focusColor: Colors.blue,
            elevation: 0,
            textColor: Colors.white,
            buttonSize: Size(175, 41),
          ),
        ],
      ),
    );
  }

  Widget _buildLogin(BuildContext context) {
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
            children: [_campoDeTexto(context), _bottombuttons(context)],
          ),
        ),
      ),
    );
  }

  Widget _buildRegister(BuildContext context) {
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
              _campoDeTextoRegister(context),
              _bottombuttonsRegister(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoDeTexto(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: RoundedTextFormField(
              fieldLabel: "Email",
              hintText: "seu@email.com",
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: RoundedTextFormField(
              fieldLabel: "Senha",
              hintText: "Senha",
              obscureText: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoDeTextoRegister(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1.0, bottom: 12),
            child: Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Color.fromRGBO(255, 255, 255, 1)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: RoundedTextFormField(
              fieldLabel: "Nome",
              hintText: "Seu nome",
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: RoundedTextFormField(
              fieldLabel: "Email",
              hintText: "seu@email.com",
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: RoundedTextFormField(
              fieldLabel: "Senha",
              hintText: "Senha",
              obscureText: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: RoundedTextFormField(
              fieldLabel: "Confirmar senha",
              hintText: "Confirmar senha",
              obscureText: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottombuttons(BuildContext context) {
    void _redefSenha() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PaginaNovaSenha()),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          child: MyButton(
            text: "Log In",
            onPressed: onPressed,
            elevation: 0,
            color: Colors.blue,
            textColor: Colors.white,
            buttonSize: Size(420, 52),
            fontSize: 32,
          ),
        ),
        TextButton(
          onPressed: _redefSenha,
          child: Text(
            "Esqueci minha senha",
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Widget _bottombuttonsRegister(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          child: MyButton(
            text: "Criar conta",
            onPressed: onPressed,
            elevation: 0,
            color: Colors.blue,
            textColor: Colors.white,
            buttonSize: Size(420, 52),
            fontSize: 32,
          ),
        ),
      ],
    );
  }
}
