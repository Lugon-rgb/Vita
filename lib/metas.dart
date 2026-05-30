import 'package:flutter/material.dart';

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
  String title;
  String category;
  String deadline;
  String description;
  String period;
  double progress;

  Goal({
    required this.title,
    required this.category,
    required this.deadline,
    required this.description,
    required this.period,
    this.progress = 0,
  });
}

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final List<Goal> goals = [];

  int selectedBottomIndex = 1;

  final titleController = TextEditingController();
  final deadlineController = TextEditingController();
  final descriptionController = TextEditingController();

  String selectedCategory = "Financeiro";

  // FILTRO DOS BOTÕES SUPERIORES
  String selectedPeriod = "Todas";

  final List<String> categories = [
    "Financeiro",
    "Saúde",
    "Carreira",
    "Pessoal",
  ];

  final List<String> periods = [
    "Curto Prazo",
    "Longo Prazo",
  ];

  String selectedFilter = "Todos";

  // FILTRO DAS METAS
  List<Goal> get filteredGoals {
    List<Goal> filtered = goals;

    // FILTRO POR CATEGORIA
    if (selectedFilter != "Todos") {
      filtered = filtered
          .where(
            (goal) =>
                goal.category == selectedFilter,
          )
          .toList();
    }

    // FILTRO POR PRAZO
    if (selectedPeriod != "Todas") {
      filtered = filtered
          .where(
            (goal) =>
                goal.period == selectedPeriod,
          )
          .toList();
    }

    return filtered;
  }

  void addGoal() {
    if (titleController.text.trim().isEmpty) return;

    setState(() {
      goals.add(
        Goal(
          title: titleController.text,
          category: selectedCategory,
          deadline: deadlineController.text,
          description: descriptionController.text,

          // GUARDA O PRAZO DA META
          period: selectedPeriod == "Todas"
              ? "Curto Prazo"
              : selectedPeriod,
        ),
      );
    });

    titleController.clear();
    deadlineController.clear();
    descriptionController.clear();

    Navigator.pop(context);
  }

  void showAddGoalPage() {
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
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },

                        icon:
                            const Icon(Icons.arrow_back),
                      ),

                      const SizedBox(width: 5),

                      const Text(
                        "Nova Meta",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Título",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: titleController,
                    decoration: customInput(
                      "Ex: Juntar R\$ 5000",
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            const Text(
                              "Categoria",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            DropdownButtonFormField<
                                String>(
                              value: selectedCategory,

                              dropdownColor:
                                  const Color(
                                      0xFF1A1D26),

                              decoration:
                                  customInput(
                                      "Selecione"),

                              items:
                                  categories.map((
                                category,
                              ) {
                                return DropdownMenuItem(
                                  value: category,
                                  child:
                                      Text(category),
                                );
                              }).toList(),

                              onChanged: (value) {
                                setState(() {
                                  selectedCategory =
                                      value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            const Text(
                              "Prazo",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            DropdownButtonFormField<
                                String>(
                              value:
                                  selectedPeriod ==
                                          "Todas"
                                      ? "Curto Prazo"
                                      : selectedPeriod,

                              dropdownColor:
                                  const Color(
                                      0xFF1A1D26),

                              decoration:
                                  customInput(
                                      "Selecione"),

                              items: periods.map((
                                period,
                              ) {
                                return DropdownMenuItem(
                                  value: period,
                                  child:
                                      Text(period),
                                );
                              }).toList(),

                              onChanged: (value) {
                                setState(() {
                                  selectedPeriod =
                                      value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Data Limite (Opcional)",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: deadlineController,
                    decoration:
                        customInput("dd/mm/aaaa"),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Descrição (Opcional)",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: descriptionController,
                    maxLines: 4,

                    decoration: customInput(
                      "Detalhes da meta...",
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton.icon(
                      onPressed: addGoal,

                      icon: const Icon(Icons.save),

                      label: const Text(
                        "Salvar Meta",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF2563EB),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  15),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          bottomNavigationBar: buildBottomBar(),
        ),
      ),
    );
  }

  InputDecoration customInput(String hint) {
    return InputDecoration(
      hintText: hint,

      filled: true,

      fillColor: const Color(0xFF111827),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),

        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.1),
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),

        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.1),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),

        borderSide: const BorderSide(
          color: Color(0xFF2563EB),
        ),
      ),
    );
  }

  Widget buildFilterChip(String text) {
    final bool isSelected = selectedFilter == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = text;
        });
      },

      child: Container(
        margin: const EdgeInsets.only(right: 10),

        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),

        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2563EB)
              : const Color(0xFF1F2430),

          borderRadius: BorderRadius.circular(30),
        ),

        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected
                ? Colors.white
                : Colors.white70,
          ),
        ),
      ),
    );
  }

  // BOTÕES SUPERIORES
  Widget buildTab(String text) {
    bool isSelected = selectedPeriod == text;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPeriod = text;
          });
        },

        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),

          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0F1117)
                : Colors.transparent,

            borderRadius:
                BorderRadius.circular(15),
          ),

          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : Colors.white54,
              ),
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBar buildBottomBar() {
    return BottomNavigationBar(
      currentIndex: selectedBottomIndex,

      backgroundColor: const Color(0xFF111827),

      selectedItemColor:
          const Color(0xFF2563EB),

      unselectedItemColor: Colors.white54,

      type: BottomNavigationBarType.fixed,

      onTap: (index) {
        setState(() {
          selectedBottomIndex = index;
        });
      },

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: "Início",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.gps_fixed),
          label: "Metas",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.note_alt_outlined),
          label: "Notas",
        ),

        BottomNavigationBarItem(
          icon: Icon(
            Icons.account_balance_wallet_outlined,
          ),
          label: "Finanças",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: "Perfil",
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [
                  const Text(
                    "Metas",
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  ElevatedButton.icon(
                    onPressed: showAddGoalPage,

                    icon: const Icon(Icons.add),

                    label:
                        const Text("Nova Meta"),

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(
                              0xFF2563EB),

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                15),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // BOTÕES DE PRAZO
              Container(
                padding: const EdgeInsets.all(5),

                decoration: BoxDecoration(
                  color: const Color(0xFF1A1D26),

                  borderRadius:
                      BorderRadius.circular(20),
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

              // CATEGORIAS
              SingleChildScrollView(
                scrollDirection:
                    Axis.horizontal,

                child: Row(
                  children: [
                    buildFilterChip("Todos"),
                    buildFilterChip(
                        "Financeiro"),
                    buildFilterChip("Saúde"),
                    buildFilterChip(
                        "Carreira"),
                    buildFilterChip(
                        "Pessoal"),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Expanded(
                child: filteredGoals.isEmpty
                    ? Container(
                        width: double.infinity,

                        padding:
                            const EdgeInsets.all(
                                30),

                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius
                                  .circular(25),

                          border: Border.all(
                            color: Colors.white
                                .withOpacity(0.1),
                          ),
                        ),

                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,

                          children: [
                            const Icon(
                              Icons.gps_fixed,
                              size: 55,
                              color:
                                  Colors.white38,
                            ),

                            const SizedBox(
                                height: 15),

                            const Text(
                              "Nenhuma meta encontrada.",
                              style: TextStyle(
                                fontSize: 22,
                                color:
                                    Colors.white60,
                              ),
                            ),

                            const SizedBox(
                                height: 10),

                            GestureDetector(
                              onTap:
                                  showAddGoalPage,

                              child: const Text(
                                "Criar uma agora",
                                style: TextStyle(
                                  color: Color(
                                      0xFF2563EB),
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount:
                            filteredGoals.length,

                        itemBuilder:
                            (context, index) {
                          final goal =
                              filteredGoals[
                                  index];

                          return Container(
                            margin:
                                const EdgeInsets
                                    .only(
                              bottom: 18,
                            ),

                            padding:
                                const EdgeInsets
                                    .all(20),

                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                      0xFF1A1D26),

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          25),
                            ),

                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [
                                Text(
                                  goal.title,

                                  style:
                                      const TextStyle(
                                    fontSize: 22,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                const SizedBox(
                                    height: 8),

                                Text(
                                  "${goal.category} • ${goal.period}",

                                  style:
                                      const TextStyle(
                                    color: Colors
                                        .white60,
                                  ),
                                ),

                                const SizedBox(
                                    height: 15),

                                ClipRRect(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              10),

                                  child:
                                      LinearProgressIndicator(
                                    value:
                                        goal.progress,
                                    minHeight: 10,
                                  ),
                                ),

                                const SizedBox(
                                    height: 15),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .end,

                                  children: [
                                    IconButton(
                                      onPressed:
                                          () {
                                        setState(() {
                                          goal.progress =
                                              goal.progress ==
                                                      1
                                                  ? 0
                                                  : 1;
                                        });
                                      },

                                      icon: Icon(
                                        goal.progress ==
                                                1
                                            ? Icons
                                                .check_circle
                                            : Icons
                                                .check_circle_outline,

                                        color: Colors
                                            .green,
                                      ),
                                    ),

                                    IconButton(
                                      onPressed:
                                          () {
                                        setState(() {
                                          goals.remove(
                                              goal);
                                        });
                                      },

                                      icon:
                                          const Icon(
                                        Icons
                                            .delete,
                                        color:
                                            Colors
                                                .red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: buildBottomBar(),
    );
  }
}