import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
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

class TelaQuiz extends StatefulWidget {
  const TelaQuiz({super.key});

  @override
  State<TelaQuiz> createState() => _TelaQuizState();
}

class _TelaQuizState extends State<TelaQuiz> {
  int perguntaAtual = 0;

  int vidaTotal = 0;
  int estaminaTotal = 0;

  List<Map<String, dynamic>> perguntas = [
    {"pergunta": "P V", "tipo": "vida"},

    {"pergunta": "P S", "tipo": "estamina"},

    {"pergunta": "P V", "tipo": "vida"},

    {"pergunta": "P S", "tipo": "estamina"},
  ];

  void responder(int valor) {
    String tipo = perguntas[perguntaAtual]["tipo"];

    if (tipo == "vida") {
      vidaTotal += valor;
    } else {
      estaminaTotal += valor;
    }

    if (perguntaAtual < perguntas.length - 1) {
      setState(() {
        perguntaAtual++;
      });
    } else {
      Navigator.pop(context, {"vida": vidaTotal, "estamina": estaminaTotal});
    }
  }

  Widget botaoResposta(String texto, int valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),

      child: SizedBox(
        width: double.infinity,

        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 30, 64, 214),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
          ),
          onPressed: () {
            responder(valor);
          },

          child: Text(texto),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 13, 15, 17),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 13, 15, 17),

        title: const Text("Quiz", style: TextStyle(color: Colors.white)),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            Text(
              perguntas[perguntaAtual]["pergunta"],

              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            botaoResposta("Muito ruim", -10),
            botaoResposta("Ruim", -5),
            botaoResposta("Boa", 5),
            botaoResposta("Muito boa", 10),
          ],
        ),
      ),
    );
  }
}

class Financias extends StatefulWidget {
  const Financias({super.key});

  @override
  State<Financias> createState() => _FinanciasState();
}

class _FinanciasState extends State<Financias> {
  final db = FirebaseFirestore.instance;

  int limite = 0;
  int gastou = 0;
  List<Map<String, dynamic>> gastos = [];

  TextEditingController limiteController = TextEditingController();
  TextEditingController nomeController = TextEditingController();
  TextEditingController gastoController = TextEditingController();

  double get progresso {
    if (limite == 0) return 0;
    return gastou / limite;
  }

  Map<String, double> gastosSemana() {
    Map<String, double> dias = {
      "Seg": 0,
      "Ter": 0,
      "Qua": 0,
      "Qui": 0,
      "Sex": 0,
      "Sab": 0,
      "Dom": 0,
    };

    DateTime agora = DateTime.now();
    DateTime inicioSemana = agora.subtract(Duration(days: agora.weekday - 1));

    for (var gasto in gastos) {
      DateTime data = (gasto['data'] as Timestamp).toDate();
      if (data.isBefore(inicioSemana)) continue;

      int valor = gasto['valor'] as int;

      switch (data.weekday) {
        case 1:
          dias["Seg"] = dias["Seg"]! + valor;
          break;
        case 2:
          dias["Ter"] = dias["Ter"]! + valor;
          break;
        case 3:
          dias["Qua"] = dias["Qua"]! + valor;
          break;
        case 4:
          dias["Qui"] = dias["Qui"]! + valor;
          break;
        case 5:
          dias["Sex"] = dias["Sex"]! + valor;
          break;
        case 6:
          dias["Sab"] = dias["Sab"]! + valor;
          break;
        case 7:
          dias["Dom"] = dias["Dom"]! + valor;
          break;
      }
    }
    return dias;
  }

  List<BarChartGroupData> _buildBarGroups(Map<String, double> dados) {
    const List<String> diasOrdem = [
      "Seg",
      "Ter",
      "Qua",
      "Qui",
      "Sex",
      "Sab",
      "Dom",
    ];
    List<BarChartGroupData> groups = [];

    for (int i = 0; i < diasOrdem.length; i++) {
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: dados[diasOrdem[i]]!,
              color: Colors.blueAccent,
              width: 22,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }
    return groups;
  }

