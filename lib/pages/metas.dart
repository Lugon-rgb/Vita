import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ========================
// MODELO DA META
// ========================
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const GoalsPage(),
    );
  }
}


class Goal {
  String? id; // ID do documento no Firestore
  String title;
  String category;
  String deadline;
  String description;
  String period;
  double progress;

  Goal({
    this.id,
    required this.title,
    required this.category,
    required this.deadline,
    required this.description,
    required this.period,
    this.progress = 0,
  });

  // Converte para Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'deadline': deadline,
      'description': description,
      'period': period,
      'progress': progress,
    };
  }

  // Cria um Goal a partir de um documento do Firestore
  factory Goal.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Goal(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      deadline: data['deadline'] ?? '',
      description: data['description'] ?? '',
      period: data['period'] ?? '',
      progress: (data['progress'] ?? 0).toDouble(),
    );
  }
}

// ========================
// PÁGINA DE METAS
// ========================
class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  // Referência para a coleção do usuário logado no Firestore
  // Estrutura: users/{uid}/goals/{goalId}
  CollectionReference get _goalsRef {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('goals');
  }

  final titleController = TextEditingController();
  final deadlineController = TextEditingController();
  final descriptionController = TextEditingController();

  String selectedCategory = "Financeiro";
  String selectedPeriod = "Todas";
  String selectedGoalPeriod = "Curto Prazo";
  String selectedFilter = "Todos";

  final List<String> categories = ["Financeiro", "Saúde", "Carreira", "Pessoal"];
  final List<String> periods = ["Curto Prazo", "Longo Prazo"];

  // ========================
  // FIRESTORE: SALVAR / EDITAR
  // ========================
 Future<void> saveGoal({Goal? goal}) async {
  if (titleController.text.trim().isEmpty) return;

  final data = {
    'title': titleController.text.trim(),
    'category': selectedCategory,
    'deadline': deadlineController.text.trim(),
    'description': descriptionController.text.trim(),
    'period': selectedGoalPeriod,
    'progress': goal?.progress ?? 0.0,
  };

  try {
    if (goal == null) {
      await _goalsRef.add(data);
    } else {
      await _goalsRef.doc(goal.id).update(data);
    }

    _resetForm();
    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao salvar: $e')),
    );
  }
}
  // ========================
  // FIRESTORE: DELETAR
  // ========================
  Future<void> deleteGoal(Goal goal) async {
    try {
      await _goalsRef.doc(goal.id).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao deletar: $e')),
      );
    }
  }

  // ========================
  // FIRESTORE: ATUALIZAR PROGRESSO
  // ========================
  Future<void> toggleProgress(Goal goal) async {
    final newProgress = goal.progress == 1 ? 0.0 : 1.0;
    try {
      await _goalsRef.doc(goal.id).update({'progress': newProgress});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar progresso: $e')),
      );
    }
  }

  void editGoal(Goal goal) {
    titleController.text = goal.title;
    deadlineController.text = goal.deadline;
    descriptionController.text = goal.description;
    setState(() {
      selectedCategory = goal.category;
      selectedGoalPeriod = goal.period;
    });
    showAddGoalPage(editingGoal: goal);
  }

  void _resetForm() {
    setState(() {
      titleController.clear();
      deadlineController.clear();
      descriptionController.clear();
      selectedCategory = "Financeiro";
      selectedGoalPeriod = "Curto Prazo";
    });
  }

  // ========================
  // FILTRO LOCAL (sobre os dados do stream)
  // ========================
  List<Goal> _applyFilters(List<Goal> goals) {
    List<Goal> filtered = goals;

    if (selectedFilter != "Todos") {
      filtered = filtered.where((g) => g.category == selectedFilter).toList();
    }

    if (selectedPeriod != "Todas") {
      filtered = filtered.where((g) => g.period == selectedPeriod).toList();
    }

    return filtered;
  }

  // ========================
  // TELA DE ADICIONAR / EDITAR META
  // ========================
  void showAddGoalPage({Goal? editingGoal}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: const Color(0xFF0F1117),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          _resetForm();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        editingGoal == null ? "Nova Meta" : "Editar Meta",
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text("Título",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: titleController,
                    decoration: customInput("Ex: Juntar R\$ 5000"),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Categoria",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: selectedCategory,
                              dropdownColor: const Color(0xFF1A1D26),
                              decoration: customInput("Selecione"),
                              items: categories
                                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => selectedCategory = value!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Prazo",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: selectedGoalPeriod,
                              dropdownColor: const Color(0xFF1A1D26),
                              decoration: customInput("Selecione"),
                              items: periods
                                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => selectedGoalPeriod = value!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  const Text("Data Limite (Opcional)",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: deadlineController,
                    decoration: customInput("dd/mm/aaaa"),
                  ),

                  const SizedBox(height: 25),

                  const Text("Descrição (Opcional)",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    maxLines: 4,
                    decoration: customInput("Detalhes da meta..."),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () => saveGoal(goal: editingGoal),
                      icon: const Icon(Icons.save),
                      label: Text(
                        editingGoal == null ? "Salvar Meta" : "Salvar Alterações",
                        style: const TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ========================
  // WIDGETS AUXILIARES
  // ========================
  InputDecoration customInput(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFF111827),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF2563EB)),
      ),
    );
  }

  Widget buildFilterChip(String text) {
    final bool isSelected = selectedFilter == text;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = text),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF1F2430),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget buildTab(String text) {
    bool isSelected = selectedPeriod == text;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedPeriod = text),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0F1117) : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.white54,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ========================
  // BUILD PRINCIPAL
  // ========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Metas",
                    style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _resetForm();
                      showAddGoalPage();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Nova Meta"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1D26),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    buildTab("Todas"),
                    buildTab("Curto Prazo"),
                    buildTab("Longo Prazo"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    buildFilterChip("Todos"),
                    buildFilterChip("Financeiro"),
                    buildFilterChip("Saúde"),
                    buildFilterChip("Carreira"),
                    buildFilterChip("Pessoal"),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // STREAM — escuta mudanças no Firestore em tempo real
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _goalsRef.snapshots(),
                  builder: (context, snapshot) {
                    // Carregando
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Erro
                    if (snapshot.hasError) {
                      return Center(child: Text('Erro: ${snapshot.error}'));
                    }

                    // Converte documentos em lista de Goal e aplica filtros
                    final allGoals = snapshot.data!.docs
                        .map((doc) => Goal.fromDoc(doc))
                        .toList();

                    final filtered = _applyFilters(allGoals);

                    // Lista vazia
                    if (filtered.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.gps_fixed,
                                size: 55, color: Colors.white38),
                            const SizedBox(height: 15),
                            const Text(
                              "Nenhuma meta encontrada.",
                              style: TextStyle(
                                  fontSize: 22, color: Colors.white60),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                _resetForm();
                                showAddGoalPage();
                              },
                              child: const Text(
                                "Criar uma agora",
                                style: TextStyle(
                                    color: Color(0xFF2563EB), fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Lista de metas
                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final goal = filtered[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 18),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1D26),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                goal.title,
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "${goal.category} • ${goal.period}",
                                style:
                                    const TextStyle(color: Colors.white60),
                              ),
                              const SizedBox(height: 15),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: goal.progress,
                                  minHeight: 10,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: () => editGoal(goal),
                                    icon: const Icon(Icons.edit,
                                        color: Colors.amber),
                                  ),
                                  IconButton(
                                    onPressed: () => toggleProgress(goal),
                                    icon: Icon(
                                      goal.progress == 1
                                          ? Icons.check_circle
                                          : Icons.check_circle_outline,
                                      color: Colors.green,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => deleteGoal(goal),
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}