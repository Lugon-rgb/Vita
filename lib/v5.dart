import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Paginas/financias.dart';
import 'Paginas/tela_quiz.dart';
import 'Paginas/edita_quiz.dart';
import 'Paginas/carregamento.dart';
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
      home: Carregamentos(),
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
  int xp = 0;
  int nivel = 1;
  int myIndex = 0;
  int streak = 1;
  int melhorStreak = 1;

  void verificarStatus() {
    vida = vida.clamp(0, 100);
    estamina = estamina.clamp(0, 100);
  }

  Future<void> salvarDados() async {
    await db.collection("usuarios").doc("João").set({
      "vida": vida,
      "estamina": estamina,
      "xp": xp,
      "nivel": nivel,
      "streak": streak,
      "melhorStreak": melhorStreak,
      "ultimoAcesso": Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Future<void> _ganharXp(int quantidade) async {
    xp += quantidade;
    if (xp >= 500) {
      xp = xp - 500;
      nivel += 1;
    }
    setState(() {});
    await salvarDados();
  }

  Future<void> carregarDados() async {
    try {
      DocumentSnapshot dados = await db
          .collection("usuarios")
          .doc("João")
          .get();

      if (dados.exists) {
        final data = dados.data() as Map<String, dynamic>? ?? {};

        setState(() {
          vida = data['vida'] ?? 100;
          estamina = data['estamina'] ?? 100;
          xp = data['xp'] ?? 0;
          nivel = data['nivel'] ?? 1;
          streak = data['streak'] ?? 1;
          melhorStreak = data['melhorStreak'] ?? 1;
        });
      } else {
        await salvarDados();
      }
    } catch (e) {
      debugPrint("Erro ao carregar dados: $e");
    }
  }

  Future<void> verificarStreak() async {
    try {
      final docRef = db.collection("usuarios").doc("João");
      DocumentSnapshot dados = await docRef.get();

      DateTime hoje = DateTime.now();

      if (!dados.exists) {
        streak = 1;
        melhorStreak = 1;
        await salvarDados(); // Cria o documento aqui
        setState(() {});
        return;
      }

      final data = dados.data() as Map<String, dynamic>? ?? {};

      DateTime? ultimoAcesso = (data['ultimoAcesso'] as Timestamp?)?.toDate();

      if (ultimoAcesso == null) {
        streak = 1;
        melhorStreak = 1;
      } else {
        int diferencaDias = hoje.difference(ultimoAcesso).inDays;

        if (diferencaDias == 1) {
          streak = (data['streak'] ?? 1) + 1;
          if (streak > (data['melhorStreak'] ?? 1)) {
            melhorStreak = streak;
          } else {
            melhorStreak = data['melhorStreak'] ?? 1;
          }
        } else if (diferencaDias > 1) {
          streak = 1;
          melhorStreak = data['melhorStreak'] ?? 1;
        } else {
          streak = data['streak'] ?? 1;
          melhorStreak = data['melhorStreak'] ?? 1;
        }
      }

      await docRef.set({
        "streak": streak,
        "melhorStreak": melhorStreak,
        "ultimoAcesso": Timestamp.now(),
      }, SetOptions(merge: true));

      setState(() {});
    } catch (e) {
      debugPrint("Erro ao verificar streak: $e");
    }
  }

  Future<void> adicionarAtividade({
    required String titulo,
    required String descricao,
    int xp = 0,
  }) async {
    try {
      await db.collection("usuarios").doc("João").collection("atividades").add({
        "titulo": titulo,
        "descricao": descricao,
        "xp": xp,
        "data": Timestamp.now(),
      });

      debugPrint("Atividade registrada: $titulo");
    } catch (e) {
      debugPrint("Erro ao adicionar atividade: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _inicializarUsuario();
  }

  Future<void> _inicializarUsuario() async {
    await carregarDados();
    await verificarStreak();
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
              "Olá, João!",
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
        children: [
          homeNova(context),
          Financias(onGanharXp: (xp) => setState(() => this.xp += xp)),
        ],
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nível $nivel",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "$xp / 500 XP",
                          style: const TextStyle(
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
                      child: Row(
                        children: [
                          Icon(Icons.bolt, color: Colors.orange, size: 16),
                          Text(
                            "$streak dias",
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
              // QUIZ + EDITAR (substitui o Expanded do QUIZ)
              Expanded(
                flex: 2, // ocupa mais espaço por ser dois botões
                child: Row(
                  children: [
                    // BOTÃO QUIZ
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
                            await salvarDados();
                            await _ganharXp(25);
                            await adicionarAtividade(
                              titulo: "Quiz Concluído",
                              descricao: "Você completou um quiz",
                              xp: 25,
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 30,
                            horizontal: 8,
                          ),
                          margin: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 5,
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
                    // BOTÃO EDITAR QUIZ
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TelaEditarQuiz(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 30,
                            horizontal: 8,
                          ),
                          margin: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: const Color.fromARGB(255, 26, 29, 30),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.edit_note,
                                color: Color.fromARGB(255, 30, 64, 214),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'EDITAR',
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

          // Lista Dinâmica
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: StreamBuilder<QuerySnapshot>(
              stream: db
                  .collection("usuarios")
                  .doc("João")
                  .collection("atividades")
                  .orderBy("data", descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "Nenhuma atividade ainda",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                final atividades = snapshot.data!.docs;

                return Column(
                  children: atividades.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final DateTime dataAtv = (data['data'] as Timestamp)
                        .toDate();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 26, 29, 30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['titulo'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  data['descricao'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${dataAtv.day}/${dataAtv.month}",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              if (data['xp'] != null && data['xp'] > 0)
                                Text(
                                  "+${data['xp']} XP",
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