  Future<void> salvarFinancas() async {
    await db.collection("usuarios").doc("arthur").set({
      "limite": limite,
      "gastou": gastou,
      "gastos": gastos,
    }, SetOptions(merge: true));
  }

  Future<void> carregarFinancas() async {
    DocumentSnapshot dados = await db
        .collection("usuarios")
        .doc("arthur")
        .get();
    if (dados.exists) {
      Map<String, dynamic> data = dados.data() as Map<String, dynamic>;

      setState(() {
        limite = data.containsKey('limite') ? data['limite'] : 0;
        gastou = data.containsKey('gastou') ? data['gastou'] : 0;
        gastos = data.containsKey('gastos')
            ? List<Map<String, dynamic>>.from(data['gastos'])
            : [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    carregarFinancas();
  }

  @override
  void dispose() {
    limiteController.dispose();
    nomeController.dispose();
    gastoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dadosSemana = gastosSemana();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 13, 15, 17),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 13, 15, 17),
        title: const Text("Finanças", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================== CARD RESUMO ====================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 26, 29, 30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Limite: R\$ $limite",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Total gasto: R\$ $gastou",
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progresso > 1 ? 1 : progresso,
                        minHeight: 12,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(Colors.green),
                      ),
                    ),

                    const SizedBox(height: 10),
                    if (progresso >= 1)
                      const Text(
                        "Você atingiu o limite!",
                        style: TextStyle(color: Colors.red),
                      ),
                    if (progresso >= 0.5 && progresso < 1)
                      const Text(
                        "Você já gastou mais de 50%!",
                        style: TextStyle(color: Colors.orange),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ==================== DEFINIR LIMITE ====================
              TextField(
                controller: limiteController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Definir limite",
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white24),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 30, 64, 214),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  setState(() {
                    limite = int.tryParse(limiteController.text) ?? 0;
                  });
                  limiteController.clear();
                  salvarFinancas();
                },
                child: const Text("Salvar limite"),
              ),

              const SizedBox(height: 30),

              // ==================== ADICIONAR GASTO ====================
              TextField(
                controller: nomeController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Nome do gasto (ex: Mercado, Uber)",
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white24),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: gastoController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Valor (R\$)",
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white24),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 30, 64, 214),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  int valor = int.tryParse(gastoController.text) ?? 0;
                  String nome = nomeController.text.trim().isNotEmpty
                      ? nomeController.text.trim()
                      : "Gasto";

                  if (valor > 0) {
                    setState(() {
                      gastos.add({
                        "valor": valor,
                        "nome": nome,
                        "data": Timestamp.now(),
                      });
                      gastou += valor;
                    });
                    salvarFinancas();

                    gastoController.clear();
                    nomeController.clear();
                  }
                },
                child: const Text("Adicionar gasto"),
              ),

              const SizedBox(height: 30),

              // Gráfico Semanal
              const Text(
                "Gastos da Semana",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                height: 240,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 26, 29, 30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: BarChart(
                  BarChartData(
                    maxY: dadosSemana.values.isNotEmpty
                        ? dadosSemana.values.reduce((a, b) => a > b ? a : b) *
                              1.3
                        : 100,
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const dias = [
                              "Seg",
                              "Ter",
                              "Qua",
                              "Qui",
                              "Sex",
                              "Sab",
                              "Dom",
                            ];
                            return Text(
                              dias[value.toInt()],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 35,
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: _buildBarGroups(dadosSemana),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Lista de gastos
              const Text(
                "Lista de gastos",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: gastos.length,
                itemBuilder: (context, index) {
                  final gasto = gastos[index];
                  DateTime data = (gasto['data'] as Timestamp).toDate();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 26, 29, 30),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.attach_money,
                        color: Colors.green,
                      ),
                      title: Text(
                        "R\$ ${gasto['valor']}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "${gasto['nome']} • ${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            gastou -= gasto['valor'] as int;
                            gastos.removeAt(index);
                          });
                          salvarFinancas();
                        },
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
