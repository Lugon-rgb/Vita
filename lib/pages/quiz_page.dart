import 'package:flutter/material.dart';

class TelaQuiz extends StatelessWidget {
  const TelaQuiz({super.key});

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
