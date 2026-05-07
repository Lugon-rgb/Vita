import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Limite: $limite", style: TextStyle(fontSize: 20)),
            Text("Total gasto: $gastou", style: TextStyle(fontSize: 20)),

            SizedBox(height: 20),
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
      ),
    );
  }
}
