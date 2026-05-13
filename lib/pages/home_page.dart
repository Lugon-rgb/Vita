import 'package:flutter/material.dart';
import 'package:vita_appprojetos/pages/quiz_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
