import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/conquista_snackbar.dart'; 
import '../data/conquista_desbloqueio.dart';
import '../data/titulo_desbloqueio.dart';
import '../data/titulo_snackbar.dart';
import '../data/espera_snackbar.dart';

class Financias extends StatefulWidget {
  const Financias({super.key});

  @override
  State<Financias> createState() => _FinanciasState();
}

class _FinanciasState extends State<Financias> {
  final db = FirebaseFirestore.instance;
  late final String _uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonimo';
  int limite = 0;
  int gastou = 0;
  List<Map<String, dynamic>> gastos = [];

  TextEditingController limiteController = TextEditingController();
  TextEditingController nomeController = TextEditingController();
  TextEditingController gastoController = TextEditingController();

  double get progresso {
    if (limite == 0) return 0;
    return gastou / limite;
  }

  Map<String, double> gastosSemana() {
    Map<String, double> dias = {
      "Seg": 0,
      "Ter": 0,
      "Qua": 0,
      "Qui": 0,
      "Sex": 0,
      "Sab": 0,
      "Dom": 0,
    };

    DateTime agora = DateTime.now();
    DateTime inicioSemana = agora.subtract(Duration(days: agora.weekday - 1));

    for (var gasto in gastos) {
      DateTime data = (gasto['data'] as Timestamp).toDate();
      if (data.isBefore(inicioSemana)) continue;

      int valor = gasto['valor'] as int;

      switch (data.weekday) {
        case 1:
          dias["Seg"] = dias["Seg"]! + valor;
          break;
        case 2:
          dias["Ter"] = dias["Ter"]! + valor;
          break;
        case 3:
          dias["Qua"] = dias["Qua"]! + valor;
          break;
        case 4:
          dias["Qui"] = dias["Qui"]! + valor;
          break;
        case 5:
          dias["Sex"] = dias["Sex"]! + valor;
          break;
        case 6:
          dias["Sab"] = dias["Sab"]! + valor;
          break;
        case 7:
          dias["Dom"] = dias["Dom"]! + valor;
          break;
      }
    }
    return dias;
  }

  List<BarChartGroupData> _buildBarGroups(Map<String, double> dados) {
    const List<String> diasOrdem = [
      "Seg",
      "Ter",
      "Qua",
      "Qui",
      "Sex",
      "Sab",
      "Dom",
    ];
    List<BarChartGroupData> groups = [];

    for (int i = 0; i < diasOrdem.length; i++) {
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: dados[diasOrdem[i]]!,
              color: Colors.blueAccent,
              width: 22,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }
    return groups;
  }

