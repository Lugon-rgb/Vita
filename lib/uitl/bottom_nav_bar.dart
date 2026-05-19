import 'package:flutter/material.dart';
import 'package:vita_appprojetos/pages/home_page.dart';
import 'package:vita_appprojetos/pages/metas.dart';
import 'package:vita_appprojetos/pages/tela_usuario.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        backgroundColor: const Color.fromARGB(255, 26, 29, 30),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),

          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Metas',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: 'Notas',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Finanças',
          ),

          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
      body: _pages[_selectedIndex],
    );
  }
}
