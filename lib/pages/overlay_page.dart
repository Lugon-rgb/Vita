import 'package:flutter/material.dart';
import 'package:vita_appprojetos/pages/financias.dart';
import 'package:vita_appprojetos/pages/home_page.dart';
import 'package:vita_appprojetos/pages/metas.dart';
import 'package:vita_appprojetos/pages/notas.dart';
import 'package:vita_appprojetos/pages/tela_usuario.dart';
import 'package:vita_appprojetos/pages/titulos.dart';

class OverlayPage extends StatefulWidget {
  const OverlayPage({super.key});

  @override
  State<OverlayPage> createState() => _OverlayPageState();
}

class _OverlayPageState extends State<OverlayPage> {
  int currentPageIndex = 0;

  String _tituloEquipado =
      "Guerreiro do Foco"; // simulacao temporaria do titulo equipado, dps vai ser puxado do firebase

  void _abrirSeletorDeTitulos() async {
    // funcao que abre a tela de titulos e espera o resultado do titulo selecionado para atualizar o titulo equipado
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TitulosPage()),
    );

    if (resultado != null && resultado is String) {
      // se o usuario tiver selecionado um título valido, roda o setState para redesenhar as telas
      setState(() {
        // redesenha a tela
        _tituloEquipado = resultado; // atualizan o titulo equipado
        currentPageIndex =
            0; // volta pra homepage para mostrar o titulo equipado atualizado
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<int, Widget> _pages = {
      0: HomePage(
        titulo: _tituloEquipado,
        aoClicarNoTitulo:
            _abrirSeletorDeTitulos, // passando a funcao como parametro que vai agir na homepage
      ),
      1: const GoalsPage(),
      2: const NotasPage(),
      3: const Financias(),
      4: ProfileScreen(aoClicarNoSeletorDeTitulos: _abrirSeletorDeTitulos),
    };

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 13, 15, 17),
      body: _pages[currentPageIndex]!,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        backgroundColor: const Color.fromARGB(255, 26, 29, 30),
        destinations: const [
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
