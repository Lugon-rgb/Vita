import 'package:flutter/material.dart';

void main() {
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
  int vida = 100;
  int estamina = 100;
  int myIndex = 0;

  void verificarStatus() {
    vida = vida.clamp(0, 100);
    estamina = estamina.clamp(0, 100);
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

      body: myIndex == 0 ? homePage(context) : Financias(),

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
  int limite = 0;
  int gastou = 0;

  List<int> gastos = [];

  TextEditingController limiteController = TextEditingController();
  TextEditingController gastoController = TextEditingController();
  double get progresso {
    if (limite == 0) return 0;

    return gastou / limite;
  }

  @override
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