  // ignore: unused_element
  Future<void> _ganharXpFinancas() async {
    final docRef = db.collection("users").doc(_uid);
    final dados = await docRef.get();
    // ignore: unnecessary_cast
    final data = dados.data() as Map<String, dynamic>? ?? {};

    // Verifica se já ganhou XP hoje
    final DateTime? ultimoXp = (data['ultimoXpFinancas'] as Timestamp?)
        ?.toDate();
    final DateTime agora = DateTime.now();

    if (ultimoXp != null &&
        ultimoXp.day == agora.day &&
        ultimoXp.month == agora.month &&
        ultimoXp.year == agora.year) {
      return; // já ganhou XP hoje, não faz nada
    }

    // Calcula XP baseado no progresso de gastos
    int xpGanho;
    if (progresso < 0.5) {
      xpGanho = 50;
    } else if (progresso < 1.0) {
      xpGanho = 25;
    } else {
      xpGanho = 0;
    }

    if (xpGanho == 0) return;

    int xpAtual = data['xp'] ?? 0;
    int nivelAtual = data['nivel'] ?? 1;

    xpAtual += xpGanho;
    if (xpAtual >= 500) {
      xpAtual -= 500;
      nivelAtual += 1;
    }

    await docRef.set({
      'xp': xpAtual,
      'nivel': nivelAtual,
      'ultimoXpFinancas': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Future<void> salvarFinancas() async {
    await db.collection("users").doc(_uid).set({
      "limite": limite,
      "gastou": gastou,
      "gastos": gastos,
    }, SetOptions(merge: true));
  }

  Future<void> carregarFinancas() async {
    DocumentSnapshot dados = await db.collection("users").doc(_uid).get();
    if (mounted && dados.exists) {
      Map<String, dynamic> data = dados.data() as Map<String, dynamic>;

      setState(() {
        limite = data.containsKey('limite') ? data['limite'] : 0;
        gastou = data.containsKey('gastou') ? data['gastou'] : 0;
        gastos = data.containsKey('gastos')
            ? List<Map<String, dynamic>>.from(data['gastos'])
            : [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    carregarFinancas();
  }

  @override
  void dispose() {
    limiteController.dispose();
    nomeController.dispose();
    gastoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dadosSemana = gastosSemana();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 13, 15, 17),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 13, 15, 17),
        title: const Text("Finanças", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================== CARD RESUMO ====================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 26, 29, 30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Limite: R\$ $limite",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Total gasto: R\$ $gastou",
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progresso > 1 ? 1 : progresso,
                        minHeight: 12,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(Colors.green),
                      ),
                    ),

                    const SizedBox(height: 10),
                    if (progresso >= 1)
                      const Text(
                        "Você atingiu o limite!",
                        style: TextStyle(color: Colors.red),
                      ),
                    if (progresso >= 0.5 && progresso < 1)
                      const Text(
                        "Você já gastou mais de 50%!",
                        style: TextStyle(color: Colors.orange),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ==================== DEFINIR LIMITE ====================
              TextField(
                controller: limiteController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Definir limite",
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white24),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 30, 64, 214),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed:() async {
                  int novoLimite = int.tryParse(limiteController.text) ?? 0;

                  if (novoLimite > 0) {
                    // guarda se o limite anterior era zero antes de atualizar a tela
                    bool primeiroLimite = (limite == 0); 

                    setState(() {
                      limite = novoLimite;
                    });

                    // salva no firebase
                    await salvarFinancas();

                    limiteController.clear();

                    // se era o primeiro limite, dispara a conquista passando o ID pro snackBar
                    if (primeiroLimite) {
                      String? conquistaDesbloqueada = await ConquistaDesbloqueio.checarPilarFinancas();
                      
                      if (conquistaDesbloqueada != null && mounted) {
                        mostrarSnackBarConquista(context, conquistaDesbloqueada);
                        await esperarSnackbar();
                      }

                      final titulosDesbloqueados = TituloDesbloqueio.consumirTitulosPendentes();
                      if (titulosDesbloqueados.isNotEmpty && mounted) {
                        for (String idTitulo in titulosDesbloqueados) {
                          mostrarSnackBarTitulo(context, idTitulo);
                          await esperarSnackbar();
                        }
                      }
                    }
                  }
                },
                child: const Text("Salvar limite"),
              ),

              const SizedBox(height: 30),

              // ==================== ADICIONAR GASTO ====================
              TextField(
                controller: nomeController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Nome do gasto (ex: Mercado, Uber)",
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white24),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: gastoController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Valor (R\$)",
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white24),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 30, 64, 214),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed:() async { 
                  int valor = int.tryParse(gastoController.text) ?? 0;
                  String nome = nomeController.text.trim().isNotEmpty
                      ? nomeController.text.trim()
                      : "Gasto";

                  if (valor > 0) {
                    // guarda se a lista local estava vazia antes de adicionar o item
                    bool primeiroRegistro = gastos.isEmpty;

                    setState(() {
                      gastos.add({
                        "valor": valor,
                        "nome": nome,
                        "data": Timestamp.now(),
                      });
                      gastou += valor;
                    });
                    
                    // aguarda salvar as finanças no banco
                    await salvarFinancas();

                    gastoController.clear();
                    nomeController.clear();

                    // conquista registro de ouro
                    // se a lista estava zerada antes, roda a logica da conquista
                    if (primeiroRegistro) {
                      String? conquistaDesbloqueada = await ConquistaDesbloqueio.checarRegistroDeOuro();
                      
                      if (conquistaDesbloqueada != null && mounted) {
                        mostrarSnackBarConquista(context, conquistaDesbloqueada);
                        await esperarSnackbar();
                      }
                    }

                    String? conquistaDias = await ConquistaDesbloqueio.checarDisciplinaFinanceira(gastos);
                    
                    if (conquistaDias != null && mounted) {
                      mostrarSnackBarConquista(context, conquistaDias);
                      await esperarSnackbar();
                    }

                    await TituloDesbloqueio.checarMestreDoReal(valor);

                    final titulosDesbloqueados = TituloDesbloqueio.consumirTitulosPendentes();
                    if (titulosDesbloqueados.isNotEmpty && mounted) {
                      for (String idTitulo in titulosDesbloqueados) {
                        mostrarSnackBarTitulo(context, idTitulo);
                        await esperarSnackbar();
                      }
                    }
                  }
                },
                child: const Text("Adicionar gasto"),
              ),

              const SizedBox(height: 30),

              // Gráfico Semanal
              const Text(
                "Gastos da Semana",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                height: 240,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 26, 29, 30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: BarChart(
                  BarChartData(
                    maxY: dadosSemana.values.isNotEmpty
                        ? dadosSemana.values.reduce((a, b) => a > b ? a : b) *
                              1.3
                        : 100,
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const dias = [
                              "Seg",
                              "Ter",
                              "Qua",
                              "Qui",
                              "Sex",
                              "Sab",
                              "Dom",
                            ];
                            return Text(
                              dias[value.toInt()],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 35,
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: _buildBarGroups(dadosSemana),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Lista de gastos
              const Text(
                "Lista de gastos",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: gastos.length,
                itemBuilder: (context, index) {
                  final gasto = gastos[index];
                  DateTime data = (gasto['data'] as Timestamp).toDate();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 26, 29, 30),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.attach_money,
                        color: Colors.green,
                      ),
                      title: Text(
                        "R\$ ${gasto['valor']}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "${gasto['nome']} • ${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            gastou -= gasto['valor'] as int;
                            gastos.removeAt(index);
                          });
                          salvarFinancas();
                        },
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
