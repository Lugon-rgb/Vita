import 'package:flutter/material.dart';
import 'package:vita_appprojetos/uitl/my_button.dart';

// ignore: must_be_immutable
class DialogBox extends StatelessWidget {
  VoidCallback galeria;
  VoidCallback camera;
  DialogBox({super.key, required this.galeria, required this.camera});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text("Selecione a fonte")),
      backgroundColor: const Color.fromARGB(255, 13, 15, 17),
      content: SizedBox(
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MyButton(text: "Galeria", onPressed: galeria),

            const SizedBox(width: 8),

            MyButton(text: "Camera", onPressed: camera),
          ],
        ),
      ),
    );
  }
}
