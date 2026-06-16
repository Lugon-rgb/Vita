import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vita_appprojetos/pages/TelaQuiz.dart';

class HomePage extends StatefulWidget {

final String titulo; // guarda o nome do titulo atual
final VoidCallback aoClicarNoTitulo; // funcao chamada quando clica no titulo

const HomePage({
  super.key, 
  required this.titulo, // obrigatorio passar o titulo
  required this.aoClicarNoTitulo, // obrigatorio passar a funcao do clique
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final user = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance;

  int vida = 100;
  int estamina = 100;

  void verificarStatus() {
    vida = vida.clamp(0, 100);
    estamina = estamina.clamp(0, 100);
  }

  Future salvarDados() async {
    await db.collection("usuarios").doc(user?.uid ?? "usuario").set({
      "vida": vida,
      "estamina": estamina,
    }, SetOptions(merge: true));
  }

  Future carregarDados() async {
    DocumentSnapshot dados =
        await db.collection("usuarios").doc(user?.uid ?? "usuario").get();

    if (mounted && dados.exists) {
      setState(() {
        vida = dados['vida'] ?? 100;
        estamina = dados['estamina'] ?? 100;
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
      backgroundColor: const Color.fromARGB(255, 13, 15, 17),
      appBar: appBar(),
      body: SingleChildScrollView(child: body()),
    );
  }

  Center body() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CARD PRINCIPAL
            Container(
              padding: const EdgeInsets.all(20.0),
              margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: const Color.fromARGB(255, 26, 29, 30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Nível 18",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          Text(
                            "290 / 500 XP",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 117, 72, 4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.bolt, color: Colors.orange, size: 16),
                            Text(
                              " 7 dias",
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // VIDA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Vida (HP)',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$vida / 100',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: vida / 100,
                      minHeight: 8,
                      backgroundColor: Colors.white,
                      valueColor:
                          const AlwaysStoppedAnimation(Colors.redAccent),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // ESTAMINA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Energia (Stamina)',
                        style: TextStyle(
                          color: Color.fromARGB(255, 33, 207, 178),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$estamina / 100',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: estamina / 100,
                      minHeight: 8,
                      backgroundColor: Colors.white,
                      valueColor: const AlwaysStoppedAnimation(
                        Color.fromARGB(255, 33, 207, 178),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // BOTOES RAPIDOS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // META
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 8,
                      ),
                      margin: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: const Color.fromARGB(255, 26, 29, 30),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.track_changes,
                            color: Color.fromARGB(255, 30, 64, 214),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'NOVA META',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // NOTA
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 8,
                      ),
                      margin: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: const Color.fromARGB(255, 26, 29, 30),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            color: Color.fromARGB(255, 30, 64, 214),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'NOVA NOTA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // QUIZ
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final resultado = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TelaQuiz()),
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 8,
                      ),
                      margin: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: const Color.fromARGB(255, 26, 29, 30),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.play_circle_outline_outlined,
                            color: Color.fromARGB(255, 30, 64, 214),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'QUIZ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // CARDS DE ESTATISTICA
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(30.0),
                      margin: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: const Color.fromARGB(255, 26, 29, 30),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.track_changes,
                            color: Color.fromARGB(255, 30, 64, 214),
                            size: 32,
                          ),
                          SizedBox(height: 6),
                          Text(
                            '3',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Metas Ativas',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(30.0),
                      margin: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: const Color.fromARGB(255, 26, 29, 30),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.auto_awesome,
                              color: Colors.green, size: 32),
                          SizedBox(height: 6),
                          Text(
                            '1',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Metas Concluídas',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // TITULO
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.electric_bolt,
                    color: Color.fromARGB(255, 30, 64, 214),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Atividade Recente',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // CARD ATIVIDADE
            Container(
              padding: const EdgeInsets.all(30.0),
              margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: const Color.fromARGB(255, 26, 29, 30),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meta concluída: Fazer lista de cálculo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '14 de abr, 22:50',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      '+130 XP',
                      style: TextStyle(
                        color: Color.fromARGB(255, 44, 99, 208),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Olá, ${user?.displayName ?? 'Usuário'}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 2),

          GestureDetector( // titulo clicavl que agora abre a tela de titulos
            onTap: widget.aoClicarNoTitulo, // quando clicar no titulo, ativa a funcao que veio como parametro do overlay p abrir a tela de titulos
            child: Text(
              widget.titulo, // usa o titulo que veio do overlay
              style:TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 13, 15, 17),
      elevation: 0.0,
    );
  }
}
