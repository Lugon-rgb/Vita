import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vita_appprojetos/pages/financias.dart';
import 'package:vita_appprojetos/pages/metas.dart';
import 'package:vita_appprojetos/pages/TelaQuiz.dart';
import 'package:vita_appprojetos/pages/tela_usuario.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  int vida = 100;
  int estamina = 100;
  int currentPageIndex = 0;

  final List<Widget> _pages = [
    const SizedBox.shrink(), // Home is rendered separately below
    GoalsPage(),
    const Financias(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  void verificarStatus() {
    vida = vida.clamp(0, 100);
    estamina = estamina.clamp(0, 100);
  }

  Future<void> salvarDados() async {
    await db.collection("usuarios").doc(user?.uid ?? "arthur").set({
      "vida": vida,
      "estamina": estamina,
    }, SetOptions(merge: true));
  }

  Future<void> carregarDados() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> dados = await db
          .collection("usuarios")
          .doc(user?.uid ?? "arthur")
          .get();

      if (!mounted || !dados.exists) return;

      final data = dados.data();
      setState(() {
        vida = (data?['vida'] as int?) ?? 100;
        estamina = (data?['estamina'] as int?) ?? 100;
        verificarStatus();
      });
    } catch (_) {
      // Se o carregamento falhar, a tela continua com os valores padrão.
    }
  }

  Future<void> abrirQuiz() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TelaQuiz()),
    );

    if (!mounted || resultado == null) return;

    setState(() {
      vida += (resultado['vida'] as int?) ?? 0;
      estamina += (resultado['estamina'] as int?) ?? 0;
      verificarStatus();
    });

    await salvarDados();
  }

  void abrirMeta() {
    setState(() {
      currentPageIndex = 1;
    });
  }

  void abrirNota() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('A funcionalidade de notas ainda está em construção.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName ?? 'Usuário';

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 13, 15, 17),
      appBar: appBar(displayName),
      body: IndexedStack(
        index: currentPageIndex,
        children: [
          SingleChildScrollView(child: buildHomeContent(context)),
          _pages[1],
          _pages[2],
          _pages[3],
        ],
      ),
    );
  }

  Widget buildHomeContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color.fromARGB(255, 26, 29, 30),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nível 18",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      Text(
                        "290 / 500 XP",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 117, 72, 4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.bolt, color: Colors.orange, size: 16),
                        Text(
                          " 7 dias",
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Vida (HP)',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$vida / 100',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: vida / 100,
                  minHeight: 8,
                  backgroundColor: Colors.white,
                  valueColor: const AlwaysStoppedAnimation(Colors.redAccent),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Energia (Stamina)',
                    style: TextStyle(
                      color: Color.fromARGB(255, 33, 207, 178),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$estamina / 100',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: estamina / 100,
                  minHeight: 8,
                  backgroundColor: Colors.white,
                  valueColor: const AlwaysStoppedAnimation(
                    Color.fromARGB(255, 33, 207, 178),
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: abrirMeta,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 8,
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: const Color.fromARGB(255, 26, 29, 30),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.track_changes,
                        color: Color.fromARGB(255, 30, 64, 214),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'NOVA META',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: abrirNota,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 8,
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: const Color.fromARGB(255, 26, 29, 30),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: Color.fromARGB(255, 30, 64, 214),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'NOVA NOTA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: abrirQuiz,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 8,
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: const Color.fromARGB(255, 26, 29, 30),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.play_circle_outline_outlined,
                        color: Color.fromARGB(255, 30, 64, 214),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'QUIZ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(30),
                margin: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color.fromARGB(255, 26, 29, 30),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.track_changes,
                      color: Color.fromARGB(255, 30, 64, 214),
                      size: 32,
                    ),
                    SizedBox(height: 6),
                    Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Metas Ativas',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(30),
                margin: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color.fromARGB(255, 26, 29, 30),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.green, size: 32),
                    SizedBox(height: 6),
                    Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Metas Concluídas',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(left: 20, top: 20),
          child: Row(
            children: [
              Icon(
                Icons.electric_bolt,
                color: Color.fromARGB(255, 30, 64, 214),
              ),
              SizedBox(width: 5),
              Text(
                'Atividade Recente',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(30),
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromARGB(255, 26, 29, 30),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meta concluída: Fazer lista de cálculo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '14 de abr, 22:50',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color.fromARGB(255, 19, 47, 61),
                ),
                child: const Text(
                  '+130 XP',
                  style: TextStyle(
                    color: Color.fromARGB(255, 44, 99, 208),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  AppBar appBar(String displayName) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Olá, $displayName!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Guerreiro do Foco',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 13, 15, 17),
      elevation: 0.0,
    );
  }
}
