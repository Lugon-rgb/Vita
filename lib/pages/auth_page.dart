import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vita_appprojetos/pages/carregamento.dart';
import 'package:vita_appprojetos/pages/pagina_login.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Carregamentos();
          } else {
            return PaginaLogin();
          }
        },
      ),
    );
  }
}
