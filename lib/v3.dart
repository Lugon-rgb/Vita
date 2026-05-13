import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Vita Teste", home: VitaTeste());
  }
}

// principal

class VitaTeste extends StatefulWidget {
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
        vida = dados['vida'];
        estamina = dados['estamina'];
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
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Vita",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),

      body: IndexedStack(
        index: myIndex,
        children: [homePage(context), Financias()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: myIndex,
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Finanças'),
        ],
      ),
    );
  }

  // homepage
  Widget homePage(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vida: $vida', style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          Text('Estamina: $estamina', style: TextStyle(fontSize: 24)),

          SizedBox(height: 30),

          ElevatedButton(
            onPressed: () async {
              final resultado = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TelaQuiz()),
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
            child: Text("Fazer Quiz"),
          ),
        ],
      ),
    );
  }
}

//  TelaQuiz

class TelaQuiz extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quiz")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Você treinou hoje?", style: TextStyle(fontSize: 22)),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {'vida': 10, 'estamina': 5});
              },
              child: Text("Sim"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {'vida': -5, 'estamina': -5});
              },
              child: Text("Não"),
            ),
          ],
        ),
      ),
    );
  }
}

// Financias

class Financias extends StatefulWidget {
  @override
  State<Financias> createState() => _FinanciasState();
}

class _FinanciasState extends State<Financias> {
  final db = FirebaseFirestore.instance;

  int limite = 0;
  int gastou = 0;

  List<int> gastos = [];

  TextEditingController limiteController = TextEditingController();
  TextEditingController gastoController = TextEditingController();
  double get progresso {
    if (limite == 0) return 0;

    return gastou / limite;
  }

  Future salvarFinancas() async {
    await db.collection("usuarios").doc("arthur").set({
      "limite": limite,
      "gastou": gastou,
      "gastos": gastos,
    }, SetOptions(merge: true));
  }

  Future carregarFinancas() async {
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
            ? List<int>.from(data['gastos'])
            : [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    carregarFinancas();
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Limite: $limite", style: TextStyle(fontSize: 20)),
          Text("Total gasto: $gastou", style: TextStyle(fontSize: 20)),
          SizedBox(height: 20),

          LinearProgressIndicator(value: progresso > 1 ? 1 : progresso),

          if (progresso >= 1)
            Text("Você atingiu o limite!", style: TextStyle(color: Colors.red)),
          SizedBox(height: 20),
          if (progresso >= 0.5 && progresso < 1)
            Text(
              "Você já gastou mais de 50% do limite!",
              style: TextStyle(color: Colors.orange),
            ),

          TextField(
            controller: limiteController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Definir limite",
              border: OutlineInputBorder(),
            ),
          ),

          SizedBox(height: 10),

          ElevatedButton(
            onPressed: () {
              setState(() {
                limite = int.tryParse(limiteController.text) ?? 0;
              });
              limiteController.clear();
              salvarFinancas();
            },
            child: Text("Salvar limite"),
          ),

          SizedBox(height: 20),

          TextField(
            controller: gastoController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Adicionar gasto",
              border: OutlineInputBorder(),
            ),
          ),

          SizedBox(height: 10),

          ElevatedButton(
            onPressed: () {
              int valor = int.tryParse(gastoController.text) ?? 0;

              if (valor > 0) {
                setState(() {
                  gastos.add(valor);
                  gastou += valor;
                });
                salvarFinancas();
              }

              gastoController.clear();
            },
            child: Text("Adicionar gasto"),
          ),

          SizedBox(height: 20),

          Text("Lista de gastos:", style: TextStyle(fontSize: 18)),

          Expanded(
            child: ListView.builder(
              itemCount: gastos.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text("Gasto: ${gastos[index]}"));
              },
            ),
          ),
        ],
      ),
    );
  }
}
