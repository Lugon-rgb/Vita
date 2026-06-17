import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

// import 'pages/notas.dart';
// import 'pages/conquistas.dart';
// import 'pages/titulos.dart';
import 'package:vita_appprojetos/pages/auth_page.dart';
// import 'package:vita_appprojetos/pages/home_page.dart';
// import 'pages/conquistas.dart';
// import 'pages/titulos.dart';
import 'package:vita_appprojetos/pages/metas.dart';
import 'package:vita_appprojetos/pages/overlay_page.dart';
import 'package:vita_appprojetos/pages/tela_usuario.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
            color: Color.fromARGB(179, 255, 255, 255),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),

      // LOGIN PRIMEIRO
      home: const AuthPage(),

      routes: {
        '/HOME': (context) => const OverlayPage(),
        '/METAS': (context) => const GoalsPage(),
        '/PERFIL': (context) => ProfileScreen(aoClicarNoSeletorDeTitulos: () => {}),
        '/HOME': (context) => const OverlayPage(),
      },
    );
  }
}