import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'editar_quiz.dart';
import 'nova_nota.dart';
// ignore: unused_import
import 'package:vita_appprojetos/pages/metas.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vita_appprojetos/pages/TelaQuiz.dart';
import '../data/conquista_desbloqueio.dart';
import '../data/conquista_snackbar.dart';
import '../data/xp_manager.dart';
import '../data/titulo_desbloqueio.dart';
import '../data/titulo_snackbar.dart';
import '../data/espera_snackbar.dart';

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
  late final String _uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonimo';

  int vida = 100;
  int estamina = 100;
  int xp = 0;
  int nivel = 1;
  int streak = 0;
  int melhorStreak = 0;
  int metasConcluidas = 0;
  int metasAtivas = 0;

  StreamSubscription<DocumentSnapshot>? _userSub;
  int? _nivelAnterior; // guarda o ultimo nivel conhecido, pra detectar quando ele sobe

  void verificarStatus() {
    vida = vida.clamp(0, 100);
    estamina = estamina.clamp(0, 100);
  }

  Future<void> salvarDados() async {
    await db.collection("users").doc(user!.uid).set({
      "vida": vida,
      "estamina": estamina,
      "streak": streak,
      "melhorStreak": melhorStreak,
      "ultimoAcesso": Timestamp.now(),
      "metasConcluidas": metasConcluidas,
      "metasAtivas": metasAtivas,
    }, SetOptions(merge: true));
  }

  Future<void> _ganharXp(int quantidade) async {
    // a logica de xp/nivel agora e' toda feita pelo GerenciadorXp, de forma
    // atomica. nao precisamos mais atualizar xp/nivel manualmente aqui: o
    // listener em tempo real (_escutarDadosDoUsuario) vai receber essa
    // mudanca do Firestore sozinho e atualizar a tela / mostrar a snackbar
    // de level up se for o caso
    await GerenciadorXp.adicionarXp(quantidade);
  }

  // escuta o documento do usuario em tempo real. isso substitui o antigo
  // carregarDados() (que so lia uma vez, com .get()) por um listener que
  // atualiza a tela sozinha sempre que algo mudar no Firestore - inclusive
  // quando o xp/nivel mudam por causa de uma conquista desbloqueada em
  // qualquer outra tela do app
  void _escutarDadosDoUsuario() {
    _userSub = db
        .collection("users")
        .doc(user?.uid ?? "usuario")
        .snapshots()
        .listen((dados) {
      if (!mounted || !dados.exists) return;

      // usamos dados.data() (um Map comum) em vez do operador dados['campo'],
      // porque esse operador lanca uma excecao se o campo nao existir no
      // documento - e e exatamente isso que acontecia com contas novas,
      // cujo documento e criado sem os campos 'xp'/'nivel' (eles so aparecem
      // na primeira vez que o usuario ganha xp). Map.data() e seguro:
      // retorna null pra campos ausentes, em vez de travar o app
      final campos = dados.data() as Map<String, dynamic>? ?? {};

      final novoNivel = campos['nivel'] ?? 1;

      if (_nivelAnterior != null && novoNivel > _nivelAnterior!) {
        _mostrarSnackBarLevelUp(novoNivel);
      }

      setState(() {
        vida = campos['vida'] ?? 100;
        estamina = campos['estamina'] ?? 100;
        xp = campos['xp'] ?? 0;
        nivel = novoNivel;
        streak = campos['streak'] ?? 0;
        melhorStreak = campos['melhorStreak'] ?? 0;
        metasConcluidas = campos['metasConcluidas'] ?? 0;
        metasAtivas = campos['metasAtivas'] ?? 0;
      });

      _nivelAnterior = novoNivel;
    }, onError: (erro) {
      // rede de seguranca: se algo der errado no listener, so registra no
      // console em vez de deixar uma excecao nao tratada se propagar
      debugPrint('Erro ao escutar dados do usuário: $erro');
    });
  }

  void _mostrarSnackBarLevelUp(int novoNivel) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E1E1E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.amber, width: 1.5),
        ),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            const Text("⭐", style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Você subiu para o Nível $novoNivel!",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> verificarStreak() async {
    try {
      final docRef = db.collection("users").doc(user?.uid ?? "usuario");
      DocumentSnapshot dados = await docRef.get();

      DateTime hoje = DateTime.now();

      if (!dados.exists) {
        streak = 0;
        melhorStreak = 0;
        await salvarDados(); // Cria o documento aqui
        setState(() {});
        return;
      }

      final data = dados.data() as Map<String, dynamic>? ?? {};

      DateTime? ultimoAcesso = (data['ultimoAcesso'] as Timestamp?)?.toDate();

      if (ultimoAcesso == null) {
        streak = 0;
        melhorStreak = 0;
      } else {
        int diferencaDias = hoje.difference(ultimoAcesso).inDays;

        if (diferencaDias == 1) {
          streak = (data['streak'] ?? 0) + 1;
          if (streak > (data['melhorStreak'] ?? 0)) {
            melhorStreak = streak;
          } else {
            melhorStreak = data['melhorStreak'] ?? 0;
          }

          // checagem do titulo minimalista absoluto, so roda quando o streak
          // realmente avanca 1 dia (uma vez por dia real)
          await TituloDesbloqueio.checarMinimalistaAbsoluto(
            metasAtivas: data['metasAtivas'] ?? 0,
            gastos: data['gastos'] ?? [],
          );
        } else if (diferencaDias > 1) {
          streak = 0;
          melhorStreak = data['melhorStreak'] ?? 0;
          await TituloDesbloqueio.resetarMinimalista(); // quebrou o streak, zera o contador
        } else {
          streak = data['streak'] ?? 0;
          melhorStreak = data['melhorStreak'] ?? 0;
        }
      }

      await docRef.set({
        "streak": streak,
        "melhorStreak": melhorStreak,
        "ultimoAcesso": Timestamp.now(),
      }, SetOptions(merge: true));

      // chamada da funcao que retorna uma lista de conquistas desbloqueadas com base no streak atual
      List<String> novasConquistas =
          await ConquistaDesbloqueio.checarConquistasDeStreak(streak);
      // se houver conquistas novas, mostra o snackBar para cada uma
      if (novasConquistas.isNotEmpty && mounted) {
        for (String nomeConquista in novasConquistas) {
          mostrarSnackBarConquista(context, nomeConquista);
          await esperarSnackbar();
        }
      }

      final titulosDesbloqueados = TituloDesbloqueio.consumirTitulosPendentes();
      if (titulosDesbloqueados.isNotEmpty && mounted) {
        for (String idTitulo in titulosDesbloqueados) {
          mostrarSnackBarTitulo(context, idTitulo);
          await esperarSnackbar();
        }
      }

      setState(() {});
    } catch (e) {
      debugPrint("Erro ao verificar streak: $e");
    }
  }

  Future<void> _limitarAtividades() async {
    final snapshot = await db
        .collection("users")
        .doc(_uid)
        .collection("atividades")
        .orderBy("data", descending: true)
        .get();

    // Se tiver mais de 5, deleta os mais antigos
    if (snapshot.docs.length > 5) {
      final parasApagar = snapshot.docs.sublist(
        5,
      ); // pega do índice 5 em diante
      for (final doc in parasApagar) {
        await doc.reference.delete();
      }
    }
  }

  Future<void> adicionarAtividade({
    required String titulo,
    required String descricao,
    int xp = 0,
  }) async {
    try {
      await db.collection("users").doc(_uid).collection("atividades").add({
        "titulo": titulo,
        "descricao": descricao,
        "xp": xp,
        "data": Timestamp.now(),
      });
      await _limitarAtividades();

      debugPrint("Atividade registrada: $titulo");
    } catch (e) {
      debugPrint("Erro ao adicionar atividade: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _escutarDadosDoUsuario();
    verificarStreak();
  }

  @override
  void dispose() {
    _userSub?.cancel(); // cancela o listener pra nao vazar memoria quando sair da tela
    super.dispose();
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Nível $nivel",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          Text(
                            "$xp / ${GerenciadorXp.limiarDoNivel(nivel)} XP",
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
                        child: Row(
                          children: [
                            Icon(Icons.bolt, color: Colors.orange, size: 16),
                            Text(
                              "$streak",
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
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(
                        Colors.redAccent,
                      ),
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
                      backgroundColor: Colors.white24,
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GoalFormPage()),
                      );
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
                        borderRadius: BorderRadius.circular(15),
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NovaNotaPage()),
                      );
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
                        borderRadius: BorderRadius.circular(15),
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

                // QUIZ + EDITAR
                Expanded(
                  flex: 2, // ocupa mais espaço por ser dois botões
                  child: Row(
                    children: [
                      // BOTÃO QUIZ
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final resultado = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TelaQuiz(),
                              ),
                            );
                            if (resultado != null) {
                              setState(() {
                                vida += resultado['vida'] as int;
                                estamina += resultado['estamina'] as int;
                                verificarStatus();
                              });
                              await salvarDados();
                              await _ganharXp(25);
                              await adicionarAtividade(
                                titulo: "Quiz Concluído",
                                descricao: "Você completou um quiz",
                                xp: 25,
                              );

                              // NOVO: ganhar xp pode ter subido de nivel e liberado um titulo
                              final titulosDesbloqueados =
                                  TituloDesbloqueio.consumirTitulosPendentes();
                              if (titulosDesbloqueados.isNotEmpty && mounted) {
                                for (String idTitulo in titulosDesbloqueados) {
                                  mostrarSnackBarTitulo(context, idTitulo);
                                }
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 30,
                              horizontal: 8,
                            ),
                            margin: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 5,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
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
                      // BOTÃO EDITAR QUIZ
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TelaEditarQuiz(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 30,
                              horizontal: 8,
                            ),
                            margin: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 5,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: const Color.fromARGB(255, 26, 29, 30),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.edit_note,
                                  color: Color.fromARGB(255, 30, 64, 214),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'EDITAR',
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
                      child: Column(
                        children: [
                          Icon(
                            Icons.track_changes,
                            color: Color.fromARGB(255, 30, 64, 214),
                            size: 32,
                          ),
                          SizedBox(height: 6),
                          Text(
                            '$metasAtivas',
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
                      child: Column(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: Colors.green,
                            size: 32,
                          ),
                          SizedBox(height: 6),
                          Text(
                            '$metasConcluidas',
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

            // Atividades recentes
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

            // Lista Dinâmica
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: StreamBuilder<QuerySnapshot>(
                stream: db
                    .collection("users")
                    .doc(_uid)
                    .collection("atividades")
                    .orderBy("data", descending: true)
                    .limit(5)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "Nenhuma atividade ainda",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  final atividades = snapshot.data!.docs;

                  return Column(
                    children: atividades.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final DateTime dataAtv = (data['data'] as Timestamp)
                          .toDate();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 26, 29, 30),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['titulo'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    data['descricao'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${dataAtv.day}/${dataAtv.month}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                if (data['xp'] != null && data['xp'] > 0)
                                  Text(
                                    "+${data['xp']} XP",
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar appBar() {
  return AppBar(
    toolbarHeight: 70, // aumenta a altura só aqui, pra caber as 2 linhas sem "subir"
    centerTitle: true,
    title: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
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

        GestureDetector(
          onTap: widget.aoClicarNoTitulo,
          child: Text(
            widget.titulo,
            style: const TextStyle(
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