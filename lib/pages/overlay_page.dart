import 'package:flutter/material.dart';
import 'package:vita_appprojetos/pages/home_page.dart';
import 'package:vita_appprojetos/pages/metas.dart';
import 'package:vita_appprojetos/pages/tela_usuario.dart';

class OverlayPage extends StatefulWidget {
  const OverlayPage({super.key});

  @override
  State<OverlayPage> createState() => _OverlayPageState();
}

class _OverlayPageState extends State<OverlayPage> {
  int currentPageIndex = 0;

  final List _pages = [
    HomePage(),
    GoalsPage(),
    Placeholder(),
    Placeholder(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 13, 15, 17),
      body: _pages[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        backgroundColor: const Color.fromARGB(255, 26, 29, 30),
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),

          NavigationDestination(
            icon: Icon(Icons.track_changes),
            label: 'Metas',
          ),

          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            label: 'Notas',
          ),

          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Finanças',
          ),

          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
