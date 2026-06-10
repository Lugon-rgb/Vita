import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaQuiz extends StatefulWidget {
  const TelaQuiz({super.key});

  @override
  State<TelaQuiz> createState() => _TelaQuizState();
}

class _TelaQuizState extends State<TelaQuiz> {
  final db = FirebaseFirestore.instance;

  int perguntaAtual = 0;
  int vidaTotal = 0;
  int estaminaTotal = 0;
  bool carregando = true;

  List<Map<String, dynamic>> perguntas = [];

  @override
  void initState() {
    super.initState();
    _carregarPerguntas();
  }

  Future<void> _carregarPerguntas() async {
    final snapshot = await db
        .collection('usuarios')
        .doc('João')
        .collection('Quiz')
        .orderBy('criadoEm', descending: false)
        .get();

    setState(() {
      perguntas = snapshot.docs
          .map(
            (doc) => {
              'pergunta': doc['pergunta'] as String,
              'tipo': doc['tipo'] as String,
            },
          )
          .toList();
      carregando = false;
    });
  }

  void responder(int valor) {
    String tipo = perguntas[perguntaAtual]["tipo"];
    if (tipo == "vida") {
      vidaTotal += valor;
    } else {
      estaminaTotal += valor;
    }

    if (perguntaAtual < perguntas.length - 1) {
      setState(() => perguntaAtual++);
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
          onPressed: () => responder(valor),
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
      body: carregando
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 30, 64, 214),
              ),
            )
          : perguntas.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma pergunta cadastrada.\nAdicione perguntas no editor!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${perguntaAtual + 1} / ${perguntas.length}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
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
