import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Paginas/Financias.dart';
import 'Paginas/TelaQuiz.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VitaTeste(),
    );
  }
}

class VitaTeste extends StatefulWidget {
  const VitaTeste({super.key});

  @override
  State<VitaTeste> createState() => _VitaTesteState();
}

class _VitaTesteState extends State<VitaTeste> {
  final db = FirebaseFirestore.instance;

  int vida = 100;
  int estamina = 100;

  int myIndex = 0;

  void verificarStatus() {
    vida = vida.clamp(0, 100);
    estamina = estamina.clamp(0, 100);
  }

  Future salvarDados() async {
    await db.collection("usuarios").doc("arthur").set({
      "vida": vida,
      "estamina": estamina,
    }, SetOptions(merge: true));
  }

  Future carregarDados() async {
    DocumentSnapshot dados = await db
        .collection("usuarios")
        .doc("arthur")
        .get();

    if (dados.exists) {
      setState(() {
        vida = dados['vida'] ?? 100;
        estamina = dados['estamina'] ?? 100;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 13, 15, 17),

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 13, 15, 17),
        elevation: 0,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "Olá, Arthur!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              "Guerreiro do Foco",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),

      body: IndexedStack(
        index: myIndex,
        children: [homeNova(context), Financias()],
      ),

      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color.fromARGB(255, 26, 29, 30),

        selectedIndex: myIndex,

        onDestinationSelected: (index) {
          setState(() {
            myIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),

          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Finanças',
          ),
        ],
      ),
    );
  }

  Widget homeNova(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // CARD PRINCIPAL
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

                // VIDA
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

                // ESTAMINA
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

          // BOTOES RAPIDOS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,

            children: [
              // META
              Expanded(
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

              // NOTA
              Expanded(
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

              // QUIZ
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final resultado = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TelaQuiz()),
                    );

                    if (resultado != null) {
                      setState(() {
                        vida += resultado['vida'] as int;
                        estamina += resultado['estamina'] as int;

                        verificarStatus();
                      });

                      salvarDados();
                    }
                  },

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

          // CARDS DE ESTATISTICA
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

          // TITULO
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

          // CARD ATIVIDADE
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),

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
      ),
    );
  }
}
