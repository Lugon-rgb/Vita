import 'package:flutter/material.dart';
import 'package:vita_appprojetos/pages/home_page.dart';
import 'package:vita_appprojetos/pages/metas.dart';
import 'package:vita_appprojetos/pages/overlay_page.dart';
import 'package:vita_appprojetos/pages/pagina_login.dart';
import 'package:vita_appprojetos/pages/tela_usuario.dart';
import 'pages/conquistas.dart';
import 'pages/titulos.dart';

void main() {
  runApp(const VitaApp());
}

class VitaApp extends StatelessWidget {
  const VitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vita',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      // home: const ConquistasPage()
      // home: const GoalsPage(),
      home: PaginaLogin(),
      routes: {
        '/METAS': (context) => const GoalsPage(),
        '/PERFIL': (context) => const ProfileScreen(),
        '/HOME': (context) => const OverlayPage(),
      },
    );
  }
}
