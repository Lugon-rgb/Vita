import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../v5.dart';

class Carregamentos extends StatefulWidget {
  const Carregamentos({super.key});

  @override
  State<Carregamentos> createState() => _CarregamentosState();
}

class _CarregamentosState extends State<Carregamentos> {
  @override
  void initState() {
    super.initState();
    _carregarEIr();
  }

  Future<void> _carregarEIr() async {
    // Espera o Firebase carregar os dados
    await FirebaseFirestore.instance.collection('usuarios').doc('arthur').get();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => VitaTeste()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 13, 15, 17),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('lib/imagens/logo.png'),
            const SizedBox(height: 20),
            const Text(
              'VITA',
              style: TextStyle(
                color: Color.fromARGB(255, 194, 4, 4),
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
