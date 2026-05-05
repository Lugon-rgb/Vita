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

// ---------------- TELA PRINCIPAL ----------------

class VitaTeste extends StatefulWidget {
  @override
  State<VitaTeste> createState() => _VitaTesteState();
}

class _VitaTesteState extends State<VitaTeste> {
  int vida = 100;
  int estamina = 100;

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
      body: Padding(
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
      ),
    );
  }
}

// ---------------- TELA QUIZ ----------------

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
