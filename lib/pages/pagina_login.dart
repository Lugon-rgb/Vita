import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vita_appprojetos/pages/pagina_nova_senha.dart';
import 'package:vita_appprojetos/uitl/auth_util.dart';
import 'package:vita_appprojetos/uitl/dialog_box.dart';
import 'package:vita_appprojetos/uitl/my_button.dart';
import 'package:vita_appprojetos/uitl/text_form_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';

class PaginaLogin extends StatefulWidget {
  @override
  State<PaginaLogin> createState() => _PaginaLoginState();
}

class _PaginaLoginState extends State<PaginaLogin> {
  final _emailUsuario = TextEditingController();
  final _senhaUsuario = TextEditingController();
  final _confSenha = TextEditingController();
  final _nomeUsuario = TextEditingController();

  AuthUtil _auth = AuthUtil();

  bool _isObscured = true;
  bool _isObscuredR = true;
  bool _isLoginMode = true;
  bool _isLoading = false;

  File? _fotoPerfil;

  final picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _fotoPerfil = File(pickedFile.path);
      });
    }
  }

  void addImage() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          camera: () {
            pickImage(ImageSource.camera);
            Navigator.pop(context);
          },
          galeria: () {
            pickImage(ImageSource.gallery);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void onPressed() {}

  void logUserIn() async {
    final email = _emailUsuario.text.trim();
    final senha = _senhaUsuario.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      if (mounted) {
        _showError('Por favor, preencha email e senha');
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.logUserIn(email: email, senha: senha);
      // Clear form fields
      _clearFormFields();
      // Navigation is handled by AuthPage StreamBuilder
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _showError(_getErrorMessage(e.code));
      }
    } catch (e) {
      if (mounted) {
        _showError('Erro ao fazer login. Tente novamente.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void registerUser() async {
    final email = _emailUsuario.text.trim();
    final senha = _senhaUsuario.text.trim();
    final conSenha = _confSenha.text.trim();
    final nome = _nomeUsuario.text.trim();

    if (email.isEmpty || senha.isEmpty || nome.isEmpty) {
      if (mounted) {
        _showError('Por favor, preencha email, nome e senha');
      }
      return;
    }

    if (senha != conSenha) {
      if (mounted) {
        _showError('Senhas precisam ser identicas');
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.registerUser(
        email: email,
        senha: senha,
        nome: nome,
        // fotoPerfil: _fotoPerfil,
      );
      // Clear form fields
      _clearFormFields();
      // Navigation is handled by AuthPage StreamBuilder
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _showError(_getErrorMessage(e.code));
      }
    } catch (e) {
      if (mounted) {
        _showError('Erro ao criar conta. Tente novamente.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearFormFields() {
    _emailUsuario.clear();
    _senhaUsuario.clear();
    _confSenha.clear();
    _nomeUsuario.clear();
    if (mounted) {
      setState(() {
        _fotoPerfil = null;
      });
    }
  }

  @override
  void dispose() {
    _emailUsuario.dispose();
    _senhaUsuario.dispose();
    _confSenha.dispose();
    _nomeUsuario.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-credential':
        return 'Email ou senha incorretos';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente mais tarde';
      case 'channel-error':
        return 'Erro de conexão. Verifique sua internet';
      case 'weak-password':
        return 'Senha muito fraca';
      case 'email-already-in-use':
        return 'Email já está associado a uma conta';
      default:
        return 'Erro ao fazer login: $code';
    }
  }

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
    void _obscure() {
      setState(() {
        _isObscured = !_isObscured;
      });
    }

    return SizedBox(
      child: Form(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: RoundedTextFormField(
                fieldLabel: "Email",
                hintText: "seu@email.com",
                controller: _emailUsuario,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: RoundedTextFormField(
                fieldLabel: "Senha",
                hintText: "Senha",
                obscureText: _isObscured,
                controller: _senhaUsuario,
                iconDec: IconButton(
                  onPressed: _obscure,
                  icon: _isObscured
                      ? Icon(Icons.visibility_off_outlined)
                      : Icon(Icons.visibility_outlined),
                  iconSize: 35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoDeTextoRegister(BuildContext context) {
    void _obscureR() {
      setState(() {
        _isObscuredR = !_isObscuredR;
      });
    }

    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1.0, bottom: 12),
            child: GestureDetector(
              onTap: addImage,
              child: Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Color.fromRGBO(255, 255, 255, 1)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(125),
                  child: _fotoPerfil != null
                      ? Image.file(_fotoPerfil!, fit: BoxFit.cover)
                      : Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.grey[700],
                          size: 45,
                        ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 13.0),
            child: RoundedTextFormField(
              fieldLabel: "Nome",
              hintText: "Seu nome",
              controller: _nomeUsuario,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: RoundedTextFormField(
              fieldLabel: "Email",
              hintText: "seu@email.com",
              controller: _emailUsuario,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: RoundedTextFormField(
              fieldLabel: "Senha",
              hintText: "Senha",
              controller: _senhaUsuario,
              obscureText: _isObscuredR,
              iconDec: IconButton(
                onPressed: _obscureR,
                icon: _isObscuredR
                    ? Icon(Icons.visibility_off_outlined)
                    : Icon(Icons.visibility_outlined),
                iconSize: 35,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: RoundedTextFormField(
              fieldLabel: "Confirmar senha",
              hintText: "Confirmar senha",
              controller: _confSenha,
              obscureText: _isObscuredR,
              iconDec: IconButton(
                onPressed: _obscureR,
                icon: _isObscuredR
                    ? Icon(Icons.visibility_off_outlined)
                    : Icon(Icons.visibility_outlined),
                iconSize: 35,
              ),
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
          child: _isLoading
              ? SizedBox(
                  width: 420,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              : MyButton(
                  text: "Log In",
                  onPressed: logUserIn,
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
    void _contaCriada() {
      setState(() {
        _isLoginMode = true;
      });
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          child: MyButton(
            text: "Criar conta",
            onPressed: registerUser,
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
