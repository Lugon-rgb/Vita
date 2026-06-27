import 'package:flutter/material.dart';
import 'package:vita_appprojetos/uitl/my_button.dart';

// ignore: must_be_immutable
class DialogBox extends StatelessWidget {
  VoidCallback sim;
  VoidCallback nao;
  DialogBox({super.key, required this.sim, required this.nao});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text("Você deseja excluir sua conta?")),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      content: SizedBox(
        height: 100,
        child: Column(
          children: [
            Text(
              "(Essa ação não é reversível!)",
              style: TextStyle(color: Colors.red[700]),
            ),
            SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyButton(text: "Sim", onPressed: sim),
                SizedBox(width: 8),
                MyButton(
                  text: "Cancelar",
                  onPressed: nao,
                  color: Colors.redAccent.withOpacity(0.2),
                  textColor: Colors.redAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
