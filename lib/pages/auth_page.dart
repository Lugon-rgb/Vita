import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vita_appprojetos/pages/overlay_page.dart';
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
            return OverlayPage();
          } else {
            return PaginaLogin();
          }
        },
      ),
    );
  }
}
